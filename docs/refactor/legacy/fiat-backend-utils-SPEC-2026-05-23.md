# Refactor SPEC — fiat-backend utilities consolidation

Date: 2026-05-23
Status: SPEC (design baseline; impl owned by Terminal B per House rule 10)
Scope: banxe-referrers + files-api + banxe-circuit-breaker + banxe-tariff + node-clickhouse -> CRMPort + banxe-files + @banxe/circuit-breaker + banxe-tariff + upstream clickhouse client
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/ on evo1
Related: ADR-021 five-new-ports (CRMPort); ADR-019 GraphQL migration; CLASS_KEEP.tsv KEEP-EXTRACT rows; SPEC #5 EMI Banking Services (consul pattern)
Owner: Central authors SPEC; Terminal B owns impl

## Purpose

Specify smart refactor of five legacy fiat-backend utility services into four NEW components: a CRMPort implementation (referrers), a standalone S3 file service (banxe-files), a shared circuit-breaker library (@banxe/circuit-breaker), a standalone tariff service (banxe-tariff), plus a vendor-to-OSS replacement for the node-clickhouse fork. These utilities support the EMI core (banxe-baas, banxe-open-banking, banxe-sepa from SPEC #5) and Trading (banxe-trading-backend from SPEC #4) without being part of either bounded context.

## Legacy inventory (read-only audit 2026-05-23)

### 1. banxe-fiat-backend/banxe-referrers (referral programme)

- Path: banxe/banxe-fiat-backend/banxe-referrers
- Lang: TypeScript NestJS + TypeORM (generate-ormconfig.ts, migrations/)
- Size: 2.1 MB
- Pkg: banxe-referrers v0.0.8
- Consul env coupling (consul.banxe.com); ilink-console-tools
- GraphQL: schema.graphql present (ADR-019 implication)
- Git history: feature/consul_host_update merge; rc version 0.0.8
- Role: referral programme tracking
- Reuse target: TRANSFORM into CRMPort implementation (CRM domain)

### 2. banxe-fiat-backend/files-api (S3 file service)

- Path: banxe/banxe-fiat-backend/files-api
- Lang: TypeScript NestJS
- Size: 1.8 MB
- Pkg: files-api v0.0.8
- Consul + Dockerfile + docker-compose + docker-entrypoint.sh + curl-samples
- Has files_api.agc (Argo workflow config?)
- Git history: file_extension bug fix, recent feat updates
- Role: S3 file upload service
- Reuse target: TRANSFORM into standalone banxe-files (NEW S3 service)

### 3. banxe-fiat-backend/banxe-circuit-breaker (shared resilience pattern)

- Path: banxe/banxe-fiat-backend/banxe-circuit-breaker
- Lang: TypeScript NestJS + tests
- Size: 1.5 MB
- Pkg: banxe-circuit-breaker v0.0.8
- Consul env coupling
- Git history: update_logs feature; TODO delete; save request
- Role: cross-service circuit-breaker (resilience pattern wrapper)
- Reuse target: TRANSFORM into shared library @banxe/circuit-breaker (monorepo package, not standalone service)

### 4. banxe-fiat-backend/banxe-tariff (pricing/fees)

- Path: banxe/banxe-fiat-backend/banxe-tariff
- Lang: TypeScript NestJS
- Size: 1.4 MB
- Pkg: banxe-tariff v0.0.10
- Consul env coupling
- GraphQL: schema.graphql + example.graphql (ADR-019 implication)
- Git history: graphql documentation; rc version 0.0.10
- Role: tariff/fees service for EMI products
- Reuse target: TRANSFORM into standalone banxe-tariff (NEW pricing service)

### 5. crypto-api/node-clickhouse (OSS clickhouse client fork)

- Path: crypto-api/node-clickhouse
- Lang: plain JS (npm package mirror)
- Size: 112 KB
- Pkg: clickhouse v1.2.17 (mirror of npm clickhouse package)
- Git history: port settings fix; body rewrite fix; query to body
- Role: ClickHouse client SDK fork (minor bug fixes only)
- Reuse target: DROP fork; use upstream @clickhouse/client (official, modern SDK)

## Decision per service

### banxe-referrers: TRANSFORM-INTO-CRMPort-impl
- Base for CRMPort adapter (ReferralCRMAdapter).
- Drop Consul; move to /etc/banxe-crm/.env mode 600.
- Drop GraphQL coupling per ADR-019 (Apollo to Hasura).
- Keep TypeORM migrations system.
- Modernise to NestJS 10 + Node 18+.

### files-api: TRANSFORM-INTO-banxe-files
- Base for standalone banxe-files (S3 file service).
- Drop Consul; move to /etc/banxe-files/.env mode 600.
- Keep Dockerfile + docker-compose patterns.
- Review files_api.agc (Argo coupling); replace with Kubernetes Job or systemd service if not needed.
- Modernise to NestJS 10 + Node 18+.

### banxe-circuit-breaker: TRANSFORM-INTO-LIBRARY
- Convert from standalone service to shared @banxe/circuit-breaker NPM package (monorepo).
- Drop Consul + NestJS wrapper; expose pure circuit-breaker library API.
- Consumed by every NEW service via npm dependency.
- Tests preserved.

### banxe-tariff: TRANSFORM-INTO-banxe-tariff
- Base for standalone banxe-tariff (pricing/fees service).
- Drop Consul; move to /etc/banxe-tariff/.env mode 600.
- Drop GraphQL coupling per ADR-019.
- Modernise to NestJS 10 + Node 18+.

### node-clickhouse: DROP
- OSS fork with minor fixes; upstream @clickhouse/client v1.x is modern, audited, official.
- Replace in every NEW service that needs ClickHouse access.
- Tag fork ARCHIVE for forensic only.

## Legacy to NEW mapping

| Legacy | NEW location | Verdict |
|---|---|---|
| banxe-referrers | banxe-crm standalone NEW repo (CRMPort adapter) | TRANSFORM |
| files-api | banxe-files standalone NEW repo | TRANSFORM |
| banxe-circuit-breaker | @banxe/circuit-breaker (shared lib in monorepo) | TRANSFORM-LIB |
| banxe-tariff | banxe-tariff standalone NEW repo | TRANSFORM |
| node-clickhouse (fork) | @clickhouse/client (upstream) | DROP |

## CRMPort contract (per ADR-021)

```typescript
export type CRMUserId = string;
export type ReferralCode = string;

export interface ReferralEvent {
  referrer: CRMUserId;
  referee: CRMUserId;
  code: ReferralCode;
  occurredAt: string;
  metadata?: Record<string, unknown>;
}

export interface CRMUser {
  userId: CRMUserId;
  tier?: string;
  attributes?: Record<string, unknown>;
}

export interface CRMPort {
  registerReferral(event: ReferralEvent): Promise<{ accepted: boolean; reason?: string }>;
  resolveReferralCode(code: ReferralCode): Promise<CRMUserId | null>;
  getUser(userId: CRMUserId): Promise<CRMUser | null>;
  updateUserTier(userId: CRMUserId, tier: string): Promise<void>;
}
```

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + decisions (this SPEC).
- Phase B (Terminal B): scaffold 3 standalone NEW repos (banxe-crm, banxe-files, banxe-tariff) + 1 monorepo lib (@banxe/circuit-breaker).
- Phase C (Terminal B): implement CRMPort + ReferralCRMAdapter; migrate file upload logic + tariff GraphQL-free REST endpoints; extract circuit-breaker pure-library API.
- Phase D (Terminal B): contract tests for CRMPort; integration tests for banxe-files against MinIO/S3 emulator; tariff service contract tests; circuit-breaker unit tests.
- Phase E (Terminal B): cut legacy callers across NEW EMI services to use the 4 new components; replace node-clickhouse imports with @clickhouse/client.
- Phase F (Terminal B): tag 5 legacy services ARCHIVE; record decommission in IL.

## Risk register tie-in

- R-MIG-02 (legacy on evo1 only): mirror all five legacy dirs to off-evo1 backup per R4 PREP.
- R-PRIV-02 (GDPR Art. 15-17): banxe-files must support recipient-level redaction on SAR; ensure S3 lifecycle policy aligned with GDPR retention.
- R-COMP-FCA-03 (referral programme audit): CRMPort.registerReferral persisted to guardian_audit_events with correlationId for MLRO + Section 4 evidence.
- R-OPS-CONSUL-01 (Consul EOL): four out of five services share Consul coupling that ends with this SPEC; final removal of Consul from NEW dependency tree closes a recurring operational risk.

## Acceptance criteria

- 3 NEW standalone repos scaffolded (banxe-crm, banxe-files, banxe-tariff) on NestJS 10 + Node 18+.
- @banxe/circuit-breaker NPM package published in NEW monorepo, used by at least 2 other NEW services.
- CRMPort interface defined; ReferralCRMAdapter implemented; contract tests green.
- node-clickhouse fork removed from every NEW dependency tree; replaced by @clickhouse/client.
- Consul coupling removed from all four NestJS NEW services; .env mode 600 pattern applied.
- 5 legacy services tagged ARCHIVE; decommission in IL.

## Open questions

- Should banxe-crm be a single CRM service (referrals + future loyalty + segmentation), or one repo per CRM concern? Owner: Product + Architecture WG.
- Does banxe-files need multi-region S3 replication for CASS 15 evidence packs, or single-region acceptable? Owner: SRE + MLRO.
- Should banxe-tariff expose pricing only, or also enforce limits (KYC tier-dependent fee waivers, etc.)? Owner: Treasury + Product.
- Where does @banxe/circuit-breaker live: dedicated public npm package, internal npm registry, or git submodule? Owner: Architecture WG.

## References

- ADR-021 five-new-ports (CRMPort)
- ADR-019 GraphQL migration (Apollo to Hasura — drops GraphQL coupling in 3 of 5 legacy)
- ADR-017 vendor-to-OpenSource policy (node-clickhouse fork drop)
- REFACTOR_MASTER_PLAN.md
- CLASS_KEEP.tsv (5 KEEP-EXTRACT rows: referrers, files-api, circuit-breaker, tariff, node-clickhouse)
- RISK_REGISTER-2026-05-22.md (R-MIG-02, R-PRIV-02)
- SPEC #5 emi-banking-services (Consul pattern reference)
- UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md (House rule 10)
- UNIVERSAL-CANON-BEST-SOLUTION-AND-SEQUENTIAL-2026-05-23.md (House rules 11 + 12)

=== END OF fiat-backend utilities SPEC (snapshot 4ca0eef) ===

## NEW capability anchor (per NEW-PROJECT-PRIORITY-MAP canon)

This SPEC is re-anchored from legacy-folder grouping to NEW-capability service (canon: NEW drives legacy reuse):
- C10 (Referral / CRM) <- banxe-referrers (via CRMPort)
- C11 (Tariff / fees) <- banxe-tariff
- C12 (File / document service) <- files-api (via banxe-files)
- C13 (Resilience / circuit breaker) <- banxe-circuit-breaker (as @banxe/circuit-breaker lib)
- node-clickhouse fork serves NO standalone NEW capability -> DROP (use upstream @clickhouse/client), per anti-map.

Rationale: the five legacy projects were originally grouped because they live in the banxe-fiat-backend folder (legacy-driven). Under the NEW-priority canon they are grouped because they each serve a distinct NEW capability C10-C13 (the node-clickhouse fork is anti-mapped). No decision in this SPEC changes; only the justification is corrected to NEW-need-first.
