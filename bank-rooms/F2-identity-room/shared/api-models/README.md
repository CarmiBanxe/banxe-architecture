# shared/api-models — runtime-boundary MIRRORS (not working code)

Cabinet-aligned mirrors of the identity-cluster Pydantic API models, copied read-only from `~/banxe-emi-stack/api/models/` per the R1 migration manifest. **Runtime-boundary reference only** — not imported, not validated at runtime, not modified here.

Mirrors: `auth.py`, `customers.py`, `kyc.py` (sources: `api/models/<same>.py`).

**Discipline:**
- Reuse-not-rebuild — **ADR-102**; compliance-source governance — **ADR-173**.
- Amount/decimal and PII handling rules are enforced in the basement runtime, not restated here; this mirror documents the contract shape only.
- No business-owner PII processing or in-house registry data is introduced in this room (per build specs).

**Anchors:** build specs `../../../../docs/architecture/A-{IDV,KYC,KYB}-BUILD-SPEC.md` · install-audits `../../../../docs/audit/spec-audits/A-{IDV,KYC,KYB}-INSTALL-AUDIT-2026-07-20.md`.
