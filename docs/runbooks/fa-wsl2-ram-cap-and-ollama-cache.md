# Runbook: FA — Raise WSL2 RAM Cap + Ollama Cache to SSD (Legion)
<!-- Gap: G-FACTORY-WSL2-RAM-CAP | IL: IL-CANON-HW-BASELINE-2026-05-06 -->
<!-- Created: 2026-05-06 | Status: READY -->

## Summary

Legion physical HW has 64 GB RAM and 4+ TB SSD, but WSL2 without an explicit `.wslconfig`
cap only exposes ~23 GiB to the Linux guest, severely constraining model selection and
Ollama blob cache capacity. This runbook raises WSL2 to ~56 GB and migrates Ollama blobs
to the SSD.

---

## Prerequisites

- Windows 11 on Legion host
- WSL2 distribution already installed (Ubuntu or similar)
- Ollama installed inside WSL2 (or Windows-native)
- ~10 GB free on C: / Windows volume (for paging file)
- SSD path chosen for Ollama cache (e.g. `D:\ollama-models` or `/mnt/d/ollama-models`)

---

## Step 1 — Edit `.wslconfig` on Windows host

Open PowerShell or cmd on Windows (not inside WSL2):

```powershell
notepad "$env:USERPROFILE\.wslconfig"
```

Add or update the `[wsl2]` section:

```ini
[wsl2]
memory=56GB
swap=8GB
processors=12
```

**Notes:**
- `memory=56GB` leaves ~8 GB for Windows; adjust to `48GB` if Windows feels sluggish.
- `swap=8GB` offloads model weight overflow to disk — acceptable latency trade-off for
  large models during cold load.
- `processors=12` is advisory; WSL2 uses all cores by default but this sets a ceiling.
- Do **not** set `localhostForwarding=false` unless you have a specific reason.

---

## Step 2 — Restart WSL2

In PowerShell:

```powershell
wsl --shutdown
wsl
```

Verify inside WSL2:

```bash
free -h
# Expected: ~54-56 GiB total
```

---

## Step 3 — Migrate Ollama blob cache to SSD

### 3a. Locate existing Ollama model directory

```bash
ls ~/.ollama/models/blobs/ | wc -l   # count of existing blobs
du -sh ~/.ollama/                     # current size
```

### 3b. Choose target SSD path

The SSD is mounted at `/mnt/d` (or `/mnt/e` depending on partition letter).
Verify:

```bash
df -h | grep /mnt
lsblk -o NAME,SIZE,MOUNTPOINT,TYPE
```

Create target directory:

```bash
mkdir -p /mnt/d/ollama-models
```

### 3c. Copy existing blobs (preserve structure)

```bash
rsync -avh --progress ~/.ollama/models/ /mnt/d/ollama-models/
```

Wait for completion. Verify checksums on a sample:

```bash
md5sum ~/.ollama/models/blobs/sha256-$(ls ~/.ollama/models/blobs/ | head -1 | cut -c1-8)* 2>/dev/null | head -3
md5sum /mnt/d/ollama-models/blobs/sha256-$(ls /mnt/d/ollama-models/blobs/ | head -1 | cut -c1-8)* 2>/dev/null | head -3
```

### 3d. Set `OLLAMA_MODELS` environment variable

Add to `~/.bashrc` (or `~/.zshrc`):

```bash
export OLLAMA_MODELS=/mnt/d/ollama-models
```

Reload:

```bash
source ~/.bashrc
```

### 3e. Restart Ollama and verify

```bash
# If running as systemd service inside WSL2:
sudo systemctl restart ollama

# If started manually:
pkill ollama; ollama serve &

ollama list   # should show models from /mnt/d/ollama-models
```

### 3f. (Optional) Remove old blobs from home directory after verification

```bash
du -sh ~/.ollama/
# Only run this after confirming ollama list works from new path
rm -rf ~/.ollama/models/blobs/
```

---

## Step 4 — Validate model selection

With 56 GB RAM and GPU offloading (RTX 4070 Laptop, 8 GB VRAM):

| Model | RAM needed | VRAM layers | Viable? |
|-------|-----------|-------------|---------|
| Qwen2.5-Coder-7B-Q4 | ~5 GB | all | ✅ (baseline) |
| Qwen2.5-Coder-14B-Q4 | ~9 GB | all | ✅ |
| Qwen2.5-Coder-32B-Q4 | ~20 GB | partial | ✅ after RAM cap raised |
| Qwen3-30B-A3B-Q4 | ~19 GB | partial | ✅ after RAM cap raised |
| Qwen2.5-Coder-72B-Q4 | ~45 GB | CPU-only | ⚠️ slow, swap kicks in |

Recommended target: **Qwen2.5-Coder-32B-Q4** or **Qwen3-30B-A3B-Q4** for `factory-coder` route.

Test with:

```bash
ollama run qwen2.5-coder:32b-instruct-q4_K_M "def fibonacci(n: int) -> int:"
```

---

## Step 5 — Update LiteLLM config (if applicable)

If `factory-coder` route in LiteLLM config points to an Ollama model:

```yaml
# ~/litellm-config.yaml (or /etc/litellm/config.yaml)
model_list:
  - model_name: factory-coder
    litellm_params:
      model: ollama/qwen2.5-coder:32b-instruct-q4_K_M
      api_base: http://localhost:11434
```

Restart `litellm-v2.service`:

```bash
sudo systemctl restart litellm-v2.service
systemctl --user status litellm-v2.service
```

---

## Rollback

To revert WSL2 memory cap:

```powershell
# On Windows host: remove or comment out memory= line in .wslconfig
notepad "$env:USERPROFILE\.wslconfig"
# Then:
wsl --shutdown && wsl
```

To revert Ollama cache location:

```bash
unset OLLAMA_MODELS
# Remove the export line from ~/.bashrc
# Restart ollama
```

---

## Verification Checklist

- [ ] `free -h` inside WSL2 shows ≥ 50 GiB total
- [ ] `echo $OLLAMA_MODELS` returns SSD path
- [ ] `ollama list` shows models without error
- [ ] Ollama `pull` goes to SSD (check `du -sh /mnt/d/ollama-models/`)
- [ ] LiteLLM `factory-coder` route responds to a test prompt
- [ ] No Windows OOM during normal coding session (monitor Task Manager → RAM)

---

## References

- GAP: `GAP-REGISTER.md` → `G-FACTORY-WSL2-RAM-CAP`
- HW baseline: `docs/canon/factory-project-stack-2026-05.md` § HW Baseline
- Canon: `docs/canon/operator-canon-2026-05.md` Principle 1 (HW-first)
- IL: `INSTRUCTION-LEDGER.md` → `IL-CANON-HW-BASELINE-2026-05-06`
- LiteLLM aliases: `docs/runbooks/fa-02-litellm-canonical-aliases.md`
