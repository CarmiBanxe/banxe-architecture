# A-KYB — Install Audit — 2026-07-20

Status: INSTALL-AUDIT / FACT-ONLY / DRAFT — no legal/prudential conclusions.

## Scope & context
Проверка установленности A-KYB (business onboarding) по `docs/architecture/A-KYB-BUILD-SPEC.md` (запреты: no in-house registry scraping, no raw-PII persistence, borderline → MLRO HITL). Часть S-A5.

## Code locations (verified 2026-07-20)
- Полный модуль `services/kyb_onboarding/`: `kyb_agent.py`, `onboarding_workflow.py`, `risk_assessor.py`, `application_manager.py`, **`companies_house_adapter.py`** (официальный реестр — адаптер, не scraping), `ubo_registry.py`, `models.py`.
- KYBAgent [ФАКТ, код]: `process_application`; `process_ubo_screening` — **«L1 auto if all UBOs clear; L4 HITLProposal if any sanctions hit (I-27)»**, `requires_approval_from="MLRO"`; `process_decision → HITLProposal`; `_pending_hitl`-очередь в агенте.

## Room & agent mapping
Room: `bank-rooms/F2-identity-room/` (kyb_agent в agents-identity-room.yaml). Связки: UBO-скрин → sanctions-контур (F3/aml-room, Tier-A ADR-173); merchant-onboarding консьюмер — `services/merchant_acquiring/approve_kyb(actor)` (F2/payments).

## Controls / HITL references
- Кодом enforced: sanctions-hit на UBO → L4 MLRO (I-27); решение по заявке → HITLProposal (человек).
- Спек-запреты соблюдены структурно: Companies House = адаптер официального API [ФАКТ: файл], не scraping; raw-PII persistence — [operator: verify models.py поля при следующем шаге].
- Гейты-референсы: H-006/H-007-классы для business-принципалов.

## Open questions [counsel/operator]
- [operator] Verify: `models.py` — отсутствие raw-PII persistence сверх redacted refs (spec-требование).
- [operator] UBO-скрин источники — подтверждение Tier-A-only для блокировок (ADR-173).
- [counsel] KYB-периметр для merchant-acquiring связки (лицензионная сторона — Sprint 3 map).

## Next actions
Вердикт-кандидат: **INSTALLED (модуль полный, HITL enforced кодом)**; два operator-verify пункта выше — до финализации вердикта; статус-обновление планов — после S-A5 shell-подтверждения.
