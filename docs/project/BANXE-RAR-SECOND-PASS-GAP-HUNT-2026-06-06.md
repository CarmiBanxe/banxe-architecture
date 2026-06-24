# BANXE.RAR Second-Pass Gap Hunt

Date: 2026-06-06
Status: PROPOSED (forensic review plan; does not modify existing roadmap or IL)
Source: DELTA-ANALYSIS-LEGACY-REFACTOR-vs-CURRENT-ROADMAP.md, SPRINT-EXTENSION-LEGACY-REFACTOR-S12-S17.md, BANXE-LEGACY-REFACTOR-INDEX-2026-05-25.md, 9 contract/group SPECs in docs/refactor/legacy/

## Status

This is a second-pass forensic review plan. The first wave (Phase A) achieved 24/24 KEEP-row coverage via 7 SPECs and produced 6 contract SPECs on 2026-06-06. That wave was architecturally sound but explicitly scoped to CLASS_KEEP.tsv only. Four additional classification files (TRANSFORM 99 rows, PORT 22, MERGE 15, REVIEW 69, TAIL 39) remain uninventoried. R0-DISCOVERY unverified claims from the delta analysis are still open.

## Why this pass is needed

New capability requirements surfaced after the first refactor wave. The UNVERIFIED-CLAIMS-LEGACY-DISCOVERY.md deliverable does not yet exist. KYCProviderPort remains inline in SPEC #5 without its own dedicated SPEC. CLASS_TRANSFORM.tsv alone has 99 rows with no Phase A inventory pass. Until these areas are forensically verified, completeness of the smart refactor is asserted but not proven.

## Audit questions

1. What important legacy capabilities may still be missed by the 7+6 existing SPECs?
2. What additional reusable assets can still be extracted from BANXE.RAR beyond the 24 KEEP rows?
3. Is the smart refactor conceptually correct but still incomplete in coverage?

## Gap-hunt dimensions

### Hidden capabilities
Look for runtime services, cron jobs, scheduled tasks, or background workers in legacy projects that were classified but never inventoried at function level. Priority targets: the 99 TRANSFORM rows and 69 REVIEW rows where no SPEC exists.

What to look for:
- Background job definitions (Bull queues, node-cron, systemd timers, PM2 ecosystem configs).
- WebSocket or SSE endpoints that provide real-time data to frontends (trading tickers, notification streams).
- Internal RPC services not exposed via public API but consumed by other legacy projects.

### Ops and backoffice flows
Search for admin panels, operator dashboards, internal tooling, manual override scripts, and batch-processing pipelines. These often exist outside the main application codebase (shell scripts, Python notebooks, standalone Node services) and are easy to miss during architecture-level inventory.

