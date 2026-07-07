---
title: "SOURCE (verbatim, zero-loss) — Best-Decision Self-Learning Loop consultant spec"
provenance: operator-supplied consultant paper
intake_date: 2026-07-07
status: PROPOSED
classification: reference source (NOT canon)
body_bytes: 34974
body_sha256: c4f71e729f3791e97429f5482c405c201cee395b4d8daff6d9828ed53c30553f
---

# SSOT INTAKE HEADER (ADR-161) — read before the source body

**This file is a citable SOURCE, not canon.** It preserves, byte-for-byte, an operator-supplied consultant
specification on a Best-Decision Self-Learning Loop for the EMI BANXE agent fleet. The verbatim body follows this
header, unmodified.

- **Provenance:** operator-supplied consultant paper; intake 2026-07-07; status **PROPOSED** (reference only).
- **Body integrity (zero-loss):** body-bytes=`34974`, body-sha256=`c4f71e729f3791e97429f5482c405c201cee395b4d8daff6d9828ed53c30553f`.
  Verify: `tail -c 34974 <this-file> | sha256sum` MUST equal the body-sha256 above.
- **Thresholds/weights herein are the CONSULTANT's proposal, NOT adopted config.** Per Config-over-Hardcoding
  (CLAUDE.md §10), any adoption lands in governance config via a human-gated PR. Nothing in this file sets a live
  threshold, weight, or gate.
- **No canon is derived here.** Any derived canon (e.g. a future `BEST-DECISION-LEARNING-LOOP.md`) must be
  pointer-first to this source and to the anchors below — it must not restate thresholds.
- **Alignment note (informational):** the paper's confidence tiers (AUTO≥0.90 / REVIEW 0.70–0.90 / BLOCK<0.70)
  correspond to the existing **BUG-007** thresholds; its DecisionRecord/OutcomeRecord map onto
  `schemas/agent_decision_record.schema.json`; its "propose-only, human-gated" boundary corresponds to I-27 /
  `BEST-DECISION-BOUNDARY`. These are observations, not adoptions.
