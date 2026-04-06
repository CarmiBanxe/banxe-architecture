# Sprint 8 — Block Plan (BLOCK-A through J)

**Источник:** ADR-013 (Midaz CBS), ADR-014 (Composable Financial Stack)  
**Sprint:** 8 (2026-04-06)  
**Deadline критический:** Block J — 7 May 2026 (FCA CASS 7 / EMR 2011 Reg.19)

---

## Статусы

| Статус | Значение |
|--------|----------|
| ✅ DONE | Реализовано, proof в ADR/IL |
| 🔄 IN_PROGRESS | Начато, есть артефакты |
| ⏳ NOT_STARTED | Запланировано, не начато |
| ❓ NOT_DEFINED | Блок упомянут, но не детализирован в текущих ADR |

---

## Block A — Core Banking System (CBS)

**Статус: ✅ DONE**  
**Sprint:** 8 BLOCK-A  
**ADR:** ADR-013

| Задача | Proof | Статус |
|--------|-------|--------|
| Midaz v3.5.3 deploy | `curl :8095/health → "healthy"` | ✅ |
| MongoDB rs0 replica | `docker ps → midaz-mongodb (healthy)` | ✅ |
| RabbitMQ 4.1.3 | `docker ps → midaz-rabbitmq (healthy)` | ✅ |
| PostgreSQL reuse (midaz_onboarding, midaz_transaction) | env vars verified | ✅ |
| Redis reuse (DB 1) | env vars verified | ✅ |
| DEF-002: healthcheck (distroless) | `disable:true` + cron | ✅ |

---

## Block B — Infrastructure / DevOps

**Статус: ❓ NOT_DEFINED**  
Явно не упомянут в ADR-013 / ADR-014. Возможно покрыт как часть Block A или операционной инфраструктуры GMKtec.

---

## Block C — Payment Rails

**Статус: ⏳ NOT_STARTED**  
**ADR:** ADR-014 Tier 1 (упомянут в диаграмме как отдельный блок)  
FPS, SEPA, SWIFT — конфигурация и интеграция. Sprint 10+ (ADR-014 Implementation Plan).

---

## Block D — General Ledger / Reconciliation Engine

**Статус: ⏳ NOT_STARTED**  
**ADR:** ADR-013 Consequences ("Next: reconciliation engine Block D-recon, Sprint 9"), ADR-014  
LedgerPort v1 adapter в процессе, Transaction API (`NotImplementedError`) — Sprint 9.  
**Следующий шаг:** D-recon design document + ClickHouse link.

---

## Block E — (не определён)

**Статус: ❓ NOT_DEFINED**  
Не упомянут явно в доступных ADR.

---

## Block F — Compliance Stack

**Статус: ✅ DONE (80%)**  
**ADR:** ADR-014 ("Block F compliance is already at 80%")  
AML/KYC/Sanctions API :8093, Jube TM, Marble, Watchman, ClickHouse audit trail, Semgrep + CI pipeline.  
Остаток 20%: OpenSanctions Yente (Phase 3), FIN-RPT reporting (Block K).

---

## Block G — (не определён)

**Статус: ❓ NOT_DEFINED**  
Не упомянут явно в доступных ADR.

---

## Block H — (не определён)

**Статус: ❓ NOT_DEFINED**  
Не упомянут явно в доступных ADR.

---

## Block I — (не определён)

**Статус: ❓ NOT_DEFINED**  
Не упомянут явно в доступных ADR.

---

## Block J — Safeguarding Engine (FCA CASS 7 / EMR 2011 Reg.19)

**Статус: 🔄 IN_PROGRESS**  
**ADR:** ADR-013 (Safeguarding Accounts section), ADR-014 ("P0 DEADLINE")  
**⚠️ DEADLINE: 7 May 2026** — FCA hard deadline

### Phase 1 — DONE ✅ (2026-04-06)

| Entity | ID | Статус |
|--------|----|--------|
| Organization: BANXE LTD | `019d6301-32d7-70a1-bc77-0a05379ee510` | ✅ |
| Safeguarding Ledger | `019d632f-519e-7865-8a30-3c33991bba9c` | ✅ |
| GBP Asset | `019d632f-7c06-75e0-9a49-8249da13f609` | ✅ |
| client_funds account (liability, CASS 7.13) | `019d6332-da7f-752f-b9fd-fa1c6fc777ec` | ✅ |
| operational account (asset, CASS 7.14) | `019d6332-f274-709a-b3a7-983bc8745886` | ✅ |

### Phase 2 — Sprint 9 ⏳

- [ ] Reconciliation engine: link accounts to external bank statements
- [ ] Daily safeguarding reconciliation report (FCA CASS 7.15)
- [ ] ClickHouse safeguarding event log
- [ ] LedgerPort Transaction API (currently `NotImplementedError`)

---

## Итоговая таблица

| Block | Название | Статус | Sprint |
|-------|---------|--------|--------|
| A | Core Banking System (Midaz) | ✅ DONE | 8 |
| B | Infrastructure / DevOps | ❓ NOT_DEFINED | — |
| C | Payment Rails (FPS/SEPA/SWIFT) | ⏳ NOT_STARTED | 10+ |
| D | GL Reconciliation Engine | ⏳ NOT_STARTED | 9 |
| E | (не определён) | ❓ NOT_DEFINED | — |
| F | Compliance Stack | ✅ 80% DONE | 1–8 |
| G | (не определён) | ❓ NOT_DEFINED | — |
| H | (не определён) | ❓ NOT_DEFINED | — |
| I | (не определён) | ❓ NOT_DEFINED | — |
| J | Safeguarding Engine | 🔄 IN_PROGRESS | 8–9 |

**NOT_DEFINED блоки (B, E, G, H, I):** требуют явного определения от CEO. Возможно покрыты ADR 015+ или не используются в текущей номенклатуре.
