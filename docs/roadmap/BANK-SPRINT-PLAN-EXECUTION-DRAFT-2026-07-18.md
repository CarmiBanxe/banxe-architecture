# BANK SPRINT PLAN — EXECUTION DRAFT

> **Status:** **DRAFT / NOT FOR MERGE** · **Date:** 2026-07-18 (rev. 2 — lane/action tagging normalized) · **База:** origin/main @ c66c198
> **Producer:** factory terminal (sandbox) для **Central terminal**
> **Parent:** `BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` (v2) — реестры OD-R/ED/UNK там; операторская сводка — `docs/architecture/BANK-LAUNCH-CONTROL-PANEL-2026-07-18.md`.
> **Маркировка:** [FACT-REPO]/[PLAN-CONCEPT]/[INFERENCE]/[UNKNOWN]
> **Lane-теги (ровно один на спринт):** [LC] Launch-Critical · [PL] Pre-Launch/Adjacent · [PX] Post-Launch/Expansion
> **Action-теги:** [code] код/конфиг/интеграция · [op] оператор/governance/HITL · [ext] внешний провайдер/регулятор/credentials

## Rules of use

1. Central ведёт исполнение спринт за спринтом; фабрика получает [code]-задачи как spec-build; [op] — только оператор; [ext] — внешние стороны.
2. Спринт закрыт только при выполнении всех exit-критериев и подписи gate-owner.
3. Никакой пункт [PLAN-CONCEPT] не исполняется в regulated-зоне до ратификации соответствующего ADR (OD-R21).
4. I-71/I-27/worktree-isolation действуют на всех спринтах.
5. Следующий спринт = первый незакрытый [LC], чьи блокеры сняты; [PL]/[PX] — только если [LC]-хребет ждёт внешнего/операторского входа.

## Sprint sequencing logic

[INFERENCE] Порядок = «надзор прежде входа, вход прежде денег, деньги прежде рельсов»: губернанс-субстрат (A1–A3) → intent-вход в sandbox (A4) → комплаенс-поток и KYC (A5) → CASS-контур (A6) → внешние рельсы (A7) → security-закрытие (A12) → запуск (A13). A8/A9/A10/A11 паркуются на своих зависимостях, не блокируя хребет. Концепт-линия S9–S13 (intent-layer-launch, [PLAN-CONCEPT]) вложена: S9→A4.1, S10→A4.2, S11→A5, S12→A13/post, S13→[PX].

## Sprint table

| Sprint | Lane | Actions | Название | Gate owner | Критический пред-к |
|---|---|---|---|---|---|
| S-A0 | [LC] | [op][code] | Planning baseline | operator | — |
| S-A1 | [LC] | [op] | Governance decisions & roles | CEO/CTIO/MLRO/Legal | — |
| S-A2 | [LC] | [code][op] | Runtime activation prereqs | CTIO | A1 частично |
| S-A3 | [LC] | [code][op] | HITL live binding | CTIO+MLRO | A1 |
| S-A4 | [LC] | [code][op] | Intent substrate + L0/L1 sandbox | CTIO | A2, A3 |
| S-A5 | [LC] | [code][op][ext] | Compliance overlay + L2 + KYC live | MLRO | A3, A4 |
| S-A6 | [LC] | [code][op][ext] | CASS/safeguarding closure | CFO+MLRO | A3 |
| S-A7 | [LC] | [code][op][ext] | Payment rails activation | CTIO+COO/CFO | A5, A6, ED-01/02 |
| S-A8 | [PL] | [code][op][ext] | CFO / reporting stack | CFO | A6 |
| S-A9 | [PX] | [code][op][ext] | Crypto readiness (Paybis) | MLRO+operator | A5, ED-08/09 |
| S-A10 | [LC] | [code][op] | HII client surface + XAI (минимум) | CTIO+product | A4 |
| S-A11 | [PX] | [code][op] | API/BaaS/MCP exposure | CTIO+security | A12, OD-R18 |
| S-A12 | [LC] | [code][op] | Security/observability closure | CTIO+CEO | параллельно A7+ |
| S-A13 | [LC] | [code][op][ext] | Launch governance / go-live | CTIO+CEO+MLRO+CFO | все [LC] |

