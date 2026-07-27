# ADR-QUARANTINE-MIDAZ-EVO1 — Quarantine-vs-repair for evo1/legion R0 services

**Status: PROPOSED — NOT ACCEPTED.** Draft only. Not committed, not merged, not activated.
No ADR number allocated (would require operator ratification + real ledger mint).

**Date:** 2026-07-19 (drafted from operator audit `QUARANTINE-VS-REPAIR JUSTIFICATION 10:51`
+ local repo docs only — no new live probes were run for this ADR).

## 1. Context

Operator audit (10:51) confirmed:
- Current `TL_TARGETS` CRITICAL set is exactly:
  `evo1-redis-allocator|tcp|100.68.102.48:6379|critical`,
  `evo1-control-plane|http|http://100.68.102.48:9108/health|critical`.
  **`midaz-ledger`, `mongodb`, `workflow-service`, and `keycloak` are NOT in `TL_TARGETS`
  at all** — neither critical nor noncritical. Traffic-light's 🔴/🟡/🟢 verdict currently
  cannot detect the true state of any of these four services.
- ADR-143 allocator (factory-critical) — **PONG, GREEN**. Unaffected by this ADR.

`docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` (verbatim, not restated in full — pointer):
- **Scope boundary (§ header, lines 8–10):** *"this is the **factory** build-out roadmap
  (factory infra, training runner, traffic-light, skill adoption). For **project/EMI
  status** see the companion `docs/ROADMAP-STATUS-2026-06-23.md`."*
- **A6 (§0):** *"Env: evo1 `midaz-ledger`/`mongodb`/`workflow-service` **RESTARTING
  (RED)**; legion `keycloak` **unhealthy (YELLOW)**; `redis-cli` absent on legion"* →
  driver **R0 (S-FAC-60/61)**.
- **R0 exit (§1):** *"Bring RED/YELLOW services to a known-good contract: evo1
  `midaz-ledger`/`mongodb`/`workflow-service`, legion `keycloak`; install `redis-cli` on
  legion. Exit: every audited service GREEN or explicitly quarantined with a reason."*
- **S-FAC-60 DoD (§2, verbatim):** *"Root-cause for `midaz-ledger`/`mongodb`/
  `workflow-service` RESTARTING documented; remediation runbook; services GREEN ≥30 min
  or quarantined w/ reason in ledger."*
- **S-FAC-61 DoD (§2, verbatim):** *"`redis-cli` installed on legion; keycloak
  YELLOW→GREEN root-cause + fix; uniform healthcheck contract... documented per service."*

**Answer to Task 1a (classification):** in this roadmap's own scope statement, these four
services are audited and remediated as **factory-environment** items under block **R0**
(sprints S-FAC-60/61) — not tracked here as project/EMI status (that lives in the
companion `ROADMAP-STATUS` doc, not read for this ADR). **OPEN POINT:** `midaz-ledger` is
also the name used elsewhere in the BANXE org for the production EMI ledger/CBS
component. This roadmap does not state whether the specific `evo1` instance referenced in
A6 is a factory-only dev/test copy or has any bearing on project/EMI status — **not
confirmed either way, do not assume it is "just factory infra and therefore low-risk."**
Operator should confirm this distinction before treating quarantine here as risk-free.

## 2. Evidence per service (dated — do not conflate snapshots)

| Service | 2026-06-23 roadmap (A6) | Most recent local evidence | Current state |
|---|---|---|---|
| `midaz-ledger` | RESTARTING (RED) | `docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md`: remediation runbook exists (Step E, `docker start`), but root-cause is only **4 ranked hypotheses, none confirmed** (§2/§6 of that runbook); a separate, differently-labeled note in `INSTRUCTION-LEDGER.md` IL-487 mentions *"evo1 midaz+ballerine Up/healthy (S-FAC-61)"* under a **conflicting sprint-number scheme** — explicitly flagged **"not confirmed"** by the S-FAC-61 runbook itself | **UNKNOWN** (stale RED vs. unconfirmed "healthy" hint — genuinely unresolved) |
| `mongodb` | RESTARTING (RED) | Same runbook, same status — no service-specific evidence beyond the grouped A6 finding | **UNKNOWN** |
| `workflow-service` | RESTARTING (RED) | Same runbook; additionally the **exact container/service name is itself unconfirmed** (`docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md` §6: *"not found by name in any file read for this runbook"*) | **UNKNOWN** (plus an identity gap) |
| `keycloak` | unhealthy (YELLOW) | `docs/runbooks/S-FAC-61-health-contract-2026-07-18.md` §1/§3: **independently re-verified live, 2026-07-18** — `keycloak-banxe-emi` container `Up 30 hours (healthy)`, `:8180/realms/master` → HTTP 200. Root cause (per `IL-487`): original healthcheck lacked `Connection: close` → keep-alive hang → false-negative "unhealthy". Fix already applied host-side, confirmed still in effect. Residual open item: fix persistence across host reboot is **[UNKNOWN]**, unrelated to current health. | **GREEN**, confirmed, has been for ≥30h — **not actually YELLOW right now** |

## 3. Quarantine vs Repair — per service

