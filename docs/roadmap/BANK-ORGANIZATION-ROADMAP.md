# BANK-ORGANIZATION-ROADMAP — Организация банка нового поколения BANXE (35 репо)

> **STATUS: PROPOSED — каждый спринт требует отдельной операторской авторизации; ничего не активировано.**
> ⚠ SANDBOX / TRAINING context (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false).
> STEP9 v3, ENGREF01, 2026-07-26. СВОДИТ существующий канон (ссылки, не дубли) + закрывает 6 пробелов
> аналитик Intent-First / BDSL / мировой-опыт. Companion: `../architecture/DIRECTOR-CONTROL-PLANE.md`.
> Барьеры на всех спринтах: LedgerPort-only (ADR-013/I-28), `config/runtime_gate/` §72, MEMORY.md,
> `decisions/` заморожены (73+ ссылки), ADR-102 Duplication Audit перед любым переносом.

## §0. ПАРАМЕТРЫ БАНКА НОВОГО ПОКОЛЕНИЯ (существующий канон + закрытие пробелов)

Из существующего канона:
| Параметр | Источник |
|---|---|
| AI-native: сотрудники = AI-агенты + human-double HITL | `docs/master-document/01-master-full.md` v3.0 |
| Composable open-source (не монолит) | `COMPOSABLE-ARCH.md` (6 независимых оркестрируемых контуров), ADR-013 |
| Event-driven: Midaz / Kafka / Temporal | master-doc v3.0; `docs/engine/BANXE-AI-ENGINE-REFERENCE.md` L1–L2 |
| Explainable & compliant-by-design (EU AI Act, GDPR, CASS 15, SM&CR) | ADR-169, ADR-171, `banxe_audit.hitl_decisions` |
| Confidence-gated autonomy (0.75/0.90 + HITL) | `config/gates/confidence-thresholds.yaml` (sandbox-active); agents.md BUG-007 |
| Fail-closed-over-best-decide | `docs/canon/BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md` |
| 3 Lines of Defence + SM&CR owners | `governance/CANONICAL-ORG-CHART-v2.md` (NORMATIVE) |
| Federated / privacy-preserving | engine-reference L4 (FATE, VaultGemma), analytics #3 |
| Foundation-model-driven (PRAGMA-style) | `docs/engine/BANXE-ENGINE-MATH.md` §10, roadmap E5 |
| Текущее покрытие ~30–35% (payment rails 0%, Treasury 0%, CBS ~5% — GAPS) | master-doc v3.0; ROADMAP-STATUS-2026-06-23 S-PROD-3 |

Добавлено из аналитик (закрытие пробелов):
- **INTENT-FIRST / AGENT-AS-INTERFACE:** chat-first Intent Layer вместо UI-кликов; AI-ассистент = точка входа
  (Revolut AIR / Starling / bunq Finn 2026); UI = fallback. Якоря: ADR-167 (assistant-ui intent-first),
  `docs/adr/ADR-172-client-intent-record-schema.md`, `tools/sandbox/intent_slice/` (D2-CS6).
