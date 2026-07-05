# Fleet Passport-Binding Conformance Audit (2026-07-05)

**Auditor:** Factory (prepare-only, read-only). **Scope:** `agents/passports/**/*.yaml` on `origin/main`
(`11738ac`). **Trigger:** a fleet survey flagged ~14 passports as "UNMAPPED/THIN" via a crude
`department|level` grep. This audit re-runs the check rigorously (schema-aware) to separate genuine gaps from
counting artefacts.

## Verdict

The alarmist "14 unmapped" read is **wrong**. The rigorous set of passports lacking **any** org-binding field
(`department|human_double|reports_to|autonomy_level|hitl_gates`) is **13**, and it splits three ways: **9 are
conformant infra adapters** (bound by `bounded_context` + call-graph — no defect), **3 are genuinely
schema-nonconformant governor stubs** (the real gap), and **1 is an intentional developer-plane agent**. Net
**actionable gap = 3 passports**, plus one systemic documentation note.

## A. False positives in the survey's §5 list (confirmed BOUND)

`aml/*` sub-agents (`banxe_aml_orchestrator`, `jube_adapter_core`, `mlro_report_agent`, `sanctions_check_core`,
`tx_monitor_core`, `watchman_adapter_core`, `yente_adapter_agent`), `data_lake_elt_agent`, `treasury_alm_agent`,
`gap_tracker_agent` — all flagged "THIN" by the crude grep, but all carry `autonomy_level`/`human_double` (in
the AML SMF17 format or a nested `name:` block). They are **bound**; the grep just didn't match their shape.

## B. Conformant infra adapters — thin on org-fields BY DESIGN (9, no action)

`aml_orchestrator`, `banxe_aml_orchestrator` (root), `clickhouse_writer`, `crypto_aml`, `jube_adapter`,
`sanctions_check`, `tx_monitor`, `watchman_adapter`, `yente_adapter`. These are **schema-conformant** L2/L3
technical adapters/orchestrators with `agent_id`, `name`, `level`, `bounded_context` (CTX-01/CTX-03),
`allowed_callers/callees`, and skills. They legitimately have **no** `department`/`human_double` — org placement
for infra adapters lives in `docs/governance/AGENT-ORG-ASSIGNMENT-MATRIX.md`, not the passport. **No defect.**

## C. Genuine gap — schema-nonconformant governor stubs (3, ACTION)

`adverse_media_governor`, `regulatory_returns_governor`, `safeguarding_recon_governor` use an **ad-hoc
GAP-stub format** (`id:` not `agent_id:`; fields `gap/domain/title/owner/sprint/responsibilities`) and are
**missing schema-required fields** per `schemas/agent_passport.schema.json` (`agent_id`, `name`, `level`,
`trust_zone`, `ports`, `bounded_context`, `governance`; `capabilities`/`version` partial). They were created as
GAP-005/006/K-gabriel placeholders and never upgraded to full passports. **These are the real conformance gap.**
(Not CI-enforced — `validate_schemas.py` only self-tests the schema, so they pass silently.)

## D. Intentional (1, no action)

`spec_first_auditor` — `CTX-00-DEVELOPER`, out-of-bank developer-plane agent, placement ratified in #1012
(`UNMAPPED-AGENTS-PLACEMENT.md`). Minimal by design.

## Systemic note — matrix↔passport placement-sync gap

Org placements decided in `AGENT-ORG-ASSIGNMENT-MATRIX.md` (e.g. `clickhouse_writer` → CTO/Data-Analytics,
`spec_first_auditor` → developer-plane, both from #1012) are **not written back into the passport files** —
the passports still carry no `department`. This is a documentation-sync gap, not a runtime defect: the matrix
is the SSOT for org placement (per that doc), but a reader of a passport alone cannot see its placement.

## Recommendation

1. **Upgrade the 3 governor stubs** (§C) to `agent_passport.schema.json` shape — add `agent_id`/`name`/`level`/
   `trust_zone`/`ports`/`bounded_context`/`governance` + `department`/`human_double` (adverse_media → Compliance/MLRO;
   regulatory_returns → Reporting/CFO+MLRO; safeguarding_recon → Safeguarding/CFO+MLRO). Prepare-only; **does not
   activate** any agent (all stay PROPOSED, I-27).
2. **Decide** whether the matrix→passport `department` back-write is wanted, or whether the matrix stays the sole
   placement SSOT (either is defensible; the passports should at least *reference* the matrix).
3. **Consider CI enforcement** — `validate_schemas.py` self-tests the schema but does not validate passports
   against it, so nonconformant stubs land silently.

## Anchors

`agents/passports/**` · `schemas/agent_passport.schema.json` · `governance/STAFF-MATRIX-v3.md` (70 registry) ·
`docs/governance/AGENT-ORG-ASSIGNMENT-MATRIX.md` (org placement SSOT) · `docs/governance/UNMAPPED-AGENTS-PLACEMENT.md`
(#1012). Prepare-only, read-only; no passport edited, no agent activated.
