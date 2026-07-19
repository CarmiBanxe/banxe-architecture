# F3/risk-room

## Purpose / coverage
Fraud, ATO, credit, risk oversight, Consumer Duty.

## Key agents/services
`RiskOversightAgent` (L1 read-only; decisions L3 human, ADR-079), `FraudScoringAgent` (Jube), `CreditScoringAgent`/`lending_agent`, `ConsumerDutyAgent`.

## Regulatory Status Notes
- Register area: **#8 AI-governance (AMBER)** — legal vs internal high-risk.
- Canonical source: `../../docs/governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`.
- Freeze: no GREEN without evidence artefact in register.

### Sprint 2 (AI-governance)
`../../docs/sprints/sprint-2-high-risk-map.md` · `sprint-2-ai-act-compliance-timeline.md` — grid-строки этой комнаты: CreditScoring/lending (Annex III credit?), FraudScoring/AML-cluster (Recital 58 exclusion — counsel; internal канон: high-risk). Пометка «INTERNAL HIGHER STANDARD by policy» обязательна там, где internal шире legal.

### AI-oversight artefacts (Workstream B)
`../../docs/governance/ai-oversight/FraudScoringAgent-notes.md` · `CreditScoringAgent-notes.md` — Art.14-style stop/override/explainability по коду.
