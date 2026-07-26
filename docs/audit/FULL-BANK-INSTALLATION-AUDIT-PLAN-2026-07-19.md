# FULL BANK INSTALLATION AUDIT PLAN — 2026-07-19

**Status: DRAFT / NOT FOR MERGE** · sandbox-only · ветка `agent/factory/bank-operating-model/20260718`
Назначение: реестр «плиток» установленных подсистем банка со статусами READY/PARTIAL-READY/GAP; наполняется по одной плитке за change-set. Родственные аудиты: `docs/audit/FULL-PROJECT-INSTALLATION-AUDIT-2026-06-21.md`, `docs/audit/PHASE-3-SSOT-CONFORMANCE-2026-07-05.md`, `docs/audit/FEATURE-INSTALLATION-AUDIT-*-2026-06-2*.md` (не редактируются этим планом).

---

### Floor 1 – Intent-first demo (intent_slice)

- **Subsystem:** Intent Layer / Client-facing floor-1 demo.
- **Implementation:**
  - `tools/sandbox/intent_slice/` (contracts, gates, normalizer, card, hitl_stub, lineage_log, profile, demo, evidence_pack)
  - snapshot: `tools/sandbox/intent_slice/evidence/snapshot-20260718T222645Z/`
- **Documentation:**
  - `docs/runbooks/INTENT-SLICE-OPERATOR-QUICKSTART-2026-07-19.md`
  - `docs/runbooks/LINEAGE-EXPLORER-QUICKSTART-INTENT-SLICE-2026-07-19.md`
  - `docs/runbooks/BANK-FLOOR1-INTENT-DEMO-MAPPING-2026-07-19.md`
- **Canonical links:**
  - ADR-172/172/047/046/128/173
  - LINEAGE-EXPLORER-SPEC-v0.1
  - BANK-FOUR-FLOOR-MEMO (floor 1 = CLIENT / INTENT-FIRST)
  - BANK-MASTER-ROADMAP §9
  - BANK-SPRINT-PLAN (S-A4, S-A10)
- **Coverage:**
  - **Status: PARTIAL-READY** (demo + evidence + lineage mapping существуют; интеграция с Dispatcher/`INTENT_LAYER_ENABLED` и full Explorer UI остаётся OPEN POINT).
  - **READY:** demo intent, HITL path, lineage, evidence (15/15 тестов PASS, живой snapshot с verdict `executed`).
  - **GAP:** Dispatcher integration, budget-halt CLI flag, SCA/sanctions rails mocks, `immutable_storage_ref`/`input_tokens`/`output_tokens` fields, ADR ratification.
- **OPEN POINTS:**
  - полноценный Lineage Explorer (конфиг/UI);
  - интеграция с Intent Dispatcher + `INTENT_LAYER_ENABLED` (OD-R11, контракт роутингов);
  - CLI-флаг budget-halt;
  - mock SCA/санкции/рельсы до S-A5/S-A7 и ключей;
  - поля `immutable_storage_ref`/`input_tokens`/`output_tokens` не эмитятся slice;
  - ратификация ADR-172/172/173.

---

### Floor 2 – Operational layer (EMI core / payments / accounts / reconciliation)

> Numbering note (best-decision, зафиксировано без вопроса): в репо-каноне `governance/MASTER-ORG-CODE-RUNTIME-DOSSIER.md` §2 операционный банковский слой = **FLOOR 3 (BANKING DOMAIN)**; здесь плитка названа «Floor 2 – Operational layer» по операторской нумерации задания. Маппинг нумераций — BANK-FOUR-FLOOR-MEMO §2. OPEN POINT: закрепить единую нумерацию при ратификации (OD-R09-смежно).