- **DATA SOVEREIGNTY:** on-premises AI (Legion/evo1/evo2), zero 3rd-party storage — trust premium
  (vs BBVA/OpenAI cloud). Якоря: VietBank-модель (analytics #3 E11), LiteLLM self-host маршруты.
- **COMPLIANCE-NATIVE (не bolt-on):** governance встроен в Intent Layer с рождения (vs retrofitted AI
  Revolut 65%). Якоря: Ruflo/ARL mandatory middleware, ADR-030 Trust Zones.

## §1. DIRECTOR-CENTRIC УПРАВЛЕНИЕ

- **Директор = `ceo_orchestration_agent`** (существующий: `agents/souls/ceo-orchestration-agent.md`,
  Level 1 top orchestrator; статус **PROPOSED/STUB — GAP-078, service-кода нет**; human double =
  **CEO Moriel Carmi, SMF1**; активация = HITL-L4 гейт).
- К директору сходятся **8 department heads** (`governance/CANONICAL-ORG-CHART-v2.md`, NORMATIVE);
  independent lines (internal audit, risk oversight, board reporting) — вне департаментов, к Board.
- Director control plane = engine-reference **L6 orchestration** (ACTIVE sandbox). Директор видит:
  8 департаментов, весь реестр агентов, статусы; управляет через оркестрацию; **НЕ активирует сам**
  (I-27/HITL; активация — операторские гейты).
- Иерархия: **Level 0 Board/люди → L1 Executive AI (CEO-агент) → L2 Department Heads → L3 Team Leads →
  L4 Workers**; human_double только на L1/L2 и независимых линиях (org-chart-v2 принцип 4).

## §2. ИСТОЧНИК КАНОНОВ: Fable5 через фабрику

Banking-canon (оргправила, роли, полномочия, FCA/SM&CR-рамки) — запрос фабрики → **Fable5** (read-only
advisory, confidence-scored, **<0.90 → HITL**) → PROPOSED canon-артефакт → оператор ратифицирует.
Fable5 не пишет код и не активирует. Хуки — в спринтах §4. Прецедент модели: D1=0.95 auto / D2=0.80 HITL (ADR-171).

## §3. РЕГУЛЯТОРНЫЙ СЛОЙ FCA-2026 (каждый пункт → banking-canon-запрос к Fable5; PROPOSED; привязка к датам)

| Тема | Содержание | Canon-запрос |
|---|---|---|
| FCA agentic-AI payments | PSR 2017; SCA для machine-initiated платежей; consent-at-delegation | F5-REG-1 |
| SM&CR personal liability | связка SMF-holder ↔ Decision Lineage (каждое агентное решение прослеживается к SMF-человеку; 2026-02-24) | F5-REG-2 |
| Safeguarding PS25/12 | дедлайн 2026-05-07 (S-PROD-1 OVERDUE) — приоритет back-office волны (D1) | F5-REG-3 |
| Consumer Duty reversibility | `revocation_method` обязателен в ClientIntentRecord | F5-REG-4 |
| DORA / PSD3 | continuous reconciliation, операционная устойчивость | F5-REG-5 |
| EU AI Act | Art.9 (risk mgmt) / Art.14 (human oversight) / Art.15 (accuracy) / Art.17 (QMS) + Annex III/IV; **Art.49 — регистрация в EU DB к Aug 2026** | F5-REG-6 |
| GDPR Art.22 | право не подпадать под чисто автоматизированное решение — HITL-контракт для клиентских решений | F5-REG-7 |
| BaFin HITL | немецкий надзорный паттерн human-in-the-loop (EU-экспансия) | F5-REG-8 |

## §4. СПРИНТЫ (все PROPOSED, по-спринтно operator-gated)

Формат каждого: цель · входы (ссылки) · выходы · роль Director · Fable5-хуки · риски · зависимости · DoD.

### S0 — Инвентаризация 35 репо
Цель: паспорт+классификация. Входы: repo-аудит; `config/fleet/server-inventory.yaml`.
Классификация: **CORE-BANK** banxe-architecture, banxe-emi-stack, banxe-ui, banxe-payment-core,
banxe-trading-backend/frontend · **PLATFORM/INFRA** banxe-ai-infrastructure, banxe-platform, banxe-infra,
banxe-monitoring, banxe-collaboration · **GOVERNANCE** factory, banxe-business-processes, banxe-repo-template ·
**ENGINE/RESEARCH** OpenManus-RL, MetaClaw, MiroFish/banxe-mirofish, developer-core, OpenManus ·
**KNOWLEDGE/LEGAL** legal-canon, legal-reference-fr, banxe-lexisnexis-distro, banxe-training-data,
crypto-ops-monitor · **ARCHIVE(freeze)** banxe-archive-2026-04-18, collaboration, legi_fr,
gpt-archive-toolkit, france.code-civil, obsidian-vault, braslina, guiyon, ss1.
Выход: REPO-PASSPORT-REGISTER.md. **Director: утверждает классификацию.** Fable5: не требуется.
Риск: незамеченные репо. DoD: 35/35 в реестре с категорией.

### S1 — Технологическая карта (cross-repo ORG-MAP)
Цель: репо→департамент (из 8, org-chart-v2)→bank-rooms F0–F4→emi-stack services→`SERVICE-MAP.md`→
`archimate/banxe-model.xml`. Выход: ORG-MAP.md. **Director = владелец ORG-MAP.**
**Fable5 F5-ORG-1: canon department↔repo mapping.** Риск: двойная принадлежность. Зависимость: S0.
DoD: каждый не-ARCHIVE репо → ровно один департамент; canon ратифицирован.

### S2 — Перепись штата + закрытие org-chart-v2 Sprint-2 TODO
Цель: единый cross-repo реестр агентов (souls/passports/swarms из architecture+emi-stack+ai-infrastructure;
расширение реестра `BANXE-AI-ENGINE-REFERENCE.md` §2 — второго не создавать); **СОЗДАТЬ недостающие
department-head паспорта: ceo / cfo / coo / cro / board_reporting / internal_audit / risk_oversight (PROPOSED)**;
пробелы: агент-без-инструкции / инструкция-без-агента / дубли (изв. HELD: aml_orchestrator 3-паспорта — operator/MLRO).
**Director: владелец реестра.** Fable5: не обязателен (спорные дубли → HITL).
Риск: stub-паспорта со status:active (читать тело). Зависимость: S1. DoD: 100% агентов в реестре; head-паспорта созданы (PROPOSED).

### S3 — Оргструктура
Цель: связать Director→8 heads→L3 team-leads→L4 workers по org-chart-v2; human_double только L1/L2 +
независимые линии. Выход: ORG-STRUCTURE.md (+additive к `AGENT-ORG-STRUCTURE.md`).
**Director: вершина reports_to-цепочки.** **Fable5 F5-ORG-2: canon иерархии полномочий / 3LoD.**
Риск: конфликт с Trust Zones/HITL — только additive. Зависимость: S2. DoD: каждый агент имеет путь к Director.

### S4 — Должностные инструкции
Цель: дописать souls/passports по `agents/_template/` + `agents/souls/_TEMPLATE.md`; обязательные поля:
**reports_to** (вверх к директору), **SMF-mapping**, **trust_zone**, **level**. Все PROPOSED (PASSPORT > SOUL).
**Director: валидатор полноты штата.** **Fable5 F5-ORG-3: canon шаблона должности** (полномочия/лимиты/эскалация).
Риск: массовые правки паспортов → по-департаментно. Зависимость: S3. DoD: 0 агентов без паспорта, 100% с reports_to.

### S5 — Разнос кода из подвала
Цель: бесхозный код → repo/room/agent; **закрыть GAP-078 (service-код ceo_orchestration_agent)**;
владение в ORG-MAP. Входы: ORG-MAP, реестр, Phase-2 наработки (docs/roadmap/PHASE2-*).
**Director: реестр владения кодом.** Fable5: не обязателен. Риск: скрытые консьюмеры (ADR-102 fail-closed);
emi-stack scope = back-office до новых гейтов. Зависимости: S1–S3. DoD: 0 бесхозных модулей; GAP-078 закрыт (PROPOSED-код).

### S-INTENT — Intent Layer (Intent-First парадигма)
Цель: реализовать **ClientIntentRecord** (dataclass: intent_id, client_id, intent_type, natural_language,
parsed_params, consent_timestamp, consent_method, scope_limits, revocation_method, expires_at,
linked_agent_id, linked_budget_policy_id) — базис: `docs/adr/ADR-172-client-intent-record-schema.md`,
`tools/sandbox/intent_slice/` (уже на main, D2-CS6).
Поток: **Intent Capture → Business Process Repository lookup → Agent Budget check → Execution → Decision Lineage.**
SCA consent-at-delegation (PSR 2017). **Dual-track UX** (AI-трек + классический параллельно — паттерн
Alipay/KakaoBank, analytics #3): Classic Layer равноправен, не деградация. **Director: intent-маршрутизация через L6.**
**Fable5 F5-REG-1: canon FCA agentic-payments.** Риск: W-05 prod-guard (снят только в sandbox). Зависимости: S13-00, S-COST.
DoD: intent-поток работает в sandbox на TRAINING; каждый intent в lineage.

### S-COST — AI Cost Governance
Цель: свести `governance/ai-cost-policy/agent-budget-policy.md` + ADR-037 + LiteLLM BudgetManager:
max_tokens_per_task, max_cost_per_job, retry_ceiling, **halt_on_exceed**, escalation_path; защита от
looping-agent (кейс $30K/6ч). Привязка Safeguarding PS25/12 (стоимость не может съесть safeguarding-объёмы).
Смежность: ADR-030 runtime_gate budgets (**чужой трек §72 — интеграция только joint change-set**).
**Director: бюджетная видимость per-agent/per-case.** Fable5: не обязателен. Зависимости: нет (ранний).
DoD: халт-контур в sandbox; 0 путей исполнения мимо budget-check.

### S-BDSL — Best-Decision Self-Learning Loop (спецификация аналитики BDSL — реализовать)
- DecisionRecord + OutcomeRecord schema (append-only, hash-chain `prev_record_hash`, WORM/Kafka);
- MAUT-утилиты (U=Σ wj·uj), decision_space, Pareto frontier, stopping_rule (satisficing vs full-search;
  secretary-правило 37%);
- MetricsEngine: **Regret R̄ ≤0.05** · Brier ≤0.15 · ECE ≤0.08 · Pareto Efficiency ≥0.95 ·
  Escalation Recall ≥0.98 · Minimax suboptimal ≤5%; counterfactual-оценка: **IPW / causal forest**;
- **Best-Decision Test Gate (BDT):** authoring blocking + runtime 24h, окно 90d;
- Confidence tiers: AUTO ≥0.90 / REVIEW 0.70–0.90 / BLOCK <0.70; **compliance/payment AUTO ≥0.95**;
- **NEVER-AUTONOMOUS LIST**: payments/compliance всегда human; RLHF self-mod human-gated;
  **no satisficing в payment/compliance** (только full-search); **no auto-unblock**;
- RLHF Reward Model (human-approved only); bias probes (prospect/anchoring/omission, contrastive);
- **Drift-контроль: PSI > 0.25 → эскалация**;
- ImprovementProposal → Human Review Queue (SLA: CRITICAL 4h / MAJOR 24h);
- EU AI Act Art.9/14/15/17 + GDPR Art.22 маппинг.
**Director: потребитель метрик, узел Review Queue.** **Fable5 F5-BDSL-1: canon Never-Autonomous + tiers.**
Зависимости: S-LINEAGE (schema), S-COST. DoD: BDT-гейт активен в sandbox; метрики считаются; лист ратифицирован.

### S13-00 — Business Process Repository
Цель: связать репо `banxe-business-processes`; ArchiMate import; **rule-bound interpreter поверх LLM-intent**
(детерминизм для FCA/IMF); BP-rules (напр. BP-042 recurring_payment_under_1000).
**Director: BPR = его свод процессов.** Fable5: canon процессной нотации (при необходимости).
Зависимость: S1. DoD: BPR-lookup доступен intent-потоку.

### S-LINEAGE — расширение Decision Lineage
Цель: апгрейд `banxe_audit.hitl_decisions` до **AgentDecisionRecord**: + triggering_event,
intent_id (→ClientIntentRecord), policies_evaluated (→BPR), reasoning_summary, confidence_score,
action_taken, action_params, **human_reviewed_by, human_override**, halt_triggered, halt_reason, outcome;
согласовать со STEP5-схемой (уже применённой в sandbox: 14+8 колонок).
Метод: **DELTA ALTER** (прецедент engine-ref +8; вторая таблица запрещена, ADR-102); sandbox → prod по G1.
⚠ Примечание к заданию: предложенный `ORDER BY (agent_id, created_at)` **конфликтует** с канонической
сортировкой STEP5 `ORDER BY (decision_id, ts)` — sorting key в ClickHouse не меняется ALTER'ом;
разрешение (оставить каноническую / проекция / materialized view по agent_id) = решение внутри спринта
с operator-ревью, НЕ вторая таблица. TTL 7Y сохраняется.
**Director: lineage = его аудиторская память.** Fable5 F5-REG-2 (SM&CR-связка). Зависимость: S-INTENT (intent_id).
DoD: расширенная схема в sandbox; каждый intent-путь пишет полный record.

### S-TRAIN — Дообучение движка-директора Banksy (BDSL as training program)
Цель: непрерывно дообучать директора (`ceo_orchestration_agent` + engine control-plane) принимать
Best-Decision замкнутым циклом. Методика (полная): `../engine/BANKSY-TRAINING-BDSL.md`.
Контуры: 1-СБОР (DecisionRecord: decision_space/MAUT wj-uj/chosen/confidence/tier/stopping_rule/bias_flags/
minimax_regret/hash-chain + OutcomeRecord: ground_truth_utility/utility_error/IPW-causal-forest) →
2-ОЦЕНКА (MetricsEngine, пороги S-BDSL) → 3-**RLHF human-gated 3 стадии** (Preference→RM offline hold-out→
Policy Update ТОЛЬКО после human approval, PPO; никакой self-modification) → 4-SELF-LEARNING
(ImprovementProposal→Human Review Queue SLA 4h/24h→APPROVED versioned update) → 5-DRIFT (PSI>0.25;
re-test BDT 24h при drift/volume-spike/regulatory-event; Cross-Agent Correlation 3+ = системная причина) →
6-GATE (BDT: authoring **min 500 cases** blocking + runtime 24h/90d) → 7-BIAS (contrastive probes;
prospect_bias_rate>0.03→REVIEW) → 8-TIERS (AUTO≥0.90/REVIEW/BLOCK; payment/compliance AUTO≥0.95).
**NEVER-AUTONOMOUS при обучении:** директор не переобучает себя без human approval; payment/compliance
всегда human; веса/пороги — только APPROVED proposal + **Compliance Officer sign-off**; RLHF offline+human.
Регуляторика: AI Act Art.9/14/15/17 + GDPR Art.22 + BaFin; лог 7Y hash-chain WORM.
Rollout: Ph0 (инфра+калибровка: Brier<0.20, R<0.10, 500 ground-truth) → Ph1 shadow low-risk →
Ph2 (BDT PASS 3 мес + EU-conformity + EU-DB-reg Aug 2026) → Ph3 (compliance/payment AUTO≥0.95).
**Director: субъект обучения И потребитель (Decision Quality Registry).**
**Fable5 F5-TRAIN-1: canon границ обучения (Never-Autonomous, human-gate на policy update).**
Зависимости: S-BDSL (схемы/гейт), S-LINEAGE (лог). DoD: Ph0 green в sandbox; цикл 1–8 работает на TRAINING;
0 policy-updates без human approval.

### S6 — Уборка документации *(перенесено из v1-каркаса)*
R1 canon-консолидация (operator-review 20+37 diff-строк) + R2 слияние ADR-индексов + R3 перенос 11 корневых
кандидатов + STEP8-аудит для каждого CORE/PLATFORM репо + cross-repo doc-index + сверка controlled-copy canon
(banxe-repo-template). Зависимости: нет. DoD: R1–R3 закрыты; controlled-copies синхронны/ратифицированы.

### S7 — Валидация
Каждый агент = {место + инструкция (reports_to) + код + SMF/level}; 0 бесхозных коробок; 0 сотрудников без
кабинета; **Director control plane видит 100% штата**; **3LoD целостны**; cross-repo canon синхронен;
**GAPS master-doc (payment rails 0% / Treasury 0% / CBS ~5%) трекаются** явным списком; **BDSL-метрики
зелёные** (R̄≤0.05, Brier≤0.15, ECE≤0.08, Recall≥0.98). Выход: VALIDATION-REPORT.md → go/no-go к PROD-gate
G0–G6. Fable5: финальный advisory (confidence-scored).

### Фаза Z — ARCHIVE (9 репо)
Только опись + заморозка; включение любого архивного репо = отдельное операторское решение.

## §5. Сводка объёма и порядок

**13 спринтов** (S0–S5, S-INTENT, S-COST, S-BDSL, S13-00, S-LINEAGE, **S-TRAIN**, S6, S7) + фаза Z · 35 репо ·
**Fable5-canon-запросы: 8 регуляторных (F5-REG-1…8) + 3 организационных (F5-ORG-1…3) + 1 BDSL + 1 TRAIN
(F5-TRAIN-1) + 1 финальный advisory (S7) = 14 хуков** · Director-роль явно прописана во всех 13 спринтах.
Рекомендуемый порядок волн: S0→S1→S2 (фундамент) ∥ S-COST+S6 (независимые, ранние) → S3→S4 →
S13-00→S-INTENT→S-LINEAGE→S-BDSL→**S-TRAIN** (intent/learning-контур) → S5 → S7. Всё PROPOSED; авторизация по-спринтно.

> **OPEN POINT v2 — ЗАКРЫТ:** хвост доставлен в STEP9-v3 (S6/S7/Z подтверждены — совпали с v1-сохранением;
> добавлен Документ 2 `../architecture/BANK-NEXT-GEN-CONCEPT.md`). Остаточный обрыв v3 («Обновить
> docs/DOCUMENTATION-MASTER-INDE…») тривиален — индекс обновлён по установленному паттерну.

---
*STEP9 v2 | ENGREF01 | PROPOSED | sandbox-labeled | сведение канона + 6 пробелов аналитик; Director-centric + Fable5-canon-on-demand.*
