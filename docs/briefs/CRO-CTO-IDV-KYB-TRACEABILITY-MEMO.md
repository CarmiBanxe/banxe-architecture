# CRO/CTO Memo — IDV/KYB Traceability and Product-Perimeter Notes

DRAFT / INTERNAL ONLY / NO LEGAL STATUS

## Purpose
Зафиксировать для CRO/CTO принятую внешнюю ориентацию по IDV/KYC-классификации, KYB-периметру и пределам correlation_id-трассируемости — и её операционные следствия. Не правовой документ; светофоры реестра этим memo не меняются.

## Accepted external orientation
- IDV/KYC = **non-Annex-III, treated as high-risk internally by policy** [counsel — не заменяет legal advice].
- KYB-периметр читается вместе с merchant-acquiring permissions там, где KYB гейтит активацию [counsel — лицензионная сторона].
- correlation_id достаточен для technical fault tracing, но **сам по себе не является достаточным доказательством regulatory decision traceability**.

## Operator implications
- [operator] Если correlation_id используется как trace-якорь — decision-layer поля (кто решил, по какой политике, с каким исходом — ADR-046-набор) требуют явного маппинга поверх него; проверить покрытие в KYC/KYB-потоках (S-A5 аудиты: `../audit/spec-audits/`).
- [operator] Merchant-onboarding решения читать против product-permissions логики (`../sprints/sprint-3-permissions-map-per-product.md` §KYB perimeter note), а не только против готовности KYB-модуля.
- [operator] Внутренняя кодовая/аудит-верификация (import-graph PARKED-legacy, models.py raw-PII, Tier-A UBO) — отдельный трек от правовой характеризации.
- [counsel] Финальная Annex III-позиция по IDV/KYC и лицензионный вердикт KYB↔acquiring связки.

## Next actions
- CRO/CTO: внести формулу “non-Annex-III, treated as high-risk internally by policy” в internal-колонку High-Risk grid при ратификации (актом, не этим memo).
- CTO: спланировать decision-layer mapping поверх correlation_id для KYC/KYB (кандидат в A2-verify список).
- CRO: связать Merchant/KYB строки Sprint-3 map в единый review-пакет для counsel-рассылки.
- Operator: закрыть три verify-пункта S-A5 (factory DI primary, PARKED non-use, KYB models.py) до S-A6.
- Все статус-изменения — только evidence-backed процессом реестра.
