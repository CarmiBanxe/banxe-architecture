# CreditScoringAgent — Oversight Notes (Art.14-style)

Status: DRAFT / NOT FOR MERGE
Agent / code path: маска `banxe-emi-stack/services/agents/credit_scoring_agent.py` (`CreditScoringMask`, gate-chain: process_ref → scope → band [+CREDIT_OFFICER step-up] → cost_cap); домен `services/lending/credit_scorer.py` (`CreditScorer.score_customer` → CreditScore), `lending_agent.py`, `loan_originator.py`.
Room / owner: F3/risk-room · CRO (SMF4); escalation role: CREDIT_OFFICER.

## Decision context
Кредитный скоринг + подготовка решений по заявкам. Ключевой код-инвариант [ФАКТ, docstring+логика маски]: **rejection ⇒ force_review=True + requires_step_up=True независимо от confidence; НЕТ code path, пропускающего отказ автоматически**; нет reviewer'а → HOLD_FOR_REVIEW (proceed=False, `handle.decide` НЕ вызывается), эскалация CREDIT_OFFICER.
## Stop-function
HOLD_FOR_REVIEW-путь = встроенный стоп на отказах; scope-allow-list маски — единственный периметр операций; cost_cap-гейт останавливает по бюджету (BudgetHaltGate-семантика S-A2).
## Override / escalation path
CREDIT_OFFICER — обязательный step-up на каждый reject; человек принимает/отклоняет через `decide(actor=...)`; Art.14-требование «HITL on all rejections» реализовано кодом, не только политикой.
## Explainability output shape
`CreditScore` dataclass **«with all factor breakdowns»** [ФАКТ, docstring] — по-факторная атрибуция; confidence_score в intent-объекте маски.
## Threshold / tuning change-control
Скоринг-модель/пороги: изменение = **H-014 (CRO+CTO)**; I-27 propose-only; band-пороги маски — config-канон, не хардкод.
## Logging / traceability
Маска эмитит AgentDecisionRecord per action (ADR-046, §D2-контракт); reject-решения несут human_reviewed_by (CREDIT_OFFICER).
## Register linkage
#8 (context); потенциальная Annex III credit-релевантность — строка Map.
## Related
`../../sprints/sprint-2-high-risk-map.md` (grid: CreditScoring/lending — Annex III? [counsel]) · `art14-per-agent-notes-template.md`.
## Legal classification: [counsel]
## Open questions
- Annex III creditworthiness-охват фактического флоу [counsel].
- Полный список факторов CreditScore — зафиксировать в explainability-приложении при A2.
