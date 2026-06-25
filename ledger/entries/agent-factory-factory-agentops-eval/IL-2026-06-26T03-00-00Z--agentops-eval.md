---
il_ts: 2026-06-26T03:00:00Z
session_id: agent-factory-factory-agentops-eval
source: CEO
status: DONE
---
### AgentOps/LLMOps status aggregator — scripts/agentops-eval.sh: read-only status over EXISTING Guardian/Canon-Judge/eval signals; new gates/owners/thresholds = AWAITS OPERATOR
- **Decision:** Created `scripts/agentops-eval.sh` (bash, `set -euo pipefail`, READ-ONLY, no mutation) — a status aggregator over the AgentOps/LLMOps controls that ALREADY exist in canon, each 🟢/🟡/🔴/⚪. It asserts **no new thresholds, owners, or blocking gates** (those are AWAITS OPERATOR per MODEL-RISK-MANAGEMENT §5/§6) — it only reads existing signals. Added Makefile targets `agentops`/`agentops-json`/`agentops-self-test` (existing untouched).
- **Per-control status (live):**
  - **Guardian 🟢** — 16 deterministic rules (8 factory F1-F8 + 8 project P1-P8); `.github/workflows/guardian.yml` present + `build_ledger.py --check` passes locally. (software-factory-canon §3.1/§4.1, lines 69-70.)
  - **Canon Judge 🟡 (audit-mode)** — LLM eval vs ADR-025, reported honestly as **audit / log-only, no block** (qwen3.5:35b); the script flags that a **BLOCKING independent-validation gate for T1 is AWAITS OPERATOR** — it does not assert one. (software-factory-canon §6, line 154; MRM §5.)
  - **Post-training eval 🟢** — `make train-verify` = pass (all mandatory skills bound).
  - **Skill-coverage eval 🟢** — `make skills-audit` unbound=0 (57/57 bound).
  - **Kill-switch / decommission 🟢 (present)** — `ollama rm` = per-model **operator confirmation** (governed MANUAL control, MRM §4 / HW-matrix, G-CLUSTER-03); reported as a governed manual control, NOT an automated switch.
  - **Explainability / monitoring thresholds ⚪ AWAITS OPERATOR** — numeric drift/hallucination thresholds (MRM §6) not invented.
  Overall 🟢 (Guardian pass + decommission control present).
- **Honesty boundary (AWAITS OPERATOR — MRM §5/§6, not asserted):** blocking independent-validation gate for T1; independent-validator OWNER (SR 11-7 effective challenge); revalidation cadence; numeric eval/monitoring thresholds. The aggregator lists these as ⚪ and invents nothing.
- **Proof — --self-test green + live:** `bash scripts/agentops-eval.sh --self-test` → overall 🟢, exit 0; `--self-test --json` valid (overall 🟢), exit 0; `make agentops-self-test` exit 0. LIVE run → overall **🟢**: Guardian pass, Canon Judge audit-mode (🟡 advisory), train-verify pass, skills unbound=0, kill-switch present; AWAITS items ⚪; clean exit 0 (the earlier 141 was SIGPIPE from a truncating `| head` in testing, not the script). LIVE `--json` valid. `bash -n` clean; 98 lines (≤300); semgrep pre-commit green. Exit 0 always (status aggregator, not a gate).
- **Basis:** `docs/canon/software-factory-canon-v1.md` (Guardian 16 rules §3.1/§4.1; Canon Judge audit-mode §6); `docs/governance/MODEL-RISK-MANAGEMENT.md` (§4 decommission per-model operator confirm; §5 independent-validation/owner/cadence AWAITS OPERATOR; §6 thresholds AWAITS OPERATOR); existing signals `scripts/train.sh` (train-verify), `scripts/skills-bind-audit.sh` (skills-audit), `.github/workflows/guardian.yml`, `ledger/build_ledger.py`.
- **Append-only (ADR-059-A):** ONE new tail shard at il_ts `2026-06-26T03:00:00Z` (strictly > fresh tree max `2026-06-26T02:30:00Z`); INSTRUCTION-LEDGER.md + IL-SEQUENCE.json regenerated via `python3 ledger/build_ledger.py`, `--check` exit 0. Isolated worktree off `origin/main 5485e8e` (ADR-120); RULE 7 self-honored. Anti-dup (ADR-102): no prior `scripts/agentops-*`.
- **Status:** DONE — AgentOps/LLMOps status aggregator in place (`make agentops`); reports existing controls honestly, asserts no operator-gated item. DO NOT MERGE pending operator review.
- **Recommended next (operator):** merge; decide the four AWAITS-OPERATOR items (T1 blocking independent-validation gate, independent-validator owner per SR 11-7, revalidation cadence, numeric eval/monitoring thresholds) to move Canon-Judge 🟡→🟢 for T1 and enable drift/hallucination monitoring.
- **Refs:** `scripts/agentops-eval.sh` (NEW), `Makefile` (agentops targets); `docs/canon/software-factory-canon-v1.md` (Guardian/Canon Judge); `docs/governance/MODEL-RISK-MANAGEMENT.md` (§4-§6); `scripts/train.sh`, `scripts/skills-bind-audit.sh`, `.github/workflows/guardian.yml`; ADR-025 (Canon Judge), ADR-059-A, ADR-120, ADR-121, I-28.
