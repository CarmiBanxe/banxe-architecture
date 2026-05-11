# ADR-035 ROADMAP — Progress Report
# ADR-035 ROADMAP — Parts 1–6 Progress
# Updated: 2026-05-11 (Part 6 complete)
# Date: 2026-05-11 | Auditor: Sub-terminal A (Claude Code)

## Reference: ADR-035 AI Pool Roadmap (10 Steps)

Source: `docs/adr/ADR-035-ai-pool-roadmap-2026-05-11.md` (committed 2026-05-11, SHA 1cc7cbb)

---

## Step Status Matrix

| Step | Title                              | Status      | Evidence / Notes                          |
|------|------------------------------------|-------------|-------------------------------------------|
| 1    | Smoke gate (ADR-035 original)      | ✅ DONE      | PR #105 merged; 3 files: emit script + workflow + tests |
| 2    | Pool audit — read-only SSH         | ✅ DONE      | This document + pool-audit-2026-05-11.md  |
| 3    | Model inventory deduplication      | 🟡 PARTIAL  | Inventory done (Part 6); dedup plan TBD  |
| 4    | LiteLLM route — add evo2           | ✅ DONE      | evo2 added; 6 LB pairs; simple-shuffle verified |
| 5    | Redis + LiteLLM cache              | ✅ DONE      | Redis on evo1 (Docker, hardened) + LiteLLM cache wired; cache verified 0.65ms |
| 6    | LLM router + A-8 resolution        | ✅ DONE      | MetaClaw stopped; default→evo1; fallback-claude guardrail-gated |
| 7    | Tailscale mesh verify all 3 nodes  | ✅ DONE      | All 3 nodes verified; 6/6 directed pairs direct WireGuard; Ollama HTTP reachable |
| 8    | Compliance routing guardrails      | 🟡 PARTIAL  | C1 fix + custom_code guardrail active (pre_call); Presidio not installed (not needed) |
| 9    | Load balancing (evo1 + evo2)       | 🔜 PENDING  | Requires Steps 4 + 5 first               |
| 10   | HITL gate for L3+ agent decisions  | 🔜 PENDING  | Architectural; blocked by Steps 4–9      |

Legend: ✅ Done | 🟡 Partial | 🔜 Pending | ❌ Blocked

---

## Step 1 — Detail (ADR-035 Smoke Gate)

**PR #105** — `feat/adr-035-smoke-failure-audit-2026-05-09`  
**Files changed:** 3 (scripts/emit_ci_smoke_failure.py, .github/workflows/smoke-gate-full.yml, tests/test_ci_smoke_failure_emitter.py)  
**Tests:** 17 unit tests — all green  
**Supersedes:** PR #103 (smoke-gate-full.yml without failure audit hook)  
**Compliance:** ADR-027 BufferedAuditPort fallback wired; `# noqa: S108  # nosec B108` on /tmp path

---

## Step 2 — Detail (This Step)

**Branch:** docs/pool-audit-2026-05-11  
**Files:**
- `docs/audit/pool-audit-2026-05-11.md` — raw collected data + risk register
- `docs/audit/roadmap-progress-2026-05-11.md` — this file

**Collection method:** Read-only SSH to evo1 and evo2; local inspection of Legion

**Key findings that affect roadmap prioritisation:**

### Finding F-1: evo1 resource contention (A-1, HIGH)
evo1 carries both inference load (Ollama peak 63 GB) and production services
(ClickHouse 1.2 GB, openclaw-gateway 1.7 GB combined, banxe-watchman 276 MB, uvicorn 80 MB).
Combined peak could exhaust 123 GB RAM. Step 3 (deduplication) should off-load inference-only
models to evo2, reducing evo1 load before Step 9 (load balancing) is activated.

### Finding F-2: evo2 orphaned from router (A-3, MEDIUM)
Active LiteLLM config on Legion routes exclusively to evo1 (100.68.102.48). evo2 runs
llama-server independently with a large model loaded (55.8 GB RSS). Step 4 (add evo2 to
LiteLLM routes) is required before any load balancing can occur.