## Per-sprint details

### S-A0 — Planning baseline · [LC] · [op][code]
- **Why:** без ратифицированного плана каждое следующее решение спорно.
- **Purpose/Scope:** ратификация roadmap v2 + этого плана (OD-R09); выбор имени BANK-memo; фикс двойной маркировки ADR-046..049 [code]; drafting ADR-заготовок OD-R19/OD-R21 [code].
- **Deliverables:** merged план (операторский merge), 2 draft-ADR. **Prereq:** нет.
- **Blocks:** OD-R09.
- **Exit:** план в main; IL-запись; cadence решён [op]. **Gate:** operator.

### S-A1 — Governance decisions & roles · [LC] · [op]
- **Why:** девять операторских решений снимаются одним HITL-сеансом и открывают всё остальное.
- **Purpose/Scope:** OD-R01 GDPR — **вне очереди, день 1**; OD-R02/03 кадры; OD-R04/05 реестр-фиксы; OD-R06 пакет 8 conformance; амендмент org-chart после назначений [code].
- **Deliverables:** назначения зафиксированы; decision-memo по 8 пунктам [code]; GDPR-нотификация исполнена/отклонена с обоснованием.
- **Prereq:** нет. **Blocks:** OD-R01..R06; ED-12 (юрист); UNK-04.
- **Exit:** OD-R01..R06 закрыты. **Gate:** CEO/CTIO/MLRO/Legal.

### S-A2 — Runtime activation prereqs · [LC] · [code][op]
- **Why:** движок без памяти и cost-каппинга нельзя выпускать даже в sandbox.
- **Purpose/Scope:** Qdrant evo1 deploy (B1) [code+op OD-R10]; верификация LiteLLM BudgetManager (UNK-11) [code]; при отсутствии — конфиг per-agent budgets/halt по agent-budget-policy [code, PLAN-CONCEPT→через OD-R21]; решение ADR-133 [op OD-R12 — запуск не блокирует, INFERENCE].
- **Deliverables:** Qdrant :6333 LISTENING; `agent-budget-policy.md` draft (10 агентов) [code].
- **Prereq:** A1 частично. **Blocks:** OD-R10, OD-R12; UNK-11.
- **Exit:** healthcheck зелёный; BudgetExceeded-тест зелёный. **Gate:** CTIO.

### S-A3 — HITL live binding · [LC] · [code][op]
- **Why:** надзор должен работать раньше, чем откроется вход (I-27).
- **Purpose/Scope:** Guardian-формы HITL-001..017 [code]; активация [op OD-R13]; L2-петля «двойник предложил — человек решил» в sandbox [code].
- **Prereq:** A1 (роли). **Blocks:** OD-R13.
- **Exit:** 17/17 форм работают; петля пройдена; каждая форма пишет в append-only audit. **Gate:** CTIO+MLRO.

### S-A4 — Intent substrate + L0/L1 sandbox · [LC] · [code][op]
- **Why:** это и есть открытие входа банка — под полным надзором и с мандатом клиента.
- **Purpose/Scope (S9+S10 концепт-линии, [PLAN-CONCEPT] через OD-R21):**
  - A4.1 substrate [code]: DecisionLineageWrapper (запись до/после действия агента) + AgentDecisionRecord ClickHouse TTL 7yr (частично IN-REPO: `services/agents/_lineage.py` [FACT-REPO]); budget-policy enforcement.
  - A4.2 intent capture [code+op]: ClientIntentRecord (scope_limits/consent/revocation/expires) + SCA consent-at-delegation + revocation; BPR v1 = 10–15 YAML-правил (Compliance Officer approver); `INTENT_LAYER_ENABLED=true` sandbox [op OD-R11]; аудит 6 missing mask-вариантов (UNK-07) [code].
- **Prereq:** A2, A3; OD-R21. **Blocks:** OD-R11, OD-R21; UNK-07.
- **Exit:** e2e intent→dispatcher→planner→A2A→lineage в sandbox; L0/L1 работают; revocation-тест зелёный. **Gate:** CTIO.

