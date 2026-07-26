# BANKSY-TRAINING-BDSL — Дообучение движка-директора Banksy (BDSL as training program)

> **STATUS: PROPOSED — методика; всё human-gated; ничего не активировано.**
> ⚠ SANDBOX / TRAINING context (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false).
> STEP9 S-TRAIN, ENGREF01, 2026-07-26. Источники: Best-Decision-Self-Learning-Loop + Концепция-Лучшего-Решения
> (session analytics). Субъект: директор = `ceo_orchestration_agent` + engine control-plane
> (`../architecture/DIRECTOR-CONTROL-PLANE.md`). Схемы: roadmap S-BDSL (DecisionRecord/OutcomeRecord/BDT),
> S-LINEAGE (AgentDecisionRecord). Принцип-арбитр: fail-closed-over-best-decide.

## Цель

Непрерывно дообучать движок-директор принимать Best-Decision по методике BDSL — замкнутым циклом
сбор→оценка→RLHF→proposal→drift→gate, где **каждое изменение политики проходит человека**.

## Замкнутый цикл (8 контуров)

### 1. СБОР
- **DecisionRecord** на каждое решение директора: decision_space, MAUT-веса wj/полезности uj, chosen,
  confidence, tier, stopping_rule, bias_flags, minimax_regret; **hash-chain** (`prev_record_hash`),
  append-only WORM/Kafka.
- **OutcomeRecord** через lag: факт-исход, ground_truth_utility, utility_error, counterfactual-оценка
  (**IPW / causal forest**).

### 2. ОЦЕНКА (MetricsEngine)
Regret **R̄ ≤ 0.05** · Brier **≤ 0.15** · ECE **≤ 0.08** · Pareto Efficiency **≥ 0.95** ·
Escalation Recall **≥ 0.98** · Minimax-suboptimal **≤ 5%**.

### 3. RLHF (human-gated, 3 стадии)
Preference Data из пар (Decision, Outcome) → **Reward Model RM(d)** — offline, на hold-out →
**Policy Update ТОЛЬКО после human approval** (PPO). **Никакой self-modification без человека.**

### 4. SELF-LEARNING
**ImprovementProposal** (изменить веса wj / пороги tier; rationale; estimated_regret_reduction; drift PSI)
→ **Human Review Queue** (SLA: CRITICAL 4h / MAJOR 24h) → APPROVED → versioned policy update /
REJECTED / DEFERRED.

### 5. DRIFT
**PSI > 0.25** = concept-drift → переобучение. **Re-test BDT 24h** при: drift / volume-spike /
regulatory-event. **Cross-Agent Correlation:** одинаковая деградация у 3+ агентов = системная причина
(эскалация выше агентного уровня).

### 6. QUALITY GATE (перед активацией любой версии политики)
**Best-Decision Test Gate (BDT):** authoring — минимум **500 cases, blocking**; runtime — окно **24h**,
история **90d**; вердикт PASS / REVIEW / BLOCK.

### 7. BIAS
Contrastive probes (**prospect / anchoring / omission**) на каждой версии;
**prospect_bias_rate > 0.03 → REVIEW**.

### 8. TIERS (после обучения)
AUTO **≥ 0.90** / REVIEW **0.70–0.90** / BLOCK **< 0.70**; **payment/compliance AUTO ≥ 0.95**.

## NEVER-AUTONOMOUS при обучении (жёсткие границы)

- Директор **не переобучает себя** без human approval.
- Payment/compliance-решения — **всегда human**.
- Веса/пороги меняет **только APPROVED proposal + Compliance Officer sign-off**.
- RLHF — offline + human; **satisficing запрещён в payment/compliance** (только full-search).

## Регуляторика

EU AI Act **Art.9** (risk-mgmt) / **Art.14** (oversight) / **Art.15** (accuracy) / **Art.17** (QMS) +
GDPR **Art.22** + BaFin HITL; decision-log **7Y, hash-chain, WORM** (S-LINEAGE / hitl_decisions контур).

## Rollout (фазы)

| Фаза | Условие входа | Содержание |
|---|---|---|
| **Ph0** | — | инфраструктура + калибровка: Brier < 0.20, R < 0.10, **500 ground-truth cases** |
| **Ph1** | Ph0 green | shadow-режим на low-risk решениях |
| **Ph2** | **BDT PASS 3 месяца** + EU-conformity + **EU-DB регистрация (Art.49, Aug 2026)** | расширение периметра |
| **Ph3** | Ph2 green + operator | compliance/payment с AUTO ≥ 0.95 (в рамках NEVER-AUTONOMOUS листа) |

## Роли

- **Fable5:** canon границ обучения (Never-Autonomous, human-gate на policy update) — F5-TRAIN-1.
- **Director:** субъект обучения (его политика улучшается) И потребитель (видит метрики флота через
  **Decision Quality Registry** в control plane).
- **Оператор/Compliance Officer:** единственные, кто утверждает policy updates.

---
*STEP9 S-TRAIN | ENGREF01 | PROPOSED, human-gated | связки: roadmap S-BDSL (схемы/гейт), S-LINEAGE (лог), DIRECTOR-CONTROL-PLANE (реестр качества решений).*
