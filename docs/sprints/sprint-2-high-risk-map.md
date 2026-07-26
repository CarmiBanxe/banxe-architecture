# Legal-vs-Internal High-Risk Map — Sprint 2

Status: DRAFT / INTERNAL ONLY / NOT FOR MERGE

## Purpose
Per-agent классификация по двум осям: legal high-risk (AI Act Annex III / Art.6(3)) — counsel-only колонка; internal high-risk (более строгий стандарт банка) — governance-решение CRO/CTO. Внутренний «higher bar» не выдаётся за statutory.

## Scope
Grid (Agent · Use case · Annex III category · LEGAL YES/NO/UNKNOWN [counsel] · INTERNAL YES/NO [CRO/CTO] · Art.6(3) exception YES/NO/UNKNOWN) — стартовые строки: CreditScoringAgent/lending_agent (credit); card_agent (по Scope Note S1); crypto_agent; KYC-Specialist-v2/kyb_agent; FraudScoringAgent/AML-cluster (Recital 58 exclusion? канон: internal YES); consent_agent (legal NO per register — confirm); midaz_agent (legal NO — strict oversight regardless); HRAgent (employment?); остальные из MASTER TABLE.
Narrative rules: определения обеих осей; везде, где internal шире legal — пометка **“INTERNAL HIGHER STANDARD by policy, not a statutory minimum.”**

## Register linkage
- Area **#8 (AI-governance)** — AMBER (не меняется). GREEN: grid заполнен+утверждён; counsel валидировал legal-колонки; internal-политика принята и отражена в HITL-MATRIX/room-доках.

## Room linkage
- `bank-rooms/F4-security-room/README.md` и cross-room (identity, risk); primary держатель — ai-platform контур.

## Open questions
- Ожидаемая Annex III-релевантность: credit scoring; HRAgent employment-uses; иное — [counsel].
- Сознательные internal-high-risk без legal: auto-closure, AML-cluster — [CRO/CTO решение].

## See also
- Sprint 2 набор: `sprint-2-art37-applicability-assessment.md` · `sprint-2-interim-consent-owner-decision.md` · `sprint-2-high-risk-map.md` · `sprint-2-ai-act-compliance-timeline.md`
- Сводка/аудит: `sprint-1-4-status-summary.md` · `sprint-1-4-shell-audit.md` · Register: `../governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`
- AI-oversight артефакты: `../governance/ai-oversight/art14-per-agent-notes-template.md` + notes (Fraud/Credit/Sanctions)
- High-risk AI register (draft): `../governance/HIGH-RISK-AI-REGISTER-DRAFT.md`
- Sprint 3 permissions wiring (products→gates, non-legal): `sprint-3-permissions-map-per-product.md` Приложение A

## IDV/KYC internal classification note
- IDV/KYC здесь НЕ трактуются как expressly named Annex III категории финансового сектора; это НЕ правовой вывод — финальная классификация остаётся [counsel].
- Внутренняя политика может (и в текущем каноне склонна) трактовать IDV/KYC как heightened-risk: формула — **“non-Annex-III, treated as high-risk internally by policy”**.
- Источник ориентации: принятый external-reviewer ввод (2026-07-20); grid-колонка LEGAL для KYC/kyb-строк не предзаполняется этим примечанием.
