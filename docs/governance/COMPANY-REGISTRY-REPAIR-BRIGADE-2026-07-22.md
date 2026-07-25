# COMPANY REGISTRY — REPAIR-BRIGADE — 2026-07-22

**COMPANY OWNERSHIP / REPAIR-BRIGADE / DOCS-ONLY / READ-ONLY RUNTIME**
Self-healing infrastructure (`services/watchdog/*`). Contains **0 `*_agent.py`** — excluded from the agent-registry entirely. **NOT part of the bank agent headcount.** Listed here for ownership completeness only. Extracted from AGENT-REGISTRY-MASTER-2026-07-22.md.

| prior_id (in old MASTER) | canonical_name | source_path | class | classification |
|---|---|---|---|---|
| AG-F4-007 | RepairEngine | services/watchdog/repair_engine.py | RepairEngine | REPAIR-BRIGADE (infra, not employee) |
| AG-F4-008 | GuardedActionExecutor | services/watchdog/guarded_actions.py | GuardedActionExecutor | REPAIR-BRIGADE (infra, not employee) |
| AG-F4-009 | ActionScorer | services/watchdog/decision_policy.py | DefaultActionScorer | REPAIR-BRIGADE (infra, not employee) |
| AG-F4-010 | RootCauseClassifier | services/watchdog/root_cause_classifier.py | RootCauseClassifier | REPAIR-BRIGADE (infra, not employee) |
| AG-F4-011 | BestSolutionScorer | services/watchdog/best_solution.py | BestSolutionScorer | REPAIR-BRIGADE (infra, not employee) |
| AG-F4-012 | Watchdog | services/watchdog/watchdog.py | Watchdog | REPAIR-BRIGADE (infra, not employee) |

**Count:** 6 watchdog modules. NOT agents-of-record; excluded from bank headcount and from BANK-MASTER.

---
**This does not replace legal advice.**