What to look for:
- Admin/backoffice routes in Express/Koa/NestJS apps (e.g., /admin/*, /internal/*).
- Manual reconciliation scripts (CSV import/export, balance correction tools).
- Operator override endpoints (force-approve, manual KYC override, fee waiver).

### Compliance and evidence paths
Identify audit trail generators, regulatory report exporters, FCA/MLRO evidence collectors, transaction monitoring rule engines, and SAR filing workflows. These are compliance-critical even if they have no user-facing surface. Cross-reference against ADR-027 (audit trail 5y) and ADR-036 (Travel Rule).

What to look for:
- SAR/STR report generation logic and templates.
- Travel Rule data enrichment and VASP message handlers.
- Sanctions screening integration code (beyond SumSub KYC — transaction-level screening).

### Orchestration and automation artifacts
Look for CI/CD pipelines, deployment scripts, infrastructure-as-code (Terraform, Ansible, Docker Compose overrides), migration runners, and seed-data generators that the legacy system depended on but that were not carried into the NEW architecture.

What to look for:
- Docker Compose files that define service topology and startup order not captured in NEW.
- Database migration scripts (Sequelize, Knex, Alembic) with business-logic-bearing seed data.
- Makefile or shell-based release automation that encodes deployment invariants.

### Runtime-only but concept-critical assets
Identify environment variables, feature flags, configuration files, and runtime constants that encode business logic (e.g., fee schedules, rate limits, tier thresholds). These are invisible in source-code-only inventory but define system behavior.

What to look for:
- .env files or config modules that hard-code fee tiers, withdrawal limits, or KYC level thresholds.
- Feature flag definitions (LaunchDarkly, Unleash, or custom) that gate compliance-sensitive features.
- Rate-limit and throttle configs that implement regulatory or contractual SLA requirements.

### Vendor lock-in still hiding in legacy
Search for direct SDK integrations (Paymentology, SumSub, Binance, BitShares) where the legacy code bypasses the hexagonal port pattern. Confirm whether ADR-021 ports fully abstract every vendor dependency or if some remain hard-wired.

What to look for:
- Direct `require()/import` of vendor SDKs outside adapter boundaries (Paymentology, Binance, BitShares).
- Hard-coded vendor API base URLs or auth tokens in application code rather than config.
- Vendor-specific data models leaking into domain entities (e.g., Paymentology card schema in core types).

### Extractable reusable libraries still not isolated
Look for shared utility code (crypto primitives, HTTP clients, validation helpers, serialization layers) that multiple legacy projects import but that was not promoted to a standalone @banxe/ package in the refactor SPECs.

What to look for:
- Common utility folders (lib/, utils/, shared/) duplicated across multiple legacy projects.
- Internal npm packages or symlinks in the monorepo that indicate shared library intent.
- Crypto address validation, IBAN formatting, or currency conversion helpers used by 3+ projects.

## Evidence model

Each finding should be recorded in this schema:

| Legacy artifact | Evidence type | Why it matters | Existing NEW mapping | Gap status | Recommended action |
|---|---|---|---|---|---|
| (path or module name) | code / config / script / doc | (business or compliance rationale) | (NEW component or port, if any) | COVERED / PARTIAL / MISSING | extract / archive / defer / new-SPEC |

## Completeness criteria

**Smart refactor complete enough:** all CLASS_KEEP + CLASS_TRANSFORM + CLASS_PORT rows have a SPEC or explicit archive decision; every ADR-021 port has a dedicated contract SPEC (including KYCProviderPort); no unverified claims remain from the delta analysis section 3; compliance-critical artifacts confirmed covered by at least one NEW component.

**Architecturally correct but still incomplete:** hexagonal port model is sound and all 5+1 ports are defined, but coverage gaps exist in TRANSFORM/PORT/MERGE/REVIEW/TAIL classifications; vendor lock-in persists in at least one integration; ops/backoffice flows have no NEW owner; KYCProviderPort still inline.

## Expected outputs

1. Updated gap list with per-row status for CLASS_TRANSFORM (99), CLASS_PORT (22), CLASS_MERGE (15), CLASS_REVIEW (69), CLASS_TAIL (39).
2. Newly discovered capability IDs if legacy artifacts reveal functions not captured by existing classifications.
3. Updated roadmap deltas (additive R-track extensions or new sub-sprints if warranted).
4. Candidates for new SPECs (e.g., KYCProviderPort standalone SPEC #8, ops-tooling SPEC, compliance-evidence SPEC).
5. Candidates for archive-only classification (legacy code with forensic value but no runtime role in NEW).
6. Verified or falsified status for all 7 unverified claims from delta analysis section 3.

## Decision rules

- Do not create new repos unless a reusable boundary is proven by multiple consumers.
- Do not copy legacy code 1:1; Transform-first canon applies (REFACTOR_MASTER_PLAN.md).
- Extract only if the artifact is reusable across two or more NEW components or compliance-critical.
- Archive if forensic or audit value exists but no runtime role remains in the NEW architecture.
- Defer to ADR process for any architectural decision that changes the port model or adds new bounded contexts.

## Next step

Findings from this second pass will be recorded in:
**docs/project/BANXE-RAR-SECOND-PASS-FINDINGS-2026-06-06.md**

That document will use the evidence model table above and produce actionable inputs for roadmap amendment.