### S-A5 — Compliance overlay + L2 supervised + KYC live · [LC] · [code][op][ext]
- **Why:** деньги двигаются только через живой комплаенс и подтверждение человека.
- **Purpose/Scope (S11):** real-time overlay 3 уровня [code, PLAN-CONCEPT]: L1 fast-check <50ms → L2 rule-check (BPR+sanctions) <200ms → L3 deep-AML <2s + HITL-ticket; SAR-драфт цикл через HITL-001 (без подачи) [code]; sanctions auto-block тест (Watchman [FACT-REPO]) [code]; Ballerine KYC e2e [code]; Sumsub при ключах [ext ED-03]; паспорта волна-1 L1 read-only [op OD-R14]; L2 Supervised: каждый перевод → confirmation card → человек [code].
- **Prereq:** A3, A4. **Blocks:** OD-R14; ED-03/04/05 (частично).
- **Exit:** путь intent→overlay→MLRO-очередь в sandbox; латентности в бюджетах. **Gate:** MLRO.

### S-A6 — CASS/safeguarding closure · [LC] · [code][op][ext]
- **Why:** EMI без живого safeguarding-контура не запускается.
- **Purpose/Scope:** daily recon live-режим [code+op]; shortfall HITL-011 цепочка [code]; FIN060 dry-run CFO (HITL-010, без submit) [op]; FCA-статус вопрос [op OD-R20 / ext ED-10].
- **Prereq:** A3. **Blocks:** OD-R20; ED-10; UNK-10.
- **Exit:** 5 подряд зелёных recon; FIN060 dry-run подписан. **Gate:** CFO+MLRO.

### S-A7 — Payment rails activation · [LC] · [code][op][ext]
- **Why:** без рельсов slice не банк, а витрина; ключи — длиннейший внешний lead-time.
- **Purpose/Scope:** hardening 6 стабов + observability [code]; ключи [ext ED-01/02, op OD-R16]; PSD2 router выбор [op OD-R07]; switch-on по runbook, HITL-016 ≥£50k [op]. Cards — вне спринта (UNK-09).
- **Prereq:** A5, A6, ключи. **Blocks:** OD-R07/R16; ED-01/02.
- **Exit:** sandbox e2e платёж; первая controlled-live транзакция. **Gate:** CTIO+COO/CFO.

### S-A8 — CFO / reporting stack · [PL] · [code][op][ext]
- **Why:** полный регуляторный цикл важен, но dry-run из A6 достаточен для запуска slice.
- **Purpose/Scope:** finance-агенты волна-2 [op OD-R14]; RegData live (HITL-010) [op/ext ED-10]; ALCO-отчёты из dbt [code].
- **Prereq:** A6. **Blocks:** OD-R14; ED-10.
- **Exit:** первый live FIN060 цикл. **Gate:** CFO.

### S-A9 — Crypto readiness (Paybis) · [PX] · [code][op][ext]
- **Why:** crypto вне launch slice; готовим, не блокируя запуск.
- **Purpose/Scope:** Wave B mock-тесты [code]; SRC-06/07/08 [ext ED-08/09]; Travel-Rule заготовка + MLRO-runbook [code]; ADR-114 [op OD-R17].
- **Prereq:** A5. **Blocks:** OD-R17; ED-08/09; UNK-02.
- **Exit:** Wave B зелёный или явный deferred. **Gate:** MLRO+operator.

### S-A10 — HII client surface + XAI · [LC]-минимум · [code][op]
- **Why:** slice нужен клиентский вход; всё сверх минимума — [PX].
- **Purpose/Scope:** минимум [code]: Home (balance+Quick Actions+AI Insight Card) + чат streaming + TransferCard/KYCProgressCard + human-escalation [PLAN-CONCEPT uxui]; XAI в HITL-формах (ADR-169) [code]; banxe-ui CI [op из OD-R06]; FOS portal [ext ED-06 — PL-часть]. Прочие поверхности (FX-rich/Crypto/Cards/Analytics-deep/Savings/Marketplace/voice) — [PX].
- **Prereq:** A4. **Blocks:** OD-R22; UNK-12; ED-06 (не блокирует минимум).
- **Exit:** пилотный сценарий «клиент → intent → confirmation → исполнение → lineage» в sandbox portal (ADR-101). **Gate:** CTIO+product.

