# F2 / identity-room

**Floor 2 — Banking core · Identity cluster (IDV / KYC / KYB / consent)**
Room kit hardened per FLOOR2-IDENTITY-ROOM-HARDENING (S-A5 cabinet-alignment). Docs-only; no runtime code lives here.

## Purpose / coverage

Identity boundary of the bank: KYC/KYB onboarding, consent, and identity documents. The room is simultaneously a **destination** for cabinet-aligned runtime-boundary artefacts and a **governance-gap register** for the identity cluster. It mirrors — it does not run — the A-IDV / A-KYC / A-KYB build specs.

## Basement split (where the code actually lives)

- **Runtime (basement):** `~/banxe-emi-stack` — `api/routers/{auth,customers,customer_lifecycle,kyc,kyb_onboarding,adverse_media}.py`, `api/models/{auth,customers,kyc}.py`, `services/kyc/{kyc_provider_port,kyc_port,factory,mock_kyc_workflow}.py`. This is the authoritative runtime; it is **never modified from this room**.
- **Architecture / cabinet (this repo):** `~/wt/architecture-bank-operating-model-20260718/bank-rooms/F2-identity-room/` — build specs, install-audits, and **cabinet-aligned mirrors** of ports/API under `shared/`. Mirrors are runtime-boundary reference artefacts, not working code (see `shared/*/README.md`).
- **Migration record:** `migration-logs/F2-identity-cabinet-aligned-manifest-*.txt` (copied set) and `migration-logs/F2-identity-gated-exclusions-*.txt` (deliberately excluded live/legacy/provider files).

## Delegation discipline (technical fact, from R3 / BUILD-SPECs)

A-IDV / A-KYC / A-KYB consume `KYCProviderPort` / `RegistryProviderPort` and do **not** reimplement them. The BUILD-SPEC files assert: DELEGATED to licensed providers (SumSub, RegistryProviderPort); **no in-house** OCR / biometrics / facial / liveness / registry scraping / business-owner PII processing; **"No runtime code here"**; no cross-repo write into `banxe-emi-stack`; no AML/sanctions/PEP screening; no B-EMI. Reuse-not-rebuild is enforced by **ADR-102**; compliance-source governance by **ADR-173**.

## Regulatory posture — internal policy vs legal classification (do not mix)

- **IDV/KYC — internal policy stance:** treated as **"non-Annex-III, high-risk internally by policy"** (per CRO/CTO memo). This is an **internal control posture, not legal advice** and not a legal Annex III determination. `[counsel]`
- **KYB — perimeter rule:** the KYB perimeter is **not** assessed in isolation; it is read **together with merchant-acquiring permissions**, because KYB outcomes gate merchant activation. The licensing/regulatory consequence of that coupling remains `[counsel]`.
- **Traceability:** `correlation_id` is sufficient for **technical fault tracing**, but does **not** by itself close **regulatory decision traceability** — that needs decision-layer fields (**initiator, input data, decision outcome, override trail**) on top of the correlation id. Sufficiency for any regulatory requirement remains `[counsel] / [external reviewer]`.

## Regulatory Status Notes (register — unchanged)

- Register areas: **#5 Consent/DPO (AMBER; potential RED if Art.37 requires a DPO and none is appointed)** · #8 cross-room.
- Canonical source: `../../docs/governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`.
- Freeze: the room is never "greener" than its worst affecting register entry; no GREEN without evidence.

### Sprint 2 (Consent/DPO)
Artefacts: `../../docs/sprints/sprint-2-art37-applicability-assessment.md` · `sprint-2-interim-consent-owner-decision.md` — DRAFT; #5 AMBER→GREEN only on a counsel outcome for Art.37 + a DPO decision.

### Governance Gap Register
- **DPO VACANT** — interim owner per the Interim Consent-Owner Decision (temporary only).

## Key agents / services

`KYC-Specialist-v2` (`services/agents/kyc_onboarding_agent.py`), `kyb_agent`, `consent_agent`, `document_agent`. Autonomy and HITL gates: see `hitl-summary.md` and `agents-identity-room.yaml`.

## Room kit index

- `agents-identity-room.yaml` — agent roster, register refs, HITL gate refs (the identity `agents-*` kit file).
- `hitl-summary.md` — identity/KYC/KYB/consent HITL gates (real gate IDs from `../../HITL-MATRIX.yaml`).
- `diagrams/identity-room-overview.svg` — room overview (basement → cabinet, delegation, HITL).
- `shared/{ports,api-routers,api-models}/` — runtime-boundary mirrors (+ per-dir README).
- `A-IDV|A-KYC|A-KYB/README-MIGRATED-RUNTIME-SCOPE.md` — per-spec migrated-scope notes.

## Anchors

- ADR: `../../docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md` · `../../docs/adr/ADR-173-compliance-source-governance.md`
- Invariants: `../../INVARIANTS.md` (**I-27** — HITL: AI proposes, human decides)
- S-A5: `../../docs/roadmap/S-A5-EXECUTION-PLAN-A-IDV-KYC-KYB-2026-07-19.md`
- Install-audits: `../../docs/audit/spec-audits/A-IDV-INSTALL-AUDIT-2026-07-20.md` · `A-KYC-INSTALL-AUDIT-2026-07-20.md` · `A-KYB-INSTALL-AUDIT-2026-07-20.md`
- Build specs: `../../docs/architecture/A-IDV-BUILD-SPEC.md` · `A-KYC-BUILD-SPEC.md` · `A-KYB-BUILD-SPEC.md`
- Briefs: `../../docs/briefs/FLOOR2-A-CHAIN-CONTEXT-FOR-CONSULTANTS.md` · `CRO-CTO-IDV-KYB-TRACEABILITY-MEMO.md` · `HIGH-RISK-AI-REGISTER-OPERATOR-MEMO.md`
