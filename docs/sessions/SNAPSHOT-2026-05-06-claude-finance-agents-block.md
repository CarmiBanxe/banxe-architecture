# SNAPSHOT — Anthropic Claude Finance Agents: оценка применимости в EMI BANXE AI BANK

## Метаданные

| Поле | Значение |
|------|----------|
| Тип | Roadmap Block (Anthropic Claude Finance Agents — EMI applicability assessment) |
| Дата | 2026-05-06 (CEST) |
| Базовый чекпоинт | `checkpoint-2026-05-06-sber-oss-emi-block` → `23bc5d9` |
| Источники | https://claude.com/solutions/financial-services#finance-agents; пользовательский анонс |
| Тег после merge | `checkpoint-2026-05-06-claude-finance-agents-block` (ставит оператор) |

**Цель документа:** зафиксировать инвентаризацию и оценку применимости готовых Anthropic Claude finance agent templates в EMI BANXE AI BANK с явным разделением «применимо в текущем EMI-периметре / резерв на расширение лицензии», регуляторными и data-residency ограничениями и точками интеграции с уже существующим стеком BANXE. Это документ-план; код в banxe-emi-stack в этом ходе не создаётся.

---

## 1. Внешний контекст: что предлагает Anthropic

Anthropic выпустила набор готовых agent templates для финансовых команд под брендом **Claude Finance Agents**:

| Template | Краткая суть |
|----------|-------------|
| **KYC agent** | Оркестрация KYC/KYB: парсинг документов, sanctions/PEP-проверка, формирование risk tier |
| **Reconciliation agent** | Автоматическая сверка позиций, выявление расхождений, human-readable отчёт |
| **Month-end close agent** | Сбор данных для закрытия периода, P&L draft, пакет внутренней отчётности |
| **Credit memo agent** | Подготовка кредитного меморандума, анализ кредитоспособности заёмщика |
| **Pitch book agent** | Автоматизация сборки питчбука для M&A / ECM / DCM мандатов |
| **Valuation review agent** | Верификация DCF/comp-валюации, выявление аномалий |
| **Fund accounting agent** | NAV-расчёт, распределение расходов, investor reporting для инвест-фондов |

**Деплой-режимы:**
- Claude Cowork plugin (desktop/browser)
- Claude Code (CLI) — разработка и тестирование агентов
- Cookbook (open-source templates) → Managed Agents в production через Anthropic API

**Бизнес-логика Anthropic:** enterprise-ниша, где ценность измеряется сэкономленными часами аналитиков и compliance-офицеров, а не качеством свободных ответов. Основная аудитория — buy-side, sell-side, корпоративный finance, регуляторный compliance.

---

## 2. Регуляторный контекст EMI BANXE

### 2.1 Что разрешает EMI-лицензия (EMD2 / PSD2)

- Выпуск электронных денег (e-money issuance)
- IBAN-счета и хранение клиентских средств (safeguarding по CASS 15)
- Переводы: SEPA, SWIFT, FPS, CHAPS
- Карты (prepaid / debit, Mastercard / Visa)
- Money remittance и FX-конвертация
- PIS / AIS (PSD2 Open Banking)
- EMT (Electronic Money Token) под MiCA

### 2.2 Что НЕ разрешает EMI-лицензия

- Кредитование, BNPL, выдача займов
- Привлечение депозитов
- Инвестиционные услуги (MiFID II)
- Investment banking мандаты (M&A, ECM, DCM)
- Investment management / fund management

**Следствие:** шаблоны pitch book, valuation review, credit memo, fund accounting — вне текущего EMI-периметра BANXE. Любое их использование допустимо только после соответствующего расширения лицензии и отдельного ADR.

### 2.3 AML/CFT-приоритет по EBA

Для EMI-организаций EBA особо выделяет: transaction monitoring, SAR/STR submission, периодическую KYC re-verification. Именно в этих областях Claude Finance Agents создают наибольшую регуляторную ценность для BANXE.

---

## 3. EMI-периметр: фильтр применимости

