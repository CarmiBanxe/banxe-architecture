# BANK MASTER ROADMAP — TO 100% LAUNCH READINESS (DRAFT)

> **Status:** **DRAFT / NOT FOR MERGE** — операторский HITL обязателен
> **Date:** 2026-07-18 · **База:** origin/main @ c66c198 · **Ветка:** agent/factory/bank-operating-model/20260718
> **Producer:** factory terminal (sandbox) — как durable input для **Central terminal**
> **Дисциплина:** [ФАКТ] = подтверждено репо · [ВЫВОД] = следует из фактов · [НЕИЗВЕСТНО] = не установлено

---

# 1. Purpose and planning rule

[ФАКТ, канон] Разделение ролей: **фабрика строит ФАБРИКУ; БАНК строит Central terminal**. Этот документ — BANK-only план; фабричный roadmap (R0–R5, S-FAC-60..69, `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md`) сюда НЕ входит и упоминается только как внешний вход там, где влияет на банк.

Правила плана: дубликаты источников агрессивно свёрнуты (позднейший канон побеждает, superseded помечены); уникальные треки старых версий сохранены; операторские решения НЕ схлопнуты в техзадачи; critical path отделён от «nice to have».

# 2. Source base used

[ФАКТ] Основные семейства источников (все верифицированы в origin/main, если не сказано иное):

1. **BANK memo:** `docs/architecture/BANK-FOUR-FLOOR-MEMO-2026-07-18-DRAFT.md` (durable capture) ≡ `docs/architecture/BANK-OPERATING-MODEL-FOUR-FLOORS-2026-07-18.md` — содержимое идентично, DRAFT-файл добавляет только handoff-header; при merge оставить одно имя (решение Central).
2. **Intent-канон:** ADR-045/049/053/054/055, `docs/canon/INTENT-FIRST-CANON-2026-06-07.md`, `docs/canon/intent-layer-masks.md`, `docs/roadmap/intent-first-migration-roadmap-2026-06-08.md`, `docs/runbooks/intent-dispatcher-deployment.md`, ADR-167 (assistant-ui intent-first Floor-1).
3. **UX/UI:** `docs/BANXE-UI-ARCHITECTURE.md`, `docs/BANXE-UI-UX-SYSTEM.md`, `docs/BANXE-UI-UX-RESEARCH.md`, `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` + UIUX-GATE/RUNTIME/EVIDENCE specs, ADR-101 (sandbox portal UX shell), `docs/handoff/DESIGN-56-assistant-ui-with-mastra.md`.
4. **Engine:** `docs/architecture/two-engines-master-analysis-and-roadmap-canonical-2026-07-10.md`, `docs/agent-engine-dossier/` (ENGINE-ROADMAP, SPRINT-PLAN, VERIFIED-RUNTIME-SNAPSHOT), ADR-146/147/150.
5. **Org/Governance:** `governance/CANONICAL-ORG-CHART-v2.md`, `governance/STAFF-MATRIX-v3.md`, `HITL-MATRIX.yaml`, `governance/MASTER-ORG-CODE-RUNTIME-DOSSIER.md`, ADR-128/046/047/048, ADR-153/154/156/160.
6. **Roadmap/Impl:** `docs/ROADMAP-MATRIX.md`, `docs/ROADMAP-STATUS-2026-06-23.md`, `docs/architecture/EMI-IMPL-STATE-REFRESH-2026-06-26.md`, `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-25.md` (supersedes 06-24), `docs/project/right-track/ROADMAP_8Q-2026-05-22.md`, Paybis-dossier, Trading-Block roadmap (ADR-094 dropped items).

[ФАКТ] **v7/v8/v9 концепт-документы в репо НЕ НАЙДЕНЫ** — если существуют, то transcript-only/вне репо → [НЕИЗВЕСТНО], в план не включены как источник (UNK-08). GAP AUDIT и ACTION PLAN этой сессии — transcript-only (ephemeral), их содержимое консолидировано сюда.

# 3. Definition of «100% bank launch readiness»

[ВЫВОД] 100% = все измерения ниже в состоянии READY. Текущая оценка — по фактам аудита:

| # | Dimension | Сейчас | Основание |
|---|---|---|---|
| D1 | Governance readiness | 86% | TARGET-MODEL-CONFORMANCE-2026-06-25 [ФАКТ] |
| D2 | Human role readiness | ЧАСТИЧНО | 7 SMF назначены; DPO/HoC/CCO пусто [ФАКТ] |
| D3 | Agent-passport readiness | 38/70 ACTIVE | STAFF-MATRIX-v3 [ФАКТ] |
| D4 | Engine/runtime readiness | L2 достигнут, L3 pending | SPRINT-PLAN §0 [ФАКТ] |
| D5 | Intent Layer readiness | код merged, флаг OFF, −6 mask-вариантов | GAP-091 [ФАКТ] |
| D6 | Compliance readiness | swarm ACTIVE; формы HITL не live | HITL-MATRIX / org_roles.py [ФАКТ] |
| D7 | Safeguarding/recon readiness | REAL, recon v2 DONE | EMI-IMPL-STATE [ФАКТ] |
| D8 | Payments/rails readiness | код REAL, ключей нет | provider-stubs [ФАКТ] |
| D9 | KYC/KYB/AML readiness | движки ACTIVE; Sumsub credentials-gated | EMI-IMPL-STATE [ФАКТ] |
| D10 | Finance/CFO/reg-reporting | FIN060 генератор REAL; RegData=HITL-010 | ROADMAP-MATRIX §J [ФАКТ] |
| D11 | Crypto/blockchain readiness | Wave A DONE; B/C gated | Paybis-dossier [ФАКТ] |
| D12 | Product/UX/UI readiness | канон есть; Floor-1 «тончайший» | MASTER-ORG-DOSSIER §2 [ФАКТ] |
| D13 | BaaS/API/MCP readiness | 34 MCP tools, реестр ACCEPTED; внешняя экспозиция не определена | ADR-147 [ФАКТ]/[НЕИЗВЕСТНО] |
| D14 | Operations/support readiness | complaints case-prep REAL; FOS portal gated | EMI-IMPL-STATE [ФАКТ] |
| D15 | Observability/security readiness | Guardian+webhook OK; GAP-082/090 открыты | STAFF-MATRIX §6 [ФАКТ] |
| D16 | External provider readiness | 0/6 ключей | provider-stubs [ФАКТ] |
| D17 | Launch governance/sign-off | L3-пакет не собран | ENGINE-ROADMAP §3 [ФАКТ] |

# 4. Workstream map (WS1–WS16)

**WS1 Governance & Org.** Цель: conformance 100%, канон-гигиена. Есть [ФАКТ]: 86%, все артефакты построены, ADR-стек зрелый. Нет: 8 операторских решений; двойная маркировка статусов ADR-046..049. Operator-blocked: все 8 решений. External: нет. [НЕИЗВЕСТНО]: Board sign-off процедура.

**WS2 Human Roles & HITL.** Цель: полный SMF+staff контур и живые HITL-формы. Есть: 7 SMF, 17 гейтов YAML, `services/hitl/org_roles.py`. Нет: DPO/HoC/CCO; Guardian-формы live. Operator: назначения, активация форм. External: нет. [НЕИЗВЕСТНО]: штат ниже SMF.

**WS3 Agent Passports & Twins.** Цель: 70/70 паспортов в корректном статусе. Есть: 38 ACTIVE, 21 soul. Нет: 32 PROPOSED; OD-1 дубль; OD-5 mismatch; board_reporting passport TODO. Operator: I-27 волны, OD-1/OD-5. [НЕИЗВЕСТНО]: критерии готовности волн (предлагается в S-A1).

**WS4 Banking Engine & Runtime.** Цель: L3 production-ready движок. Есть: 5/5 GAP merged, LangGraph/A2A/MCP/sandbox live-или-merged. Нет: Qdrant deploy (B1), L3-пакет, B8/B9 (ADR-133). Operator: L3 sign-off, деплой-окно. External: нет. [НЕИЗВЕСТНО]: ADR-133 срок.