### S-A11 — API/BaaS/MCP exposure · [PX] · [code][op]
- **Why:** внешняя поверхность — после security-закрытия и только по операторской модели.
- **Purpose/Scope:** BaaS-модель [op OD-R18]; экспозиция подмножества API/MCP за auth + rate-limits [code].
- **Prereq:** A12. **Blocks:** OD-R18; UNK-06.
- **Exit:** документированная закрытая-по-умолчанию поверхность. **Gate:** CTIO+security.

### S-A12 — Security/observability closure · [LC] · [code][op]
- **Why:** запуск с открытыми P1 security-GAP невозможен.
- **Purpose/Scope:** GAP-082 [op]; GAP-090 остаток [code]; evo2 Prometheus [op]; rails-дашборды [code]; sandbox pen-check [code].
- **Prereq:** параллельно A7+. **Blocks:** OD-R06(evo2)/R08; ED-07.
- **Exit:** 0 открытых P1 security-GAP. **Gate:** CTIO+CEO.

### S-A13 — Launch governance / go-live · [LC] · [code][op][ext]
- **Why:** финальный переключатель «здание → действующий банк».
- **Purpose/Scope:** launch-пакет (все exit-критерии + рубрика roadmap v2) [code]; полный dry-run [code+op]; L3-gate движка [op OD-R15]; финальные подписи; controlled go-live [op]. **После запуска:** поэтапное включение L3 Conditional по BPR-правилам (S12 концепт-линии) и запуск monthly evidence review (S13 → [PX]).
- **Prereq:** все [LC]. **Blocks:** OD-R15; ED-11; UNK-03 (Board-процедура).
- **Exit:** go-live executed; post-launch мониторинг активен. **Gate:** CTIO+CEO+MLRO+CFO; Board [UNKNOWN].

## Blocking matrix

| Sprint | OD | ED | UNK |
|---|---|---|---|
| S-A0 | R09 | — | — |
| S-A1 | R01–R06 | ED-12 | UNK-04 |
| S-A2 | R10, R12 | — | UNK-11 |
| S-A3 | R13 | — | — |
| S-A4 | R11, R21 | — | UNK-07 |
| S-A5 | R14 | ED-03/04/05 | — |
| S-A6 | R20 | ED-10 | UNK-10 |
| S-A7 | R07, R16 | ED-01/02 | UNK-09 (cards out) |
| S-A8 | R14 | ED-10 | — |
| S-A9 | R17 | ED-08/09 | UNK-02 |
| S-A10 | R22 | ED-06 (PL) | UNK-12 |
| S-A11 | R18 | — | UNK-06 |
| S-A12 | R06(evo2), R08 | ED-07 | — |
| S-A13 | R15 | ED-11 | UNK-03 |

## Exit criteria matrix

| Sprint | Ключевой измеримый exit |
|---|---|
| S-A0 | план merged + IL |
| S-A1 | 6 OD закрыты, GDPR исполнено |
| S-A2 | Qdrant LISTENING + BudgetExceeded-тест зелёный |
| S-A3 | 17/17 форм live + L2-петля пройдена |
| S-A4 | e2e intent-цепочка + revocation-тест + L0/L1 live (sandbox) |
| S-A5 | overlay-латентности в бюджете + MLRO-очередь работает |
| S-A6 | 5× зелёных recon + FIN060 dry-run подписан |
| S-A7 | первая controlled-live транзакция FPS/SEPA |
| S-A8 | первый live FIN060 цикл |
| S-A9 | Wave B зелёный / deferred зафиксирован |
| S-A10 | пилотный клиентский сценарий e2e в sandbox portal |
| S-A11 | внешняя поверхность документирована и закрыта по умолчанию |
| S-A12 | 0 P1 security-GAP |
| S-A13 | go-live executed + post-launch мониторинг |

## Epic addendum (rev. 3 — additive, P0/P1/P2)

