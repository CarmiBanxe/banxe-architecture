# ADR-035 ROADMAP — Progress Report
# ADR-035 ROADMAP Part 1 / Step 2 deliverable
# Date: 2026-05-11 | Auditor: Sub-terminal A (Claude Code)

## Reference: ADR-035 AI Pool Roadmap (10 Steps)

Source: `docs/adr/ADR-035-ai-pool-roadmap-2026-05-11.md` (committed 2026-05-11, SHA 1cc7cbb)

---

## Step Status Matrix

| Step | Title                              | Status      | Evidence / Notes                          |
|------|------------------------------------|-------------|-------------------------------------------|
| 1    | Smoke gate (ADR-035 original)      | ✅ DONE      | PR #105 merged; 3 files: emit script + workflow + tests |
| 2    | Pool audit — read-only SSH         | ✅ DONE      | This document + pool-audit-2026-05-11.md  |
| 3    | Model inventory deduplication      | 🔜 PENDING  | Blocked by Step 2 completion              |
| 4    | LiteLLM route — add evo2           | 🔜 PENDING  | Blocked by Step 3; risk A-3 flagged       |
| 5    | Redis session layer                | 🔜 PENDING  | No Redis on any node (risk A-5)           |
| 6    | Grafana unified dashboard          | 🔜 PENDING  | evo2 has grafana; evo1 does not           |
| 7    | Tailscale mesh verify all 3 nodes  | 🔜 PENDING  | Legion→evo1 Tailscale confirmed; evo2 unverified |
| 8    | Compliance routing guardrails      | 🟡 PARTIAL  | C1 fix applied (Kimi K2 disabled); Presidio not installed |
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

