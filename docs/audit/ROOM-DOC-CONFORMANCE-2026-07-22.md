# Room-Doc Conformance vs MASTER — 2026-07-22

**GOVERNANCE-AUDIT / PILLAR-2 ROOM-DOC CONFORMANCE / DOCS-ONLY / READ-ONLY RUNTIME**
Verifies that each of the 17 room `agents-roster.md` files exactly reflects its rows in `../governance/AGENT-REGISTRY-MASTER-2026-07-22.md` (source of truth). Rosters generated from MASTER only — no runtime, no invented agents. Read-only over `~/banxe-emi-stack`.

## Conformance table

| room | MASTER_agents | roster_rows | dir (pre-existing) | match |
|---|---|---|---|---|
| F2-payments | 27 | 27 | yes | yes |
| F1-customer-ops | 18 | 18 | yes | yes |
| F3-treasury | 10 | 10 | **created** | yes |
| F3-risk | 10 | 10 | yes | yes |
| F3-aml | 10 | 10 | yes | yes |
| F4-devops | 9 | 9 | yes | yes |
| F2-ledger | 9 | 9 | yes | yes |
| F2-identity | 8 | 8 | yes | yes |
| F1-support | 8 | 8 | **created** | yes |
| F4-audit-cell | 7 | 7 | **created** | yes |
| F4-ai-platform | 7 | 7 | **created** | yes |
| F3-finbi | 6 | 6 | **created** | yes |
| F1-marketing | 6 | 6 | yes | yes |
| F3-regrep | 4 | 4 | **created** | yes |
| F2-safeguarding | 4 | 4 | **created** | yes |
| F4-security | 2 | 2 | yes | yes |
| F1-hr-legal | 2 | 2 | **created** | yes |
| **TOTAL** | **147** | **147** | 8 created / 9 pre-existing | 17/17 |

## Verdict

- **Conformant rooms:** 17 / 17 (100%). Every room's `agents-roster.md` row count equals its MASTER-per-room count.
- **[reconcile] rooms:** 0.
- **Directories created this step:** 8 (F1-support, F1-hr-legal, F2-safeguarding, F3-treasury, F3-finbi, F3-regrep, F4-ai-platform, F4-audit-cell) — each with a create-if-missing README stub.
- **agents-roster.md generated/refreshed:** 17 (all rooms), each headed "Generated from AGENT-REGISTRY-MASTER-2026-07-22.md; MASTER is source of truth."
- **Total roster rows across rooms:** 147 = MASTER total (86 census + 61 functional). No row invented, dropped, or duplicated.
- **Flags preserved:** `[gated-counsel]` and `[pending human ratification]` carried into rosters verbatim from MASTER (not resolved here).

**Documentation conformance = 100% (17/17 rooms).** Existing `agents-*.yaml` kit files were not overwritten — `agents-roster.md` is a separate MASTER-derived file alongside them.

Open: rosters inherit MASTER's open items (20 `[pending human ratification]` → `[audit]`; 21 `[gated-counsel]` → `[counsel]`). All legal → `[counsel]`.

---
**This does not replace legal advice.**
