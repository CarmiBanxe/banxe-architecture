# CELL — MLRO ROOT (root of the MLRO tree, independent line)

**STATUS: PROPOSED — pending MC-C1 counsel-review. NOT canon.** · Sandbox-only · no push
Schema: `docs/orgcells/SCHEMA.md` (12 fields, validation V1–V6; independence proof §4)

> This cell encodes **SM&CR SMF17** independence. It is `PROPOSED` and explicitly **not canon**
> until counsel review (MC-C1).

---

```yaml
cell_id: mlro-root
name: MLRO / Financial Crime — independent line
kind: MLRO_ROOT
reporting_line: MLRO_LINE
vertical:
  manager_ref: null          # V1: root of the MLRO tree — NOT under the engine, by construction
department_ref: null
data_policy: "sandbox-only; no secrets, no credentials, no real data"
status: PROPOSED             # V5: no activation evidence cited → PROPOSED
```

## functions[] (PRIMARY) — non-delegable

| # (exec order) | name | description | input → output |
|---|---|---|---|
| 1 | `sar_determination` | Decides whether a suspicious-activity report is filed. **Non-delegable to the engine or any ENGINE_HIERARCHY cell.** | suspicion case file → SAR filed / not filed, with reasoning recorded |
| 2 | `pep_approval` | Approves or refuses a politically-exposed-person relationship or transaction. Non-delegable. | PEP case → approve / refuse |
| 3 | `sanctions_determination` | Sanctions screening determinations, including **reversal** of an automated block — reversal is MLRO-only. | screening hit / reversal request → determination |
| 4 | `edd_decision` | Enhanced-due-diligence outcome where the EDD threshold is met (the payment path proposes, this line decides). | EDD proposal (e.g. threshold-triggered HITL proposal) → EDD outcome |
| 5 | `independent_reporting` | Reports directly to the Board on financial-crime matters; the engine is neither an intermediary nor a recipient of authority. | period / event → Board report |

## horizontal[]

| peer_ref | interaction |
|---|---|
| `engine-director` | **Cooperation only, never subordination (V4).** Receives referrals and HITL proposals from the engine line and returns binding determinations. The engine cannot task or overrule this cell, and no `vertical` edge from it to this cell can be expressed at all (SCHEMA §4). |

## authority

- **Alone (non-delegable, MLRO/SMF17):** SAR filing decision · PEP approval · sanctions determination incl. reversal · EDD outcome.
- **Escalated:** matters requiring Board or joint sign-off per the org canon (e.g. actions the referenced gate table binds to MLRO **and** CEO/CFO jointly).
- **HITL binding:** SAR and PEP determinations sit at **HUMAN_MLRO L4** — a human MLRO decides; there is no AUTO band for them. The engine's confidence bands (AUTO > 90 / REVIEW 70–90 / BLOCK < 70) may **propose** but never dispose on these functions. Gate definitions referenced, not restated: `banxe-emi-stack: services/hitl/org_roles.py` (cross-repo).
- **Structural note:** this cell's authority does not derive from the Director. It derives from the independent line to the Board (org canon Dept-6).

## source_refs[] (paths only — ADR-102, never duplicated)

| Path | Resolution | What is referenced |
|---|---|---|
| `docs/canon/passports/mlro.yaml` | **repo-local** | MLRO human passport (role, responsibility, gate authority) |
| `governance/SPRINT-4-MLRO-LINE.md` | **repo-local** | MLRO operating-model delta (ADR-102 companion) |
| `governance/CANONICAL-ORG-CHART-v2.md` | **repo-local** | Dept-6 MLRO/Financial-Crime: independent 2nd line, reports to Board, **not** inside Compliance, **not** under CFO/COO |
| `banxe-emi-stack: services/hitl/org_roles.py` | cross-repo (path-only) | `OrgRole.MLRO = SMF17`; SAR filing / PEP approval / sanctions reversal as non-delegable gates |
| `banxe-emi-stack: agents/compliance/soul/mlro_agent.soul.md` | cross-repo (path-only) | MLRO agent soul (behavioural canon of the agent twin) |

## Placeholder — MT-05 FROZEN (do not resolve)

`aml_orchestrator` is referenced **as a placeholder only**. Its identity conflict (3 passports / 2 ids, L1-vs-L2, AMBER-vs-RED) is **FROZEN** under MT-05 `[pending human ratification]`.

- **Not done here, and must not be done under this schema:** resolving the conflict, deduplicating the passports, re-passporting, or choosing an id.
- When ratified, the resolved unit attaches **under this root** (`manager_ref: mlro-root`, `reporting_line: MLRO_LINE`) — V2 makes any other attachment invalid.

## Notes

- Functions above are **specification only**; Banksy code is refactored **into** this cell afterwards per the canonical rule (SCHEMA §0) — functions and order only, never secrets, credentials, or real data.
- No child cells are declared in this bootstrap.

---
**This does not replace legal advice.**