Аддитивная надстройка: эпики привязаны к существующим спринтам, ничего из плана выше не удалено. Приоритеты: P0 = до production Intent Layer, P1 = дифференциатор после P0-ADR, P2 = platform/scale после первых клиентов.

### P0 — Epic «Governed Intent Layer v1» [LC]

Закрывает 3 частично закрытых guardrails Unified Concept (cost-policy, Decision Lineage schema, HITL-threshold policy) [PLAN-CONCEPT→канон через ADR].

| Sprint | Содержание | Привязка | ADR |
|---|---|---|---|
| G1 IntentRecord Schema + lifecycle | схема, SCA consent-at-delegation, revocation | = S-A4.2 | **ADR-171** (new, PROPOSED) |
| G2 Decision Lineage + Lineage Explorer | конкретизация v1.0 (ClickHouse TTL 7yr, wrapper) + внутренний Lineage Explorer UI [code, new deliverable] | = S-A4.1 (+Explorer) | ADR-046 (существует, ACCEPTED — амендмент-конкретизация, НЕ новый номер, ADR-102 reuse) |
| G3 Autonomy Ladder + HITL-policy | лестница L0–L4, пороги повышения | = S-A3 + S-A4 | **ADR-172** (new, PROPOSED; расширяет ADR-128) |
| G4 Cost-Policy Engine + guardrails | per-agent caps, stop-conditions, circuit breakers | = S-A2 | ADR-047 (существует, ACCEPTED — runtime-конкретизация, НЕ новый номер) |

### P0 — Epic «Delegation Center v1» [LC-min/PL]

| Sprint | Содержание | Привязка |
|---|---|---|
| UX-Delegation-1 | UI управления Intent'ами: список активных ClientIntentRecord, лимиты, уровень автономии, **revocation** | новый под-спринт **S-A10.1**; revocation-часть = [LC] (право отзыва должно быть клиентски реализуемо в slice), остальное [PL] |

### P1 — Epics (после P0-ADR, до платформы) [PL]

| Epic | Sprints | Примечание |
|---|---|---|
| SME Business Co-Pilot v1 (Cashflow+Debt) | SME-C1 (Cashflow Forecast Engine + Cashflow Insight Card), SME-C2 (Debt Dispatcher v1) | поверх работающего L2; кандидат в WS18-Commercial |
| Compliance Co-Pilot v1 | SME-Comp1 (Compliance Readiness Score + KYC/KYB Gap Finder), SME-Comp2 (Transaction Risk Overlay + Audit Pack Builder) | переиспользует overlay из S-A5 |
| Rich Cards Core v1 | UX-Rich1 (ConfirmationCard, FXRateCard), UX-Rich2 (Cashflow Insight Card, ExplanationCard) | ConfirmationCard уже в S-A10-минимуме; UX-Rich1 частично [LC] |

### P2 — Epics (platform/scale, после первых клиентов) [PX]

| Epic | Sprints | Привязка |
|---|---|---|
| Intent-First Partner API | BaaS-1 (ClientIntentRecord API CRUD+docs), BaaS-2 (Partner Dashboard v1: intents/lineage/compliance) | детализация S-A11/WS13; гейт OD-R18 |
| MCP Server v1 | MCP-1 (core + регистрация внешних агентов), MCP-2 (governance adapter: autonomy levels + cost-caps) | детализация S-A11; внешняя экспозиция только после S-A12 |
| Business Co-Pilot v2 | SME-C3 Client Radar, SME-C4 Supplier Watchdog, SME-C5 Scenario Board, SME-C6 Budget Coach, SME-Comp3 Compliance Navigator + Auto Healthcheck | требует UNK-13 (commercial-допущения) |

**GitHub Projects/issues:** интеграция из фабрики не выполняется (I-71: никаких gh-мутаций). Список issue-кандидатов = строки таблиц выше (эпик → milestone, спринт → issue); заведение — операторски/Central после ратификации.

---
*DRAFT / NOT FOR MERGE. Producer: factory sandbox terminal, 2026-07-18 (rev. 3 — epic addendum).*