- **Anchors:** `.claude/rules/agents.md` (BUG-007), `schemas/agent_decision_record.schema.json`,
  `tests/best-decision/`, `governance/novelty-pipeline-config.yaml`, `docs/adr/ADR-162-best-decision-principle.md`,
  ADR-164 / `docs/design/BEST-DECISION-AGENT.md` (PR #1080, pending), `docs/canon/BEST-DECISION-BOUNDARY.md`,
  `docs/sources/best-decision-concept-2026-07-06-v2.md`, `docs/sources/emi-banxe-engine-2026-07-06.md`.

---

<!-- ===== VERBATIM SOURCE BODY BELOW — DO NOT EDIT (zero-loss, body-sha256 c4f71e729f3791e97429f5482c405c201cee395b4d8daff6d9828ed53c30553f) ===== -->
# Best-Decision Self-Learning Loop: Техническая Спецификация для Флота ИИ-Агентов EMI BANXE

> **Версия:** 1.0 | **Статус:** Draft-for-Review | **Регуляторный контекст:** EU AI Act Annex III (High-Risk), Art. 9, 14, 17; GDPR Art. 22; BaFin AI Principles

***

## 0. Принципы и Инварианты

Данная спецификация строится на трёх абсолютных инвариантах, нарушение которых недопустимо:

1. **Append-only immutability.** Ни одна запись decision-log не может быть изменена или удалена после создания. Только добавление.
2. **Human-gated activation.** Ни одно изменение решающих правил, весов, порогов compliance-/payment-контура не применяется без явного письменного утверждения уполномоченного человека (`APPROVER` роль в IAM).
3. **Explainability by construction.** Каждое решение агента должно быть объяснимо в человекочитаемых терминах до его принятия, а не постфактум.

Теоретическая база — концепция «Лучшего Решения» (см. первоисточник: *Best-Decision Concept Research*, 2026), в частности: VNM Expected Utility, MDP/Bellman Optimality, MAUT, Secretary Problem / Optimal Stopping, Prospect Theory (Kahneman & Tversky 1979), Satisficing (Simon 1978 Nobel Lecture), RLHF Pipeline, Minimax Regret.

***

## 1. Decision Record Schema

### 1.1 Модель данных: `DecisionRecord`

Каждый ИИ-агент обязан эмитировать строго типизированную запись при каждом принятии решения. Хранилище — append-only event log (Kafka / immutable object storage с WORM-политикой).

```json
{
  "$schema": "banxe/decision-record/v1.2",
  "record_id": "uuid-v4",                     // immutable primary key
  "agent_id": "agent:kyc-checker:v2.3.1",
  "agent_version": "2.3.1",
  "decision_domain": "KYC | AML | PAYMENT | CREDIT | COMPLIANCE | ESCALATION",
  "timestamp_utc": "ISO-8601",
  "trace_id": "distributed-trace-uuid",       // связь с request-span

  "context": {
    "entity_id": "customer/tx/account ref (hashed)",
    "session_id": "uuid",
    "input_hash": "SHA-256 of input payload",
    "input_schema_version": "1.0"
  },

  "decision_space": {
    "D": [                                    // множество рассмотренных альтернатив
      { "id": "d1", "label": "APPROVE",  "feasible": true  },
      { "id": "d2", "label": "REVIEW",   "feasible": true  },
      { "id": "d3", "label": "BLOCK",    "feasible": true  },
      { "id": "d4", "label": "ESCALATE", "feasible": true  }
    ],
    "pruned": [                               // отсеянные варианты с причиной
      { "id": "d5", "label": "PARTIAL_APPROVE", "reason": "regulatory_constraint_EMD2_art8" }
    ]
  },

  "criteria": [                               // MAUT-вектор критериев
    {
      "id":     "c1",
      "name":   "regulatory_compliance_risk",
      "weight": 0.40,                         // w_j из MAUT
      "score_chosen": 0.92,                   // u_j(x_ij) ∈ [0,1]
      "score_method": "rule-engine-v3.1",
      "normalization": "linear_min_max"
    },
    {
      "id":     "c2",
      "name":   "customer_harm_risk",
      "weight": 0.30,
      "score_chosen": 0.85,
      "score_method": "ml-model:harm-scorer:v1.4",
      "normalization": "linear_min_max"
    },
    {
      "id":     "c3",
      "name":   "revenue_impact",
      "weight": 0.15,
      "score_chosen": 0.70,
      "score_method": "lookup-table",
      "normalization": "linear_min_max"
    },
    {
      "id":     "c4",
      "name":   "operational_cost",
      "weight": 0.15,
      "score_chosen": 0.60,
      "score_method": "lookup-table",
      "normalization": "linear_min_max"
    }
  ],

  "utility_computation": {
    "method":       "MAUT_additive",
    "formula":      "U = sum(w_j * u_j)",    // §MAUT из первоисточника
    "U_chosen":     0.860,
    "U_per_option": { "d1": 0.860, "d2": 0.741, "d3": 0.680, "d4": 0.590 },
    "pareto_dominated_by_chosen": ["d2","d3","d4"],
    "pareto_frontier": ["d1"]               // здесь один доминирует
  },

  "chosen": {
    "decision_id": "d1",
    "label":       "APPROVE",
    "confidence":  0.87,                    // P(outcome=expected | context)
    "confidence_method": "ensemble_calibrated_isotonic",
    "tier":        "AUTO",                  // AUTO | REVIEW | BLOCK — см. §4
    "rationale":   "All 4 criteria above threshold; no prospect-bias flag triggered"
  },

  "stopping_rule": {
    "applied": "satisficing",               // satisficing | full_search | secretary_37pct
    "threshold_met_at_step": 1,             // какой кандидат прошёл порог
    "exploration_ratio": 0.0,               // 0 = immediate accept; 1 = full exploration
    "note": "Domain KYC allows satisficing; payment execution requires full_search"
  },

  "bias_flags": {
    "prospect_bias_check": "PASS",          // loss-framing detector
    "anchoring_check":     "PASS",
    "omission_bias_check": "PASS",
    "method": "contrastive-probe-v1.1"
  },

  "minimax_regret": {
    "computed": true,
    "regret_matrix": {
      "d1_worst_case_regret": 0.08,
      "d2_worst_case_regret": 0.31,
      "d3_worst_case_regret": 0.45
    },
    "minimax_optimal": "d1",
    "chosen_matches_minimax": true
  },

  "human_review": {
    "required":      false,
    "reviewer_id":   null,
    "review_ts":     null,
    "override":      null,
    "override_reason": null
  },

  "schema_hash": "SHA-256 of record sans this field",  // integrity seal
  "prev_record_hash": "SHA-256 of prior record",       // hash-chain
  "emitted_to": ["kafka:decision-log-topic", "audit-s3-worm"]
}
```

### 1.2 Инварианты схемы

- Поля `record_id`, `timestamp_utc`, `schema_hash`, `prev_record_hash` генерируются агентом и верифицируются оркестратором при приёме. Любое несоответствие хэша → автоматический `BLOCK` + алерт.
- `criteria[].weight` суммируются до 1.0 ± 1e-6; нарушение → запись помечается `INVALID`.
- `decision_space.D` должно содержать не менее двух допустимых альтернатив. Единственный вариант — запрещён (нет реального «выбора»).
- Для compliance/payment-контура: `stopping_rule.applied` должно быть `full_search`; `satisficing` запрещён регуляторными ограничениями.

***

## 2. Outcome Capture

### 2.1 Структура `OutcomeRecord`

Исход фиксируется в отдельной записи, связанной с `DecisionRecord` по `record_id`. Задержка обратной связи — ключевая проблема банковского домена: транзакционные исходы приходят через секунды, KYC-исходы — через часы/дни, AML-детекция — через недели/месяцы.

```json
{
  "outcome_id":        "uuid-v4",
  "decision_record_id": "uuid-v4",          // FK → DecisionRecord
  "agent_id":          "agent:kyc-checker:v2.3.1",
  "observed_at_utc":   "ISO-8601",
  "feedback_lag_sec":  86400,               // реальная задержка в секундах

  "outcome_class":  "SUCCESS | FAILURE | PARTIAL | ESCALATED | UNKNOWN",
  "outcome_detail": {
    "regulatory_outcome": "COMPLIANT | VIOLATION | PENDING",
    "customer_outcome":   "SATISFIED | HARMED | NEUTRAL",
    "financial_outcome":  "+€1250 | -€0 | risk_avoided",
    "operational_outcome": "resolved_in_sla | breach_sla"
  },

  "ground_truth_utility": 0.91,            // U_actual, верифицированный постфактум
  "utility_error": 0.051,                  // |U_predicted - U_actual|

  "counterfactual": {
    "method":  "propensity_score_matching | inverse_propensity_weighting | causal_forest",
    "available": true,
    "cf_record_ids": ["uuid-similar-case-1", "uuid-similar-case-2"],
    "U_counterfactual_d2": 0.71,           // что было бы при REVIEW
    "U_counterfactual_d3": 0.55,
    "achieved_regret":  0.0,               // U_optimal - U_chosen = 0 (optimal chosen)
    "confidence_ci_95": [0.82, 0.98]
  },

  "feedback_source": "automated_pipeline | human_reviewer | regulatory_report | external_signal",
  "feedback_quality": "HIGH | MEDIUM | LOW | ESTIMATED"
}
```

### 2.2 Обработка запаздывающей обратной связи

Немедленный feedback невозможен в большинстве банковских сценариев. Стратегия:[1]

| Горизонт | Метод до прихода ground-truth |
|---|---|
| < 1 мин (транзакция) | Детерминированный исход доступен сразу |
| 1ч — 24ч (KYC-проверка) | Промежуточный сигнал (документы получены / запрос отклонён) |
| 1д — 30д (AML-расследование) | Surrogate signal (SARs, alert-resolution) |
| 30д — 12мес (кредитный риск) | Causal forest / IPW counterfactual estimation[2][3] |
| > 12мес (регуляторное дело) | Manual outcome tagging, LOW quality |

Counterfactual Value Estimator использует метод CausalML `CounterfactualValueEstimator`: моделирует вероятность конверсии \(P(Y=1 \mid X, W)\) для каждой не-выбранной альтернативы. Полученные оценки маркируются `feedback_quality: ESTIMATED` и имеют пониженный вес в обучении (\(w_{est} = 0.3\) против \(w_{gt} = 1.0\) для ground-truth).[2]

***

## 3. Метрики «Лучшести» Решения

Все метрики исчисляются над скользящим окном `W` (по умолчанию `W = 90d`), если не указано иное.

### 3.1 Regret

**Достигнутый сожаление** \(R_t\) для решения в момент времени \(t\):
\[R_t = U_{\mathrm{oracle}}(s_t) - U_{\mathrm{chosen}}(s_t)\]
где \(U_{\mathrm{oracle}}(s_t)\) — максимальная полезность, достижимая в состоянии \(s_t\) согласно постфактумному анализу (oracle).[4][5]

**Накопленный сожаление** за \(T\) решений:
\[\rho_T = \sum_{t=1}^{T} R_t\]

**Средний регрет** (используется как KPI):
\[\bar{R} = \frac{\rho_T}{T}\]

Целевой порог: \(\bar{R} \leq 0.05\) (5% от максимально достижимой полезности). No-regret алгоритм обеспечивает \(\bar{R} \to 0\) при \(T \to \infty\).[6][4]

**Минимакс-сожаление** (для неопределённых сценариев):
\[MMR = \min_{d \in D} \max_{s \in S} \left[ U_{\mathrm{best}}(s) - U_d(s) \right]\]
Агент, чей выбор не является минимаксно-оптимальным при известной матрице исходов, получает флаг `minimax_suboptimal`.

### 3.2 Калибровка Уверенности: Brier Score

Brier Score измеряет точность вероятностных предсказаний:[7][8]
\[BS = \frac{1}{N} \sum_{i=1}^{N} (f_i - o_i)^2\]
где \(f_i \in [0,1]\) — заявленная агентом confidence, \(o_i \in \{0,1\}\) — реализовавшийся исход.

Интерпретация: BS = 0 — идеальная калибровка; BS = 1 — наихудшая.[8]

**Expected Calibration Error (ECE)** — разбивает предсказания на \(M\) бинов и считает взвешенное отклонение:[9][10]
\[ECE = \sum_{m=1}^{M} \frac{|B_m|}{N} \left| \mathrm{acc}(B_m) - \mathrm{conf}(B_m) \right|\]

| Метрика | Пороговое значение (pass) | Действие при нарушении |
|---|---|---|
| Brier Score | BS ≤ 0.15 | REVIEW агент |
| ECE | ECE ≤ 0.08 | Пересмотр калибровки |
| Средний регрет | R̄ ≤ 0.05 | Флаг деградации |
| Minimax suboptimal rate | ≤ 5% решений | Ретест + анализ |

### 3.3 Корректность Эскалации

\[P(\mathrm{correct\_escalation}) = \frac{TP_{\mathrm{esc}}}{TP_{\mathrm{esc}} + FN_{\mathrm{esc}}}\]
\[P(\mathrm{false\_escalation}) = \frac{FP_{\mathrm{esc}}}{FP_{\mathrm{esc}} + TN_{\mathrm{esc}}}\]

Целевые пороги: Recall эскалации ≥ 0.98 (ни одна реальная проблема не пропущена); False escalation rate ≤ 0.10 (операционная нагрузка на ревьюеров).

### 3.4 Pareto-Эффективность при Многокритериальности

Решение считается **Парето-доминируемым**, если существует альтернатива \(d' \in D\) такая, что:
\[\forall j: u_j(d') \geq u_j(d) \quad \text{и} \quad \exists j: u_j(d') > u_j(d)\]

**Pareto Efficiency Rate (PER):**
\[PER = 1 - \frac{\text{число решений, доминируемых хотя бы одной альтернативой}}{\text{общее число решений}}\]

Целевой порог: PER ≥ 0.95. Нарушение означает, что агент систематически выбирает субоптимальные точки, не находящиеся на Парето-фронте.

### 3.5 Метрики при Неполной/Запаздывающей Обратной Связи

Для решений с `feedback_quality: ESTIMATED` применяется **Inverse Propensity Weighting (IPW)**:[3]
\[\hat{U}_{\mathrm{IPW}} = \frac{1}{N} \sum_{i=1}^{N} \frac{\mathbb{1}[W_i = w]}{e(X_i)} \cdot Y_i\]
где \(e(X_i)\) — propensity score (вероятность выбора данного решения при данном контексте). Оценки IPW используются в метриках с флагом `[estimated]` до поступления ground-truth.

***

## 4. Best-Decision Test как Обязательный Gate

### 4.1 Трёхуровневая Система Уверенности

Концепция «уровней уверенности» опирается на HITL-паттерн, устоявшийся в banking-AI практике:[11][12]

```
Confidence c ∈ [0, 1]
│
├── c ≥ 0.90  →  Tier AUTO      : решение применяется автоматически
│                                 (логируется, контролируется постфактум)
│
├── 0.70 ≤ c < 0.90  →  Tier REVIEW : решение приостанавливается,
│                                 направляется человеку-ревьюеру
│                                 SLA: 4ч (compliance), 24ч (KYC/AML)
│
└── c < 0.70  →  Tier BLOCK     : выполнение заблокировано,
                                  автоматический fallback к human decision
```

**Важно:** для compliance-/payment-контура нижняя граница AUTO поднимается до `c ≥ 0.95` по требованию EU AI Act Art. 14 (human oversight).[13][14]

### 4.2 Best-Decision Test Suite

Тест запускается в двух режимах:

**A) Authoring Gate** — при регистрации нового агента или версии агента в реестре. Блокирует деплой при неудаче.

**B) Runtime Periodic Gate** — каждые 24 ч (configurable) по скользящему окну. Триггерит REVIEW или BLOCK агента при деградации.

