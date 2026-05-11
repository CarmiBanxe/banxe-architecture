# Runbook: Legion LLM Router Setup (LiteLLM Proxy)

**Environment:** Legion WSL2
**Date:** 2026-05-11
**Prerequisite:** evo1 reachable at `http://evo1:11434`
**DO NOT run as root.**

---

## Part A — OfficeCLI Install

```bash
# A.1 Prerequisites
sudo apt-get update && sudo apt-get install -y python3.12 python3.12-venv pipx

# A.2 Install OfficeCLI via pipx
pipx install officecli

# A.3 PATH update (add to ~/.bashrc if not present)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

# A.4 Verify
officecli --version

# A.5 Create safe workspace (NEVER use /data/* paths)
mkdir -p ~/banxe-dev/office-workspace
echo 'export OFFICECLI_WORKSPACE="$HOME/banxe-dev/office-workspace"' >> ~/.bashrc
source ~/.bashrc

# A.6 Confirm no symlinks into /data/*
ls -la ~/banxe-dev/office-workspace

# A.7 Smoke test
officecli --workspace "$OFFICECLI_WORKSPACE" status
```

---

## Part B — LiteLLM Proxy Install

```bash
# B.1 Install LiteLLM proxy
pipx install 'litellm[proxy]'
litellm --version
```

---

## Part C — Router Configuration

```bash
# C.1 Create config directory
mkdir -p ~/banxe-dev/llm-router

# C.2 Write config (copy-paste exactly)
cat > ~/banxe-dev/llm-router/config.yaml << 'EOF'
model_list:
  # Priority 1 — on-prem Ollama on evo1 (stays within EMI perimeter)
  - model_name: "default"
    litellm_params:
      model: "ollama/llama3"
      api_base: "http://evo1:11434"

  # Priority 2 — Anthropic Claude FALLBACK ONLY
  # BLOCKED for any request matching regulated path keywords (see guardrails below)
  - model_name: "fallback-claude"
    litellm_params:
      model: "claude-sonnet-4-6"
      api_key: "os.environ/ANTHROPIC_API_KEY"

router_settings:
  routing_strategy: "least-busy"
  fallback_models: ["fallback-claude"]
  timeout: 30
  num_retries: 2

guardrails:
  - guardrail_name: "block-regulated-paths"
    litellm_params:
      guardrail: "presidio"
      mode: "during_call"
      block_request_if_contains:
        - "/compliance/"
        - "/kyc/"
        - "/aml/"
        - "kyc_id"
        - "aml_flag"
        - "transaction_id"
        - "iban"
        - "national_id"

general_settings:
  master_key: "os.environ/LLM_ROUTER_MASTER_KEY"
  database_url: null
  store_model_in_db: false
EOF
```

---

## Part D — Environment Variables

```bash
# D.1 Set in ~/.bashrc (NEVER commit this file to any repo)
cat >> ~/.bashrc << 'EOF'
export OLLAMA_BASE_URL="http://evo1:11434"
export ANTHROPIC_API_KEY="<your-key-here>"      # replace before use
export LLM_ROUTER_MASTER_KEY="dev-only-$(openssl rand -hex 8)"
EOF
source ~/.bashrc
```

**WARNING:** Do NOT commit `~/.bashrc` exports, `config.yaml`, or any file
containing `ANTHROPIC_API_KEY` or `LLM_ROUTER_MASTER_KEY` to any branch
in `banxe-emi-stack` or `banxe-architecture`.
The Semgrep rule `banxe-hardcoded-secret` will catch inline keys but NOT
externally-sourced shell exports. Add `~/banxe-dev/llm-router/config.yaml`
to `~/.gitignore` as a host-level safeguard.

---

## Part E — Startup and Health Checks

```bash
# E.1 Start router (foreground, dev mode)
litellm --config ~/banxe-dev/llm-router/config.yaml --port 4000 --detailed_debug
```

```bash
# E.2 Health check — evo1 Ollama (run in separate terminal)
curl -sf http://evo1:11434/api/tags | python3 -m json.tool | head -20
# Expected: JSON listing available models on evo1
```

---

## Part F — Smoke Tests

### F.1 — Positive: non-regulated prompt routed to evo1

```bash
curl -s http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer $LLM_ROUTER_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"default","messages":[{"role":"user","content":"ping"}]}' \
  | python3 -m json.tool
# Expected: response from evo1 Ollama model
```

### F.2 — Negative: regulated keyword blocked BEFORE Anthropic

```bash
curl -s http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer $LLM_ROUTER_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"default","messages":[{"role":"user","content":"/kyc/ check this IBAN"}]}' \
  | python3 -m json.tool
# Expected: guardrail block response (error/blocked)
# The request MUST NOT appear in Anthropic API logs.
```

---

## Hard Rules (Enforce Always)

1. **Never point any backend at `http://evo2:*`** — evo2 is production inference;
   dev traffic causes resource starvation and log contamination.

2. **Never run `litellm` or `officecli` as root under WSL2** — root shares the
   Windows host token store; a root process can escape the namespace boundary
   and reach host-mounted evo1/evo2 NFS shares.

3. **Never commit `~/.bashrc` exports, `config.yaml`, or any file containing
   `ANTHROPIC_API_KEY` or `LLM_ROUTER_MASTER_KEY`** to any branch in
   `banxe-emi-stack` or `banxe-architecture`. The Semgrep rule
   `banxe-hardcoded-secret` enforces this for inline keys; `.gitignore` covers
   the config file. Both controls must be active simultaneously.