| Template (Anthropic) | EMI-применимость | Причина | Связи в BANXE |
|---|---|---|---|
| **KYC agent** | **YES (in scope)** | EMI KYC/KYB обязателен; стыкуется с ADR-028 re-verification triggers | `services/kyc/kyc_port`, `services/customer_lifecycle/*`, ADR-028 |
| **Reconciliation agent** | **YES (in scope)** | Safeguarding recon, payments recon, ledger vs bank | `services/recon/*`, Safeguarding Engine, ClickHouse audit (ADR-027) |
| **Month-end close agent** | **PARTIAL** | EMI закрывает свой month-end (P&L, safeguarding отчёты, FIN060) — но **не** клиентский investment accounting | `reporting/FIN060`, Consumer Duty annual report |
| **Credit memo** | **OUT-OF-SCOPE (canonical)** | EMI не выдаёт кредиты — каноничный запрет EMD2/PSD2 | — |
| **Pitch book** | **OUT-OF-SCOPE (reserve)** | Investment banking advisory вне EMI | — |
| **Valuation review** | **OUT-OF-SCOPE (reserve)** | Investment services вне EMI | — |
| **Fund accounting** | **OUT-OF-SCOPE (reserve)** | Investment management вне EMI | — |

> **Правило:** out-of-scope шаблоны не реализуются и не интегрируются до тех пор, пока не будет соответствующего расширения лицензии и отдельного ADR. Наличие шаблона у Anthropic не является основанием для его внедрения в регулируемую деятельность BANXE.

---

## 4. Применения в EMI-операциях BANXE (только in-scope)

### 4.1 KYC Agent (Claude template)

**Роль в BANXE:** вспомогательная/альтернативная имплементация поверх существующего KYC-канала (Ballerine + SumSub). Не заменяет регуляторно-утверждённые провайдеры, но может выступать оркестрирующим слоем.

**Сценарии применения:**
- Парсинг и нормализация документов (паспорт, utility bill, corporate registry extract)
- Оркестрация sanctions/PEP-check — агрегация сигналов от Moov Watchman + внешних списков
- Формирование KYC risk tier с текстовым обоснованием (explainability для MLRO)
- Enhanced Due Diligence (EDD) пакет для клиентов с риском ≥ I-04 (£10k/£50k порог)

**Интеграция с ADR-028:** `BanxeEventType.ROLE_CHANGED / BENEFICIAL_OWNER_CHANGED / JURISDICTION_CHANGED` генерируют `KycReTriggerEvent`, который публикуется в InMemoryEventBus / Kafka topic. Внешний Claude KYC agent или локальный GigaAgent-адаптер подписываются на этот топик. Выбор имплементации фиксируется в ADR-042 (резерв, не создавать в этом PR).

**Точки интеграции в коде:**
```
services/kyc/kyc_port.py        → KYCGuardPort (Protocol)
services/customer_lifecycle/fsm.py → notify_attribute_change()
services/events/event_bus.py    → InMemoryEventBus / BanxeEventType
```

**HITL-ограничение (I-27):** агент формирует KYC risk report и PROPOSES решение. Финальный onboarding decision — MLRO или Compliance Officer (L3/L4).

### 4.2 Reconciliation Agent (Claude template)

**Роль в BANXE:** надстройка над существующим ReconciliationEngine для генерации human-readable отчётов по расхождениям и создания кейсов.

**Сценарии применения:**

1. **Safeguarding recon (CASS 15)** — ежедневная сверка client money pool (segregated account в банке-хранителе) и клиентских балансов по Midaz ledger. Агент выявляет delta > £0, формирует incident report.
2. **Payments recon** — Modulr/SEPA/SWIFT транзакции vs internal ledger (Midaz). Агент матчит по reference/amount/date, помечает unmatched.
3. **Cross-entity recon** — TomPay ↔ Neuronext (Phase 6 Crypto Block). Агент сверяет on-chain события с off-chain ledger записями.
4. **Intra-day recon** — real-time reconciliation для high-volume платёжных потоков.

**Ограничения:**
- Агент формирует отчёт и кейсы — он **не пишет** в ledger и не закрывает транзакции.
- Все результаты сверок логируются в ClickHouse audit trail (ADR-027, I-24 append-only).
- Расхождения маршрутизируются по канону алертов ADR-033.

