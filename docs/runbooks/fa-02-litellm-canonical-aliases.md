# FA-2 — LiteLLM canonical aliases (factory-mid / heavy / coder + project-reason)

| Field | Value |
|---|---|
| FA-ID | FA-2 |
| Sprint | IL-FACTORY-AUDIT-01 |
| Predecessor | FA-1 (PR #80, G-FACTORY-01 closed) |
| Branch | docs/fa-02-litellm-canonical-aliases |
| Status | DRAFT — runbook + add commands ready, awaiting operator go |
| Date | 2026-05-06 |
| Target | /home/mmber/MetaClaw/litellm/litellm-config.v2.yaml on Legion |

## Goal

Add 4 canonical aliases to LiteLLM config that match A4 orchestration proposal naming, while preserving all existing operational route names. After FA-2, both the canonical aliases (`factory-mid`, `factory-heavy`, `factory-coder`, `project-reason`) AND the legacy operational names (`qwen3-30b`, `ai-heavy`, `coding`, `reasoning-235b`) work. This formalises the orchestration plan from A4 without breaking any current consumer.

## Canonical alias map

Per A4 §"Factory plane orchestration" + §"Project plane orchestration":

| Canonical alias | Existing route(s) covering same model | Hardware | Use case | Action |
|---|---|---|---|---|
| `factory-fast` | `factory-fast` (added by FA-1) | Legion RTX 4070 | autocomplete, lint fixes, single-line edits | ✅ DONE (FA-1 / PR #80) |
| `factory-mid` | `qwen3-30b` (evo1+evo2 LB) | Strix Halo iGPU (Vulkan) | multi-file refactor, spec writing | add alias |
| `factory-heavy` | `ai-heavy` (evo1+evo2 LB) | Strix Halo iGPU | architecture-level reasoning, cross-repo plans | add alias |
| `factory-coder` | `coding` (evo1) | Strix Halo iGPU | coding-tuned heavy work (51 GB qwen3-coder-next) | add alias |
| `project-reason` | `reasoning-235b` (evo2 standalone llama-server :8082) | evo2 + RPC | compliance review, MLRO escalation, fraud explanation | add alias |

## Add steps (each gated on operator `go`)

### Phase A — Read-only verify current routes

```bash
CFG=/home/mmber/MetaClaw/litellm/litellm-config.v2.yaml
python3 -c "import yaml; c=yaml.safe_load(open('$CFG').read()); names=sorted({m['model_name'] for m in c['model_list']}); print('routes:', names)"
```

Expected: 15 unique route names including factory-fast (from FA-1) but NO factory-mid / factory-heavy / factory-coder / project-reason.

### Phase B — Backup config (operator go required)

```bash
CFG=/home/mmber/MetaClaw/litellm/litellm-config.v2.yaml
cp -v "$CFG" "${CFG}.bak-fa-02-$(date +%Y%m%d-%H%M%S)"
```

### Phase C — Append 4 new aliases via python+yaml (operator go required)

Aliases mirror existing route configs but use canonical names:

```yaml
# factory-mid → qwen3:30b-a3b on evo1+evo2 (LB)
- model_name: factory-mid
  litellm_params:
    model: ollama/qwen3:30b-a3b
    api_base: http://192.168.0.72:11434
    api_key: sk-banxe-evo1-local-2026
    timeout: 120
- model_name: factory-mid
  litellm_params:
    model: ollama/qwen3:30b-a3b
    api_base: http://192.168.0.15:11434
    api_key: sk-banxe-evo2-local-2026
    timeout: 120

# factory-heavy → llama3.3:70b on evo1+evo2 (LB)
- model_name: factory-heavy
  litellm_params:
    model: ollama/llama3.3:70b
    api_base: http://192.168.0.72:11434
    api_key: sk-banxe-evo1-local-2026
    timeout: 240
- model_name: factory-heavy
  litellm_params:
    model: ollama/llama3.3:70b
    api_base: http://192.168.0.15:11434
    api_key: sk-banxe-evo2-local-2026
    timeout: 240

# factory-coder → qwen3-coder-next:q4_K_M on evo1
- model_name: factory-coder
  litellm_params:
    model: ollama/qwen3-coder-next:q4_K_M
    api_base: http://192.168.0.72:11434
    api_key: sk-banxe-evo1-local-2026
    timeout: 240

# project-reason → qwen3:235b on evo2:8082 (standalone llama-server)
- model_name: project-reason
  litellm_params:
    model: openai/qwen3
    api_base: http://192.168.0.15:8082/v1
    timeout: 600
```

Apply via python+yaml (idempotent — assertion ensures no duplicate model_name with same api_base):

```python
import yaml
from pathlib import Path
p = Path('/home/mmber/MetaClaw/litellm/litellm-config.v2.yaml')
cfg = yaml.safe_load(p.read_text())
ml = cfg['model_list']
new_routes = [
    {'model_name': 'factory-mid', 'litellm_params': {'model': 'ollama/qwen3:30b-a3b', 'api_base': 'http://192.168.0.72:11434', 'api_key': 'sk-banxe-evo1-local-2026', 'timeout': 120}},
    {'model_name': 'factory-mid', 'litellm_params': {'model': 'ollama/qwen3:30b-a3b', 'api_base': 'http://192.168.0.15:11434', 'api_key': 'sk-banxe-evo2-local-2026', 'timeout': 120}},
    {'model_name': 'factory-heavy', 'litellm_params': {'model': 'ollama/llama3.3:70b', 'api_base': 'http://192.168.0.72:11434', 'api_key': 'sk-banxe-evo1-local-2026', 'timeout': 240}},
    {'model_name': 'factory-heavy', 'litellm_params': {'model': 'ollama/llama3.3:70b', 'api_base': 'http://192.168.0.15:11434', 'api_key': 'sk-banxe-evo2-local-2026', 'timeout': 240}},
    {'model_name': 'factory-coder', 'litellm_params': {'model': 'ollama/qwen3-coder-next:q4_K_M', 'api_base': 'http://192.168.0.72:11434', 'api_key': 'sk-banxe-evo1-local-2026', 'timeout': 240}},
    {'model_name': 'project-reason', 'litellm_params': {'model': 'openai/qwen3', 'api_base': 'http://192.168.0.15:8082/v1', 'timeout': 600}},
]
existing_keys = {(m['model_name'], m['litellm_params'].get('api_base')) for m in ml}
for r in new_routes:
    key = (r['model_name'], r['litellm_params']['api_base'])
    if key not in existing_keys:
        ml.append(r)
p.write_text(yaml.safe_dump(cfg, sort_keys=False, allow_unicode=True, default_flow_style=False))
```

### Phase D — Restart + smoke test (operator go required)

```bash
sudo systemctl restart litellm-lan-gateway
sleep 5
CFG=/home/mmber/MetaClaw/litellm/litellm-config.v2.yaml
MASTER_KEY=$(python3 -c "import yaml; print(yaml.safe_load(open('$CFG').read()).get('general_settings',{}).get('master_key',''))")

for alias in factory-mid factory-heavy factory-coder project-reason; do
  echo "── $alias ──"
  curl -sS -w 'HTTP=%{http_code}\n' http://127.0.0.1:4000/v1/chat/completions \
    -H "Authorization: Bearer $MASTER_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$alias\",\"messages\":[{\"role\":\"user\",\"content\":\"Reply with exactly: OK\"}],\"max_tokens\":10}" \
    | tail -c 400
  echo
done
```

Acceptance: each of 4 aliases returns HTTP 200 with content non-empty.

### Phase E — Confirm /v1/models contains all 5 canonical aliases (operator go required)

```bash
curl -fsS http://127.0.0.1:4000/v1/models -H "Authorization: Bearer $MASTER_KEY" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); ids=sorted({m['id'] for m in d['data']}); want=['factory-fast','factory-mid','factory-heavy','factory-coder','project-reason']; print('all canonical present:', all(w in ids for w in want)); print('missing:', [w for w in want if w not in ids])"
```

Acceptance: `all canonical present: True`, `missing: []`.

## Rollback plan

```bash
CFG=/home/mmber/MetaClaw/litellm/litellm-config.v2.yaml
ls -la "${CFG}.bak-fa-02-"*  # find backup from Phase B
cp -v "${CFG}.bak-fa-02-<timestamp>" "$CFG"
sudo systemctl restart litellm-lan-gateway
```

Reverts the 6 added route entries (4 canonical aliases × LB doubles where applicable).

## Acceptance criteria for FA-2 closure

- [ ] All 5 canonical aliases (factory-fast, factory-mid, factory-heavy, factory-coder, project-reason) return HTTP 200 via LiteLLM /v1/chat/completions.
- [ ] /v1/models lists all 5 canonical aliases.
- [ ] No existing operational routes (qwen3-30b, ai-heavy, coding, reasoning-235b, fast, ai, large, etc.) broken — sanity check 2-3 of them.
- [ ] G-FACTORY-LITELLM-ALIAS gap (open below) → DONE in GAP-REGISTER.

## Anchors

- IL-FACTORY-AUDIT-01 (PR #57) — sprint kickoff
- FA-1 PR #80 — predecessor (factory-fast added)
- A4 orchestration proposal §"Factory plane orchestration" / §"Project plane orchestration"
- docs/canon/operator-canon-2026-05.md — Principle 1 (HW-first satisfied), Principle 4 (factory unblocked)
- ADR-018 — 5-layer hybrid AI compute
- ADR-027 — Claude Code permissions reclassification

## Status

| Date | Status | Note |
|---|---|---|
| 2026-05-06 | DRAFT | Runbook + python patch ready; Phase A read-only, B-E gated on operator go. |
