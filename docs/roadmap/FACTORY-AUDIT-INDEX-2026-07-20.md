# Context & purpose

Lightweight discoverability hook, created by **S-FAC-R3**, so that key factory-related
documents living in `docs/audit/*` are visible from the roadmap layer. Per
`FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md` Gap 1,
`docs/governance/MASTER-ROADMAP.md`'s own consolidation scope is `docs/roadmap/*`
fragments only — it does not index `docs/audit/*` at all. This file does not change that
scope; it is a pointer document one level down, indexed *by* `MASTER-ROADMAP.md` §2.1,
covering the audit-plane documents the factory-canon repair line (S-FAC-R1/R2/R3) has
already examined or explicitly named as core. It copies no content and reclassifies
nothing — every verdict below was already recorded in the cited source.

# Audit document types

Two kinds of `docs/audit/*` document exist in the factory-canon corpus (per
`FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md` §"Audit integration model"):

| Type | Nature | Treat as |
|---|---|---|
| **Findings snapshot** | Time-boxed, explicitly about one day/moment (e.g. self-declared `AUTHORITATIVE for 2026-05-13 22:55 CEST`) | Historical fact about that day only; never current state |
| **Status/supersession or install audit** | Evidence-graded, re-assessable, purpose-built to stay accurate about *current* standing of other documents or code | Official factory evidence picture — the type this index tracks |

# Key factory audit artefacts

| Artefact | Path | Type | Role |
|---|---|---|---|
| Factory-Canon Status & Supersession Audit | `docs/audit/FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md` | status/supersession | S-FAC-R1 — ground truth for the 14-document factory-governance corpus's current standing |
| Floor-2 Build-Specs Installation Audit Plan | `docs/audit/FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` | plan (status: DRAFT/NOT FOR MERGE) | Umbrella plan for per-BUILD-SPEC install audits (18 specs incl. D-GL, B-EMI, M-GATEWAY, I-API) writing to `docs/audit/spec-audits/<SPEC>-INSTALL-AUDIT-<date>.md` |
| Full Bank Installation Audit Plan | `docs/audit/FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md` | plan/registry (status: DRAFT/NOT FOR MERGE) | Registry of installed-subsystem "tiles" (READY/PARTIAL-READY/GAP), filled in one tile per change-set |
| Factory Canon Rollout v1.6.1 Batch Audit | `docs/audit/FACTORY-CANON-ROLLOUT-v1.6.1-BATCH-2026-06-06.md` | status/rollout record (self-declared `REFERENCE`) | Named core by S-FAC-R1; records the one-time 7-repo canon-version rollout |
| Factory Laws vs. Reality | `docs/audit/factory-laws-vs-reality-2026-05-13.md` | findings snapshot | Named core by S-FAC-R1; single-day canon-vs-operational-reality gap analysis |
| Factory Orchestration & Training Block Audit | `docs/audit/factory-orchestration-and-training-2026-05-13.md` | findings snapshot (self-declared time-boxed) | Named core by S-FAC-R1; single-day LiteLLM/agent-routing/training-block audit |
| Sprint 1 — Software Factory Canon Ratification | `docs/audit/sprint1-software-factory-canon-2026-05-14.md` | process record (status DONE) | Named core by S-FAC-R1; ratified `docs/canon/software-factory-canon-v1.md`, still-ACTIVE canon |
| Sprint 3 — Routing Canon Enforcement | `docs/audit/sprint3-routing-canon-enforcement-2026-05-14.md` | process record (status OPEN, exit criteria unmet) | Named core by S-FAC-R1; see dependency/override note in `MASTER-ROADMAP.md` §4.2 |
| Sprint 7 — Pilot Factory Pack | `docs/audit/sprint7-pilot-factory-pack-2026-05-14.md` | process record (status DONE-WITH-OVERRIDE, see §4.2 above) | Named core by S-FAC-R1 |
| Sprint 8 — Full Factory Adoption | `docs/audit/sprint8-full-factory-adoption-2026-05-14.md` | process record (status DONE core / DEFERRED tail, DONE-WITH-OVERRIDE) | Named core by S-FAC-R1 |
| Factory Audit Trail Minimum Standard | `docs/roadmap/FACTORY-AUDIT-TRAIL-MINIMUM-STANDARD-2026-07-20.md` | **standard** | S-FAC-R4 — forward-looking minimum standard for what must be logged per factory execution/decision (execution-level and decision-level fields, passport linkage, canon/roadmap linkage, overrides/exceptions); not an audit *of* any existing document, so it carries no verdict the way the other rows do. First `docs/roadmap/*`-resident entry in this table (all others are `docs/audit/*`) — added per S-FAC-R4's own "Integration into FACTORY-AUDIT-INDEX" section, which named this exact row as the next repair step (S-FAC-P1). Storage-sink and enforcement gaps remain open per that document's own OPEN POINTs 1–2. |

**Note on inclusion criteria:** the two Floor-2/Full-Bank install-audit-plan rows above are
newly incorporated by this index at S-FAC-R3's explicit instruction — they were not part of
the 14-document set S-FAC-R1 classified. They are listed here as **plans**, not yet as
completed audits; `docs/audit/spec-audits/` in this worktree currently holds a partial,
in-progress set of per-spec outputs (confirmed present at time of writing:
`A-IDV`, `A-KYB`, `A-KYC`, `LEDGER-EMI`, `M-GATEWAY-WEB` install-audits) — this index does
not assert completeness of that set, only that the plan governing it exists and is core.

# How audits feed roadmap

- The relationship is **one-directional**: audits feed roadmap; roadmap does not feed back
  into audit docs. A roadmap document may cite an audit as evidence (as
  `TARGET-MODEL-CONFORMANCE-2026-06-24.md` cites `AGENT-ORG-STRUCTURE.md`), but an audit's
  own findings are updated only by a *newer audit*, never retroactively by a later roadmap
  decision.
- `docs/governance/MASTER-ROADMAP.md` §2.1 (the roadmap-plane consolidation index) now
  points to this file as its audit-plane discoverability hook (added by S-FAC-R3); this
  file in turn points to the audit artefacts themselves. Neither layer copies the other's
  content.
- Findings-snapshot-type audits are **not** meant to be re-consulted as current fact once
  superseded in effect by a broader/later audit — see the "Type" column above.

# OPEN POINTS

- This index covers the artefacts explicitly named as core by S-FAC-R1/R2 plus the two
  install-audit-plan documents named in the S-FAC-R3 task instructions. It is **not** a
  full enumeration of everything under `docs/audit/*` (that directory holds 90+ documents
  in this worktree) — whether a fuller audit-plane index is needed remains open, per
  `FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md` Gap 1 and
  `FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md` OPEN POINT 5.
- `docs/audit/spec-audits/` is an actively-growing directory (per the Floor-2 install-audit
  plan); this index reflects a snapshot at 2026-07-20 and will drift as more per-spec
  audits land. No mechanism to keep this index current is established here.