```yaml
# best_decision_test_spec.yaml
test_suite:
  id: "bdt-v1.2"
  gates:
    authoring:
      blocking: true
      min_sample_size: 500            # synthetic + historical cases
    runtime_periodic:
      interval_hours: 24
      window_days: 90
      blocking_on_critical: true

  assertions:
    - metric: brier_score
      threshold: "< 0.15"
      severity: CRITICAL              # fails authoring gate

    - metric: ece
      threshold: "< 0.08"
      severity: CRITICAL

    - metric: avg_regret
      threshold: "< 0.05"
      severity: MAJOR                 # triggers REVIEW, not block

    - metric: pareto_efficiency_rate
      threshold: "> 0.95"
      severity: MAJOR

    - metric: escalation_recall
      threshold: "> 0.98"
      severity: CRITICAL

    - metric: minimax_suboptimal_rate
      threshold: "< 0.05"
      severity: MINOR

    - metric: prospect_bias_rate      # доля решений с triggered prospect-bias
      threshold: "< 0.03"
      severity: MAJOR

    - metric: satisficing_in_prohibited_domain
      threshold: "== 0"              # ноль инцидентов
      severity: CRITICAL

  verdict:
    PASS:    "0 CRITICAL failures, ≤ 1 MAJOR failure"
    REVIEW:  "0 CRITICAL, 2+ MAJOR  →  agent to REVIEW tier"
    BLOCK:   "1+ CRITICAL failure   →  agent BLOCKED, escalate to human"
```

