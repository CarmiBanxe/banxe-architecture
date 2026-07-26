# A-KYC — Install Audit — 2026-07-20

Status: INSTALL-AUDIT / FACT-ONLY / DRAFT — no legal/prudential conclusions.

## Scope & context
Проверка установленности A-KYC (KYC-оркестрация поверх KYCProviderPort) по `docs/architecture/A-KYC-BUILD-SPEC.md` («consumes the port; does NOT reimplement» — ADR-102). Часть S-A5.

## Code locations (verified 2026-07-20)
- Оркестрация/порты: `services/kyc/kyc_port.py` + `kyc_provider_port.py` (общий контракт с A-IDV); `factory.py` (выбор адаптера); `mock_kyc_workflow.py` (sandbox-петля); `kyc_retrigger_audit_emitter.py` (audit-события ретриггеров).
- §D2-маска: `services/agents/kyc_onboarding_agent.py` — ADR-049 gate-chain + ADR-046 lineage per action (§D2-контракт).
- Дубль-проверка ADR-102: второй реализации порта в services/ не обнаружено (grep KYCProviderPort → только port+mask+__init__).

## Room & agent mapping
Room: `bank-rooms/F2-identity-room/`. Agents: KYC-Specialist-v2 (маска, L2) → ComplianceOfficer-гейты; связка с lifecycle (customer_lifecycle) — consumer-статусы.

## Controls / HITL references
- L2: HIGH/PROHIBITED → human (H-006, 24h, CO); PEP → H-007 (MLRO+CEO, 48h) — референсы.
- Legacy `bkyc`/`binancekyc` — PARKED-by-canon (I-27): наличие = норма, использование = нарушение; в текущем grep активных импортов не искалось — [operator: verify import-graph].
- Retrigger-audit-emitter — событийная трасса повторных проверок (I-24-класс).

## Open questions [counsel/operator]
- [operator] Import-graph проверка неиспользования PARKED-legacy.
- [operator] SumSub credentials (ED-03) — «wired, credentials pending» до ключей.
- [counsel] Достаточность carve-out формулы для текущего объёма KYC-кода.

## Next actions
Вердикт-кандидат: **INSTALLED (оркестрация+маска+audit-emitter), live-провайдер pending (ED-03)**; статус-обновление планов — после S-A5 shell-подтверждения.