### Finding F-3: 130+ GB model duplication (A-4, MEDIUM)
Seven models appear on both evo1 and evo2. Deduplication in Step 3 should designate
canonical nodes per model family:
- qwen3:235b series → evo2 only (requires 120+ GB RAM)
- qwen3-coder series → evo1 (primary coding workload)
- General 70B models → shared or evo2

### Finding F-4: Stale config file risk (A-2, MEDIUM)
`~/litellm_config.yaml` on Legion is a stale 4-model config pointing to evo2 local IP
(192.168.0.72). The active service reads `~/litellm-config.yaml` (hyphenated).
Recommendation: rename or delete the stale file before Step 4 edits.

### Finding F-5: Compliance routing partially complete (Step 8, PARTIAL)
C1 fix is applied in active config: Kimi K2 (Moonshot AI/China) disabled with UK GDPR Art.44
comment. However, Presidio guardrails (from legion-llm-router-setup.md runbook) are NOT
installed. The `block_request_if_contains` guardrail does not appear in the active config.
Priority: install Presidio guardrail before Step 4 widens routing surface to include evo2.

---

## Recommended Next Steps (ordered by risk reduction)

1. **Step 8 partial → full** — Install Presidio guardrail on Legion LiteLLM before expanding
   routing to evo2. This limits regulated-data exposure as routing surface grows.

2. **Step 3** — Model deduplication plan:
   - Map each model to canonical node
   - Remove duplicates (requires MLRO/CTIO sign-off for models used in compliance flows)
   - Free ~130 GB storage and reduce RAM pressure on evo1

3. **Step 4** — Add evo2 to LiteLLM model_list after stale config cleanup and Presidio in place.

4. **Step 5** — Redis on evo1 (primary; replicated to evo2) for session/rate-limit layer.

5. **Steps 6 + 7** — Grafana unified dashboard + Tailscale mesh verification (can run in parallel).

---

## Invariants Checked During Audit

| Invariant | Check                                             | Result  |
|-----------|---------------------------------------------------|---------|
| I-71      | Single-Writer Terminal Discipline                 | PASS — no concurrent terminals during audit |
| I-72      | Parallel Session Halt                             | PASS — no parallel session active |
| I-73      | Pre-flight Check Mandatory                        | PASS — pre-flight ran before data collection |
| I-74      | Atomic PR Lifecycle                               | PASS — single commit, no push |
| I-02      | Blocked jurisdictions (no CN/RU/etc backends)     | PASS — Kimi K2 disabled (C1 fix) |
| I-24      | No writes to audit trail during read-only step    | PASS — read-only collection only |
| I-27      | HITL — no autonomous changes to any node          | PASS — zero writes to evo1/evo2/Legion configs |

---

## Audit Signature

```
Auditor:    Sub-terminal A (Claude Code / claude-sonnet-4-6)
Canon:      SESSION-CANON-2026-05-11 (docs/canon/)
Date:       2026-05-11
Authority:  Local commit only — no push, no PR (Clause 6)
Pre-flight: CLEAR (branch docs/pool-audit-2026-05-11, base 1cc7cbb)
```


---

## Part 2 — Detail (ADR-035 ROADMAP Part 2 / Step 4)

**Branch:** feat/part2-redis-litellm-cache-2026-05-11
**Performed:** 2026-05-11 by Sub-terminal A

### Actions Taken

#### Step A+B — Redis on evo1 (hardened Docker container)
- `redis:7` Docker image already present on evo1 (no apt-get required; no sudo)
- Container `banxe-redis` started with `--network host`, `--restart unless-stopped`
- Bind: `127.0.0.1 192.168.0.72 100.68.102.48` (localhost + LAN eno1 + Tailscale only)
- `requirepass` set (48-char hex, stored at `~/banxe-dev/redis-evo1.env` chmod 600 on Legion)
- AOF persistence enabled (`appendonly yes`, `appendfsync everysec`)
- Dangerous commands disabled: `CONFIG`, `FLUSHALL`, `FLUSHDB`, `DEBUG`
- Verified PONG on all three bound interfaces including Legion→evo1 Tailscale