### 4.3 Тест как Статический Анализ Bias

Перед каждым деплоем агент прогоняется через **contrastive probe battery**:
- Prospect-bias check: идентичный сценарий предъявляется агенту в двух формулировках (gain frame vs. loss frame). Если решения расходятся → `prospect_bias_flag = TRUE`.[15]
- Anchoring probe: порядок предъявления критериев рандомизируется. Стабильность решения проверяется.
- Omission bias probe: «не делать ничего» как явный вариант должен оцениваться по тем же критериям, что и активные варианты.[16]

***

## 5. Петля Самообучения (Self-Learning Loop)

### 5.1 Архитектурный Принцип: «Предлагает Система — Утверждает Человек»

Это абсолютная граница. Система **никогда** не применяет изменения самостоятельно. Она формирует `ImprovementProposal` и помещает в очередь на ратификацию.[11][1]

```
DecisionRecord → OutcomeRecord → MetricsEngine
                                       ↓
                          [offline batch: ежедневно]
                                       ↓
                         ImprovementProposal (ℙ)
                                       ↓
                         Human Review Queue
                                       ↓
                      [APPROVED] → Change Applied (versioned)
                      [REJECTED] → Proposal archived, reason logged
                      [DEFERRED] → Back to queue with expiry
```

### 5.2 Структура `ImprovementProposal`

