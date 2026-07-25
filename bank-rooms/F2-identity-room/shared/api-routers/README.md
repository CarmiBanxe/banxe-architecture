# shared/api-routers — runtime-boundary MIRRORS (not working code)

Cabinet-aligned mirrors of the identity-cluster FastAPI routers, copied read-only from `~/banxe-emi-stack/api/routers/` per the R1 migration manifest. **Runtime-boundary reference only** — not served, not imported, not modified here.

Mirrors: `auth.py`, `customers.py`, `customer_lifecycle.py`, `kyc.py`, `kyb_onboarding.py`, `adverse_media.py` (sources: `api/routers/<same>.py`).

**Discipline:**
- Reuse-not-rebuild — **ADR-102**. These are contract/surface mirrors; endpoints are owned and run only in the basement.
- Delegation & carve-out: KYC/KYB/AML internals remain under the I-27 carve-out; no AML/sanctions/PEP screening is implemented in this room.
- Excluded from this room (see `../../migration-logs/F2-identity-gated-exclusions-*.txt`): live provider orchestration, direct HTTP adapters, legacy compliance adapters, provider stubs.

**Anchors:** build specs `../../../../docs/architecture/A-{IDV,KYC,KYB}-BUILD-SPEC.md` · install-audits `../../../../docs/audit/spec-audits/A-{IDV,KYC,KYB}-INSTALL-AUDIT-2026-07-20.md` · HITL: `../../hitl-summary.md`.
