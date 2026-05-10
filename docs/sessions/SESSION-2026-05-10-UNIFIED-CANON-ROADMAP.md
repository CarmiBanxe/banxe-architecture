# UNIFIED CANON & ROADMAP — EMI BANXE AI BANK

**Date:** 2026-05-10 00:00 CEST  
**Author:** Comet (canon-merge synthesis)  
**Status:** PROPOSED  
**Anchors:** ADR-025, canon/CANON.md v1.0, MASTER-PLAN-2026-05-05, ROADMAP.md (2026-05-09 final), PROMPT-CANON-PROJECT.md, PROMPT-CANON-DEVELOPER.md  
**Repo audit basis:** 21 CarmiBanxe repos + 5 external + 2 local-only (no remote)

---

## I. UNIFIED CANON (binding for Perplexity/Comet + Factory/Claude Code + Operator)

### A. 3-layer canon architecture
1. **Operational** (`canon/CANON.md`): profiles BANXE/LEGAL/MIXED, 5 modules (CORE/DOC/DEV/DECISION/LEGAL/FR_MODULE), 5 rule-files (DIALOGUE/COLLABORATION/AUTOMATION/REPORTING/VERIFICATION = KANONы 1-10).
2. **Governance** (`PROMPT-CANON-PROJECT.md`): factory loop (`banxe-architecture`) + product loop (`banxe-emi-stack`), IL-LEDGER-NORM-001, Spec-First Auditor v2 (12 blocks), invariants I-01..I-35, FCA/EU/US/OECD regulatory, HITL roles.
3. **Executor** (`PROMPT-CANON-DEVELOPER.md`): single big script, 100% or OPEN, ASCII-only Python, heredoc/base64 discipline, parking out-of-scope, push-privileged, handoff-memory.