```json
{
  "proposal_id":    "prop-uuid",
  "generated_at":   "ISO-8601",
  "generated_by":   "metrics-engine:v2.1",
  "agent_id":       "agent:kyc-checker:v2.3.1",
  "status":         "PENDING | APPROVED | REJECTED | DEFERRED",

  "evidence": {
    "window_start":       "2026-06-01",
    "window_end":         "2026-07-01",
    "n_decisions":        12450,
    "n_outcomes_observed": 11230,
    "triggering_metrics": {
      "avg_regret":   { "current": 0.073, "threshold": 0.05, "delta": "+0.023" },
      "ece":          { "current": 0.091, "threshold": 0.08, "delta": "+0.011" }
    }
  },

  "proposed_changes": [
    {
      "change_type": "weight_adjustment",
      "criterion_id": "c1",
      "current_weight": 0.40,
      "proposed_weight": 0.45,
      "rationale": "Regulatory violations in window had 3.2x higher utility cost than predicted. Increasing c1 weight reduces avg_regret by estimated 0.018.",
      "confidence_of_improvement": 0.82,
      "estimated_regret_reduction": 0.018
    },
    {
      "change_type": "threshold_adjustment",
      "parameter": "AUTO_tier_min_confidence",
      "current_value": 0.90,
      "proposed_value": 0.91,
      "rationale": "Brier score drift observed in confidence band [0.88–0.91]. Raising threshold redirects 4.2% of cases to REVIEW tier.",
      "estimated_false_escalation_delta": "+0.02"
    }
  ],

  "drift_analysis": {
    "concept_drift_detected": false,
    "data_drift_detected":    true,
    "drift_features":         ["transaction_volume_distribution", "country_risk_score"],
    "drift_magnitude_psi":    0.18     // Population Stability Index; >0.1 = moderate drift
  },

  "approver_instructions": "Review proposed weight change for criterion c1. Validate against current EMD2 Art.8 interpretation. Check with Compliance Officer before approving.",
  "expires_at": "ISO-8601+14d"
}
```

