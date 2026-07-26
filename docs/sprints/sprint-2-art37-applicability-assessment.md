# Art.37 Applicability Assessment — Sprint 2

Status: DRAFT / INTERNAL ONLY / NOT FOR MERGE

## Purpose
Отобразить фактические processing-активности на триггеры GDPR Art.37 и подготовить решение об обязательности DPO. Это ВХОД для counsel; финальное правовое определение — внешнее.

## Scope
Inventory (заполнить метрики: subjects/volume/duration/geo): behavioural monitoring (product/card, swarm behavior/profile_history); identity/KYC processing (kyc/kyb, Ballerine/SumSub; biometric при liveness?); AML/fraud surveillance (special regime — quantify scale; Art.10?); device fingerprinting; marketing analytics.
Trigger analysis (PLACEHOLDERS ONLY): public authority [N/A/edge cases]; large-scale systematic monitoring [LIKELY/UNLIKELY/UNCLEAR — counsel]; large-scale Art.9/Art.10 data [counsel].

## Register linkage
- Area **#5 (Consent/DPO)** — AMBER, potential RED if Art.37 triggers without DPO (не меняется).
- GREEN: counsel-исход + DPO-решение (назначен ЛИБО формальный «not required»). RED: обязателен, а назначения/плана нет.

## Room linkage
- `bank-rooms/F2-identity-room/README.md`.

## Open questions / counsel placeholders
- Считается ли наш мониторинг «large-scale systematic monitoring» по EDPB-guidance?
- Есть ли large-scale обработка Art.9/Art.10 данных в core-активностях?
- Релевантны ли partner-модели (Paybis, SumSub, BIN-sponsor) для DPO-триггера?

## See also
- Sprint 2 набор: `sprint-2-art37-applicability-assessment.md` · `sprint-2-interim-consent-owner-decision.md` · `sprint-2-high-risk-map.md` · `sprint-2-ai-act-compliance-timeline.md`
- Сводка/аудит: `sprint-1-4-status-summary.md` · `sprint-1-4-shell-audit.md` · Register: `../governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`
