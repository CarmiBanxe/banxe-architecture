# shared/ports — runtime-boundary MIRRORS (not working code)

These files are **cabinet-aligned mirrors** of the identity port contracts, copied read-only from the runtime basement (`~/banxe-emi-stack/services/kyc/`) per the R1 migration manifest. They exist as **runtime-boundary reference artefacts** so the architecture room can reason about the identity contract surface — they are **not** executed, imported, or modified here.

| Mirror | Basement source | Role |
|---|---|---|
| `kyc_provider_port.py` | `services/kyc/kyc_provider_port.py` | Provider port consumed by A-IDV/A-KYC/A-KYB (SumSub etc.) |
| `kyc_port.py` | `services/kyc/kyc_port.py` | Internal KYC port contract |
| `factory.py` | `services/kyc/factory.py` | Port/adapter wiring (contract-level) |

**Discipline:**
- Reuse-not-rebuild — **ADR-102** (`../../../../docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md`). The room does not re-implement these ports.
- Delegation — A-IDV/A-KYC/A-KYB **consume** `KYCProviderPort` / `RegistryProviderPort`; no in-house OCR/biometrics/registry logic (see build specs).
- Authoritative behaviour lives in the basement; edits happen there, never in this mirror.

**Anchors:** `../../../../docs/architecture/A-IDV-BUILD-SPEC.md` · `A-KYC-BUILD-SPEC.md` · `A-KYB-BUILD-SPEC.md` · install-audits `../../../../docs/audit/spec-audits/A-{IDV,KYC,KYB}-INSTALL-AUDIT-2026-07-20.md`.