### 5.3 RLHF-Аналогичный Контур: Reward Model Update

По аналогии с RLHF pipeline, система обслуживает **Reward Model (RM)** — суррогатную функцию ценности, обучаемую на парах `(DecisionRecord, OutcomeRecord)` с человеческими оценками:[17][18]

```
Stage 1: Preference Data Collection
  - Ревьюер видит два анонимизированных DecisionRecord в одинаковом контексте
  - Помечает, какое решение «лучше» (pairwise preference)
  - Накапливается dataset: D_pref = {(d_i, d_j, label)}

Stage 2: Reward Model Training (offline, human-approved trigger)
  - RM_θ обучается на D_pref: RM_θ(d) → [0,1]
  - Валидируется на hold-out set
  - Результат: предложение новой версии RM как ImprovementProposal

Stage 3: Policy Update (only after human approval)
  - Agent Policy π использует новую RM только после APPROVED-статуса
  - Откат к предыдущей версии возможен в 1 клик (versioned policy store)
```

Это прямая реализация RLHF без автономного self-modification: обучение происходит офлайн, применение — только через human gate.[19][18]

### 5.4 Защита от Дрейфа и Prospect-Bias

**Концептуальный дрейф (Concept Drift):**
Отслеживается через Population Stability Index (PSI) входных признаков и распределения `U_chosen` во времени. PSI > 0.25 → автоматический `ImprovementProposal` с `drift_analysis.concept_drift_detected: true`.

**Prospect-Bias защита:**
Inspired by Kahneman & Tversky (1979): агент систематически переоценивает потери относительно выигрышей. Контрмеры:[15]
1. Все критерии нормированы в `[0, 1]` как gains (не losses).
2. Периодический contrastive probe (§4.3) детектирует frame-dependence.
3. `bias_flags.prospect_bias_rate` — отдельная метрика в BDT.

**Simon Satisficing Guard:**
Для payment/compliance-контура `satisficing` полностью запрещён (см. §1.2). Для остальных доменов: если `stopping_rule.exploration_ratio < 0.37` систематически, генерируется предупреждение — агент может быть применяющим «правило 37%» (optimal stopping) некорректно.

***

## 6. Роль Оркестратора

### 6.1 Функции Оркестратора

Оркестратор реализует паттерн Supervisor — центральный агент, управляющий всем флотом, но не принимающий бизнес-решений.[20][21]

```
Оркестратор
├── 6.1 Decision Quality Registry
│     Реестр метрик качества по каждому агенту (real-time dashboard)
│     Хранит: BDT-историю, trend(R̄), trend(BS), trend(PER), escalation_stats
│
├── 6.2 Anomaly Detector
│     Сигнализирует при: R̄ > threshold, BS drift > δ, escalation_recall < 0.98
│     Actions: WARN → REVIEW_agent → BLOCK_agent (каскадный эскалационный путь)
│
├── 6.3 Re-test Scheduler
│     Триггерит внеплановый BDT при: drift_detected, volume_spike, regulatory_event
│
├── 6.4 Proposal Queue Manager
│     Агрегирует ImprovementProposal из всех агентов
│     Приоритизирует: CRITICAL > MAJOR > MINOR > MINOR_drift
│     Направляет в Human Review Queue с SLA (CRITICAL: 4ч, MAJOR: 24ч)
│
└── 6.5 Cross-Agent Correlation
      Детектирует системные проблемы: если 3+ агентов деградируют одновременно →
      вероятен concept drift в данных, а не в отдельном агенте
```