### B. SESSION RULES 1..7 (ADR-025, binding)
1. §15 Claude-Code-First (5 shell exceptions)
2. §1 OCAT — one move = one task
3. §4 Best-Decision Principle — agent decides itself (6 sources)
4. §2 Addressee — explicit target per move
5. §3 Whitelist — read-only without confirmation
6. §6 Scope guard — only CarmiBanxe/*
7. §8 Secret-leak zero

### C. CORE PRINCIPLE (binding)
NEW EMI stack is primary. BANXE.RAR is source of processes and domain rules ONLY, not code.
All legacy fragments PASS/REWRITE/REJECT via session doc in `banxe-architecture/docs/sessions/`.
Factory MUST follow: new code in `banxe-emi-stack` behind FROZEN ports; legacy as reference, not imported.

### D. Two-loop synchronization (factory <-> product)
Any IL in `banxe-emi-stack` ledger -> mirror in `banxe-architecture` ledger (linked-commit SHA, supersedes, sha256-anchors).
Without this — violation of PROMPT-CANON-PROJECT §11.

---

## II. CURRENT STATE (verified 2026-05-10)

### A. Production code (`banxe-emi-stack`, main)
- 27 services scaffolded (Phase 4 DONE)
- FROZEN ports (PORT-CONTRACTS-FREEZE-2026-05-08): OtpDeliveryPort, KYCWorkflowPort, PaymentRailPort, LedgerPort, CryptoLedgerPort + CryptoRpcPort
- Production adapters merged (Sprint 6-9): TwilioOtpAdapter (#94), SendGridOtpAdapter (#94), SumsubHttpAdapter (#96), ModulrSepaAdapter (#97), MidazCryptoAdapter (#98)
- CI smoke gate ADR-035 5/5: mock tier (#100), workflow (#101), branch protection (API), full nightly + CI_SMOKE_FAILURE emitter (#105)
- Coverage 41.27% (>=35% required), 9607+ tests

### B. Architecture canon (`banxe-architecture`, main)
- ADRs: numbered ADR-001..ADR-035 + 11 domain ADRs in `adrs/` + ADR-035 Accepted
- Sprint 10 BANXE.RAR dobor (#157): 0 PASS / 22 REWRITE-reference / rest REJECT — confirms CORE PRINCIPLE
- MASTER-PLAN tracks A-I: A/G partial closed; C (ADR-028) DONE; B/D/E/F/H/I open
- Sprints S1-S5 autonomous closure: 10 PRs merged 2026-05-09, 1 milestone tag

### C. Active blockers
- 11 operator decisions queue (F1 factory restoration, openclo-moa, F3 LiteLLM, 84 services classification, §0.2 Levels 1-5 governance)
- 7 external API keys (Track I): Modulr prod, Companies House, OpenCorporates, Sardine, Telegram, Marble, Jube
- 2 local-only repos (no remote): `banxe`, `banxe-ai-infrastructure` — risk of loss

### D. Repo topology (audited 2026-05-10)
- Production stack (5): banxe-emi-stack, banxe-architecture, banxe-platform, banxe-payment-core, banxe-infra
- Domain content (5): banxe-business-processes, banxe-training-data, banxe-ui, banxe-mirofish, banxe-lexisnexis-distro
- Tooling/AI (7): MetaClaw, MiroFish, developer-core, gpt-archive-toolkit, vibe-coding, obsidian-vault, collaboration
- Reference/legal (3): france.code-civil, legi_fr, crypto-ops-monitor
- Other (3): braslina, guiyon, ss1
- External deps (5): AMLGentex, AMLSim, OpenRLHF, claude-code, llama.cpp
- Local-only (2): banxe (BANXE.RAR source), banxe-ai-infrastructure

---

## III. ROADMAP TO FULL EMI BANXE AI BANK REALIZATION

### Phase 5 — Production Wiring (no operator inputs required)
1. **Track A close**: G-GUARD-03 (CH retention 12mo), G-GUARD-04 (ENFORCE all repos), G-CANON-AUTONOMY (V-14..V-17 in MetaClaw test_canon_judge.py target 17/17), G-CANON-15 (§15 Claude-Code-First in conversation-judge prompts)
2. **Track G close**: ADR-029 (Postgres backup rotation), ADR-030 (auth surface rate limits), G-INFRA-01 (evo2 in SERVICE-MAP)
3. **Two-loop mirror backfill**: IL mirrors emi-stack -> architecture for all Sprint 6-10 PRs (#94, #96, #97, #98, #100, #101, #105, #157)
4. **Local-only repos rescue**: add remote for `banxe-ai-infrastructure`; archive strategy for `banxe` (BANXE.RAR source) in private archive repo

### Phase 6 — Operator-blocked tracks
1. **Track B**: KC dev-file -> Postgres (Phase F), session-timeout hardening (Phase G)
2. **Track D**: ADR-027 ClickHouse durability + pgAudit WAL archival (CASS 15)
3. **Track E**: ADR-033 KC alert routing (n8n+Telegram / KC SPI+Slack / Prometheus+Alertmanager)
4. **Track F**: ADR-032 secrets rotation policy + Vault/Infisical long-term
5. **11-decision queue resolution** — F1 factory restoration, openclo-moa, F3 LiteLLM, 84 services, §0.2 Levels 1-5

### Phase 7 — Crypto Block (FATF Travel Rule)
1. ADR-036 (new): Crypto AML / Travel Rule integration over SumsubHttpAdapter + MidazCryptoAdapter, FATF Recommendation 16, FCA MLR 2017
2. Chainalysis/Elliptic adapter behind new `CryptoCompliancePort` (FROZEN after design-review)
3. Cross-entity reconciliation (Neuronext custody / TomPay fiat<->crypto bridge)
4. Wallet management UI integration (`banxe-ui`)

### Phase 8 — Multi-agent + Reporting (MASTER-PLAN Phase 5)
1. Multi-agent comms protocol between HITL roles (COMPLIANCE_OFFICER, MLRO, CFO, COMPLAINTS_OFFICER, FRAUD_ANALYST, SECURITY_OFFICER, CTIO)
2. Real-time dashboard (ClickHouse + Superset/Metabase)
3. Telegram bot ops interface (after Track I unblock)
4. FCA Section 4 automated reporting + MI report generator

### Phase 9 — QA + Production Readiness (MASTER-PLAN Phases 7-8)
1. E2E onboarding test, payment regression, compliance scenario playbooks
2. AI agent benchmarks, load testing
3. DR/failover, full monitoring/alerting coverage
4. Docs audit, go-live checklist sign-off
5. External API keys (Track I) sandbox -> prod cutover

### Phase 10 — Production Launch + FCA Application
1. Final compliance pack: FIN060, SAR auto-filing, Consumer Duty annual report, CASS 7.15+15 reconciliation
2. FCA EMI authorisation submission
3. Customer onboarding live
4. Continuous compliance monitoring

---

## IV. BINDING FOR EXECUTORS

### Perplexity / Comet (this session)
- All moves by OCAT, one target per move (§1 + §2)
- No middle-ground; record GAPs/IL for any partial state (§4 + 100%-or-OPEN)
- Each proposal: fact + decision + actionable command
- Read-only operations without confirmation (§3 Whitelist)
- Best-Decision Principle from 6 sources (§4)

### Factory / Claude Code (mark-legion)
- NEW stack primary; BANXE.RAR reference only
- Always branch off main; one scope = one commit = one proof SHA
- Pre-commit gates mandatory: Spec-First Auditor v2 (12 blocks) + ruff + bandit + semgrep + pytest-fast
- Push only after explicit operator yes (privileged action)
- IL-mirror in both repos after each merged PR (PROMPT-CANON-PROJECT §11)
- ASCII-only Python; em-dash only in markdown / comments
- Heredoc / base64 discipline for multiline writes (PROMPT-CANON-DEVELOPER §6)
- Parking out-of-scope to /tmp/banxe-parking-<scope>-<ts>/
- Handoff at session end: /tmp/banxe_handoff_<date>_<hhmm>.md

### Operator (Moriel Carmi)
- 11-decision queue resolution unblocks Phase 6
- 7 external API keys (Track I) unblock Phase 9 prod cutover
- Approval required for every privileged push
- Approval required for canon amendments (3-layer canon docs)

---

## V. NEXT ATOMIC STEP

Phase 5 item 3 — Two-loop mirror backfill — is the lowest-risk, no-operator-input next step.
Procedure: open IL mirror entries in `banxe-architecture/INSTRUCTION-LEDGER.md` referencing each Sprint 6-10 PR SHA (#94, #96, #97, #98, #100, #101, #105, #157), one IL block per PR, append-only.

Alternative if operator wants to start fresh track: Phase 5 item 1 (Track A close) starting with G-CANON-AUTONOMY (V-14..V-17 in MetaClaw test_canon_judge.py — target 17/17 PASS).

---

## VI. STATUS

This document is **PROPOSED**. Promotion to **ACCEPTED** requires:
- Operator approval
- IL block in `banxe-architecture/INSTRUCTION-LEDGER.md` with status: accepted
- Mirror IL block in `banxe-emi-stack/INSTRUCTION-LEDGER.md`
- sha256 anchors of all referenced canon files (CANON.md, MASTER-PLAN, ROADMAP, PROMPT-CANON-PROJECT, PROMPT-CANON-DEVELOPER)

## I.E — TOPOLOGY CANON (4th layer, binding, IMMUTABLE 2026-04-29)

Source: `~/banxe-canon/CANON.md`. Discovered in audit completion 2026-05-10 02:00 CEST. NOT a duplicate — orthogonal infrastructure layer.

### Two-machine workflow

**`mark-legion` (WSL2) — PRIMARY workstation**
- User: `mmber`, Home: `/home/mmber/`
- Role: orchestration, planning, docs, git ops, light dev

**`gmktec` / `banxe-NucBox-EVO-X2` — SERVER**
- Users: `banxe` (canonical), `root` (admin only)
- Path: `/data/banxe-emi-stack/` (main repo, production-like)
- Path: `/srv/staging/` (legacy artefacts, BANXE.RAR contents)
- SSH alias: `gmktec` (HostName 192.168.0.72, Port 2222)

### Rule (binding)
Work ALWAYS starts on `mark-legion`. Switch to `gmktec` ONLY when needed for:
- access to `/srv/staging/` legacy artefacts (BANXE.RAR-derived data)
- services requiring real broker (RabbitMQ), real DB (PostgreSQL/ClickHouse), real CBS (Midaz)
- heavy compute / disk operations on BANXE.RAR derivatives
- production-like testing

### Anti-patterns (forbidden)
- Working directly on `gmktec` for documentation / planning
- Committing from `gmktec` when `mark-legion` has the working copy
- Running `ruff`/`mypy`/`pytest` on `mark-legion` if target tree exists ONLY on `gmktec:/data/banxe-emi-stack/`

### Implication for BANXE.RAR processing
Canonical BANXE.RAR location is `gmktec:/srv/staging/`, NOT `~/banxe/` on `mark-legion`. The `~/banxe/` directory on mark-legion (no remote, local-only) is a working snapshot, not source-of-truth. Sprint 10 dobor was done against the listing artefact (`banxe-architecture/docs/inventories/BANXE-RAR-LISTING-2026-05-06.txt`), which is the canonical reference, not the local snapshot.

### Implication for Factory / Claude Code
Factory MUST respect topology: heavy/legacy/prod-like work via `ssh gmktec`, all docs/canon/IL work on `mark-legion`. Mixing layers is canon violation.

---

