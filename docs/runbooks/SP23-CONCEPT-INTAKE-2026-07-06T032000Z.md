# SP23 — BANXE concept v7-v9 intake (5 internal concept docs)

**Terminal:** B (spec-projects lane; ADR-159 §Terminal-B-Operating-Algorithm)
**Branch:** `agent/specproj/sp23/banxe-concept-v7v9-intake` (ADR-060 compliant)
**Worktree:** `~/wt/agent-specproj-sp23-banxe-concept-v7v9-intake` (ADR-120 isolation, off origin/main)
**Intake timestamp (UTC):** 2026-07-06T03:20:00Z
**Corpus SHA (`origin/main`):** 8d2a462
**Passes:** 3 (multi-pass read of 12 concept sections across 5 internal BANXE docs)
**Sections covered:** 12 / 12
**Outcome:** MIXED (Outcome-1 findings + Outcome-2 coverage)
**ADR anchors:** ADR-159 (Terminal-B algorithm), ADR-060 (branch-name gate), ADR-120 (worktree isolation), ADR-119/ADR-133/ADR-143 (ledger discipline), ADR-138 (PAYBIS sole crypto), ADR-013 (Midaz PRIMARY / Fineract FALLBACK)

---

## 1. Source (internal, not external stack-review)

Five internal BANXE strategic-concept documents forming the current internal plan for EMI BANXE AI BANK:

- **v7 Part2** — foundation model / roadmap S9-S12 alignment
- **v7 Part3** — Intent Layer / Decision Lineage / Business Process Repository (S13-00)
- **v8 Part4** — CFO-swarm 22-agent organogram + Compliance Intelligence Stack
- **v9 Part3** — KYC/AML expansion (Ballerine, Jube, Marble, Sumsub, OpenSanctions, SpiderFoot/GDELT, Tor OSINT, FINOS OpenAML)
- **v9 Part4** — payments/BIN + crypto/MiCA + UI/UX + FCA-path stack

**Key framing per operator (ADR-159 §algorithm + full-coverage-mandate + operator prompt):**

