# FLOOR2 Identity-Room Hardening Report — 2026-07-21

**FLOOR-2 / IDENTITY CLUSTER / ROOM-KIT HARDENING / DOCS-ONLY / NO RUNTIME CHANGE**

Scope: `bank-rooms/F2-identity-room` in the architecture repo only. No file in `~/banxe-emi-stack` was read-modified; no gated/excluded file was touched; no Annex III / MiCA / GDPR classification, HITL-MATRIX, register, or passport was changed.

## Artefacts created / updated

| Artefact | Action | Notes |
|---|---|---|
| `bank-rooms/F2-identity-room/README.md` | **updated** (18 → full kit) | Role, basement split, delegation, posture (3 stances), register notes preserved, anchor links |
| `bank-rooms/F2-identity-room/agents-identity-room.yaml` | **updated** (expanded) | Roster + autonomy + HITL gate refs + policy_stance. *This is the `agents-identity.yaml` deliverable; existing room-convention name kept (other rooms use `agents-<room>-room.yaml`) — see Deviations.* |
| `bank-rooms/F2-identity-room/hitl-summary.md` | **created** | Real gate IDs HITL-002/006/007/014 + consent/DPO governance-gap |
| `bank-rooms/F2-identity-room/diagrams/identity-room-overview.svg` | **created** | Basement→cabinet, providers, HITL, posture |
| `bank-rooms/F2-identity-room/shared/ports/README.md` | **created** | Runtime-boundary mirror note + ADR-102 + build-spec/audit refs |
| `bank-rooms/F2-identity-room/shared/api-routers/README.md` | **created** | Same discipline; exclusions referenced |
| `bank-rooms/F2-identity-room/shared/api-models/README.md` | **created** | Same discipline; ADR-102/173 |
| `docs/audit/FLOOR2-IDENTITY-ROOM-HARDENING-REPORT-20260721.md` | **created** | This report |

## How S-A5 and the shell-audits are reflected

- **S-A5 execution plan** and the **A-IDV/A-KYC/A-KYB install-audits** are linked from README §Anchors and the shared/ READMEs as the evidence base for the cabinet.
- **R1 migration** (`FABRIKA-F2-IDENTITY-CABINET-ALIGNED-MIGRATION-R1`) is reflected: the manifest and exclusions logs are cited in README §Basement split; shared/ READMEs enumerate the copied mirrors and point at the exclusions log.
- **Post-copy audit (R1)** findings are honoured: gated files (`mock_kyc_workflow.py`, `services/compliance/legacy/*`, `sumsub_http_stub.py`) are documented as **excluded** and were not introduced.
- **R3 focused audit** delegation facts (DELEGATED to providers; no in-house OCR/biometrics/registry; "No runtime code here") are stated as technical fact in README and the shared/ READMEs.
- **HITL gates** are mirrored from `HITL-MATRIX.yaml` with the authoritative IDs (HITL-002 EDD, HITL-006 KYC rejection, HITL-007 PEP onboarding, HITL-014 AI model update). The brief's shorthand H-006/H-007/H-012 was mapped to these real IDs; the matrix itself was not edited.

## Posture recorded (internal policy vs legal — kept separate)

- IDV/KYC: "non-Annex-III, high-risk internally by policy" — **internal stance, not legal advice** `[counsel]`.
- KYB: assessed **with** merchant-acquiring permissions, not in isolation `[counsel]`.
- `correlation_id`: technical fault tracing only; regulatory decision traceability needs initiator/input/decision/override `[counsel] / [external reviewer]`.

## Open questions left explicitly UNCLOSED

Carried verbatim from `docs/briefs/FLOOR2-A-CHAIN-CONTEXT-FOR-CONSULTANTS.md`:

- `[counsel]` **Annex III relevance of IDV/KYC flows** (via the Sprint-2 High-Risk Map). Internal high-risk-by-policy stance is a control posture, not a legal determination.
- `[counsel]` **KYB perimeter for the merchant-acquiring coupling** (licensing side). Scope of the joint perimeter unresolved.
- `[external reviewer]` **Sufficiency of the correlation_id error model** as provider-chain audit traceability. Technically supports fault tracing; regulatory sufficiency unassessed.
- `[counsel]` **Consent/DPO (register #5)** — DPO VACANT; Art.37 applicability and interim-arrangement sufficiency pending.

## Deviations / notes for operator

- The agents kit was written to the **existing** `agents-identity-room.yaml` (room naming convention) rather than creating a second `agents-identity.yaml`, to respect reuse-not-rebuild (ADR-102) and avoid a duplicate roster. If the exact filename `agents-identity.yaml` is required, it is a one-line rename decision for the operator.
- Diagram delivered as **SVG** (text-authorable, diff-able); no PNG generated.
- All changes are additive/documentation; runtime repo and gated files untouched.
