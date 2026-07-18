# BANK SPRINT PLAN — EXECUTION DRAFT

> **Status:** **DRAFT / NOT FOR MERGE** · **Date:** 2026-07-18 · **База:** origin/main @ c66c198
> **Producer:** factory terminal (sandbox) для **Central terminal**
> **Parent:** `BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` (v2) — реестры OD-R/ED/UNK живут там, здесь только ссылки.
> **Маркировка:** [FACT-REPO]/[PLAN-CONCEPT]/[INFERENCE]/[UNKNOWN] · Классы: [LC]/[PL]/[PX] · Типы действий: [code]/[op]/[ext]

## Rules of use

1. Central ведёт исполнение спринт за спринтом; фабрика получает [code]-задачи как spec-build; [op] — только оператор; [ext] — внешние стороны.
2. Спринт закрыт только при выполнении всех exit-критериев и подписи gate-owner.
3. Никакой пункт [PLAN-CONCEPT] не исполняется в regulated-зоне до ратификации соответствующего ADR (OD-R21).
4. I-71/I-27/worktree-isolation действуют на всех спринтах.

## Sprint sequencing logic

[INFERENCE] Порядок = «надзор прежде входа, вход прежде денег, деньги прежде рельсов»: губернанс-субстрат (A1–A3) → intent-вход в sandbox (A4) → комплаенс-поток и KYC (A5) → CASS-контур (A6) → внешние рельсы (A7) → security-закрытие (A12) → запуск (A13). A8/A9/A10/A11 паркуются на своих зависимостях, не блокируя хребет. Концепт-линия S9–S13 (intent-layer-launch) вложена в A4/A5/A13: S9→A4.1, S10→A4.2, S11→A5, S12→A13/post, S13→[PX].

## Sprint table

| Sprint | Класс | Название | Gate owner | Критический пред-к |
|---|---|---|---|---|
| S-A0 | [LC] | Planning baseline | operator | — |
| S-A1 | [LC] | Governance decisions & roles | CEO/CTIO/MLRO/Legal | — |
| S-A2 | [LC] | Runtime activation prereqs | CTIO | A1 частично |
| S-A3 | [LC] | HITL live binding | CTIO+MLRO | A1 |
| S-A4 | [LC] | Intent substrate + L0/L1 sandbox | CTIO | A2, A3 |
| S-A5 | [LC] | Compliance overlay + L2 + KYC live | MLRO | A3, A4 |
| S-A6 | [LC] | CASS/safeguarding closure | CFO+MLRO | A3 |
| S-A7 | [LC] | Payment rails activation | CTIO+COO/CFO | A5, A6, ED-01/02 |
| S-A8 | [PL] | CFO / reporting stack | CFO | A6 |
| S-A9 | [PX] | Crypto readiness (Paybis) | MLRO+operator | A5, ED-08/09 |
| S-A10 | [LC]min | HII client surface + XAI | CTIO+product | A4 |
| S-A11 | [PX] | API/BaaS/MCP exposure | CTIO+security | A12, OD-R18 |
| S-A12 | [LC] | Security/observability closure | CTIO+CEO | параллельно A7+ |
| S-A13 | [LC] | Launch governance / go-live | CTIO+CEO+MLRO+CFO | все [LC] |

## Per-sprint details

### S-A0 — Planning baseline [LC]
- **Purpose:** канонизировать план v2. **Scope:** ратификация roadmap+sprint-plan (OD-R09), выбор имени BANK-memo, фикс двойной маркировки ADR-046..049 [code], drafting OD-R19/OD-R21 ADR-заготовок [code].
- **Deliverables:** merged план (операторский merge), 2 draft-ADR. **Prereq:** нет. **Blockers:** OD-R09.
- **Exit:** план в main; IL-запись; cadence решён [op]. **Gate:** operator.

### S-A1 — Governance decisions & roles [LC]
- **Purpose:** снять операторские блокеры одним пакетом. **Scope:** OD-R01 (GDPR — **вне очереди, день 1**) [op]; OD-R02/03 кадры [op]; OD-R04/05 реестр-фиксы [op]; OD-R06 пакет 8 conformance [op]; амендмент org-chart после назначений [code].
- **Deliverables:** назначения зафиксированы; decision-memo по 8 пунктам [code]; GDPR-нотификация исполнена/отклонена с обоснованием.
- **Prereq:** нет. **Blockers:** только операторская доступность. **Exit:** OD-R01..R06 закрыты. **Gate:** CEO/CTIO/MLRO/Legal.

