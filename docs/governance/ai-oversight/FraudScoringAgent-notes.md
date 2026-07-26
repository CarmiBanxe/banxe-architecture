# FraudScoringAgent — Oversight Notes (Art.14-style)

Status: DRAFT / NOT FOR MERGE
Agent / code path: `banxe-emi-stack/services/fraud/` — `fraud_port.py` (FraudScoringPort, FraudRisk), `jube_adapter.py` (Jube, deployed), `sardine_adapter.py` (stub, live call NotImplemented — credentials-gated), `fraud_aml_pipeline.py`; DI: `get_fraud_adapter()`.
Room / owner: F3/risk-room · Fraud Analyst → CRO (SMF4).

## Decision context
Fraud-скоринг транзакций/событий: score + risk level + rule_ids. По коду [ФАКТ]: LOW = score <40 (proceed), MEDIUM = 40–69 (enhanced checks / HITL), HIGH-класс выше; I-04: ≥£10,000 → EDD; I-06: HARD_BLOCK → REJECT. SLA скоринга: 100ms (S5-22).
## Stop-function
Port-абстракция: подмена адаптера на mock/выключение через DI (`get_fraud_adapter`); HARD_BLOCK детерминированно ведёт к REJECT (не обходится агентом); недоступность адаптера — fail-closed на уровне пайплайна [подтвердить точное поведение при A2-аудите].
## Override / escalation path
Score-driven HITL: MEDIUM → enhanced checks; HIGH → transaction HOLD (H-009: Operator/Compliance/MLRO, 24h; если SAR-признаки — MLRO). Человек может release/confirm hold; агент — нет.
## Explainability output shape
`FraudScoringResult`: risk level + numeric score + rule_ids (+ APP_fraud_signal у Sardine-контракта) — правило-уровневая атрибуция причин.
## Threshold / tuning change-control
Пороги (40/70, I-04 суммы) — канон/конфиг; изменение = AML/fraud threshold change **H-012 (CRO+CEO)**; модельные обновления — **H-014 (CRO+CTO)**; I-27: никаких автономных обновлений (FeedbackLoopAnalyser — propose-only).
## Logging / traceability
Скоринг-события → audit trail (I-24, ClickHouse 5yr); lineage-записи ADR-046 на решениях пайплайна; hold/release — с human_reviewed_by.
## Register linkage
#8 (context) · связка H-009/H-012/H-014.
## Related
`../../sprints/sprint-2-high-risk-map.md` (grid-строка Fraud/AML-cluster; Recital 58 exclusion — counsel) · `sprint-2-ai-act-compliance-timeline.md` · `art14-per-agent-notes-template.md`.
## Legal classification: [counsel]
## Open questions
- Точное fail-closed поведение при недоступности Jube (verify при A2 code-check).
- Sardine-активация (ED-04) — меняет ли rule_ids-атрибуцию формат.
