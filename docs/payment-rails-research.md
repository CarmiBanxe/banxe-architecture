# Payment Rails Research — BaaS Provider Comparison
**IL-012 | Banxe EMI | 2026-04-06**
**Gap:** S4 — Payment Rails (0% coverage, CRITICAL)
**Deadline:** Pre-FCA Application

---

## Контекст

Banxe EMI (FCA authorisation in progress) требует доступа к:
- **GBP Faster Payments (FPS)** — основной UK rail для клиентских переводов
- **EUR SEPA CT / SEPA Instant** — европейские платежи для EMI
- **REST API + webhooks** — интеграция в Midaz ledger + banxe-emi-stack
- **Sub-account IBANs** — виртуальные счета для клиентов EMI

Исследованы: **ClearBank, Modulr, Banking Circle, Railsr**

---

## Сравнительная таблица

| Критерий | ClearBank | Modulr | Banking Circle | Railsr |
|---|---|---|---|---|
| **Регуляторный статус** | BoE clearing bank (5-й в UK) + FCA | FCA EMI (FRN 900699) | Luxembourg banking licence (CSSF 2020) + UK branch | FCA EMI (Embedded Finance Ltd / Payrnet UK) — **RESTRICTED** |
| **GBP Faster Payments** | ✅ Direct, до £1M | ✅ Direct RTGS participant | ✅ через clearing partners | ✅ Паyrnet UK FPS member |
| **EUR SEPA CT** | ✅ ISO 20022 | ✅ | ✅ 24 currencies | ✅ |
| **EUR SEPA Instant** | ✅ | ✅ (запущен 2024) | ✅ | ✅ |
| **BACS** | ✅ Direct | ✅ Direct | ✅ | ✅ |
| **CHAPS** | ✅ | ✅ | ✅ | ✅ |
| **API-first** | ✅ Full REST, clearbank.github.io | ✅ Full REST, modulr.readme.io | ✅ REST + SFTP/SWIFT | ✅ |
| **Developer portal** | ✅ Публичный docs | ✅ Публичный docs | ⚠️ Ограниченный | ✅ |
| **Sandbox / test env** | ✅ Simulation environment | ✅ Open sandbox portal | ❓ Неизвестно | ⚠️ Статус неясен |
| **Webhooks** | ✅ Signed webhooks (DigitalSignature + Nonce) | ✅ Webhook management API | ⚠️ Не подтверждено | ✅ |
| **Sub-accounts / Virtual IBANs** | ✅ Для EMI/PI — safeguarding + operational | ✅ Unlimited sub-accounts за секунды | ✅ Для PSP/банков | ✅ |
| **UK sort code + account number** | ✅ | ✅ | ✅ | ✅ |
| **EU IBANs** | ✅ (SEPA-direct participant) | ✅ NL, ES, FR, IE | ✅ LU + branches | ✅ |
| **Midaz integration path** | 🔶 Custom REST → возможно | 🔶 Custom REST → возможно | 🔶 Custom REST → возможно | 🔶 Custom REST → возможно |
| **Pricing** | Custom enterprise | Custom (pricing page есть) | Custom enterprise | Custom |
| **Минимальный порог** | Высокий (enterprise) | Средний (SME-friendly) | Высокий (>€1T volume platform) | Неизвестен |
| **Onboarding / KYB** | Полный banking-grade KYB | Стандартный EMI onboarding | Enterprise KYB | FCA-restricted: новые партнёры ЗАПРЕЩЕНЫ без FCA consent |
| **Стабильность** | ✅ Высокая, consecutive profitability | ✅ Высокая, 99.99% uptime | ✅ Высокая, €4.33B assets | ⛔ НИЗКАЯ — acquisition D Squared 2023, merger Equals Money 2025, FCA restriction |
| **Fit для startup EMI** | 🟡 Средний — enterprise фокус | 🟢 Высокий | 🟡 Средний — PSP/bank фокус | 🔴 Исключить |

---

## Детальный анализ

### 1. ClearBank

**Статус:** 5-й клиринговый банк UK, лицензирован BoE/PRA. Единственный clearing bank без retail. Специализируется на EMI, PI, финтех.

**Сильные стороны:**
- Прямой участник всех UK схем (FPS, Bacs, CHAPS)
- SEPA CT + SEPA Instant через одно API
- Публичный developer portal с полной документацией
- Simulation environment без производственного контракта
- Webhooks с криптографической подписью
- Proven: Kraken, крупные EMI используют ClearBank для safeguarding accounts
- FCA safeguarding overhaul (May 2026) — ClearBank уже опубликовал guidance для партнёров

**Слабые стороны:**
- Enterprise фокус → высокий порог входа
- Нужна регуляторная квалификация (FCA authorised firm) — подходит Banxe после FCA approval
- Пока FCA authorisation in progress — может быть сложнее onboarding

**Midaz path:** REST API совместим. Нужна кастомная интеграция: ClearBank webhook → banxe-emi-stack → Midaz transaction API. Нет готового коннектора.

---

### 2. Modulr Finance

**Статус:** FCA EMI (FRN 900699) + DNB (Netherlands). Прямой участник FPS, Bacs, RTGS.

