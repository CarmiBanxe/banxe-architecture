# A-IDV — Install Audit — 2026-07-20

Status: INSTALL-AUDIT / FACT-ONLY / DRAFT — no legal/prudential conclusions.

## Scope & context
Проверка установленности A-IDV (identity verification pipeline) по спеке `docs/architecture/A-IDV-BUILD-SPEC.md` (spec-plane; runtime → banxe-emi-stack; IDV ДЕЛЕГИРОВАН провайдеру через KYCProviderPort, не реимплементируется — ADR-102). Часть S-A5 identity-кластера (Case 1 → Case 2).

## Code locations (verified 2026-07-20)
- Порт-контракт: `banxe-emi-stack/services/kyc/kyc_provider_port.py` — KYCTier/KYCStatus/KYCSession/KYCResult/WebhookOutcome; `KYCProviderError` с обязательным `correlation_id`; typed-ошибки `InvalidSignature`, `UnknownUser` (webhook-надёжность из contract-spec представлена в типах).
- DI/фабрика: `services/kyc/factory.py`; sandbox-workflow: `services/kyc/mock_kyc_workflow.py`; audit-emitter: `services/kyc/kyc_retrigger_audit_emitter.py`.
- §D2-маска (консьюмер порта): `services/agents/kyc_onboarding_agent.py`.
- Провайдеры: Ballerine self-hosted — `infra/ballerine/` (.env.example присутствует); SumSub live-адаптер — credentials-gated stub (EMI-IMPL-STATE; ED-03).

## Room & agent mapping
Room: `bank-rooms/F2-identity-room/` (README + agents-identity-room.yaml существуют). Agents: KYC-Specialist-v2 (маска) ← KYCProviderPort ← Ballerine/SumSub-адаптеры.

## Controls / HITL references
- Делегация IDV — только через порт (ADR-102 reuse; реимплементация OCR/biometric запрещена спекой).
- Correlation_id обязателен в ошибках → трассируемость (ADR-046-совместимо).
- Гейты уровня流: H-006 (KYC reject HIGH), H-007 (PEP) — референсы, вне этого аудита.
- I-27 carve-out (M2.3-RESCOPE): identity — advisory-descriptive; код существует как sign-off'нутая поверхность [IL-трейс — open].

## Open questions [counsel/operator]
- [operator] Ballerine-vs-SumSub primary в фактическом DI (`factory.py` вердикт) — зафиксировать при следующем шаге; spec говорит SumSub primary, инфра содержит Ballerine.
- [operator] IL-трейс sign-off'а существующего KYC-кода относительно carve-out.
- [counsel] Annex III-релевантность IDV-потока (через Sprint-2 High-Risk Map).

## Next actions
Вердикт-кандидат: **INSTALLED (port+DI+mask+sandbox), провайдер-live = credentials-pending (ED-03)**. Обновление статуса в FLOOR2-планах — отдельным шагом после подтверждающего shell-аудита S-A5.
