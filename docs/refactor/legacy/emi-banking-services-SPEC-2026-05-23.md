# Refactor SPEC — EMI Banking Services consolidation

Date: 2026-05-23
Status: SPEC (design baseline; impl owned by Terminal B per House rule 10)
Scope: cex/cex + cex/gql-cex + banxe-open-banking (x2) + banxe-baas + sepa-service -> banxe-open-banking + banxe-baas + banxe-sepa (production EMI core)
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/ on evo1
Related: ADR-020 VABS to OpenBanking; ADR-021 five-new-ports (PartnerPort + CRMPort); CLASS_KEEP.tsv KEEP-FULL rows; RISK_REGISTER R-REG-04 ACPR capital adequacy
Owner: Central authors SPEC; Terminal B owns impl

## Purpose

Specify smart refactor of six legacy KEEP-FULL banking services into three NEW production EMI core components (banxe-open-banking + banxe-baas + banxe-sepa). These are the regulated banking primitives required for ACPR EMI license submission. Without this consolidation, R-REG-04 (ACPR capital adequacy reporting) remains open and FCA submission (S24) cannot proceed.

## Legacy inventory (read-only audit 2026-05-23)

### 1. cex/cex (bare git, no worktree)

- Path: cex/cex
- Size: 4.0 KB (.git only; no source)
- Git history: nginx conf + networks commits — deployment config repo, not service
- Reuse target: DROP-FORENSIC (no production code recoverable)

### 2. cex/gql-cex (bare git, no worktree)

- Path: cex/gql-cex
- Size: 4.0 KB (.git only; no source)
- Git history: stable branch merges + PHP docker sockets
- Reuse target: DROP-FORENSIC (no production code recoverable)

### 3. banxe/banxe-open-banking (standalone, older)

- Path: banxe/banxe-open-banking
- Lang: TypeScript NestJS
- Size: 1.8 MB
- Pkg: banxe-open-banking v0.0.1
- abs-common lib coupling
- Git history: updated abs-common; fix import paths; swagger docs corrections
- Reuse target: DROP (superseded by fiat-backend copy)

### 4. banxe/banxe-fiat-backend/banxe-open-banking (in monorepo, production-ready)