### 6.2 Decision Quality Registry (схема)

```sql
CREATE TABLE agent_quality_metrics (
  agent_id            TEXT        NOT NULL,
  agent_version       TEXT        NOT NULL,
  window_date         DATE        NOT NULL,
  n_decisions         INTEGER,
  avg_regret          DECIMAL(6,4),
  brier_score         DECIMAL(6,4),
  ece                 DECIMAL(6,4),
  pareto_efficiency   DECIMAL(6,4),
  escalation_recall   DECIMAL(6,4),
  prospect_bias_rate  DECIMAL(6,4),
  bdt_status          TEXT,        -- PASS | REVIEW | BLOCK
  bdt_last_run        TIMESTAMP,
  trend_regret_7d     DECIMAL(6,4), -- positive = worsening
  PRIMARY KEY (agent_id, agent_version, window_date)
);
```

### 6.3 Эскалационный Путь Оркестратора

```
Metric degradation detected
        ↓
Tier 1 (AUTO-warning):  log + slack-alert to Tech Lead
        ↓ [if unresolved 4h]
Tier 2 (REVIEW):        agent moved to REVIEW tier + ImprovementProposal generated
        ↓ [if unresolved 24h or CRITICAL metric]
Tier 3 (BLOCK):         agent suspended + mandatory human review + incident ticket
        ↓ [if unresolved 72h]
Tier 4 (ESCALATE):      CISO + Compliance Officer + optional regulatory notification
```

***

## 7. Поэтапный Rollout

### 7.1 Фаза 0: Infrastructure (Month 1–2)

- Развернуть append-only decision-log (Kafka + WORM S3).
- Реализовать `DecisionRecord` schema v1.0.
- Развернуть MetricsEngine (Brier, ECE, Regret вычисление).
- Создать Human Review Queue интерфейс.
- Создать Decision Quality Registry.

**Ни один агент ещё не обучается. Только инфраструктура.**

### 7.2 Фаза 1: Агенты Фабрики — Аудиторы и Оркестраторы (Month 2–4)

Первая волна: агенты, решения которых не имеют прямого регуляторного impact (внутренние аудиторы качества кода, оркестратор-наблюдатель).

- Эти агенты начинают эмитировать `DecisionRecord` по упрощённой схеме.
- BDT проводится на синтетических тест-кейсах.
- Пороги намеренно занижены (Brier < 0.20, R̄ < 0.10) для calibration phase.
- Человек валидирует первые 500 решений вручную — ground-truth dataset.

**Цель фазы:** отладить весь pipeline до банковских агентов.

### 7.3 Фаза 2: Агенты Банка — Информационный контур (Month 4–6)

Агенты, предоставляющие **рекомендации** (не исполняющие транзакции): customer-risk-scorer, fraud-signal-generator, document-checker.

- Полная `DecisionRecord` schema активирована.
- BDT Authoring Gate включён. Деплой только при PASS.
- Все решения в режиме REVIEW tier (c ≥ 0.70 минимум для отображения, любой threshold для execution требует человека).
- Начало сбора preference data для RM.

### 7.4 Фаза 3: Агенты Банка — Compliance/Payment контур (Month 7–12)

Самый строгий режим. Включается только после:
- Фаза 2 завершена успешно (BDT PASS ≥ 3 consecutive months).
- Compliance Officer провёл EU AI Act conformity assessment.
- EU AI database registration завершена (обязательна с Aug 2026).[22]
- Проведены penetration testing + adversarial probes.

Полная схема с AUTO≥0.95 порогом для payment-execution. Satisficing полностью запрещён в этом контуре.

***

## 8. Compliance-Границы

### 8.1 Соответствие EU AI Act