- **Subsystem:** операционный слой банка: EMI core (счета, балансы, safeguarding — Midaz/safeguarding-engine/recon), payment processing stack (SEPA/FPS, cards-контур [UNK-09], payouts, fees/GL), reconciliation & error handling (`ERROR-RECONCILIATION-ROADMAP-2026-07-01.md`), treasury/FX-for-treasury; trading block — смежный (мандат Terminal B, `TRADING-BLOCK-ROADMAP-AND-SPRINTS-2026-06-28.md`), в плитку включён только как интерфейс.
- **Implementation (на 2026-07-19):**
  - Состояние реализации: `docs/architecture/EMI-IMPL-STATE-REFRESH-2026-06-26.md` — 16/16 marker-сервисов REAL, impl-backlog=0; provider-стабы credentials-gated.
  - BUILD-SPEC'и (подтверждены в репо): `A-IDV/A-KYC/A-KYB`, `B-EMI`, `B-PRICING`, `D-FEE`, `D-FIN`, `D-GL`, `E-TREASURY`, `G-DEVICE`, `G-RT`, `H-CRM`, `H-SUPPORT`, `I-API`, `L-BI`, `M-GATEWAY`, `M-SANDBOX` (`docs/architecture/*-BUILD-SPEC.md`) + `docs/regulatory/F-FATCA-BUILD-SPEC.md`.
  - Миграции: `docs/migration/` (EMI-IMPLEMENTATION-STATE-2026-06-25, M1.x advisory-surface серия, `AWAITS-OPERATOR-3-web-next-unify.md`).
  - Reconciliation/trading: `docs/roadmap/ERROR-RECONCILIATION-ROADMAP-2026-07-01.md`, `docs/roadmap/TRADING-BLOCK-ROADMAP-AND-SPRINTS-2026-06-28.md`.
  - Program-обвязка: `ledger/entries/agent-factory-masterdossier-v1/IL-2026-07-02T12-00-00Z--global-program-plan-and-master-dossier.md`.
  - Существенная часть модулей реализована **in external repos (see EMI-CANON-COVERAGE-10-REPOS)** — прежде всего banxe-emi-stack; эта плитка в architecture-репо ссылается, не дублирует.
- **Documentation:** `FULL-PROJECT-INSTALLATION-AUDIT-2026-06-21.md`; `PHASE-3-SSOT-CONFORMANCE-2026-07-05.md`; `EMI-CANON-COVERAGE-10-REPOS-2026-06-06.md` + `EMI-CANON-COVERAGE-COMPLETE-2026-06-06.md`; `TARGET-MODEL-CONFORMANCE-2026-06-24/25.md`; `ERROR-RECONCILIATION-ROADMAP-2026-07-01.md`; `FACTORY-ROADMAP-2026-06-23.md` (интерфейс фабрики, не bank-scope); `two-engines-master-analysis-and-roadmap-canonical-2026-07-10.md`.
- **Canonical links:** ADR-045 (связь floor 1↔operational: intent диспетчеризуется в операционный слой); ADR-056/057 (ledger coupling / append-only); ADR-078..081 (CFO treasury-forecast / CRO risk-metrics / CTO data-quality / CTO deploy ports); ADR-096..101 (unified sandbox surface, demo scenarios, session recorder, partner sandbox, gamification, portal UX shell); `docs/canon/INTENT-FIRST-CANON-2026-06-07.md`; `docs/canon/BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md`.
- **Coverage:**
  - **Status: PARTIAL-READY.**
  - **READY:** core-сервисы EMI по EMI-IMPL-STATE (ledger/safeguarding/recon/tx-monitor и др. — REAL с тест-сьютами); reconciliation engine v2; append-only audit контур; sandbox-поверхность (ADR-096..101 спеки).
  - **PARTIAL:** payment rails (код REAL, ключи отсутствуют — ED-01..05); BUILD-SPEC'и B-PRICING/D-FEE/D-FIN/D-GL/E-TREASURY/G-*/H-*/I-API/L-BI/M-* — спеки есть, свежего per-spec implementation-audit'а в этом репо нет; FATCA (F-FATCA spec без audit-подтверждения); conformance 86% (TARGET-MODEL-2026-06-25) — 8 операторских решений.
  - **GAP:** cards-контур (нет BUILD-SPEC/источника — UNK-09); связка floor-1 demo ↔ операционный слой (Dispatcher, D1); live-цикл FIN060→RegData; trading-мосты (ODR-гейты Terminal B).
- **OPEN POINTS:**
  - per-spec implementation-audit для 17 BUILD-SPEC'ов не выполнен (спека↔код соответствие не подтверждено свежим аудитом);
  - внешние EMI-репо: покрытие фиксировано на 2026-06-06 (EMI-CANON-COVERAGE-*) — требуется refresh-audit (план A2);
  - миграции в статусе ожидания: `AWAITS-OPERATOR-3-web-next-unify.md`; MIG-M2.4 PSD2-router A/B/C (OD-R07); FX trading-core RESCOPE/DROP-остаток;
  - cards/BIN-sponsor: нет ни спеки, ни источника (UNK-09/ED-13);
  - нумерация этажей (см. numbering note выше).

---

*Следующие плитки (будущие change-set'ы, здесь только резерв разделов): Orchestration/engine (ENGINE-ROADMAP, SPRINT-PLAN); Governance/HITL (HITL-MATRIX, conformance); Agent fleet (AGENT-FLEET-MASTER-PLAN, ai-agent-full-inventory).*