#### Step C — Config consolidation on Legion
- Canonical config identified: `~/litellm-config.yaml` (hyphenated, active systemd service :8080)
- Stale file archived: `~/litellm_config.yaml` → `~/litellm_config.yaml.bak-2026-05-11`
- `REDIS_PASS` added to `~/.config/litellm/.env` and `environment_variables` block in config

#### Step D — LiteLLM Redis cache wired
- `~/litellm-config.yaml` updated: `cache: true`, `cache_params` pointing to `100.68.102.48:6379`
- `supported_call_types`: completion, acompletion, embedding
- TTL: 3600 seconds

#### Step E — Cache verified
- LiteLLM restarted (`systemctl --user restart litellm`) — PID 1614785, startup clean
- Call 1: upstream Groq (~300ms response)
- Call 2+: `x-litellm-response-duration-ms: 0.65` — sub-millisecond = Redis cache hit confirmed
- Redis DBSIZE = 5 keys after 3 test calls

### New Findings from Part 2

| ID  | Severity | Finding                                                 |
|-----|----------|---------------------------------------------------------|
| A-8 | MEDIUM   | Second LiteLLM instance (PID ~71814) at :4000 `--host 0.0.0.0` unmanaged by systemd (MetaClaw) |
| A-9 | LOW      | `~/litellm_config.yaml.bak.20260501` already existed — third stale config file |

**A-8 action required:** Investigate MetaClaw LiteLLM instance — restrict to 127.0.0.1 or
add to systemd management before routing external traffic through Legion.

### Runbooks Added
- `docs/runbooks/redis-evo1-setup.md`
- `docs/runbooks/legion-litellm-cache.md`

---

## Part 3 — Detail (ADR-035 ROADMAP Part 3 / Step 5 — OfficeCLI)

**Branch:** feat/part3-officecli-legion-2026-05-11
**Performed:** 2026-05-11 by Sub-terminal A

### Actions Taken

#### Step A — Prerequisites verified
- `pipx` 1.4.3 already present; `node` v22.22.0 via nvm
- Running as `mmber` (non-root) — VERIFIED
- evo1/evo2 NOT touched

#### Step B — OfficeCLI installed via npm
- `npm install -g officecli` → officecli 0.2.52
- Binary: `~/.nvm/versions/node/v22.22.0/bin/officecli` (Node.js wrapper + Linux x64 runtime)
- Pre-install: package contents inspected (postinstall.js, install.js) — downloads
  from `officecli/officecli-dist` with checksum verification. No network calls at rest.
- Version confirmed: `officecli version 0.2.52 (1f19ed2a1d6b8ab968583c76515dcec00fdd3832)`
- Note: `pipx install officecli` fails (no PyPI package); `office-cli` (PyPI) is a seating-map
  tool — wrong product. npm is the correct install path.

#### Step C — Safe workspace created
- `~/banxe-dev/office-workspace` created, owner `mmber`
- Symlink scan: zero symlinks (no `/data/*` links)

#### Step D — Env var set
- `OFFICECLI_WORKSPACE="$HOME/banxe-dev/office-workspace"` appended to `~/.bashrc`

#### Step E — Smoke test
- `officecli config status` → Config file at `~/.config/officecli/config.json`, service not yet configured
- `officecli auth status` → Free trial quota: 0 used. No API key configured.
- No network call required for smoke test commands.

#### Step F — Deny boundary
- `/data/kyc`, `/data/transactions`, `/data/aml` paths: not mounted on Legion WSL2
- Deny enforced at `~/.claude/settings.json` layer: `Read(/data/kyc/**)`,
  `Read(/data/transactions/**)`, `Read(/data/aml/**)`
- No runtime probe of deny paths (per HARD CONSTRAINTS)

### Runbook Added
- `docs/runbooks/legion-officecli-setup.md`

---

## Part 4 — Detail (ADR-035 ROADMAP Part 4 / Step 6 — LLM Router + A-8 Resolution)

**Branch:** feat/part4-llm-router-a8-resolution-2026-05-11
**Performed:** 2026-05-11 by Sub-terminal A

### A-8 MetaClaw Resolution