### S-A2 — Runtime activation prereqs [LC]
- **Purpose:** движок готов к включению. **Scope:** Qdrant evo1 deploy (B1) [code+op OD-R10]; верификация LiteLLM BudgetManager конфига (UNK-11) [code]; при отсутствии — конфиг per-agent budgets/BudgetExceededError/halt по agent-budget-policy [code, PLAN-CONCEPT→через OD-R21]; решение ADR-133 [op OD-R12, не блокирует запуск INFERENCE].
- **Deliverables:** Qdrant :6333 LISTENING; `agent-budget-policy.md` draft (10 агентов: max_tokens/max_cost/retry_ceiling/halt/escalation) [code]. **Exit:** healthcheck зелёный; cost-caps подтверждены тестом BudgetExceeded. **Gate:** CTIO.

### S-A3 — HITL live binding [LC]
- **Purpose:** YAML→живые формы. **Scope:** Guardian-формы HITL-001..017 [code]; активация [op OD-R13]; L2-петля «двойник предложил — человек решил» в sandbox [code].
- **Prereq:** A1 (роли назначены). **Exit:** 17/17 форм работают; тест-прогон петли зелёный; каждая форма пишет в append-only audit. **Gate:** CTIO + MLRO (AML-гейты).

### S-A4 — Intent substrate + L0/L1 sandbox [LC]
- **Purpose:** открыть вход банка под полным надзором. **Scope (S9+S10 концепт-линии):**
  - A4.1 substrate [code]: DecisionLineageWrapper (запись до/после действия агента, без изменения логики) + AgentDecisionRecord ClickHouse (TTL 7yr) [PLAN-CONCEPT; частично IN-REPO: `services/agents/_lineage.py` FACT-REPO]; agent-budget-policy enforcement.
  - A4.2 intent capture [code+op]: ClientIntentRecord (intent_id/scope_limits/consent/revocation/expires) + SCA consent-at-delegation hook + revocation-механизм; BPR v1 = 10–15 YAML-правил, Compliance Officer approver; `INTENT_LAYER_ENABLED=true` sandbox [op OD-R11]; аудит 6 missing mask-вариантов (UNK-07) [code].
- **Prereq:** A2, A3; OD-R21 (ратификация схем). **Exit:** e2e intent→dispatcher→planner→A2A→lineage в sandbox; L0 Advisory + L1 Alert работают; revocation-тест зелёный. **Gate:** CTIO.

### S-A5 — Compliance overlay + L2 supervised + KYC live [LC]
- **Purpose:** боевой комплаенс-поток. **Scope (S11):** real-time overlay 3 уровня [code, PLAN-CONCEPT]: L1 fast-check <50ms → L2 rule-check (BPR+sanctions) <200ms → L3 deep-AML <2s с HITL-ticket; SAR-драфт цикл через HITL-001 (без подачи) [code]; sanctions auto-block тест (Watchman IN-REPO) [code]; Ballerine KYC e2e [code]; Sumsub при ключах [ext ED-03]; паспорта волна-1 L1 read-only [op OD-R14]; L2 Supervised операции: каждый перевод → confirmation card → человек [code].
- **Prereq:** A3, A4. **Exit:** полный путь intent→compliance-overlay→MLRO-очередь в sandbox; латентности в бюджетах. **Gate:** MLRO.

### S-A6 — CASS/safeguarding closure [LC]
- **Purpose:** операционный CASS-контур. **Scope:** daily recon live-режим [code+op]; shortfall HITL-011 цепочка [code]; FIN060 dry-run CFO (HITL-010, без submit) [op]; FCA-статус вопрос [op OD-R20/ED-10].
- **Prereq:** A3. **Exit:** 5 подряд зелёных recon; FIN060 dry-run подписан. **Gate:** CFO+MLRO.

