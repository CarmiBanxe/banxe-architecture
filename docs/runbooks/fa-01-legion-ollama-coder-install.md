# FA-1 — Legion: ollama + qwen2.5-coder:7b install runbook

| Field | Value |
|---|---|
| FA-ID | FA-1 |
| Sprint | IL-FACTORY-AUDIT-01 |
| Gap | G-FACTORY-01 — Legion has no local model serving |
| Branch | docs/fa-01-legion-ollama-coder-runbook |
| Status | DRAFT — awaiting operator go |
| Date | 2026-05-06 |
| Model | qwen2.5-coder:7b-instruct-q4_K_M (~4.4 GB, fits RTX 4070 8 GB VRAM) |
| Target host | Legion (mark-legion, WSL2 Ubuntu 24.04) |

## Goal

Install ollama on Legion and pull `qwen2.5-coder:7b-instruct-q4_K_M` as the `factory-coder`
model. Wire it as the `factory-fast` and `coder` LiteLLM routes on `:4000`. Closes G-FACTORY-01.

## Hardware context

| Resource | Value |
|---|---|
| GPU | NVIDIA RTX 4070 Laptop, 8 GB VRAM, CUDA via WSL2 |
| RAM | 23 GiB (WSL2 cap) |
| Storage | /dev/sdd 1 TB ext4 (primary WSL2 disk) |
| Existing AI CLIs | llama.cpp (local build), aider, claude, openclaw, litellm |

Model selection rationale: qwen2.5-coder:7b-instruct-q4_K_M is ~4.4 GB — fits RTX 4070
8 GB VRAM fully in-VRAM (no CPU offload). The Q4_K_M quant delivers strong code-generation
quality with fast token throughput on laptop CUDA. Larger variants (14b, 32b) would require
CPU offload and violate Principle 1 (hardware must not choke).

## Phase A — Pre-check

```bash
# Verify GPU is available inside WSL2
nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader

# Verify CUDA runtime
nvcc --version || echo "nvcc not in PATH — ollama uses its own bundled CUDA libs, OK"

# Check free VRAM (target: >= 5 GB free before pull)
nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits

# Verify no existing ollama process
pgrep -a ollama && echo "EXISTING OLLAMA — stop before install" || echo "No existing ollama"

# Check disk space on /dev/sdd (need >= 6 GB free for model + ollama binary)
df -h /home/mmber | tail -1
```

Expected: GPU detected, >= 5 GB VRAM free, no existing ollama, >= 6 GB disk free.

## Install steps

### Phase B — Install ollama

```bash
# Official install script (pulls latest stable binary for Linux/CUDA)
curl -fsSL https://ollama.com/install.sh | sh

# Verify install
ollama --version

# Start ollama service (background, binds to 127.0.0.1:11434 by default)
ollama serve &
sleep 3
curl -s http://127.0.0.1:11434/ | grep -i ollama || echo "WARN: ollama serve not responding"
```

> If WSL2 systemd is active: `sudo systemctl enable --now ollama` instead of manual `ollama serve`.

### Phase C — Pull qwen2.5-coder:7b

```bash
# Pull the Q4_K_M quantisation (~4.4 GB download)
ollama pull qwen2.5-coder:7b-instruct-q4_K_M

# Verify model present
ollama list | grep qwen2.5-coder
```

Expected output: `qwen2.5-coder:7b-instruct-q4_K_M   <hash>   4.4 GB   <date>`

### Phase D — Smoke test (RTX 4070 VRAM check)

```bash
# Single-turn inference smoke test
ollama run qwen2.5-coder:7b-instruct-q4_K_M   "Write a Python function that returns True if a number is prime."   --verbose 2>&1 | tail -20

# VRAM usage during inference (run in parallel terminal)
nvidia-smi --query-gpu=memory.used,memory.free --format=csv,noheader,nounits
```

Expected: response generated, memory.used <= 6000 MiB (model fits fully in RTX 4070 VRAM).

### Phase E — Wire LiteLLM factory-fast + coder routes

LiteLLM config lives at `/home/mmber/.litellm/config.yaml` (or wherever `:4000` is configured).

Add the following model entries:

```yaml
model_list:
  # --- existing entries (do not touch) ---

  # --- FA-1 additions ---
  - model_name: factory-fast
    litellm_params:
      model: ollama/qwen2.5-coder:7b-instruct-q4_K_M
      api_base: http://127.0.0.1:11434

  - model_name: coder
    litellm_params:
      model: ollama/qwen2.5-coder:7b-instruct-q4_K_M
      api_base: http://127.0.0.1:11434
```

After edit, reload LiteLLM:

```bash
# If running as a process, restart:
pkill -f litellm && litellm --config ~/.litellm/config.yaml --port 4000 &

# Smoke test factory-fast route
curl -s http://localhost:4000/v1/chat/completions   -H "Content-Type: application/json"   -d '{"model":"factory-fast","messages":[{"role":"user","content":"ping"}],"max_tokens":10}'   | jq '.choices[0].message.content'

# Smoke test coder route
curl -s http://localhost:4000/v1/chat/completions   -H "Content-Type: application/json"   -d '{"model":"coder","messages":[{"role":"user","content":"ping"}],"max_tokens":10}'   | jq '.choices[0].message.content'
```

Expected: both routes return HTTP 200 with a non-empty `.choices[0].message.content`.

### Phase F — Editor config (aider / openclaw / cursor)

#### aider

```bash
# Via LiteLLM proxy (preferred — unified endpoint):
aider --model factory-fast       --openai-api-base http://localhost:4000/v1       --openai-api-key anything

# Direct ollama (alternative):
aider --model ollama/qwen2.5-coder:7b-instruct-q4_K_M       --openai-api-base http://127.0.0.1:11434/v1       --openai-api-key ollama
```

#### openclaw / cursor

Point `API Base` to `http://localhost:4000/v1`, model `factory-fast` or `coder`.

## Acceptance criteria (from IL-FACTORY-AUDIT-01)

- [ ] `ollama list` on Legion shows `qwen2.5-coder:7b-instruct-q4_K_M`
- [ ] LiteLLM route `factory-fast` returns HTTP 200 on `/v1/chat/completions`
- [ ] LiteLLM route `coder` returns HTTP 200 on `/v1/chat/completions`
- [ ] nvidia-smi shows model fits within RTX 4070 8 GB VRAM (no CPU offload)
- [ ] G-FACTORY-01 updated to DONE in GAP-REGISTER.md after operator verification

## Rollback plan

| Step | Command |
|---|---|
| Stop ollama | `pkill -f ollama` or `sudo systemctl stop ollama` |
| Remove model | `ollama rm qwen2.5-coder:7b-instruct-q4_K_M` |
| Uninstall ollama binary | `sudo rm /usr/local/bin/ollama` (check `which ollama` first) |
| Revert LiteLLM config | Remove the two `factory-fast` / `coder` entries from `~/.litellm/config.yaml` |
| Restart LiteLLM | `pkill -f litellm && litellm --config ~/.litellm/config.yaml --port 4000 &` |

Disk reclaimed: ~4.4 GB (model weights) + ~200 MB (ollama binary + manifest).
No DB changes. No code changes. Fully reversible.

## Anchors

- IL-FACTORY-AUDIT-01 — factory sprint
- G-FACTORY-01 — Legion has no local model serving
- Operator canon Principle 1 (hardware-first) + Principle 4 (factory waits for cluster stability)
- ADR-018 — 5-layer hybrid AI compute
- docs/canon/operator-canon-2026-05.md
- docs/roadmap/sprint-factory-developer-audit-2026-05.md
