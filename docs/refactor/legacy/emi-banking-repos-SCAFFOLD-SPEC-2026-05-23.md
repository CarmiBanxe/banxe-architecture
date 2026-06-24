# EMI Banking Repos Scaffold SPEC

Date: 2026-05-23
Status: SPEC (execution-facing scaffold companion)

## Status

This document is the execution-facing scaffold companion to `emi-banking-services-SPEC-2026-05-23.md`. It translates service-level decisions into concrete repo boundaries and internal structure for Terminal B implementation.

## Goal

Define the initial repo boundaries, internal directory layout, and PartnerPort allocation for the three NEW repos: `banxe-open-banking`, `banxe-baas`, and `banxe-sepa`. This file is the single reference Terminal B uses to scaffold Phase B.

## Shared stack

All three repos share:
- **Runtime:** Node 18+ / NestJS 10
- **ORM:** TypeORM (ormconfig pattern carried from legacy)
- **Testing:** contract-test-first PartnerPort discipline; adapter conformance tests
- **Secrets:** `/etc/<repo-name>/.env` mode 600 — no Consul, no creds.enc/dec in tree
- **Audit:** every state-changing operation persists to `guardian_audit_events` with `idempotencyKey` + `correlationId` (ADR-027, CASS 15 5y retention)
- **Event persistence:** all domain events written to append-only audit log before acknowledgement

## Repo boundaries

### banxe-open-banking

- **Purpose:** Account information services and PSD2/Open Banking connectivity for FR/EU markets.
- **What belongs inside:** OpenBankingAdapter (PartnerPort impl), account information retrieval, consent management, webhook ingestion from Open Banking providers, audit evidence persistence.
- **What must stay outside:** Payment initiation (owned by banxe-sepa for SEPA, or future card-acquiring spec), KYC/SumSub logic (see banxe-baas), direct partner SDK imports outside `adapters/`.
- **Primary adapter role:** OpenBankingAdapter — implements PartnerPort for account-information and provider-agnostic Open Banking access.
- **Persistence:** TypeORM entities for account links, consent records, provider tokens. Migrations via `typeorm migration:generate/run`.
- **Audit/logging:** All consent grants/revocations and account-data retrievals persisted to `guardian_audit_events`.

### banxe-baas

- **Purpose:** Banking-as-a-Service orchestration — partner bank integrations, beneficiary/payee handling, KYC provider unification.
- **What belongs inside:** BaasAdapter (PartnerPort impl), partners controller, beneficiary/payee CRUD, KYCProviderPort integration (SumSub), reconciliation feed production.
- **What must stay outside:** Direct SEPA payment rails (owned by banxe-sepa), Open Banking consent flows (owned by banxe-open-banking), raw partner SDK calls outside `adapters/`.
- **Primary adapter role:** BaasAdapter — implements PartnerPort for upstream partner-bank operations and beneficiary management.
- **Persistence:** TypeORM entities for partner accounts, beneficiaries, KYC verification records. Migrations carried from legacy banxe-baas.
- **Audit/logging:** All partner-bank instructions and beneficiary mutations persisted to `guardian_audit_events`.

### banxe-sepa

- **Purpose:** SEPA payment rails — SCT and potentially SCT Inst — for EUR payment initiation, status tracking, and reconciliation.
- **What belongs inside:** SepaAdapter (PartnerPort impl), payment initiation, payment status polling, SEPA-specific validation (IBAN, BIC), reconciliation feed, migration system.
- **What must stay outside:** Account information (owned by banxe-open-banking), beneficiary management (owned by banxe-baas), any `creds.enc`/`creds.dec` files (removed per S15.5).
- **Primary adapter role:** SepaAdapter — implements PartnerPort for SEPA payment initiation and reconciliation.
- **Persistence:** TypeORM entities for payment instructions, settlement records, reconciliation snapshots. Migrations carried from legacy sepa-service.
- **Audit/logging:** Every `initiatePayment` call persisted to `guardian_audit_events` with full PaymentInstruction payload. Settlement status changes logged as separate audit events.