**WS5 Intent Layer & Client Intent.** Цель: рабочий вход банка (Floor-1). Есть: dispatcher merged (infra#27), runbook деплоя, canon masks. Нет: флаг ON (sandbox), 6 mask-вариантов, BPR-resolver (ADR-048 deferred). Operator: включение флага. [НЕИЗВЕСТНО]: перечень 6 вариантов — уточнить по `docs/canon/intent-layer-masks.md` в S-A4.

**WS6 Compliance/MLRO/Risk.** Цель: живой контур MLRO. Есть: swarm 11 агентов ACTIVE, COMPLIANCE-ARCH 3-layer. Нет: HITL-001..008 формы live; SAR-контур в бою (sandbox-тест). Operator/MLRO: активация. External: нет.

**WS7 Safeguarding/Ledger/Recon.** Цель: закрыть CASS 15 контур операционно. Есть [ФАКТ]: safeguarding-engine REAL, recon v2, Midaz, ClickHouse 5yr. Нет: регулярный live-режим + FIN060→RegData цикл (HITL-010/011). Operator: CFO-подписи. External: FCA (статус после пропущенного дедлайна 2026-05-07 — UNK-10).

**WS8 Payments/Cards/FX/Rails.** Цель: включённые рельсы. Есть: C-fps/sepa/swift код, FX-treasury. Нет: ключи ClearBank/Modulr; hardening 6 стабов; card-processing трек в источниках отсутствует как отдельный блок → [НЕИЗВЕСТНО] (UNK-09). External: ключи.

**WS9 KYC/KYB/Onboarding.** Цель: боевой onboarding. Есть: kyb_onboarding REAL; legacy bkyc/binancekyc PARKED-by-canon (I-27). Нет: Sumsub wiring. External: Sumsub. Operator+MLRO: любые действия с PARKED.

**WS10 CFO/Finance/Reg-Reporting.** Цель: FIN060+finance-агенты. Есть: генератор REAL, dbt marts. Нет: 6 finance-агентов PROPOSED; RegData live cycle. Operator: активация агентов, HITL-010.

**WS11 Crypto/Blockchain.** Цель: Paybis controlled readiness. Есть: Wave A DONE, порты FROZEN. Нет: Wave B (SRC-06), Wave C (SRC-07/08, ADR-114). External: Paybis-спеки. Operator+MLRO: go-live gate.

**WS12 Product UX/UI / Hybrid Intent Interface.** Цель: клиентский интерфейс Floor-1. Есть [ФАКТ]: UI-ARCHITECTURE/UI-UX-SYSTEM канон, ADR-101 sandbox portal, ADR-167 assistant-ui, DESIGN-56 (Mastra), UIUX-gate/runtime/evidence specs. Нет: собранный клиентский assistant-ui поверх intent-слоя (Floor-1 «тончайший»). Operator: banxe-ui CI решение (из 8 conformance). [НЕИЗВЕСТНО]: продуктовый скоуп пилота.

**WS13 API/BaaS/Developer Portal/MCP.** Цель: контролируемая внешняя экспозиция. Есть: 34 MCP tools, ADR-147 registry. Нет: внешний developer-portal/BaaS-контур — в источниках не найден как готовый трек → минимальный скоуп определяет Central. [НЕИЗВЕСТНО]: BaaS-модель.

**WS14 Security/Audit/Observability.** Цель: закрыть security-GAP'ы и наблюдаемость рельсов. Есть: Guardian 7 jobs, cosign active, append-only ledgers. Нет: GAP-082 (UFW console), GAP-090 (OpenClaw bypass остаток), evo2 Prometheus/DORA (операторское), дашборды provider-портов. Operator: 2 решения. External: нет.

**WS15 External Deps/Credentials/Legal.** Цель: реестр §9 закрыт. Есть: реестр (этот документ). Нет: все позиции §9. External: все. Operator: контракты/юр.

**WS16 Launch Readiness/Cutover.** Цель: go-live пакет. Есть: ADR-156 sandbox-режим как площадка dry-run. Нет: launch-пакет, dry-run протокол, cutover runbook. Operator: финальный sign-off (CTIO+CEO+MLRO+CFO; Board — [НЕИЗВЕСТНО]).

# 5. Phase map (8 фаз × этажи × workstreams)

| Фаза | Этаж | WS | Класс |
|---|---|---|---|
| 1 Safeguarding | F3 | WS7 | **foundational, mostly done, требует операционной активации** (FIN060 cycle) [ФАКТ] |
| 2 Payment Rails | F3 | WS8 | externally blocked (ключи) [ФАКТ] |
| 3 Agent Engine | F1–F2 | WS4/WS5 | **active, operator-gated** (L3, флаги); формальный гейт [НЕИЗВЕСТНО] |
| 4 Trading | F3 | (WS11-смежно, Terminal B) | operator-gated (5 ODR) + legal; ВНЕ bank-critical-path [ВЫВОД] |
| 5 Legacy | F3 | WS9-остатки | done/parked [ФАКТ] |
| 6 Factory | вне здания | — | **параллельный, НЕ в этом плане** (role split) |
| 7 Paybis | F3–F4 | WS11 | externally blocked (SRC-06/07) + MLRO-gated [ФАКТ] |
| 8 Governance | F4 | WS1/WS2 | mostly done (86%), operator-gated [ФАКТ] |

# 6. Sprint system (S-A0…S-A13)

Формат каждого спринта: Цель/Скоуп → Deliverables → Prereq/Deps → Exit → Gate. Пометки: `[code]` = код/конфиг/рантайм (готовит Central через фабричные задачи), `[op]` = только оператор, `[ext]` = внешняя зависимость.

**S-A0 Planning baseline.** Цель: канонизировать этот план. Deliverables: ратификация roadmap (merge DRAFT→canon), выбор единого имени BANK-memo, фикс двойной маркировки ADR-046..049 `[code]`, sprint-cadence решение `[op]`. Prereq: нет. Exit: план merged, IL-запись. Gate: operator HITL (I-71).

**S-A1 Governance decisions & roles.** Цель: снять операторские блокеры пакетом. Скоуп: OD-R01..R09 из §8 (кадры, OD-1/5, conformance-пакет), GDPR GAP-085 — **вне очереди, немедленно** `[op]`. Deliverables: назначения зафиксированы в CANONICAL-ORG-CHART-амендменте `[code после op]`; decision-memo по 8 conformance `[code]`. Exit: DPO назначен, OD-1/5 закрыты, GDPR-нотификация решена. Gate: CEO/CTIO/MLRO/Legal.

**S-A2 Runtime activation prerequisites.** Цель: движок готов к включению. Скоуп: Qdrant evo1 deploy (B1) `[code+op]`, cost-governance runtime верификация (ADR-047) `[code]`, ADR-133 решение по B8/B9 `[op]` ([НЕИЗВЕСТНО] срок — может быть deferred без блока launch [ВЫВОД]). Exit: Qdrant :6333 LISTENING, cost-caps подтверждены. Gate: CTIO.

**S-A3 HITL live binding.** Цель: YAML→живые формы. Скоуп: HITL-001..017 Guardian-формы `[code]`, активация `[op]`, L2-петля на двойниках департаментов (sandbox) `[code]`. Prereq: S-A1 (роли). Exit: каждый из 17 гейтов имеет рабочую форму; тест-прогон L2-петли зелёный. Gate: CTIO+MLRO (по AML-гейтам).

**S-A4 Intent Layer sandbox activation.** Цель: открыть вход банка в sandbox. Скоуп: `INTENT_LAYER_ENABLED=true` (sandbox) `[op]` по runbook `docs/runbooks/intent-dispatcher-deployment.md`; smoke intent→dispatcher→planner→A2A→audit `[code]`; 6 недостающих mask-вариантов — уточнение перечня и реализация `[code]`; BPR-resolver skeleton (ADR-048) `[code]`. Prereq: S-A2. Exit: e2e intent-цепочка в sandbox зелёная, lineage-записи пишутся. Gate: CTIO (ADR-156 sandbox).

**S-A5 Compliance + KYC/KYB live flow.** Цель: боевой контур комплаенса в sandbox. Скоуп: SAR-драфт-цикл через HITL-001 форму (без подачи) `[code]`, sanctions auto-block тест (HITL-003) `[code]`, Sumsub wiring при получении ключей `[ext]`, паспорта-волна 1 (L1 read-only) `[op I-27]`. Prereq: S-A3. Exit: полный AML-путь от intent до MLRO-очереди в sandbox. Gate: MLRO.

**S-A6 Ledger/safeguarding/recon closure.** Цель: операционный CASS-контур. Скоуп: daily recon live-режим `[code+op]`, shortfall-alert цепочка HITL-011 `[code]`, FIN060 генерация→CFO review dry-run (HITL-010, без RegData submit) `[op]`. Prereq: S-A3. Exit: 5 подряд зелёных daily recon + FIN060 dry-run подписан CFO. Gate: CFO+MLRO. [НЕИЗВЕСТНО]: FCA-коммуникация по пропущенному дедлайну (UNK-10) — вход от оператора.

**S-A7 Payment rails activation.** Цель: включение рельсов. Скоуп: hardening 6 стабов `[code]`, наблюдаемость provider-портов `[code]`, ключи ClearBank/Modulr `[ext]`, switch-on по runbook + HITL-016 контур `[op]`. Prereq: S-A5, S-A6, ключи. Exit: sandbox-платёж FPS/SEPA e2e; затем controlled live. Gate: CTIO+COO/CFO. Card-processing: скоуп [НЕИЗВЕСТНО] (UNK-09) — решает Central.

**S-A8 CFO/reporting/ALCO stack.** Цель: финансовый этаж. Скоуп: активация 6 finance-агентов (волна 2 I-27) `[op]`, RegData live submission (HITL-010) `[op]`, ALCO-отчётность из dbt marts `[code]`. Prereq: S-A6. Exit: первый live FIN060 цикл. Gate: CFO.

**S-A9 Crypto ops controlled readiness.** Цель: Paybis Wave B/C по мере спек. Скоуп: mock-тесты Wave B `[code]`, SRC-06/07/08 `[ext]`, Travel-Rule заготовка + MLRO-runbook `[code]`, ADR-114 go-live gate `[op+MLRO]`. Prereq: S-A5. Exit: Wave B integration зелёный ИЛИ явный deferred-статус. Gate: MLRO+operator. [ВЫВОД] НЕ на critical path запуска банка (можно launch без crypto).

**S-A10 UX/UI + explainability + support.** Цель: клиентское лицо Floor-1. Скоуп: assistant-ui по ADR-167/DESIGN-56 поверх intent-слоя `[code]`, XAI-отображение (ADR-169 LIME/SHAP) в HITL-формах `[code]`, complaints/FOS контур (portal `[ext]`), banxe-ui CI `[op]`. Prereq: S-A4. Exit: пилотный клиентский сценарий e2e в sandbox portal (ADR-101). Gate: CTIO + product [НЕИЗВЕСТНО: владелец product-решения].

**S-A11 API/BaaS/MCP controlled exposure.** Цель: минимальная внешняя поверхность. Скоуп: определение BaaS-скоупа `[op/Central]`, экспозиция подмножества MCP/API за auth `[code]`, rate-limits/audit `[code]`. Prereq: S-A12 частично. Exit: документированная и закрытая по умолчанию внешняя поверхность. Gate: CTIO+security. [НЕИЗВЕСТНО]: BaaS-модель (UNK-06).

**S-A12 Security/audit/observability closure.** Цель: закрыть остаточные security-GAP'ы. Скоуп: GAP-082 `[op]`, GAP-090 остаток `[code]`, evo2 Prometheus/DORA `[op]`, дашборды rails `[code]`, pen-check sandbox `[code]`. Prereq: параллельно S-A7+. Exit: 0 открытых P1 security-GAP. Gate: CTIO+CEO (HITL-015 контур протестирован).

**S-A13 Launch governance / dry-run / go-live.** Цель: 100%. Скоуп: launch-пакет (все exit-критерии S-A1..A12 + рубрика §12) `[code]`, полный dry-run на sandbox `[code+op]`, L3-gate движка (CTIO tech → FCA-boundary review → CEO) `[op]`, финальные подписи CFO/MLRO, controlled go-live `[op]`. Exit: go-live executed + post-launch мониторинг активен. Gate: CTIO+CEO+MLRO+CFO; Board — [НЕИЗВЕСТНО] (UNK-03).

# 7. Critical path

[ВЫВОД] **До любого live-банкинга (must):** S-A1 (кадры+GDPR) → S-A2 → S-A3 → S-A4 → S-A6 → S-A12 → S-A13. Это хребет: governance → runtime → HITL → вход → CASS-контур → security → запуск.
**До customer pilot (sandbox):** + S-A5, S-A10 (клиентский сценарий + комплаенс-путь).
**До внешних рельсов:** + S-A7 (ключи!) и завершённый S-A5/S-A6.
**Post-launch, важно:** S-A8 полный цикл, S-A9 crypto, S-A11 BaaS.
**Optional/deferred:** B8/B9 Temporal saga (если ADR-133 подтвердит), Trading Block (фаза 4 — отдельный мандат Terminal B), v7-v9 концепты (не в репо).

# 8. Operator decision register (consolidated)

| ID | Тема | Зачем | Блокирует | WS/Sprint | Источник |
|---|---|---|---|---|---|
| OD-R01 | GDPR Art.33 нотификация (GAP-085) | clock running с 2026-06-27 | юр.риск немедленно | WS2/S-A1 | STAFF-MATRIX-v3 §6 [ФАКТ] |
| OD-R02 | Назначить DPO | GDPR/орг-полнота | WS2, S-A1 | WS2 | ORG-STRUCTURE [ФАКТ] |
| OD-R03 | Именовать Head of Compliance, CCO | орг-полнота | WS2 | WS2/S-A1 | CANONICAL-ORG-CHART [ФАКТ] |
| OD-R04 | OD-1: дубль `banxe_aml_orchestrator` | канон-целостность MLRO-линии | WS3/WS6 | S-A1 | STAFF-MATRIX-v3 §5 [ФАКТ] |
| OD-R05 | OD-5: статус `privacy_compliance_agent` | реестр-целостность | WS3 | S-A1 | там же [ФАКТ] |
| OD-R06 | Пакет 8 conformance-решений (MRM-пороги, merge-queue, evo2 Prometheus, banxe-ui CI, назначения, активация паспортов policy, emi-runtime builds, T1-классификация) | 86%→100% | WS1 | S-A1 | TARGET-MODEL §4 [ФАКТ] |
| OD-R07 | OD-2: PSD2 router MIG-M2.4 A/B/C | консолидация рельсов | WS8 | S-A7 | ROADMAP-STATUS [ФАКТ] |
| OD-R08 | OD-3: USB4 peer 10.0.0.1 идентификация | инфра-гигиена | WS14 | S-A12 | STAFF-MATRIX §4 [ФАКТ] |
| OD-R09 | Ратификация этого roadmap + имя BANK-memo | планирование | всё | S-A0 | этот файл |
| OD-R10 | Qdrant evo1 деплой-окно | память движка | WS4 | S-A2 | SPRINT-PLAN B1 [ФАКТ] |
| OD-R11 | `INTENT_LAYER_ENABLED=true` (sandbox) | вход банка | WS5 | S-A4 | GAP-091 [ФАКТ] |
| OD-R12 | ADR-133 (Temporal saga B8/B9) | оркестрация саг | WS4 (не critical [ВЫВОД]) | S-A2 | ENGINE-ROADMAP §5 [ФАКТ] |
| OD-R13 | Активация HITL-форм | живой governance | WS2/WS6 | S-A3 | HITL-MATRIX [ФАКТ] |
| OD-R14 | Волны активации 32 паспортов (I-27) | заселение F2 | WS3 | S-A5/A8 | STAFF-MATRIX-v3 [ФАКТ] |
| OD-R15 | L3-gate движка: CTIO+FCA-boundary+CEO | production движка | WS4/WS16 | S-A13 | ENGINE-ROADMAP §3 [ФАКТ] |
| OD-R16 | Ключи/контракты ClearBank+Modulr (решение о заключении) | рельсы | WS8/WS15 | S-A7 | ROADMAP-MATRIX §C [ФАКТ] |
| OD-R17 | ADR-114 Paybis go-live gate + MiCA stance | crypto | WS11 | S-A9 | Paybis-dossier [ФАКТ] |
| OD-R18 | BaaS/API внешняя модель | внешняя поверхность | WS13 | S-A11 | [НЕИЗВЕСТНО]-скоуп |
| OD-R19 | ADR «CTO = bank↔factory interface» | закрыть канон-гэп | WS1 | S-A0/A1 | BANK-memo §5 [ВЫВОД] |
| OD-R20 | FCA-коммуникация: статус CASS 15 после дедлайна 2026-05-07 | регуляторный риск | WS7 | S-A6 | IL-472 OVERDUE [ФАКТ] |

Trading ODR-1..5 — вне bank-critical-path (мандат Terminal B), в реестр не включены [ВЫВОД].

# 9. External dependency register

| ID | Зависимость | Тип | WS/Sprint |
|---|---|---|---|
| ED-01 | ClearBank API keys + договор | provider | WS8/S-A7 |
| ED-02 | Modulr API keys + договор | provider | WS8/S-A7 |
| ED-03 | Sumsub credentials | provider (KYC) | WS9/S-A5 |
| ED-04 | Sardine credentials | provider (fraud) | WS6/S-A5 |
| ED-05 | Twilio/SendGrid credentials | provider (OTP) | WS9/S-A5 |
| ED-06 | FOS portal access | регулятор/портал | WS14/S-A10 |
| ED-07 | Offsite storage credentials | provider (backup) | WS14/S-A12 |
| ED-08 | Paybis SRC-06 (literal API spec) | partner | WS11/S-A9 |
| ED-09 | Paybis SRC-07 (Travel Rule schema) + SRC-08 (MLRO/CASP T&C) | partner+reg | WS11/S-A9 |
| ED-10 | FCA: RegData/FIN060 live cycle + CASS 15 статус | регулятор | WS7,WS10/S-A6,A8 |
| ED-11 | Grant Thornton (Internal Audit, SMF5) — engagement live | outsourced 3rd line | WS1/S-A13 |
| ED-12 | Legal reviews: GDPR (GAP-085), MiCA stance | legal | WS15/S-A1,A9 |

# 10. Unknowns register [НЕИЗВЕСТНО]

| ID | Вопрос | Как закрыть |
|---|---|---|
| UNK-01 | Формальный гейт фазы 3 (Agent Engine) | операторская фиксация (кандидат: L3-gate = гейт фазы) |
| UNK-02 | Формальный гейт фазы 4 (Trading) | операторская фиксация; вне bank-path |
| UNK-03 | Процедура Board sign-off (в ADR NOT FOUND) | новый governance-документ или решение CEO |
| UNK-04 | Имена Head of Compliance / CCO; штат ниже SMF | операторский ввод |
| UNK-05 | Место Private Engine после деплоя | отдельный ADR (вне bank-плана) |
| UNK-06 | BaaS/developer-portal модель | продуктовое решение Central |
| UNK-07 | Перечень «6 missing intent-variants» | аудит `docs/canon/intent-layer-masks.md` в S-A4 |
| UNK-08 | v7/v8/v9 концепт-документы — существуют ли вне репо | операторский ввод; если да — доконсолидировать |
| UNK-09 | Cards-processing трек (в источниках нет отдельного блока) | Central: подтвердить in/out of scope запуска |
| UNK-10 | Последствия пропуска дедлайна CASS 15 (2026-05-07) для FCA-статуса | операторский/юридический ввод |
| UNK-11 | Cost-governance runtime (per-agent бюджеты в LiteLLM) — задеплоено ли | верификация в S-A2 |
| UNK-12 | Владелец product-решений (S-A10 gate) | операторская фиксация |

# 11. Recommended execution order

[ВЫВОД] 1) **Сегодня:** OD-R01 (GDPR) — эскалация вне очереди; параллельно S-A0 (ратификация плана). 2) **Неделя 1–2:** S-A1 пакетом (все кадровые + OD-1/5 + 8 conformance) — один HITL-сеанс оператора закрывает 9 решений. 3) **Параллельно:** S-A2 (Qdrant + верификации — почти всё готовится без ожиданий). 4) S-A3 → S-A4 (HITL-формы, затем intent в sandbox — порядок важен: сначала надзор, потом вход). 5) S-A5 + S-A6 параллельно (комплаенс-поток и CASS-контур независимы до S-A7). 6) S-A7 по факту ключей (ED-01/02 запросить уже в неделе 1 — самый длинный внешний lead time [ВЫВОД]). 7) S-A8/A10/A12 волной, S-A9/A11 по готовности внешних входов. 8) S-A13 — только при 100% рубрики §12. Фабрика (фаза 6) всё это время работает параллельно и банк не блокирует.

# 12. Completion rubric

| Уровень | Критерий (все предыдущие включены) |
|---|---|
| **25%** | S-A0/A1 закрыты: план ратифицирован, кадры назначены, GDPR решён, conformance-решения приняты (D1→100, D2→READY) |
| **50%** | S-A2..A4: Qdrant live, HITL-формы работают, intent-цепочка e2e в sandbox зелёная (D4/D5/D6 READY-sandbox) |
| **75%** | S-A5/A6 + волна-1 паспортов: AML-путь и CASS-контур живые, FIN060 dry-run подписан; ключи rails получены (D3≥50/70, D7/D9 READY) |
| **90%** | S-A7/A8/A12: рельсы controlled-live, первый live FIN060, 0 открытых P1 security-GAP, dry-run пройден (D8/D10/D15/D16 READY) |
| **100%** | S-A13: L3-gate подписан (OD-R15), launch-пакет полный, go-live executed, post-launch мониторинг активен; все D1–D17 READY или явно deferred операторским решением |

---
*DRAFT / NOT FOR MERGE. Producer: factory sandbox terminal, 2026-07-18. Все push/PR/merge — только через операторский single-writer процесс.*
