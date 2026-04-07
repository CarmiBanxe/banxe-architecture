# BLOCKED-TASKS.md — Каталог заблокированных задач

> **Правило (I-31):** При блокировке любой IL-задачи Claude Code ОБЯЗАН добавить запись.
> При разблокировке — обновить статус BLOCKED → UNBLOCKED с датой и trigger-событием.
> Append-only: не удалять записи — только обновлять статус.

---

## Формат записи

| Поле | Описание |
|------|----------|
| BT-NNN | Уникальный ID |
| Задача | Что заблокировано |
| IL ref | Связанная IL (если есть) |
| Blocker | Что блокирует (конкретно) |
| Тип блокера | CEO_DECISION / API_KEY / EXTERNAL_CONTRACT / HUMAN_ROLE / INFRA |
| Unblock trigger | Что должно произойти для разблокировки |
| Дата блокировки | ISO date |
| Статус | BLOCKED / UNBLOCKED |
| Дата разблокировки | — |

---

## ТЕКУЩИЕ БЛОКИРОВКИ

### BT-001: Payment Rails — Modulr/ClearBank sandbox
- **Задача:** S4-01..S4-11 (Payment Rails 0%)
- **IL ref:** IL-014 (MockAdapter done, real adapter blocked)
- **Blocker:** Нет sandbox-договора с BaaS провайдером. `MODULR_API_KEY` не получен.
- **Тип:** EXTERNAL_CONTRACT + CEO_DECISION
- **Unblock trigger:** CEO подписывает sandbox agreement с Modulr или ClearBank → получаем API key → заносим в `.env` на GMKtec
- **Дата блокировки:** 2026-04-07
- **Статус:** BLOCKED

---

### BT-002: MLRO (SMF17) не назначен
- **Задача:** S1-02, S1-09, S6-11 (shortfall alert recipient)
- **IL ref:** —
- **Blocker:** Нет кандидата на роль MLRO. Без MLRO FCA authorisation невозможен.
- **Тип:** HUMAN_ROLE + CEO_DECISION
- **Unblock trigger:** CEO назначает interim MLRO (outsourced UK firm) → регистрация в FCA Connect
- **Дата блокировки:** 2026-04-07
- **Статус:** BLOCKED

---

### BT-003: CFO/CRO/CCO не назначены
- **Задача:** S1-03, S1-04, S1-05
- **IL ref:** —
- **Blocker:** Нет кандидатов на SMF roles CFO (SMF2), CRO (SMF4), CCO (SMF16)
- **Тип:** HUMAN_ROLE + CEO_DECISION
- **Unblock trigger:** CEO назначает interim holders (outsourced UK specialists available)
- **Дата блокировки:** 2026-04-07
- **Статус:** BLOCKED

---

### BT-004: IDV — Sumsub API key
- **Задача:** S5-14 (IDV/KYC document verification integration)
- **IL ref:** —
- **Blocker:** `SUMSUB_API_KEY` не получен. Без него KYC document check — manual only.
- **Тип:** API_KEY + CEO_DECISION
- **Unblock trigger:** CEO регистрируется на Sumsub sandbox (sumsub.com) → получает API key → `SUMSUB_API_KEY=...` в `.env` на GMKtec
- **Дата блокировки:** 2026-04-07
- **Статус:** BLOCKED

---

### BT-005: Companies House API key
- **Задача:** S5-16 (KYB/UBO verification для corporate accounts)
- **IL ref:** —
- **Blocker:** `COMPANIES_HOUSE_API_KEY` не получен. UBO verification — manual only.
- **Тип:** API_KEY
- **Unblock trigger:** Регистрация на Companies House Developer Hub (developer.company-information.service.gov.uk) → API key → `.env`
- **Дата блокировки:** 2026-04-07
- **Статус:** BLOCKED

---

### BT-006: Core Banking GL logic
- **Задача:** S3-11 (GL payment processing в Midaz — фактические проводки)
- **IL ref:** —
- **Blocker:** Зависит от BT-001 (нет Payment Rails → нечего проводить в GL)
- **Тип:** INFRA (зависимость от BT-001)
- **Unblock trigger:** BT-001 UNBLOCKED + Modulr API key получен → можно строить GL reconciliation
- **Дата блокировки:** 2026-04-07
- **Статус:** BLOCKED

---

### BT-007: Kafka event streaming
- **Задача:** S8-07 (payment event streaming для real-time monitoring)
- **IL ref:** —
- **Blocker:** Без Payment Rails нечего стримить; Kafka infra не поднята на GMKtec
- **Тип:** INFRA (зависимость от BT-001)
- **Unblock trigger:** BT-001 UNBLOCKED + Kafka docker-compose на GMKtec
- **Дата блокировки:** 2026-04-07
- **Статус:** BLOCKED

---

### BT-008: compliance-officer-v1 live training FAIL
- **Задача:** S7-21 (ComplianceValidator live training ≥95% A/B)
- **IL ref:** IL-021 (Deviation) → IL-024 (Fix)
- **Blocker:** compliance-officer-v1 accuracy 60% в live mode. REFUTED recall < 90%, drift 0.253 > 0.15. Нужны дополнительные C/D категорийные сценарии.
- **Тип:** INFRA (модельная calibration)
- **Unblock trigger:** Расширить `scenarios/compliance_officer.json` добавив 20+ REFUTED сценариев категорий C/D → запустить feedback_loop.py --apply → повторный sprint → accuracy ≥ 85%
- **Дата блокировки:** 2026-04-08
- **Дата разблокировки:** 2026-04-08
- **Статус:** UNBLOCKED ✅

---

## РАЗБЛОКИРОВАННЫЕ ЗАДАЧИ

### BT-008 (UNBLOCKED 2026-04-08)
- Сценарии расширены: 30 → 50 (добавлены CO-C09..C20, D04..D09, E04..E05)
- SAR check в compliance_validator.py исправлен (narrowed to filing actions)
- GMKtec validation: 50/50 PASS
- Live training: STATUS=PASS, accuracy=100% (cat A/C/D)
- IL-024 DONE — commit `0704010`

---

### BT-009: Sardine.ai live fraud adapter — API keys
- **Задача:** S5-22 (Real-time fraud scoring <100ms), S5-26 (APP scam detection PSR APP 2024)
- **IL ref:** IL-027 (Deviation)
- **Blocker:** Sardine.ai production contract не заключён. `SARDINE_CLIENT_ID` + `SARDINE_SECRET_KEY` отсутствуют. `SardineFraudAdapter` — stub (NotImplementedError).
- **Тип:** EXTERNAL_CONTRACT (vendor API key)
- **Unblock trigger:** CEO → контакт sales@sardine.ai → API keys → добавить в GMKtec `.env` → реализовать `SardineFraudAdapter.score()` → тест против Sardine sandbox
- **Дата блокировки:** 2026-04-08
- **Статус:** BLOCKED

---

*Файл поддерживается: Claude Code | I-31 (PROPOSED) | append-only*