| Требование EU AI Act | Реализация в BDSL |
|---|---|
| Art. 9: Risk Management System | BDT + MetricsEngine + Оркестратор = continuous risk monitoring[13][14] |
| Art. 14: Human Oversight | REVIEW/BLOCK tier + Human-gated ImprovementProposal[13] |
| Art. 15: Accuracy, Robustness | Brier Score, ECE, Prospect-Bias probes как обязательные метрики[14] |
| Art. 17: Quality Management System | Decision Quality Registry + BDT lifecycle gate[14] |
| Annex IV: Technical Documentation | DecisionRecord schema + OutcomeRecord = полная документация каждого решения[23] |
| Art. 49: EU AI Database Registration | Обязательна до деплоя Фазы 3 (Aug 2, 2026)[22] |
| GDPR Art. 22: Automated decisions | Tier REVIEW/BLOCK обеспечивает human involvement; Tier AUTO — только при c ≥ 0.95 и низком risk-score клиента |

Согласно отчёту EBA (2025), EU AI Act и банковское регуляторное законодательство **не противоречат** друг другу; EBA отмечает необходимость интеграции двух фреймворков. BaFin принцип «human in the loop» прямо требует «достаточного вовлечения людей в интерпретацию и использование AI-выходов».[23][24]

### 8.2 Аудируемость: Требования к Хранению

- Decision-log: 7+ лет (финансовые услуги).[25]
- `schema_hash` + `prev_record_hash` = blockchain-like hash chain; обеспечивает доказуемую неизменность.
- Каждый `ImprovementProposal` с историей APPROVED/REJECTED — часть аудиторского пакета.
- Человеческие overrides в `human_review` поле — обязательно логируются с `reviewer_id` и обоснованием.

### 8.3 Граница «Предлагает — Утверждает»: Формальная Таблица

| Что | Кто ПРЕДЛАГАЕТ | Кто УТВЕРЖДАЕТ | Формат утверждения |
|---|---|---|---|
| Веса критериев (w_j) | MetricsEngine | Compliance Officer + Tech Lead | ImprovementProposal APPROVED + sign-off |
| Пороги уверенности (AUTO/REVIEW/BLOCK) | MetricsEngine | CISO + Compliance Officer | ImprovementProposal + Regulatory sign-off |
| Reward Model новая версия | Offline Training Pipeline | ML Ops Lead + Compliance Officer | Model Card + BDT PASS |
| Агент новая версия (деплой) | Dev Team | Tech Lead + Auto-BDT PASS | Deployment Gate |
| Агент BLOCK → UNBLOCK | Оркестратор | Tech Lead + Compliance Officer | Incident Resolution Record |
| Satisficing разрешение в новом домене | Архитектор | Compliance Officer + Legal | Formal Change Request |

### 8.4 Запрещённые Автономные Действия (Never-Autonomous List)

Следующие действия **никогда** не выполняются без human approval, независимо от confidence:

1. Изменение весов критериев в compliance-/payment-контуре.
2. Изменение ANY порогов уверенности для любого контура.
3. Добавление или удаление критериев из MAUT-вектора.
4. Изменение stopping_rule для compliance-/payment-агентов.
5. Перевод агента из BLOCK в REVIEW или AUTO.
6. Применение обновлённой Reward Model к активному агенту.
7. Любое изменение списка `decision_space.D` (допустимых альтернатив) для платёжных агентов.

***

## Глоссарий Ключевых Обозначений

| Символ | Значение |
|---|---|
| \(D\) | Множество допустимых решений |
| \(U(d)\) | Ожидаемая полезность решения \(d\) (MAUT/VNM) |
| \(w_j\) | Вес критерия \(j\) в MAUT, \(\sum w_j = 1\) |
| \(u_j(x)\) | Нормированная полезность по критерию \(j\) |
| \(R_t\) | Regret в момент \(t\): \(U_{\mathrm{oracle}} - U_{\mathrm{chosen}}\) |
| \(BS\) | Brier Score: \(\frac{1}{N}\sum(f_i - o_i)^2\) |
| \(ECE\) | Expected Calibration Error |
| \(PER\) | Pareto Efficiency Rate |
| \(MMR\) | Minimax Regret |
| \(RM_\theta\) | Reward Model (RLHF-аналог) |
| HITL | Human-In-The-Loop |
| PSI | Population Stability Index (дрейф данных) |
| BDT | Best-Decision Test |
| BDSL | Best-Decision Self-Learning Loop |