# Refactor SPEC — KYCProviderPort extraction (SumSub)

Date: 2026-05-26
Status: SPEC (design baseline; Phase B impl is Terminal B in Phase B window)
Scope: extract SumSub KYC integration (inline in SPEC #5 banxe-baas) into standalone banxe-kyc + KYCProviderPort
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/banxe/banxe-fiat-backend/banxe-baas on evo1
Related: ADR-021 five-new-ports (KYCProviderPort); ADR-028 KYC re-verification; ADR-034 webhook reliability KYC; SPEC #5 EMI Banking Services; RISK_REGISTER R-REG-02 KYC/AML gap
Owner: Terminal B (smart refactor) authors SPEC + owns Phase B impl

## Purpose

Break out the SumSub KYC integration (currently inline in SPEC #5 banxe-baas) into a standalone banxe-kyc service behind KYCProviderPort, the fifth ADR-021 Hexagonal port. This completes full dedicated-SPEC coverage for all five ADR-021 ports. It also directly addresses R-REG-02 (KYC/AML gap during switchover) and supports S20 external blockers (SumSub appointment) and S24 FCA submission.

## Legacy inventory (read-only audit 2026-05-26)

Source: banxe-baas (only project with real KYC business logic; banxe-open-banking has only the web SDK bootstrap).

- KYC SDK bootstrap: sumsub-local-sdk.html in both banxe-baas and banxe-open-banking (frontend KYC initiation).
- Migrations (3): partner-sumsub-levels-and-unique-partner-user-id; change-sumsub-level-field; changing-text-to-array-in-sumsubLevels.
- DTOs (6): partner-sumsub-levels.dto, client-sumsub-levels.dto, change-sumsub-level.dto, get-sumsub-access-token.dto, sumsub-access-token.dto, changed-sumsub-level.dto.
- Two-tier model: partner-level SumSub levels (B2B) + client-level SumSub levels (B2C individuals).
- Access-token flow: get-sumsub-access-token -> sumsub-access-token (web SDK session token issuance).
- Level-change flow: change-sumsub-level -> changed-sumsub-level (KYC tier upgrade/downgrade).

## Decision

### banxe-baas KYC modules: EXTRACT-INTO-banxe-kyc
- Extract all SumSub DTOs + migrations + business logic into standalone banxe-kyc NEW service.
- banxe-baas becomes a CONSUMER of KYCProviderPort, not the owner of KYC logic.
- Keep two-tier model (partner-level + client-level).
- Migrate TypeORM migrations to NEW banxe-kyc schema.
- Drop GraphQL coupling (if any) per ADR-019.
- Web SDK bootstrap (sumsub-local-sdk.html) moves to NEW frontend asset pipeline.

### SumSub adapter strategy
- Primary: SumSubAdapter (existing integration, modernised).
- Fallback (FCA risk mitigation per R-REG-02): VouchedAdapter or OnfidoAdapter as alternative KYC provider behind the same port.
- This prevents single-vendor lock-in for a regulatory-critical capability.

## KYCProviderPort contract (per ADR-021)

```typescript
export type KYCTier = "none" | "basic" | "intermediate" | "full";
export type KYCStatus = "not_started" | "pending" | "approved" | "rejected" | "review";
export type ProviderLevelId = string;

export interface KYCSession {
  userId: string;
  accessToken: string;
  expiresAt: string;
  providerLevelId: ProviderLevelId;
}

export interface KYCResult {
  userId: string;
  status: KYCStatus;
  tier: KYCTier;
  providerLevelId: ProviderLevelId;
  reviewedAt?: string;
  rejectReasons?: string[];
}

export interface KYCProviderPort {
  startSession(userId: string, tier: KYCTier): Promise<KYCSession>;
  getStatus(userId: string): Promise<KYCResult>;
  handleWebhook(payload: unknown, signature: string): Promise<KYCResult>;
  changeLevel(userId: string, newTier: KYCTier): Promise<KYCResult>;
}
```

Contract notes:
- Two tiers map: partner-level (B2B onboarding) handled separately by a PartnerKYC variant; client-level (B2C) is the primary KYCProviderPort.
- handleWebhook covers ADR-034 webhook reliability (DLQ + retry on SumSub webhook).
- changeLevel covers ADR-028 KYC re-verification triggers.
- Every status change persists to guardian_audit_events for MLRO + Travel Rule (R-REG-02, R-REG-03).

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + decision + port contract (this SPEC).
- Phase B (Terminal B): scaffold banxe-kyc NEW repo (NestJS 10 + Node 18+ + TypeORM); migrate SumSub DTOs + migrations.
- Phase C (Terminal B): implement KYCProviderPort + SumSubAdapter (primary); stub fallback adapter interface.
- Phase D (Terminal B): contract tests for KYCProviderPort; webhook reliability tests (ADR-034 DLQ + retry); shadow-mode against legacy banxe-baas KYC for 14 days.
- Phase E (Terminal B): cut banxe-baas + banxe-open-banking over to KYCProviderPort; remove inline KYC code.
- Phase F (Terminal B): tag legacy KYC modules ARCHIVE; record decommission in IL; close R-REG-02.

## Risk register tie-in

- R-REG-02 (KYC/AML gap during switchover): dual-write to legacy + NEW KYC store during cut-over; freeze new account creation in cut-over window; this SPEC is the design that closes the gap.
- R-REG-03 (Travel Rule v2): KYC tier gates crypto outflows; KYCProviderPort.getStatus feeds the Travel Rule check (crypto-ops-monitor SPEC #7).
- R-SEC-NEW-05 (SumSub API key leak): SumSub secret under /etc/banxe-kyc/.env mode 600 per UNIVERSAL-CANON section 7; rotate per S17 90-day.
- R-MIG-VENDOR-01 (SumSub single-vendor): fallback adapter interface prevents lock-in for a regulatory-critical capability.

## Acceptance criteria

- banxe-kyc NEW repo scaffolded; SumSub DTOs + migrations migrated.
- KYCProviderPort defined; SumSubAdapter implemented; fallback adapter interface stubbed.
- Webhook reliability: DLQ + retry per ADR-034; signature verification on handleWebhook.
- banxe-baas + banxe-open-banking switched to KYCProviderPort; no inline KYC code remains.
- Every KYC status change persisted to guardian_audit_events with correlationId.
- R-REG-02 marked CLOSED in RISK_REGISTER refresh.
- All five ADR-021 ports now have dedicated SPECs (WalletPort #1, ExchangePort #4, PartnerPort #5, CRMPort #6, KYCProviderPort #8) + candidate NotificationPort #3.

## Open questions

- Should partner-level KYC (B2B) be a separate PartnerKYCPort, or a mode flag on KYCProviderPort? Owner: Architecture WG + MLRO.
- Which fallback KYC provider: Vouched, Onfido, or domestic FR/EU equivalent? Owner: Compliance + Procurement.
- Does Travel Rule v2 KYC data exchange (IVMS101) live in banxe-kyc or crypto-ops-monitor? Owner: Compliance + Architecture WG.
- Does banxe-kyc need its own 5y-retention table for CASS 15 / AMLD evidence, or shares guardian_audit_events? Owner: MLRO + SRE.

## References

- ADR-021 five-new-ports (KYCProviderPort — 5th port, now dedicated)
- ADR-028 KYC re-verification triggers
- ADR-034 webhook reliability KYC (DLQ + retry)
- ADR-019 GraphQL migration
- SPEC #5 emi-banking-services (KYC was inline; this SPEC extracts it)
- SPEC #7 crypto-ops-subgroup (Travel Rule consumer of KYC status)
- CLASS_KEEP.tsv (KYC was within banxe-baas KEEP-FULL row)
- RISK_REGISTER-2026-05-22.md (R-REG-02, R-REG-03)
- BANXE-LEGACY-REFACTOR-INDEX-2026-05-25.md (this SPEC #8 fills the KYCProviderPort gap noted in the index)
- UNIVERSAL-CANON-2026-05-22 + TOPOLOGY-CLARIFICATION + BEST-SOLUTION-AND-SEQUENTIAL (House rules 1-12 + worktree-isolation)

=== END OF KYCProviderPort SPEC (SPEC #8; all 5 ADR-021 ports now have dedicated SPECs) ===