- These are **our own concept/plan**, not an external OSS review. The expected outcome is **predominance of coverage/dup** (our plan already exists as governance, ADRs, souls, dossier). NEW is emitted **only for items genuinely absent from the corpus and the 71 findings baseline** (PR #1051 30 + PR #1059 41).
- **Scope gates:** TOMPAY = UK EMI (e-money) → credit/lending/investment/trading OUT-OF-SCOPE (require distinct FCA authorisation). Any Lending 2027 / SME alt-credit-scoring / BNPL / invoice-finance item → `credit-BLOCKED`, verdict = reject, handoff = `B-EMI-CREDIT-GATE-001`.
- **Crypto scope:** Banxe crypto is white-labelled through **PAYBIS** per ADR-138 (Neuronext retired). Crypto-provider candidates (Fireblocks / Chainalysis CE / Erigon nodes) → PAYBIS-scope, reject / reference-only.

No long quotations; item-level names + one-line rationale in operator's own words (copyright discipline).

## 2. Coverage checklist — 12 concept sections

| # | Section | Read | Candidates | Coverage in corpus / 71-findings | NEW rows | credit-BLOCKED |
|---|---------|------|-----------:|:---------------------------------|---------:|---------------:|
| 1 | Financial model / unit economics (base 2026-2030, LTV/CAC, capex/opex, funding) | ✅ | 1 (plan-level) | `governance/GLOBAL-PROGRAM-PLAN.md` (own plan) | 0 | 0 |
| 2 | Roadmap sprints S9-S12 + ADR-015 / ADR-035 / ADR-036 / ADR-040 | ✅ | 4 (ADR-shaped) | `decisions/ADR-015-payment-processing-stack.md`, `decisions/ADR-035-ci-smoke-gate-policy.md`, `decisions/ADR-036-travel-rule.md`, `docs/adr/ADR-040-ai-execution-policy.md` (all present) | 0 | 0 |
| 3 | CI/CD quality-gates + monitoring (Prometheus / Grafana / ClickHouse / OpenSearch) | ✅ | 5 | `.claude/rules/infrastructure.md`, `SERVICE-MAP.md`, `agents/souls/clickhouse-writer.md`, `.githooks/pre-push`, `scripts/dora-collect.sh`, `scripts/factory-report.sh` | 0 | 0 |
| 4 | Intent Layer / Decision Lineage Schema / Business Process Repository (S13-00) | ✅ | 3 | `docs/adr/ADR-045-intent-first-banking-architecture.md`, `docs/adr/ADR-046-decision-lineage-schema.md`, `docs/adr/ADR-048-business-process-repository.md` — all DONE + `governance/{business-process,decision-lineage}/README.md` | 0 | 0 |
| 5 | CFO-swarm (22 agents: GL Close / IFRS / AP-AR / Treasury / Reg Reporting / Finance BI) | ✅ | ≈22 | `agents/souls/` cohort4-6 governor SOULs (Data / Dev-Platform / Reporting) + `ledger/entries/agent-factory-sprint6-cfo-deep-build/` + `governance/SPRINT-5-INTERNAL-AUDIT-LINE.md` + `docs/FINANCE-BLOCK-ROLES.md` | 0 | 0 |
| 6 | KYC/AML: Ballerine / Jube / Marble / Sumsub / OpenSanctions / SpiderFoot / GDELT / Tor OSINT (OnionSearch / TorBot / Reputell) / FINOS OpenAML | ✅ | 10 | Ballerine=`COMPLIANCE-ARCH.md`+`SRC-01`; Jube=`agents/souls/jube-adapter-core.md`+ADR-004; Marble=ADR-005; Sumsub=`MASTER-ORG-CODE-RUNTIME-DOSSIER.md`+BT-004; OpenSanctions/Yente=ADR-009+souls; FINOS-OpenAML=`ROADMAP.md` OSS-Sumsub-replacement block | 5 (SpiderFoot, GDELT, OnionSearch, TorBot, Reputell) | 0 |
| 7 | Core banking: Midaz / Apache Fineract / Formance / Blnk / Jenesto / SDK.finance | ✅ | 6 | Midaz/Fineract=ADR-013 (Midaz PRIMARY, Fineract FALLBACK); Formance/Blnk=`agents/souls/*-agent.md` + dossier | 2 (Jenesto, SDK.finance — both `reject`, ADR-013 already selects primary/fallback) | 0 |
| 8 | Workflow: FINOS Fluxnova / Temporal / n8n + Compliance Intelligence Stack | ✅ | 3 | Fluxnova=`docs/FINANCE-BLOCK-OSS-STACK.md` + `agents/swarms/monthly-fca-return.yaml` + `docs/FINANCE-BLOCK-ROLES.md`; Temporal=infrastructure canon; n8n=`.claude/rules/infrastructure.md` | 0 | 0 |
| 9 | Payments / BIN: Hyperswitch / Paymentology / Transact Pay / Paynetics / Modulr / Tribe | ✅ | 6 | Hyperswitch=ADR-013/015+SERVICE-MAP :8096-8098; Paymentology=`MASTER-ORG-CODE-RUNTIME-DOSSIER.md` GAP-074+BT-006; Modulr=BT-001 | 3 (Paynetics, Transact Pay, Tribe — BIN-sponsor diversification, GAP-074) | 0 |
| 10 | Crypto / MiCA: Fireblocks / Chainalysis CE / FINOS OpenAML / Erigon blockchain nodes | ✅ | 4 | Chainalysis=`COMPLIANCE-ARCH.md`+`INVARIANTS.md` (reference-only); Erigon=ADR-107; FINOS-OpenAML=coverage row 6; PAYBIS-scope=ADR-138 | 1 (Fireblocks — PAYBIS-scope reject; PAYBIS handles custody white-label) | 0 |
| 11 | UI/UX: Rich Cards / Hybrid Intent Interface / Tremor / BMAD / screenshot-to-code | ✅ | 5 | Rich-Cards/Hybrid-Intent=`MASTER-ORG-CODE-RUNTIME-DOSSIER.md` GAP-080; screenshot-to-code=`ledger/FROZEN-ARCHIVE.md` IL-063 DONE | 2 (Tremor React dashboard components, BMAD-method) | 0 |
| 12 | FCA-path: AEMI / Safeguarding PS25/12 / SMCR / DutyMark / OMP-FCA / CASP-MiCA | ✅ | 6 | AEMI/Safeguarding-PS25-12=`docs/COMPLIANCE-MATRIX.md`+`agents/souls/safeguarding-recon-governor.md`; SMCR=COMPLIANCE-MATRIX; CASP-MiCA=ADR-138+dossier | 2 (DutyMark Consumer-Duty tracker, OMP-FCA obligations-mapping tool) | 0 |
| — | Cross-cutting: Lending 2027 / SME alternative credit scoring | ✅ | 2 | scope-gate: UK EMI licence does NOT cover consumer or SME credit (needs FCA CCA authorisation) | 2 (Lending 2027, SME-alt-credit-scoring) | 2 (both credit-BLOCKED, reject, `B-EMI-CREDIT-GATE-001`) |

**Totals:** candidates ≈ 55; coverage/dup ≈ 38; NEW = 15 (Outcome-1); credit-BLOCKED = 2; outcome = **mixed** (findings + partial-coverage log).

## 3. Corpus dup-check methodology

Per ADR-159 § Terminal-B canon + full-coverage-mandate: a candidate is a **duplicate** only if it is really covered by an ADR, a running service, an active souls-registry SOUL, a DONE ledger entry, or the 71-findings baseline (PR #1051 + PR #1059). Landscape-only mentions do not count as coverage.

Because these are **internal concept docs already reflected across `governance/`, `docs/adr/`, `agents/souls/`, `docs/agent-engine-dossier/`, and `.claude/rules/`**, coverage predominance is expected (the docs describe the plan the corpus is already implementing).

Searched paths: `governance/`, `docs/adr/`, `decisions/`, `agents/souls/`, `agents/passports/`, `docs/agent-engine-dossier/`, `docs/canon/`, `docs/policies/`, `.claude/rules/`, `ledger/entries/`, `ledger/FROZEN-ARCHIVE.md`, `docs/FINANCE-BLOCK-*`, `COMPLIANCE-ARCH.md`, `INVARIANTS.md`, `MASTER-*.md`, `ROADMAP.md`, `SERVICE-MAP.md`, plus repo-wide grep for zero-hit terms.

## 4. Per-candidate verdict table (15 NEW + 2 credit-BLOCKED emitted to register)

| # | candidate | section | verdict | classification | evidence |
|---|-----------|---------|---------|----------------|----------|
| 1 | SpiderFoot | 6 | evaluate | **NEW** | zero grep hits repo-wide; direct fit for adverse-media OSINT / EDD packs |
| 2 | GDELT | 6 | evaluate | **NEW** | zero grep hits; global-events dataset for PEP / adverse-media enrichment |
| 3 | OnionSearch | 6 | evaluate | **NEW** | zero grep hits; Tor .onion index scanner — sandboxed evaluation only |
| 4 | TorBot | 6 | evaluate | **NEW** | zero grep hits; Tor .onion crawler / OSINT harvester |
| 5 | Reputell | 6 | evaluate | **NEW** | zero grep hits; Tor reputation signal aggregator |
| 6 | Paynetics | 9 | evaluate | **NEW** | zero grep hits; EEA/UK BIN sponsor alt to Paymentology (GAP-074) |
| 7 | Transact Pay | 9 | evaluate | **NEW** | zero grep hits; UK EMI card processor alt (GAP-074) |
| 8 | Tribe Payments | 9 | evaluate | **NEW** | zero grep hits (word-boundary); UK card issuing/acquiring stack (GAP-074) |
| 9 | Fireblocks | 10 | reject | **NEW** (PAYBIS-scope) | zero grep hits; PAYBIS handles crypto white-label per ADR-138 — reference-only |
| 10 | Jenesto | 7 | reject | **NEW** (ADR-013-scope) | zero grep hits; ADR-013 already selects Midaz PRIMARY / Fineract FALLBACK |
| 11 | SDK.finance | 7 | reject | **NEW** (ADR-013-scope) | zero grep hits; same rationale as row 10 |
| 12 | Tremor (React) | 11 | evaluate | **NEW** | zero grep hits (word-boundary); MIT dashboard components — fit for ops/MLRO dashboards |
| 13 | BMAD-method | 11 | evaluate | **NEW** | zero grep hits; agent-orchestrated dev method (developer-plane, not runtime) |
| 14 | DutyMark | 12 | evaluate | **NEW** | zero grep hits; Consumer-Duty outcome tracker (complements ADR-054 mask) |
| 15 | OMP-FCA obligations-mapping tool | 12 | evaluate | **NEW** | zero grep hits; complements COMPLIANCE-MATRIX 200+ req |
| 16 | Lending 2027 (consumer credit roadmap) | X-cutting | reject | **credit-BLOCKED** (B-EMI-CREDIT-GATE-001) | OUT-OF-SCOPE for UK EMI — needs FCA CCA authorisation |
| 17 | SME alternative credit scoring 2027 | X-cutting | reject | **credit-BLOCKED** (B-EMI-CREDIT-GATE-001) | same scope-gate as row 16 |
| — | ~38 coverage-hit candidates | 1-12 | (n/a — coverage-log row) | dup-of-corpus / dup-of-71 | see Section 2 coverage-checklist evidence column |

## 5. Duplication Audit (ADR-102, refactor-adjacent — none required)

This intake does not perform a structural refactor. It appends to two append-only registries (`NOVELTY-COLLECTION-REGISTER.md`, `NOVELTY-COVERAGE-LOG.md`) and one runbook. No files renamed, moved, deleted, or deduplicated. ADR-102 Duplication Audit therefore N/A for this PR.

## 6. Server-only (ADR-103)

This intake runs in the isolated per-session worktree on evo1 (`~/wt/agent-specproj-sp23-banxe-concept-v7v9-intake`), not on operator's local. Ledger discipline: `add-il-shard.sh` invoked with fail-closed Redis allocator (127.0.0.1:6379 reachable, TCP-verified). `build_ledger.py` executed from the repo ROOT per ADR-119 §2. Secrets scan: 0 (no keys / tokens embedded; only structured evidence references).

## 7. Anchors

- `.claude/rules/agents.md` — Terminal-B canon (Best Single Artifact, factory-only-execution)
- `docs/canon/TERMINAL-B-OPERATING-CANON.md` — ADR-159 §algorithm + full-coverage-mandate
- ADR-138 — Neuronext retired, PAYBIS sole crypto provider (crypto scope-gate)
- ADR-013 — Midaz PRIMARY, Fineract FALLBACK (core banking scope-gate)
- ADR-119 — IL number FROZEN at merge (no hardcoded `[IL-NNN]` in this PR)
- ADR-120 — per-session worktree isolation
- Prior intakes: PR #1051 (SP14, 30 findings), PR #1059 (SP18, 41 findings) — 71-findings baseline