- Path: banxe/banxe-fiat-backend/banxe-open-banking
- Lang: TypeScript NestJS
- Size: 1.4 MB
- Pkg: banxe-open-banking v0.0.1 (same name as #3, but in monorepo)
- Has ilink-console-tools + Consul integration (consul.banxe.com)
- Has ormconfig.json (TypeORM) + sumsub-local-sdk.html
- Git history: init phase, but production-ready due to Consul env management
- Reuse target: TRANSFORM (base for NEW banxe-open-banking)

### 5. banxe/banxe-fiat-backend/banxe-baas (Banking-as-a-Service)

- Path: banxe/banxe-fiat-backend/banxe-baas
- Lang: TypeScript NestJS
- Size: 2.4 MB
- Pkg: banxe-baas v0.0.1
- Has ormconfig.json (TypeORM) + sumsub-local-sdk.html (SumSub KYC integration)
- Modernised: "feature/remove-consul" merge — moved away from Consul env management
- Git history: partners controller route alias fix; remove-consul refactor
- Reuse target: TRANSFORM (base for NEW banxe-baas; production-ready)

### 6. banxe/sepa-service (SEPA payments rails)

- Path: banxe/sepa-service
- Lang: TypeScript NestJS + TypeORM
- Size: 1.8 MB
- Pkg: sepa-service v0.0.1
- Has migrations system (typeorm migration:generate/run)
- Has docker-compose.yaml + tool-versions (asdf)
- SECURITY CONCERN: has creds.dec / creds.enc in repo (encrypted secrets-in-tree)
- Active recent fixes: BN-2017 papaya issue, BN-2028 vulnerabilities, validation-address
- Reuse target: TRANSFORM (base for NEW banxe-sepa; remove creds.enc; rotate any leaked credentials)

## Decision per service

### cex/cex + cex/gql-cex: DROP-FORENSIC
- Bare git only; no recoverable source.
- Archive both .git dirs to BANXE.RAR mirror for forensic audit (5y retention per ADR-027).
- Re-classify in CLASS_KEEP.tsv from KEEP-FULL to DROP-FORENSIC (TSV correction note).

### banxe/banxe-open-banking (standalone): DROP
- Older copy; superseded by fiat-backend variant.
- abs-common lib coupling drops with consolidation.
- Archive only.

### banxe/banxe-fiat-backend/banxe-open-banking: TRANSFORM
- Base for NEW banxe-open-banking standalone repo.
- Drop Consul dependency (move to /etc/banxe-open-banking/.env mode 600 per UNIVERSAL-CANON section 7).
- Keep TypeORM + ormconfig pattern.
- Keep SumSub integration; consider unifying with NEW KYCProviderPort (ADR-021).
- Modernise to NestJS 10 + Node 18+.

### banxe-baas: TRANSFORM
- Base for NEW banxe-baas standalone repo.
- Consul already removed (good); use /etc/banxe-baas/.env mode 600.
- Keep partners controller pattern.
- Wire to PartnerPort (ADR-021) for upstream partner-bank integrations.

### sepa-service: TRANSFORM + SECURITY-REMEDIATION
- Base for NEW banxe-sepa standalone repo.
- IMMEDIATE: remove creds.dec / creds.enc from history (git-filter-repo); rotate any credentials decryptable from these files per S15.5 historical-leak runbook.
- Keep TypeORM migrations system.
- Keep docker-compose for local dev; modernise to NestJS 10.
- Wire to PartnerPort for SEPA payment partner (e.g. Modulr per S20 external blockers).

## Legacy to NEW mapping

| Legacy | NEW location | Verdict |
|---|---|---|
| cex/cex (bare) | (archive only) | DROP-FORENSIC |
| cex/gql-cex (bare) | (archive only) | DROP-FORENSIC |
| banxe/banxe-open-banking (standalone) | (archive only) | DROP |
| banxe-fiat-backend/banxe-open-banking | banxe-open-banking standalone NEW repo | TRANSFORM |
| banxe-fiat-backend/banxe-baas | banxe-baas standalone NEW repo | TRANSFORM |
| banxe/sepa-service | banxe-sepa standalone NEW repo | TRANSFORM + SEC-REMEDIATE |

## PartnerPort contract (per ADR-021)

```typescript
export type PartnerType = "open_banking" | "sepa" | "baas" | "card_acquiring";

export interface PartnerAccountId {
  partner: PartnerType;
  externalAccountId: string;
}

export interface PaymentInstruction {
  fromAccount: PartnerAccountId;
  toIban: string;
  amount: string;
  currency: string;
  reference: string;
  idempotencyKey: string;
}

export interface PaymentResult {
  status: "accepted" | "settled" | "rejected" | "pending";
  partnerTxId?: string;
  settledAt?: string;
  reason?: string;
}

export interface PartnerPort {
  initiatePayment(instruction: PaymentInstruction): Promise<PaymentResult>;
  getPaymentStatus(partnerTxId: string): Promise<PaymentResult>;
  reconcile(date: string): Promise<{ count: number; mismatches: number }>;
}
```

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + decisions per service (this SPEC).
- Phase B (Terminal B): scaffold NEW repos banxe-open-banking + banxe-baas + banxe-sepa; copy production-relevant code from fiat-backend variants.
- Phase C (Terminal B): implement PartnerPort interface; map each service as an adapter (OpenBankingAdapter, SepaAdapter, BaasAdapter); wire SumSub via KYCProviderPort.
- Phase D (Terminal B): contract tests against PartnerPort interface for all three adapters; shadow-mode reconciliation against legacy for 14 days.
- Phase E (Terminal B): cut legacy callers over to PartnerPort; remove legacy endpoints.
- Phase F (Terminal B): tag 6 legacy services ARCHIVE; record decommission in IL; submit FCA + ACPR evidence pack.

## Risk register tie-in

- R-MIG-02 (legacy on evo1 only): mirror all six legacy dirs to off-evo1 backup per R4 PREP.
- R-PRIV-03 (historical leaks) + R-SEC-NEW-04 (sepa-service creds.enc): immediately remove creds.enc/dec from history via git-filter-repo before any push of NEW banxe-sepa; rotate any decryptable credentials per S15.5.
- R-REG-04 (ACPR capital adequacy): banxe-baas + banxe-open-banking + banxe-sepa must provide single source of truth for client-money totals; tie reconcile() into ruflo_checkpoints (ADR-027) for CASS 15 5y retention.
- R-REG-01 (CASS 15 reconciliation failure): PartnerPort reconcile() output feeds banxe-recon (currently failed); revival of banxe-recon is a hard precondition for go-live.
- R-COMP-FCA-02 (audit trail for payments): every PartnerPort initiatePayment must persist to guardian_audit_events with idempotencyKey + correlationId for MLRO + FCA Section 4 evidence.

## Acceptance criteria

- 3 NEW repos (banxe-open-banking + banxe-baas + banxe-sepa) scaffolded with NestJS 10 + Node 18+ + TypeORM.
- PartnerPort interface defined; 3 adapters (OpenBankingAdapter, SepaAdapter, BaasAdapter) implemented; contract tests green.
- sepa-service creds.enc/dec removed from history; credentials rotated; secret moved to /etc/banxe-sepa/.env mode 600.
- Consul dependency removed from banxe-open-banking; /etc/banxe-open-banking/.env mode 600.
- SumSub integration unified via KYCProviderPort.
- Phase D shadow-mode complete: 0 mismatches on reconcile over 14 days.
- All non-test callers of legacy 6 services switched to PartnerPort.
- 6 legacy services tagged ARCHIVE; decommission in IL; CLASS_KEEP.tsv corrected (cex/cex + cex/gql-cex from KEEP-FULL to DROP-FORENSIC).

## Open questions

- Which SEPA partner at go-live: Modulr, ClearBank, or ClearJunction? Owner: CFO + Treasury.
- Which Open Banking provider primary: Plaid, TrueLayer, or domestic equivalent for FR/EU? Owner: Architecture WG.
- Does KYCProviderPort live in banxe-baas or as a separate banxe-kyc service? Owner: Architecture WG.
- Does SEPA Instant (SCT Inst) require a separate adapter or fits in SepaAdapter via a flag? Owner: Treasury.
- Does card acquiring belong in this SPEC or in a future Hyperswitch SPEC? Owner: Product.

## References

- ADR-020 VABS to Open Banking
- ADR-021 five-new-ports (PartnerPort + KYCProviderPort)
- ADR-027 audit-trail durability (CASS 15 5y)
- ADR-017 vendor-to-OpenSource policy
- REFACTOR_MASTER_PLAN.md
- CLASS_KEEP.tsv (6 KEEP-FULL rows; correction for cex/cex + cex/gql-cex)
- RISK_REGISTER-2026-05-22.md (R-REG-01 + R-REG-04 + R-PRIV-03)
- S15.5 historical-leak runbook (for sepa-service creds remediation)
- S20 external blockers (Modulr appointment)
- UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md (House rule 10)
- UNIVERSAL-CANON-BEST-SOLUTION-AND-SEQUENTIAL-2026-05-23.md (House rules 11 + 12)

=== END OF EMI Banking Services SPEC (snapshot 4ca0eef) ===

## NEW capability anchor (per NEW-PROJECT-PRIORITY-MAP canon)

Serves NEW capabilities C3 (fiat payment rails: SEPA, Open Banking) + C4 (Banking-as-a-Service: account issuance) per ADR-020 + PartnerPort. Canon: NEW drives legacy reuse — banxe-open-banking + banxe-baas + sepa-service are reused only because C3/C4 are EMI-licence-mandatory; cex/cex + cex/gql-cex (bare) and the older standalone banxe-open-banking are anti-mapped (DROP/DROP-FORENSIC, no NEW capability). KYC inside banxe-baas serves C5 and is extracted in SPEC #8. No decision change; NEW-need-first justification confirmed.