## Proposed internal layout

Layout applies to all three repos with minor per-repo adaptation:

```
src/
  partner-port/          # PartnerPort interface + types (shared contract)
  adapters/              # Partner-specific adapter (one per repo)
  application/           # Use-case services, orchestration
  domain/                # Entities, value objects, domain events
  infra/                 # TypeORM config, migrations, env loading
  audit/                 # guardian_audit_events persistence module
  tests/
    contract/            # PartnerPort contract tests
    adapter/             # Adapter conformance tests
    integration/         # DB + migration safety tests
docker-compose.yaml      # Local dev (Postgres + service)
ormconfig.json           # TypeORM configuration
```

banxe-baas adds `src/kyc/` for KYCProviderPort integration. banxe-sepa adds `src/validation/` for IBAN/BIC validation logic.

## PartnerPort allocation

| Capability | Canonical repo | Adapter | Notes |
|---|---|---|---|
| Account information | banxe-open-banking | OpenBankingAdapter | PSD2 AISP flows |
| Payment initiation | banxe-sepa | SepaAdapter | SCT + SCT Inst (flag TBD) |
| Beneficiary/payee handling | banxe-baas | BaasAdapter | CRUD + screening |
| Reconciliation feed | All three | Each adapter's `reconcile()` | Output feeds banxe-recon |
| Webhook/event ingest | banxe-open-banking | OpenBankingAdapter | Provider callback handling |
| Audit evidence persistence | All three | `audit/` module | guardian_audit_events table |

## Cross-repo rules

1. **Single source of truth for client-money totals:** banxe-baas owns the canonical client-money ledger; banxe-open-banking and banxe-sepa report positions into it.
2. **Reconciliation:** every adapter's `reconcile()` output feeds `banxe-recon` (R-REG-01 precondition). Reconciliation snapshots are checkpoint-persisted via ruflo_checkpoints (ADR-027).
3. **Audit persistence:** all `guardian_audit_events` rows must include `idempotencyKey` + `correlationId`. No event is acknowledged before persistence completes.
4. **No secrets in tree:** no `creds.enc`, `creds.dec`, or decrypted secret files. All secrets via `/etc/<repo>/.env` mode 600.
5. **No partner SDK sprawl:** direct partner SDK usage confined to `adapters/` directory. Application and domain layers depend only on PartnerPort interface.

## Testing

- **Contract tests:** each repo must have PartnerPort contract tests that validate the adapter against the canonical interface. Tests run against a stub and against a sandboxed partner environment.
- **Adapter conformance tests:** verify that each adapter correctly maps partner-specific responses to `PaymentResult` status values.
- **Migration safety checks:** integration tests confirm TypeORM migrations run cleanly on a fresh DB and produce schema parity with the legacy system where applicable.

## Exit criteria

- [ ] Three repos created with the internal layout above.
- [ ] PartnerPort interface defined in `src/partner-port/` of each repo.
- [ ] One adapter per repo implementing PartnerPort; contract tests green.
- [ ] TypeORM migrations ported from legacy where applicable; `migration:run` succeeds on clean DB.
- [ ] No `creds.enc`/`creds.dec` in any repo history (git-filter-repo confirmed for banxe-sepa).
- [ ] `docker-compose up` starts each service locally with Postgres.
- [ ] `guardian_audit_events` persistence module functional with idempotencyKey + correlationId.
- [ ] Secrets loaded from `/etc/<repo>/.env` mode 600; no Consul dependency.

## Next phase

After scaffold is validated, proceed to: `emi-banking-partnerport-CONTRACT-SPEC-2026-05-23.md` — defines the full PartnerPort contract test suite, adapter mapping rules, and shadow-mode reconciliation protocol (Phase C-D).
