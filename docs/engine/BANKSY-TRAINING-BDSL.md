# BANKSY-TRAINING-BDSL — операционный цикл дообучения движка-директора (уникальный контур)

> **Pointer-first per ADR-102: схемы/метрики/гейты НЕ определяются здесь — только операционный цикл.**
> SSOT схем и порогов: `../canon/BEST-DECISION-SELF-LEARNING-LOOP.md` (DecisionRecord/OutcomeRecord,
> MetricsEngine-пороги, BDT-гейт, tiers, NEVER-AUTONOMOUS, bias-probes, SLA) · ADR-046 (Decision Lineage
> Schema) · emi-stack `decision_records`-схема (runtime-носитель) · `../sources/best-decision-concept-*`
> (математика) · `BEST-DECISION-CURRICULUM.md` (траектория флота).
> **STATUS: PROPOSED, human-gated.** ⚠ SANDBOX/TRAINING (BANXE_ENV=sandbox, PROD_READY=false).
> STEP9 S-TRAIN / STEP11 dedup, ENGREF01. Субъект: директор (CEO-UNITARY canon: решает CEO-человек;
> `ceo_orchestration_agent` = инструмент, D-2/I-27/I-28 целы).

## Уникальное содержание: ЗАМКНУТЫЙ 8-КОНТУРНЫЙ ЦИКЛ (как контуры соединены операционно)

1. **СБОР** — каждое решение директора → DecisionRecord; исход через lag → OutcomeRecord
   *(поля/hash-chain/WORM — canon SELF-LEARNING-LOOP; персист — ADR-046 + emi-stack decision_records)*.
2. **ОЦЕНКА** — MetricsEngine по записям контура 1 *(пороги R̄/Brier/ECE/Pareto/Recall/Minimax — canon)*.
3. **RLHF, human-gated, 3 стадии** — Preference из пар (Decision, Outcome) → RM offline на hold-out →
   Policy Update **только после human approval** (PPO). Никакой self-modification.
4. **SELF-LEARNING** — ImprovementProposal (веса wj / пороги tier + rationale + est. regret reduction +
   PSI) → Human Review Queue *(SLA — canon)* → APPROVED = versioned policy update / REJECTED / DEFERRED.
5. **DRIFT** — PSI>0.25 → переобучение; re-test BDT при drift / volume-spike / regulatory-event;
   **Cross-Agent Correlation**: деградация у 3+ агентов = системная причина, эскалация выше агентного уровня.
6. **QUALITY GATE** — активация версии политики только через BDT *(authoring 500-case blocking +
   runtime 24h/90d — параметры в canon)*; вердикт PASS/REVIEW/BLOCK.
7. **BIAS** — contrastive probes на каждой версии *(набор и порог prospect>0.03→REVIEW — canon)*.
8. **TIERS** — после обучения решения идут через tiers *(AUTO/REVIEW/BLOCK; payment/compliance ≥0.95 — canon)*.

Связь контуров: 1→2 (данные) · 2→4 (метрики порождают proposals) · 3⊂4 (RLHF — один из механизмов
proposal) · 5→6 (drift форсирует re-gate) · 6→8 (только PASS-версия попадает под tiers) · 7 — поперечный
контроль на 3/4/6.

## Границы (pointer)

NEVER-AUTONOMOUS при обучении, satisficing-запрет, Compliance-Officer sign-off на веса/пороги —
**canon SELF-LEARNING-LOOP** (здесь не переопределяются). Регуляторный маппинг (AI Act Art.9/14/15/17,
GDPR Art.22, BaFin; лог 7Y hash-chain WORM) — roadmap §3 + canon.

## Rollout (операционные фазы — уникально здесь)

Ph0 инфра+калибровка (Brier<0.20, R<0.10, 500 ground-truth) → Ph1 shadow low-risk →
Ph2 (BDT PASS 3 мес + EU-conformity + EU-DB-reg Art.49 Aug 2026) → Ph3 (payment/compliance AUTO≥0.95
в рамках NEVER-AUTONOMOUS).

## Роли

Fable5 F5-TRAIN-1 — canon границ обучения. Director — субъект обучения И потребитель
(Decision Quality Registry в control plane). Оператор/Compliance Officer — единственные утверждающие.

---
*STEP11 | ENGREF01 | pointer-first (ADR-102): цикл — здесь, определения — в canon/ADR-046/SSOT.*