**Точки интеграции в коде:**
```
services/recon/reconciliation_engine.py
services/recon/statement_fetcher.py
services/recon/bankstatement_parser.py  (CAMT.053 / MT940)
ClickHouse: safeguarding_events table (5yr TTL, I-08)
```

### 4.3 Month-End Close Agent (partial)

**Роль в BANXE:** собственный month-end EMI-организации. Не клиентский investment accounting.

**Допустимые сценарии (in-scope):**
- Сбор FIN060 safeguarding отчёта (CASS 15 / FCA submission)
- Подготовка Consumer Duty annual snapshot (PS22/9)
- Сверка SAR-логов за период (MLRO summary)
- Формирование internal close package: P&L, balance sheet, safeguarding compliance status

**Недопустимые сценарии (out-of-scope):**
- Клиентский investment P&L (нет инвест-лицензии)
- NAV-расчёт фондов (нет fund management)
- Loan book provisioning (нет кредитного портфеля)

**Точки интеграции:**
```
services/reporting/fin060_generator.py
dbt/models/marts/fin060/fin060_monthly.sql
services/consumer_duty/
services/case_management/  (SAR log summary)
```

**HITL (I-27):** финальный sign-off FIN060 — CFO (L4 gate, 3 дня по матрице агентов).

---

## 5. Архитектурная карта

