# Agent Fleet — Front-3 writeup: org-assignment + 7/24 liveness

> **Status:** governance writeup (Front 3). **Additive, pointer-first (ADR-102).** **Prepare-only:** the
> factory sets the **structure** (org-matrix + liveness schema + monitor passport); it **activates no agent,
> starts no daemon, edits no canonical passport, invents no placement (UNMAPPED escalated), touches no
> legal/ss1/GUYON / ADR / perimeter, and bypasses no auth.**

## 1. Org-assignment (V + H) — summary
`docs/governance/AGENT-ORG-ASSIGNMENT-MATRIX.md` maps the **70 canonical passports** to the bank org, all
**read-derived** from the passports + `CANONICAL-ORG-CHART-v2.md` (V) + `agents/swarms/*` (H):

| Department (reports_to) | agents | line |
|---|---|---|
| Board & Executive (Board/SMF1) | 2 | Exec |
| Independent Functions — Risk·Compliance (CRO/SMF4) | 5 | 2nd |
| CFO Office (CFO/SMF2) | 9 | 1st/2nd |
| COO / Operations (COO/SMF24) | 6 | 1st |
| CTO / Technology-Data-AI (CTO/SMF26) | 15 | 1st |
| MLRO / Financial Crime (MLRO/SMF17 → Board, independent) | ~14 (incl. aml/ adapters) | 2nd |
| Front Office · Payments · HR/Legal | ~6 | 1st |
| Internal Audit (SMF5 → Audit Committee) | 2 | 3rd |
| **§UNMAPPED (escalated, not invented)** | **2** (`clickhouse_writer`, `spec_first_auditor`) | — |

- **Vertical (V) = `reports_to`** per the org-chart; **Horizontal (H) = `collaborates_with`** per swarm
  co-membership (accounting-swarm / banxe-aml-swarm / monthly-fca-return). **Three Lines of Defence** per canon §6.
- **MLRO line is independent** (canon §4 — `banxe_aml_orchestrator` = MLRO, not under Compliance/CFO/COO).
- **Data-hygiene follow-up (not invented):** the `aml/` core adapters lack a top-level `department` field —
  placed on the MLRO line by canon §4 + swarm membership; `human_double` shown as `(MLRO)` pending an explicit
  passport field. **Operator confirm.**

## 2. Liveness mechanism (7/24) — schema laid
`config/monitoring/agent-liveness.yaml` is the **fleet-scope** liveness contract (extends #988 from spec to
data): per-agent `expected_state` (active / on-demand / dormant), `heartbeat_interval` / `freshness_window`
(`[RATIFY]`), `last_seen_source`, `alert_on_silence`, and a **dashboard contract** (live / idle / silent / dead
/ unknown / dormant). Freshness = honesty: stale ⇒ **unknown, never live-by-inertia**. **7/24 daemonisation is
operator-run** (systemd/cron), alerting via Prometheus + Telegram (ADR-126), enforcement-locus `banxe-monitoring`
(#964) — **AWAITS-OPERATOR**, built infra-side.

`config/agents/passports/fleet-liveness-agent.yaml` — **FleetLivenessAgent** (schema-required-complete;
`GREEN` / `L1_AUTO` read-only; `human_double: Head of AI Platform`; `reports_to: CTO`; `hitl_gate: none`;
`parent_canon: governance/CANONICAL-ORG-CHART-v2.md`; **fleet-format `ports` inbound/outbound**). **PROPOSED,
not activated** (activation = operator ADR-135); kept under `config/agents/passports/` (not injected into the
canonical fleet).

## 3. #1005 defect — fixed on its own branch (not merged)
`#1005` (EngineHealthAgent) is **unmerged**; its files are not on `main`. Per "fix-in-worktree if unmerged /
follow-up-note if merged", the fix is applied **on the #1005 branch itself** (its correct home — avoids
duplicate files across two open PRs): (a) wording "schema-valid" → "required-complete + fleet-convention, not
strict-`additionalProperties`-valid (like the fleet)"; (b) `engine-health-agent.yaml` `parent_canon` →
`governance/CANONICAL-ORG-CHART-v2.md`, `ports: []` → fleet `inbound/outbound` format. **This PR does not
duplicate #1005's files** (would conflict); cross-ref only.

## 4. Boundaries (Rule 6 / perimeter)
- **0 agents activated, 0 daemons started.** Matrix + liveness schema + monitor passport are **structure only**.
- **70 canonical passports NOT edited** — the matrix is *read-derived*; `agents/passports/*` untouched.
- **UNMAPPED not invented** — `clickhouse_writer`, `spec_first_auditor` escalated with their available signals.
- **No auth bypass; no legal/ss1/GUYON; no ADR; no perimeter/compliance-config; no other's merged content.**

## ORCHESTRATION-NOTICE (to Central terminal)
- **The factory sets the STRUCTURE** (org-matrix, liveness schema, monitor passport — governance). **Central
  populates RUNTIME activation** (ADR-135 per-agent) + **daemonises the 7/24 liveness** (systemd/cron, infra).
- Coordination via the ledger shard; **no conflict** — the factory owns the governance data, Central owns the
  runtime. No terminal's work overwritten.
- **AWAITS-OPERATOR:** (1) **activate agents** (PROPOSED→ACTIVE, ADR-135); (2) **daemonise** FleetLivenessAgent
  7/24 (systemd/cron, banxe-monitoring); (3) **ratify** the liveness `[RATIFY]` thresholds; (4) **resolve
  §UNMAPPED** (clickhouse_writer, spec_first_auditor) + the aml/ `department`-field data-hygiene.

## Changelog
- **v1.0.0 (2026-07-03):** org-assignment matrix (70 passports, V+H, 2 UNMAPPED), fleet-liveness schema,
  FleetLivenessAgent passport (PROPOSED), writeup. *(Append future revisions; append-only.)*

## Anchors
`docs/governance/AGENT-ORG-ASSIGNMENT-MATRIX.md` (the matrix) · `config/monitoring/agent-liveness.yaml` (liveness
schema) · `config/agents/passports/fleet-liveness-agent.yaml` (monitor passport) · `governance/CANONICAL-ORG-CHART-v2.md`
(V basis) · `HITL-MATRIX.yaml` · `agents/swarms/*` (H basis) · `docs/governance/AGENT-LIVENESS-SPEC.md` (#988) ·
`docs/governance/AGENT-STATUS-NORMALIZATION.md` (#989 — PROPOSED / ADR-135 activation) · #1005 (EngineHealthAgent
— fix on its branch) · ADR-128 (HITL L1/L2/L3) · ADR-135 (activation gate) · ADR-126 (#964 alert placement) ·
ADR-102 (Duplication Audit — restates none). Operator directive 2026-07-03 (Front 3: org-assignment + 7/24
liveness + #1005 fix; prepare-only; canon-grounded; UNMAPPED escalated; passports not edited).
