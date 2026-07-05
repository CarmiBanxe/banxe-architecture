# PROPOSED-Agent Activation-Readiness Audit (2026-07-05)

**Auditor:** Factory (prepare-only, read-only). **Scope:** the **39** `agents/passports/**` entries with
`status: PROPOSED` on `origin/main`, checked against the factory-verifiable activation preconditions
(**schema conformance · SOUL present · HITL gate**). This is a **readiness report — it activates nothing**;
activation stays I-27 HITL-L4 / operator (see `docs/runbooks/AGENT-ACTIVATION-PROCEDURE.md`, #1039).

## Verdict

**0 of 39 PROPOSED agents are fully activation-ready** on the three factory-checkable preconditions — but the
crude survey read ("SOUL=0 for all") is **wrong**, and the real blocker is **bimodal**. Correcting the SOUL
naming false-negative (`apar_agent` ↔ `apar-agent.md`, underscore↔hyphen), the fleet splits cleanly:

| Cohort | Count | schema | SOUL | HITL | Blocker |
|---|---|---|---|---|---|
| **Schema-conformant, no SOUL** | ~33 | 10/10 (or 8/10 for the 4 dev-platform governors) | ✗ | mixed | **Missing SOUL** (operating charter) |
| **SOUL + HITL, schema-incomplete** | 6 (finance/) | 7–8/10 | ✓ | ✓ | **Missing schema fields** (finance-passport format) |

## A. Correction to the survey's "SOUL = 0 for all"

The crude check matched `agent_id` (underscore) against SOUL filenames (hyphen) and found 0. Normalized, **6
finance agents already have SOULs**: `apar_agent`, `beancount_export_agent`, `consolidation_agent`,
`gl_close_agent`, `ifrs_agent`, `tax_compliance_agent` (→ `agents/souls/apar-agent.md`, etc.). (The other SOULs
in `agents/souls/` map to **already-ACTIVE** AML agents — `banxe_aml_orchestrator`, `jube_adapter_core`,
`sanctions_check_core`, `tx_monitor_core`, … — which are out of this PROPOSED scope.)

## B. The real fleet-wide blocker — no PROPOSED agent has *both* a conformant passport *and* a SOUL

- **~33 agents are schema-conformant (10/10 required fields) but have NO SOUL.** A SOUL (per `SOUL-TEMPLATE.md`
  / `agents/souls/_TEMPLATE.md`) is the agent's operating charter (role, tools, HITL gate, territory) — an
  activation prerequisite. These agents are *structurally* described but have no charter to run under.
- **The 6 SOUL-bearing finance agents are schema-incomplete (7–8/10)** — they use the finance-passport format
  (missing e.g. `trust_zone`/`ports`/`bounded_context`/`governance`), exactly the class the #1035 stub-upgrade
  fixed for the 3 governors.
- Net: **the two halves are complementary** — neither cohort is complete. Fleet activation is blocked on
  **SOUL authoring** (33) and **schema completion** (6), *before* the I-27 HITL-L4 gate is even reached.

## C. HITL column — read with care (not a hard gap)

`hitl=no` for many governors is often legitimate: orchestration/governor passports route to an existing service
and declare no *direct* HITL gate (their human oversight is the department `human_double` + the service's own
gate). `hitl=yes` appears where a passport names a gate (e.g. `adverse_media_governor` → MLRO,
`safeguarding_recon_governor` → HITL-011). This column flags *where a direct gate is declared*, not a defect.

## D. Not verified here (out of a passport read)

- **Service-code existence** (cross-repo `banxe-emi-stack`) — most PROPOSED passports declare *"owner of the
  EXISTING service `services/X/`"*, so their code likely exists, but that requires the emi-stack-side check
  (the companion audit #1029 confirmed 16/18 domain paths). Per-agent service verification is a separate pass.
- **The actual I-27 HITL-L4 sign-off** — the human gate; not a factory-checkable precondition.

## Recommendation

Activation is blocked fleet-wide on two prerequisites the factory *can* prepare (both prepare-only, **no
activation**):
1. **Author SOULs** for the ~33 schema-conformant, SOUL-less agents (largest effort; each SOUL is a CLASS-B
   charter → written PROPOSED, operator/HITL-gated, per `SOUL-TEMPLATE.md`).
2. **Complete the schema fields** for the 6 finance agents (same pattern as #1035).
Only after **both** per agent + its **I-27 HITL-L4 sign-off** can that agent be activated by the operator.

## Anchors

`agents/passports/**` (39 PROPOSED) · `agents/souls/**` + `SOUL-TEMPLATE.md` · `schemas/agent_passport.schema.json` ·
`docs/runbooks/AGENT-ACTIVATION-PROCEDURE.md` (#1039) · `docs/audit/FLEET-PASSPORT-BINDING-CONFORMANCE-2026-07-05.md`
(#1034) · I-27 (`.claude/rules/compliance.md`). Prepare-only, read-only; no agent activated, no status changed.