```
┌─────────────────────────────────────────────────────────────────┐
│                  EMI BANXE AI Bank (FCA, EU)                    │
│                                                                 │
│  ┌──────────────────────────┐  ┌───────────────────────────┐    │
│  │ Compliance / Ops Console │  │ Customer / Mobile UI      │    │
│  └──────────────┬───────────┘  └──────────────┬────────────┘    │
│                 │                             │                 │
│  ┌──────────────▼─────────────────────────────▼──────────────┐  │
│  │               FastAPI Backend (BANXE Core)                │  │
│  │   services/kyc  services/recon  services/reporting        │  │
│  │   services/events/event_bus  services/customer_lifecycle  │  │
│  └──────────────────────────┬──────────────────────────────┘   │
│                             │                                   │
│  ┌──────────────────────────▼──────────────────────────────┐    │
│  │         AI-plane (LiteLLM v2, local aliases)            │    │
│  │         I-32: no direct cloud LLM bypass                │    │
│  │         I-33: PII/AML deny-paths via local aliases      │    │
│  └───────┬──────────────────┬────────────────────┬─────────┘    │
│          │                  │                    │              │
│  ┌───────▼──────┐  ┌────────▼─────────┐  ┌──────▼───────────┐  │
│  │ Local LLM    │  │ EU-managed       │  │ Future: Claude   │  │
│  │ (qwen, etc.) │  │ Anthropic        │  │ Finance Agents   │  │
│  │ Guardian     │  │ (Bedrock-EU /    │  │ (KYC / Recon /   │  │
│  │ shim ADR-026 │  │ DPA required)    │  │ Month-end only)  │  │
│  └──────────────┘  └──────────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Пояснение к схеме:**

Claude Finance Agents — это **внешний слой**, который никогда не вызывается напрямую из FastAPI Backend в обход AI-plane. Все запросы к Claude Finance Agents идут через LiteLLM v2 gateway с:
- Принудительной маршрутизацией в EU-регион Anthropic (Bedrock EU или эквивалент с DPA)
- Фильтрацией PII до отправки (I-33 deny-paths)
- Логированием запроса/ответа в ClickHouse audit trail (I-24, ADR-027)

Интеграционные точки из уже работающего стека:
- `services/events/event_bus.py` — KycReTriggerEvent → KYC Agent
- `services/kyc/kyc_port.py` — KYCGuardPort Protocol (агент имплементирует этот порт)
- `services/customer_lifecycle/fsm.py` — notify_attribute_change() триггер
- Safeguarding Engine → Reconciliation Agent
- ReconciliationEngine → расхождения → Month-end Close Agent
- ClickHouse `safeguarding_events` table → audit backbone для всех агентов

---

## 6. Регуляторные ограничения и data-residency

### 6.1 GDPR и трансграничная передача данных

| Сценарий | Допустимость | Условие |
|----------|-------------|---------|
| Передача агрегированных/анонимизированных данных в Claude Finance Agents | Допустимо | Нет PII в payload |
| Передача document snippets для KYC парсинга | Только через EU-managed Claude | DPA подписан, Bedrock EU region |
| Передача transaction patterns для recon | Допустимо при pseudonymisation | Без customer_id/name в payload |
| Raw customer PII (имя, дата рождения, IBAN) | **ЗАПРЕЩЕНО** во внешний Claude API | Нарушение GDPR Chapter V |

### 6.2 Pending invariant proposal

Без правки `INVARIANTS.md` в данном PR — фиксируется только как proposal:

> **I-38 — External AI agent platforms (Anthropic Claude Finance Agents и т.п.) must route via approved AI-plane (LiteLLM/Bedrock-EU) with DPA; no direct SaaS/PII transfer.**

Связи с уже принятыми инвариантами:
- **I-32** — no direct cloud LLM bypass (уже в INVARIANTS.md)
- **I-33** — PII/AML deny-paths via local aliases (уже в INVARIANTS.md)
- **I-36** — Claude Code bash via Guardian shim ADR-026
- **I-37** — Sber GigaChat: no EU/EEA PII to public endpoint (proposal из предыдущего блока)

### 6.3 Запреты для production-данных BANXE

- Запрещены теневые интеграции через Claude Cowork plugin / desktop tools / personal Anthropic accounts
- Запрещено использование Claude Code с production-данными BANXE без Guardian shim (I-36)
- Все production-вызовы к Claude Finance Agents только через approved AI-plane (I-32)

---

## 7. Связи с ADR/Track'ами и резерв будущих ADR

### Существующие ADR

| ADR | Связь с данным блоком |
|-----|----------------------|
| ADR-027 (audit-trail durability) | Все действия Claude-агентов логируются в ClickHouse append-only audit trail |
| ADR-028 (KYC re-verification) | KYC-агент подписывается на `KycReTriggerEvent`; events через InMemoryEventBus |
| ADR-033 (alert routing) | Расхождения reconciliation-агента маршрутизируются по канону алертов |
| ADR-034 (webhook reliability KYC) | Внешний KYC-агент использует те же webhook-гарантии для SumSub/Ballerine callbacks |

### Резервы будущих ADR (не создавать в этом PR)

| ADR | Тема |
|-----|------|
| **ADR-041** | External Agent Platform Integration Policy (Anthropic Claude / OpenAI / GigaChat) — routing, DPA, data residency |
| **ADR-042** | KYC Agent Implementation Choice (local GigaAgent vs Anthropic Claude template vs Ballerine-native) |
| **ADR-043** | Reconciliation Agent Implementation Choice and Audit Boundary |
| **ADR-044** | Month-End Close Agent Scope and HITL Sign-off Protocol |

---

## 8. Якоря для продолжения

| Поле | Значение |
|------|----------|
| Базовый тег | `checkpoint-2026-05-06-sber-oss-emi-block` |
| Новый тег после merge | `checkpoint-2026-05-06-claude-finance-agents-block` (ставит оператор) |
| Pending invariant | `I-38` (не добавлять в `INVARIANTS.md` до ADR-041) |
| Reserve ADR IDs | ADR-041, ADR-042, ADR-043, ADR-044 |

**Возможные следующие шаги (без обязательств):**
- ADR-041: External Agent Platform Integration Policy — объединяет GigaChat (I-37) и Claude Finance Agents (I-38) в единую политику
- ADR-042/043: выбор конкретных имплементаций KYC-агента и Reconciliation-агента
- PoC: reconciliation agent через approved AI-plane (LiteLLM v2) на синтетических данных safeguarding pool
- PoC: сравнение local KYC orchestrator (GigaAgent + Ballerine) vs внешний Claude KYC template

---

*Append slot для следующего блока → [`SNAPSHOT-2026-05-06-<next-block>.md`]*