### S-A7 — Payment rails activation [LC]
- **Purpose:** живые FPS/SEPA. **Scope:** hardening 6 стабов + observability [code]; ключи [ext ED-01/02, op OD-R16]; PSD2 router выбор [op OD-R07]; switch-on по runbook, HITL-016 контур ≥£50k [op].
- **Prereq:** A5, A6, ключи. **Exit:** sandbox e2e платёж; controlled live первая транзакция. **Gate:** CTIO+COO/CFO. Cards — вне спринта (UNK-09).

### S-A8 — CFO / reporting stack [PL]
- **Scope:** finance-агенты волна-2 [op OD-R14]; RegData live (HITL-010) [op]; ALCO-отчёты из dbt [code]. **Prereq:** A6. **Exit:** первый live FIN060. **Gate:** CFO.

### S-A9 — Crypto readiness [PX]
- **Scope:** Wave B mock-тесты [code]; SRC-06/07/08 [ext ED-08/09]; Travel-Rule заготовка + MLRO-runbook [code]; ADR-114 [op OD-R17]. **Exit:** Wave B зелёный или явный deferred. **Gate:** MLRO+operator. Не блокирует запуск [INFERENCE].

### S-A10 — HII client surface + XAI [LC-минимум]
- **Purpose:** клиентское лицо slice. **Scope:** минимум [code]: Home (balance+Quick Actions+AI Insight Card) + чат streaming + TransferCard/KYCProgressCard + human-escalation + «no excessive empathy» паттерн [PLAN-CONCEPT uxui]; XAI-отображение в HITL-формах (ADR-169) [code]; banxe-ui CI [op из OD-R06]; FOS portal [ext ED-06, PL].
- **Прочие поверхности (FX-rich/Crypto Hub/Cards/Analytics-deep/Savings/Marketplace/voice) — [PX], НЕ в slice.** **Prereq:** A4. **Exit:** пилотный сценарий «клиент → intent → confirmation → исполнение → lineage» в sandbox portal (ADR-101). **Gate:** CTIO+product (UNK-12/OD-R22).

### S-A11 — API/BaaS/MCP exposure [PX]
- **Scope:** BaaS-модель [op OD-R18]; экспозиция подмножества API/MCP за auth + rate-limits [code]. **Prereq:** A12. **Exit:** документированная закрытая-по-умолчанию поверхность. **Gate:** CTIO+security.

### S-A12 — Security/observability closure [LC]
- **Scope:** GAP-082 [op OD-R08-смежно], GAP-090 остаток [code], evo2 Prometheus [op], rails-дашборды [code], sandbox pen-check [code]. **Exit:** 0 открытых P1 security-GAP. **Gate:** CTIO+CEO.

### S-A13 — Launch governance / go-live [LC]
- **Scope:** launch-пакет (все exit-критерии + рубрика) [code]; полный dry-run [code+op]; L3-gate движка [op OD-R15]; финальные подписи; controlled go-live [op]; **после запуска:** включение L3 Conditional по BPR-правилам (S12 концепт-линии) поэтапно; monthly evidence review запускается как процесс [PX].
- **Prereq:** все [LC] спринты. **Exit:** go-live executed; post-launch мониторинг активен. **Gate:** CTIO+CEO+MLRO+CFO; Board [UNKNOWN UNK-03].

## Blocking matrix

| Sprint | Блокируется OD | Блокируется ED | Блокируется [UNKNOWN] |
|---|---|---|---|
| S-A0 | R09 | — | — |
| S-A1 | R01–R06 | ED-12 (юрист) | UNK-04 |
| S-A2 | R10, R12 | — | UNK-11 |
| S-A3 | R13 | — | — |
| S-A4 | R11, R21 | — | UNK-07 |
| S-A5 | R14 | ED-03/04/05 (частично) | — |
| S-A6 | R20 | ED-10 | UNK-10 |
| S-A7 | R07, R16 | ED-01/02 | UNK-09 (cards out) |
| S-A8 | R14 | ED-10 | — |
| S-A9 | R17 | ED-08/09 | UNK-02 |
| S-A10 | R22 | ED-06 (PL) | UNK-12 |
| S-A11 | R18 | — | UNK-06 |
| S-A12 | R06(evo2), R08 | ED-07 | — |
| S-A13 | R15 | ED-11 | UNK-03 |

## Exit criteria matrix (сводная)

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

---
*DRAFT / NOT FOR MERGE. Producer: factory sandbox terminal, 2026-07-18.*