#### Investigation (Step A)
- PID 71814 confirmed: `litellm --config ~/MetaClaw/litellm/litellm-config.v2.yaml --port 4000 --host 0.0.0.0`
- Owner: mmber (same user), started 2026-05-07
- Config: 30+ model aliases for evo1/evo2/Legion — purpose: comprehensive local routing gateway built during MetaClaw dev session
- Security findings: `0.0.0.0` binding (HIGH), hardcoded `master_key` (MEDIUM), no Redis password (MEDIUM), no guardrails (MEDIUM)
- Full investigation: `docs/audit/a8-metaclaw-resolution-2026-05-11.md`

#### Reconciliation (Step B)
- **Decision: canonical = systemd litellm.service at :8080 (127.0.0.1)**
- MetaClaw config archived: `~/MetaClaw/litellm/litellm-config.v2.yaml.bak-2026-05-11`
- MetaClaw stopped: `kill -15 71814`
- Port :4000 cleared; only :8080 remains

### LLM Router Configuration (Step C)

`~/litellm-config.yaml` additions:

#### New models
| model_name | backend | purpose |
|---|---|---|
| `default` | `ollama/qwen3:30b-a3b` @ `100.68.102.48:11434` | Priority 1 — evo1 Ollama (Tailscale) |
| `fallback-claude` | `claude-sonnet-4-6` @ Anthropic | Fallback — guardrail-gated |

#### router_settings
```yaml
router_settings:
  routing_strategy: simple-shuffle
  default_fallbacks: [fallback-claude]   # correct key for LiteLLM 1.82.0
  timeout: 30
  num_retries: 2
```

#### guardrails
```yaml
guardrails:
  - guardrail_name: block-regulated-paths
    litellm_params:
      guardrail: custom_code             # presidio NOT available in venv
      mode: pre_call
      default_on: true
      custom_code: <keyword blocking function — see runbook>
```
Keywords blocked: `/compliance/`, `/kyc/`, `/aml/`, `kyc_id`, `aml_flag`, `transaction_id`, `iban`, `national_id`

### Verification (Steps D + E)

| Test | Input | Expected | Result |
|---|---|---|---|
| Positive | `model=default`, content=`"ping router test"` | Reply from evo1 Ollama | `model=default`, reply `pong` ✅ |
| Negative | content contains `/kyc/` + `iban` | Guardrail block before Anthropic | Error: `Request blocked: regulated path/keyword '/kyc/'` ✅ |

Anthropic API NOT reached during negative test (verified by error source = guardrail pre_call hook).

### Runbooks Added/Updated
- `docs/audit/a8-metaclaw-resolution-2026-05-11.md` (new)
- `docs/runbooks/legion-llm-router-setup.md` (updated — was stub)


---

## Part 5 (revised) — Detail (ADR-035 ROADMAP Part 5 revised / Step 7 — Tailscale Mesh Verify)

**Branch:** feat/part5-tailscale-mesh-verify-2026-05-11
**Performed:** 2026-05-11 by Sub-terminal A
**Scope:** Read-only verification — zero writes to evo1/evo2 configs

**Rationale for revision:** Original Part 5 (qwen3:235b Q4→Q8 migration on evo2) blocked
by central terminal G-INFRA-01 evo2 mutations in flight. This revised Part 5 substitutes
the verification step, which was originally planned as Step 7 later in the roadmap.

### Node Verification

| Node | TS IP | LAN IP | TS version | Ollama | Daemon |
|------|-------|--------|-----------|--------|--------|
| Legion | 100.101.218.26 | 192.168.0.75 | 1.96.4 | N/A | active ✅ |
| evo1 | 100.68.102.48 | 192.168.0.72 | 1.96.4 | :11434 (9 models) ✅ | active ✅ |
| evo2 | 100.99.208.21 | 192.168.0.15 | 1.96.4 | :11434 (10 models) ✅ | active ✅ |

### Reachability Matrix Result

All 6 directed tailscale ping pairs: PASS (1–3ms direct WireGuard, no DERP relay).
ICMP Legion→evo1 and Legion→evo2: 0% packet loss.
Ollama HTTP via Tailscale (3 of 6 relevant pairs tested): PASS.
LiteLLM Legion :8080: loopback-only (not on Tailscale) — expected, secure.