**Сильные стороны:**
- Та же регуляторная категория что и Banxe (EMI) — проще onboarding
- Open sandbox без контракта → немедленная интеграция
- Unlimited sub-accounts (sort code + account number) за секунды via API
- EU IBANs: NL, ES, FR, IE → SEPA coverage
- 99.99% uptime, $100B+ annualised volume
- API docs публичные (modulr.readme.io), webhook management API
- SME-friendly pricing (не только enterprise)
- FIS partnership (Jan 2026) показывает платформенный рост
- Alternative banking vertical — специально для EMI-подобных сценариев

**Слабые стороны:**
- US expansion может отвлекать ресурсы от UK/EU продукта
- UK GBP IBANs (sort code + account number), не IBAN формат — нужно проверить GB IBAN support для SEPA

**Midaz path:** Modulr REST API → custom Midaz connector. Modulr webhooks (`payment.completed`, `payment.failed`) → banxe-emi-stack event bus → Midaz double-entry ledger posting. Наиболее реалистичный путь интеграции из всех 4 провайдеров.

---

### 3. Banking Circle

**Статус:** Luxembourg banking licence (CSSF Feb 2020) + UK branch. НЕ FCA EMI — банк с UK филиалом.

**Сильные стороны:**
- 650+ финансовых институтов используют платформу
- 24 currency, 10 local clearing schemes
- SEPA Instant + FPS + BACS
- €4.33B assets → очень стабильный

**Слабые стороны:**
- Ориентирован на крупные PSP/банки/маркетплейсы — не на startup EMI
- Нет открытого sandbox (по имеющимся данным)
- Минимальные объёмы — скорее всего высокие
- Luxembourg registration → не UK FCA regulated напрямую (важно для FCA application)
- Developer docs ограниченные публично

**Вывод:** Хороший для масштаба, но не подходит для старта EMI.

---

### 4. Railsr (Embedded Finance Ltd / Payrnet UK)

**Статус:** FCA EMI (Payrnet UK) — но **КРИТИЧЕСКОЕ ОГРАНИЧЕНИЕ**: FCA запретил принимать новых агентов/дистрибьюторов без явного согласия FCA.

**Timeline проблем:**
- 2023 — финансовые трудности, приобретение D Squared Capital
- 2024 — FCA restriction: новый onboarding заморожен
- Apr 2025 — слияние с Equals Money

**Вывод: ИСКЛЮЧИТЬ из рассмотрения.** Регуляторный риск неприемлем для EMI-аппликанта.

---

## Midaz Integration Architecture (общая для всех провайдеров)

```
BaaS Provider API
      │
      ├─ Webhook: payment.received / payment.sent
      │
      ▼
banxe-emi-stack (statement_poller / payment_gateway service)
      │
      ├─ Parse event → PaymentDTO
      │
      ▼
Midaz Transaction API (POST /v1/transactions)
      │
      ├─ Double-entry: Dr Client Account / Cr Nostro Account
      │
      ▼
ReconciliationEngine
      │
      └─ CAMT.053 → pgAudit → ClickHouse audit trail
```

Midaz не имеет готовых коннекторов для UK BaaS провайдеров. Все 4 требуют кастомной интеграции через REST adapter. Оценка: 2-3 спринта разработки.

---

## Рекомендация CEO

### ✅ РЕКОМЕНДАЦИЯ: Modulr Finance (первичный выбор)

**Обоснование:**

1. **Регуляторное выравнивание** — Modulr FCA EMI (та же категория что Banxe). При FCA application демонстрация партнёрства с другим FCA EMI упрощает due diligence.

2. **Самый низкий барьер входа** — открытый sandbox доступен немедленно. Можно начать интеграцию до FCA approval.

3. **Полное rail coverage** — FPS direct + Bacs direct + SEPA CT + SEPA Instant. Один контракт = все rails.

4. **Sub-accounts via API** — unlimited за секунды, sort code + account number. Критично для EMI, выдающего счета клиентам.

5. **Webhooks** — реального времени события для reconciliation engine.

6. **Midaz integration** — наиболее документированный API из четырёх, проще написать adapter.

7. **Стабильность** — 99.99% uptime, $100B+ volumes, прибыльная компания.

### 🟡 РЕЗЕРВ: ClearBank (вторичный выбор)

Рассмотреть после FCA authorisation получена. ClearBank требует FCA-regulated status. Лучше подходит для масштаба (крупный transaction volume). Используется крупными EMI для safeguarding — может стать основным инструментом на стадии роста.

### 🔴 ИСКЛЮЧЕНЫ:
- **Railsr** — FCA restriction на новый onboarding. Неприемлемо для EMI-аппликанта.
- **Banking Circle** — enterprise-only, Luxembourg (не FCA), нет публичного sandbox.

---

## Следующие шаги (P1)

| Шаг | Действие | Ответственный |
|-----|----------|---------------|
| 1 | Зарегистрироваться в Modulr sandbox (modulrfinance.com/developer) | CEO |
| 2 | Получить sandbox API key | CEO |
| 3 | Разработать `services/payment/modulr_client.py` в banxe-emi-stack | Claude Code |
| 4 | Реализовать webhook handler → Midaz transaction posting | Claude Code |
| 5 | E2E тест: FPS payment → webhook → Midaz ledger → ReconciliationEngine | Claude Code |
| 6 | ClearBank — запросить sandbox access (для будущего масштаба) | CEO (после FCA auth) |

---

*Источники: ClearBank Developer Portal (clearbank.github.io), Modulr readme.io, Banking Circle regulatory-information, Railsr/ThePaypers acquisition news, FCA register, Gemba BaaS UK report 2026*