- **`midaz-ledger`, `mongodb`, `workflow-service` → PROVISIONAL QUARANTINE (proposed).**
  S-FAC-60 DoD explicitly allows *"quarantined w/ reason in ledger"* as one of two
  qualifying exits (the other being GREEN ≥30 min). **Caveat, not silently resolved:** the
  same DoD sentence also requires *"root-cause... documented"* as a conjunctive item: read
  literally, this is only **partially** satisfied (documented as ranked hypotheses, not as
  a confirmed cause). Whether "documented as hypotheses" satisfies the DoD's
  "root-cause... documented" clause, or whether confirmation is required first, is **not
  resolved by the roadmap text — OPEN POINT for operator/CTIO judgment**, not decided here.
  Quarantine is proposed as *provisional* (subject to the root-cause-confirmation
  follow-up already tracked in the S-FAC-60 runbook), not a final closure.
- **`keycloak` → NO QUARANTINE NEEDED; record as REPAIRED/GREEN, not YELLOW.** Live
  evidence (§2) shows the S-FAC-61 DoD item for keycloak is **already MET** — quarantining
  it would misrepresent a resolved item as an open risk. The correct governance action is
  to record the corrected status (GREEN, repaired, evidence-linked to IL-487 +
  the S-FAC-61 runbook), not to add it to a quarantine list.

## 4. Ties to S-FAC-65 (traffic-light) and S-FAC-68 (DORA/KPI)

- **S-FAC-65:** none of these four services have a dedicated `TL_TARGETS` probe today
  (confirmed, §1) — a gap already flagged independently in both the S-FAC-60 and S-FAC-61
  runbooks. Until probes exist, traffic-light's GREEN verdict provides **no evidence**
  about `midaz-ledger`/`mongodb`/`workflow-service`/`keycloak` state — the ledger
  quarantine/repair record proposed here is the only governance-visible signal for these
  services in the interim, and should be treated as compensating, not redundant,
  documentation.
- **S-FAC-68:** the adoption gate (§3 of the roadmap: 3 consecutive days of GREEN
  traffic-light verdicts) can be satisfied by a verdict that **does not currently see**
  these four services. Recording this ADR + the quarantine ledger shard makes that gap
  auditable ahead of DORA/KPI wiring, rather than letting a "gate GREEN" reading imply
  "everything audited is fine."

## 5. Decision (PROPOSED, awaiting operator ratification)

1. Record a provisional-quarantine ledger entry for `midaz-ledger`, `mongodb`,
   `workflow-service` (RED, reason: RESTARTING since 2026-06-23, root-cause hypothesized
   not confirmed, no dedicated traffic-light probe) — see companion draft
   `ledger/entries/LEDGER-QUARANTINE-MIDAZ-EVO1.md`.
2. Record `keycloak` as **repaired/GREEN**, not quarantined — correcting the stale
   YELLOW carried forward from the 2026-06-23 snapshot, evidence-linked to IL-487.
3. **Do not** treat this ADR as closing S-FAC-60/61 — root-cause confirmation (vs.
   hypothesis) for the three RED services and the `workflow-service` identity gap remain
   open follow-ups, tracked in the existing runbooks, not duplicated here.

## 6. Open points / UNKNOWNS (explicit, not guessed)

- Whether this evo1 `midaz-ledger` instance has any project/EMI relevance beyond factory
  test infra (§1).
- Whether "root-cause documented as ranked hypotheses" satisfies the literal S-FAC-60 DoD
  wording, or whether confirmation is required (§3).
- Exact container/service name behind `workflow-service` (§2, carried from S-FAC-60
  runbook §6).
- The IL-487 vs. roadmap-table sprint-numbering mismatch (S-FAC-61 vs S-FAC-62) — flagged,
  not reconciled here (carried from the S-FAC-61 runbook §1).
- Whether the `keycloak` healthcheck fix has been made to persist across host reboot
  (carried from the S-FAC-61 runbook §3).
- Current (today's) live container status of `midaz-ledger`/`mongodb`/`workflow-service`
  was **not re-probed** for this ADR (out of scope per task instructions — this ADR uses
  only the operator's audit block and existing local repo docs).
- No decision-authority role is named by the roadmap for who ratifies a quarantine
  decision — this ADR does not invent one; operator sign-off is assumed per standing HITL
  discipline, not because the roadmap names a specific role.

## 7. Consequences

- No service is mutated, restarted, or touched by this ADR (read-only governance
  artifact).
- No merge, no ledger mint (`build_ledger.py`/`IL-SEQUENCE.json` untouched), no PR opened.
- If ratified, a follow-up factory task would: (a) mint the real ledger shard via the
  evo1 allocator, (b) open a PR for this ADR + shard together, (c) separately propose the
  missing `TL_TARGETS` rows for these four services (S-FAC-61 already recommends this as
  its own follow-up).

## 8. References (pointer-first, not restated)

`docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §0 (A6), §1 (R0), §2 (S-FAC-60/61) ·
`docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md` · `docs/runbooks/S-FAC-61-health-contract-2026-07-18.md` ·
`INSTRUCTION-LEDGER.md` IL-487 · `config/traffic-light.env` (current `TL_TARGETS`) · ADR-143-A.