### Notable Findings

| # | Finding | Severity | Action |
|---|---------|----------|--------|
| F-7a | evo2 shows `-` (idle) for evo1 in `tailscale status` | INFO | Normal — activates on demand, confirmed by tailscale ping |
| F-7b | DNS warning on evo1 + evo2 (MagicDNS resolver) | LOW | Non-blocking for pool ops; deferred to future part |
| F-7c | LiteLLM not exposed on Tailscale mesh | INFO (positive) | Correct loopback-only binding |

### Deliverables

- `docs/audit/tailscale-mesh-verify-2026-05-11.md` — full verification report + topology diagram
- `docs/runbooks/legion-tailscale-quick-reference.md` — quick-reference card for mesh ops
- `docs/audit/roadmap-progress-2026-05-11.md` — Step 7 updated to DONE


---

## Part 6 — Detail (ADR-035 ROADMAP Part 6 / Step 4 — Add evo2 as second LiteLLM backend)

**Branch:** feat/part6-litellm-evo2-route-2026-05-11
**Performed:** 2026-05-11 by Sub-terminal A
**Scope:** Legion-side config change only — zero writes to evo1/evo2

### Inventory (Step A)

Collected via HTTP GET /api/tags (read-only Tailscale):
- evo1: 9 models (185.1 GB total)
- evo2: 10 models (463.3 GB total, includes 235b variants)
- Shared (both nodes): 8 models → load-balanceable

Full inventory: `docs/audit/evo1-evo2-model-inventory-2026-05-11.md`

### Config Changes (Steps B + C)

`~/litellm-config.yaml` — 6 evo2 entries added (backup: `~/litellm-config.yaml.bak-part6-2026-05-11`):

| model_name | model | evo2 api_base |
|-----------|-------|--------------|
| `default` | `ollama/qwen3:30b-a3b` | `http://100.99.208.21:11434` |
| `banxe/operations` | `ollama/qwen3:30b-a3b` | `http://100.99.208.21:11434` |
| `ollama/glm-flash` | `ollama/qwen3:30b-a3b` | `http://100.99.208.21:11434` |
| `llama-3.3-70b` | `ollama/llama3.3:70b` | `http://100.99.208.21:11434` |
| `ollama/llama3.3-70b` | `ollama/llama3.3:70b` | `http://100.99.208.21:11434` |
| `ollama/qwen3.5-35b` | `ollama/qwen3.5:latest` | `http://100.99.208.21:11434` |

Router: `simple-shuffle` (unchanged from Part 4). Total model entries: 22 (verified via /model/info).

### Verification (Steps D + E + F)

| Test | Result |
|------|--------|
| LiteLLM restart clean (PID 2313804) | ✅ no errors in startup log |
| /model/info: 22 entries, 12 Ollama (6 evo1+evo2 pairs) | ✅ |
| 6 requests to `model=default`: all HTTP 200 | ✅ |
| evo1 Ollama `/api/ps` shows qwen3:30b-a3b loaded | ✅ |
| evo2 Ollama `/api/ps` shows qwen3:30b-a3b loaded | ✅ (489ms after evo1) |
| Guardrail `iban` keyword → block (no Anthropic call) | ✅ |

### Invariants

| Invariant | Check | Result |
|-----------|-------|--------|
| I-71 | Single-Writer Terminal Discipline | PASS |
| I-72 | Parallel Session Halt | PASS |
| I-73 | Pre-flight Check Mandatory | PASS — fetch + log + PR check |
| I-74 | Atomic PR Lifecycle | PASS — single commit, local only |
| I-27 | HITL — no writes to evo1/evo2 | PASS — Legion config only |
| I-02 | No sanctioned jurisdiction backends | PASS — all evo IPs are local LAN |

### Next Unblocked

Step 3 (model dedup) is now unblocked — inventory from Part 6 provides the source of truth.
Recommended: designate canonical nodes per model family before Step 9 (load balancing) expands.

