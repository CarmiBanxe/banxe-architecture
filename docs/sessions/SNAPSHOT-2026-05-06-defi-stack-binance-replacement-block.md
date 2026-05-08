# SNAPSHOT — Composable DeFi Stack vs Binance Dealer Program: оценка применимости в BANXE

## Метаданные

| Поле | Значение |
|------|----------|
| Тип | Roadmap Block (Composable DeFi Stack vs Binance Dealer Program — BANXE assessment) |
| Дата | 2026-05-06 (CEST) |
| Базовый чекпоинт | `checkpoint-2026-05-06-claude-finance-agents-block` |
| Источник | Пользовательский markdown «Decentralized Crypto Trading Platform — замена Binance Dealer Program»; executive summary, слоистая разбивка, revenue model, risk-раздел |
| Тег после merge | `checkpoint-2026-05-06-defi-stack-binance-replacement-block` (ставит оператор) |

**Цель документа:** зафиксировать инвентаризацию и оценку применимости Composable DeFi Stack (LI.FI / 0x / Rubic / dYdX v4 Builder Codes / Injective / GMX v2 / StakeKit / Hummingbot / Enso / OpenDAX / HollaEx) как структурной альтернативы Binance Dealer/white-label программе для BANXE, с явным разграничением «что укладывается в EMI-периметр / что требует CASP/MiFID-обвязки», AML/Travel-Rule привязкой и точками интеграции с существующим стеком. Это документ-план; код в `banxe-emi-stack` в этом ходе не создаётся.

---

## 1. Внешний контекст: предлагаемый стек

Вместо единого контрагента Binance — **Composable DeFi Stack** из open-source протоколов, организованных по слоям. Клиент работает через дашборд BANXE, исполнение происходит на DEX/perp-DEX/yield-протоколах, fee — on-chain.

### 1.1 Слоистая разбивка

| Слой | Протоколы / продукты |
|------|---------------------|
| **Frontend** | OpenDAX, HollaEx, dYdX v4 Frontend (open-source), кастомный React/Next.js |
| **Aggregation / Routing** | LI.FI, 0x Cross-Chain API, Rubic, Odos, ParaSwap, Enso |
| **Spot DEX** | Те же агрегаторы поверх Uniswap v4 / Curve / Balancer и т.д. |
| **Perp / Derivatives** | dYdX v4 (Builder Codes), Injective, GMX v2 |
| **Yield / Earn** | StakeKit / Yield.xyz, Aave, Compound, Lido, EigenLayer |
| **Trading bots / Automation** | Hummingbot, Enso bundles |

### 1.2 Revenue mechanics (out of the box)

| Механика | Протокол | Примерный уровень |
|----------|---------|-------------------|
| Builder Codes fee redirect | dYdX v4 | до 40% от trading fee |
| Integrator fee | LI.FI / 0x / Rubic / Odos | 0.1–0.3% от swap |
| Referral Tier 3 | GMX v2 | 25% rebate / tier fee share |
| Fee redirect | Injective | 40% trading fee redirect |
| Performance/protocol fee | StakeKit / Yield.xyz | % от yield |
| Partner fee | 0x Swap API | настраиваемый bps |

Все revenue mechanics помечены `pending-legal-review` — корректная квалификация поступлений требует UK/EU legal opinion, чтобы убедиться, что BANXE не реклассифицируется как investment firm (см. §7).

> Это **внешний design proposal**, не решение BANXE. Настоящий документ инвентаризирует кандидатов и фильтрует их через EMI-периметр.

---

## 2. EMI-периметр и фильтр применимости

### 2.1 Регуляторная рамка

BANXE — FCA-регулируемый EMI под EMD2/PSD2. Это означает:

**Разрешено в рамках EMI:**
- Выпуск электронных денег (e-money), IBAN-счета, safeguarding (CASS 15)
- Переводы (SEPA, SWIFT, FPS), FX-конвертация
- Карты (prepaid/debit), Money remittance
- PIS/AIS (PSD2 Open Banking)
- EMT (Electronic Money Token) под MiCA как часть EMI/MiCA-ролей
- Non-custodial UI-агрегация свопов, где BANXE не является контрагентом и не держит крипто-средства клиентов за пределами EMI-обязательств

**НЕ разрешено без дополнительной лицензии:**
- Кредитование, BNPL, займы
- Привлечение депозитов
- Инвестиционные услуги (MiFID II), деривативы, маржинальная торговля
- Investment management, fund management
- Custodial DeFi (принятие крипто-средств клиентов для DeFi-активности = CASP custody под MiCA)

### 2.2 Таблица фильтра применимости

| Слой / протокол | Природа сервиса | EMI-совместимость | Требования для использования | Связи в BANXE |
|---|---|---|---|---|
| **LI.FI / 0x Cross-Chain / Rubic / Odos / ParaSwap / Enso** | Cross-chain swap aggregator | **YES — только non-custodial UI-режим** | DPA, AML pre-trade screening, sanctions/PEP-фильтр, Travel Rule support | `services/aml`, `services/kyc`, `services/events` |
| **dYdX v4 Builder Codes / GMX v2 / Injective** | Perp DEX, leverage, derivatives | **OUT-OF-SCOPE** — только под CASP/MiFID-оболочкой и non-custodial UI | Отдельная лицензия / legal entity / ADR | Reserve only |
| **StakeKit / Yield.xyz / Aave / Compound / Lido / EigenLayer** | Yield, staking, lending | **OUT-OF-SCOPE** как «Earn от лица BANXE»; non-custodial UI допустим под CASP/MiCA | DPA, AML, sanctions, явный disclosure | Reserve only |
| **Hummingbot / Enso bundles** | Trading automation | **OUT-OF-SCOPE** как клиентское предложение; допустим как внутренний аналитический инструмент | Отдельный ADR на внутреннее применение | Internal analytics only |
| **OpenDAX / HollaEx Frontend** | Exchange frontend framework | **PARTIAL** — применим как UI-каркас только при отказе от встроенных custody/escrow режимов | Архитектурный ревью совместимости с FCA/MiCA/EMI-каноном | Reserve / future ADR |
| **Builder Codes / Referral / Integrator / Performance fee** | Revenue mechanics | `pending-legal-review` | UK/EU legal opinion + отдельный ADR | — |
| **EMT-стейблкоины** | E-money token (MiCA Art. 48) | **YES** | MiCA EMT whitepaper, ongoing compliance | `services/payment`, `services/ledger` |

> **Правило:** OUT-OF-SCOPE / Reserve пункты не реализуются и не интегрируются до соответствующей лицензии и отдельного ADR. Наличие open-source протокола не является основанием для его внедрения в регулируемую деятельность.

---

## 3. Применения in-scope (текущий EMI-периметр)

### 3.1 Non-custodial swap UI

BANXE предоставляет UI поверх LI.FI / 0x / Rubic, **не принимая** средства клиента в кастоди. Все транзакции инициируются клиентом с подписью из собственного кошелька; BANXE — маршрутизатор + AML-фильтр.

**Поток:**
```
Клиент (собственный кошелёк)
  → BANXE UI (маршрутизация, AML pre-trade screening)
  → Aggregation layer (LI.FI / 0x / Rubic)
  → DEX / bridge (on-chain исполнение)
```

**AML-контрольные точки (обязательны):**
- Pre-trade screening: sanctions/PEP-проверка адреса назначения и токена
- Blocked tokens/chains/pools: проверка по OFAC/EU consolidated list + FATF blocked jurisdictions (I-02)
- Post-trade audit: все события → ClickHouse audit trail (ADR-027, I-24)
- Re-verification trigger: смена jurisdiction/UBO клиента → `BanxeEventType.JURISDICTION_CHANGED` / `BENEFICIAL_OWNER_CHANGED` (ADR-028)

**Интеграция в существующий стек:**
```
services/aml/aml_thresholds.py      → blocked jurisdictions (I-02), EDD thresholds (I-04)
services/kyc/kyc_port.py            → KYCGuardPort Protocol
services/customer_lifecycle/fsm.py  → notify_attribute_change()
services/events/event_bus.py        → InMemoryEventBus / BanxeEventType
ClickHouse: safeguarding_events      → append-only audit (I-08, I-24)
```

### 3.2 EMT-стейблкоин-операции (MiCA EMT)

Эмиссия, конвертация и redemption EMT-стейблкоинов как часть EMI/MiCA EMT-роли. Исключительно в периметре payment flows и FX — без перехода в инвестиционные продукты. Привязка к Phase 6 (Crypto Block) и services/payment.

### 3.3 Travel Rule исполнение

Все исходящие крипто-операции из BANXE-UI подпадают под FATF Recommendation 16 и MiCA AML/CFT (5AMLD/6AMLD). Интеграция:
- Travel-Rule-провайдер: Sumsub Travel Rule / Notabene / Veriscope (выбор — отдельный ADR)
- Переиспользование существующего AML pipeline
- Audit trail через ADR-027 / ClickHouse
- SAR-логирование через `services/case_management`

### 3.4 Internal use: Hummingbot / Enso для аналитики рынка

Только как внутренний инструмент маркет-аналитики BANXE (мониторинг spread, ликвидности, routing efficiency). Без клиентского предложения и без алготрейдинга от лица BANXE. Требует отдельного ADR на внутреннее применение (ADR-046, резерв).

---

## 4. Применения reserve (вне текущего EMI, под будущую CASP/MiCA/MiFID-обвязку)

Следующие компоненты зафиксированы как **резерв** и не реализуются до получения соответствующей лицензии и выпуска отдельного ADR:

| Компонент | Лицензионная предпосылка |
|-----------|-------------------------|
| dYdX v4 Builder Codes (perp trading) | CASP custody + MiFID investment firm или non-custodial CASP UI |
| GMX v2 referral (leverage trading) | то же |
| Injective fee redirect (derivatives) | то же |
| StakeKit / Yield.xyz (yield-агрегация) | CASP / MiCA + явный disclosure; не «гарантированный yield» |
| Aave / Compound / Lido / EigenLayer (lending/staking) | то же |
| Hummingbot как клиентское предложение | MiFID + дополнительная оценка |
| OpenDAX / HollaEx (полный exchange) | Архитектурный ревью + CASP + FCA sandbox |

---

## 5. Архитектурная карта

```
┌──────────────────────────────────────────────────────────────┐
│                EMI BANXE AI Bank (FCA, EU)                   │
│                                                              │
│  ┌──────────────────────────┐  ┌─────────────────────────┐   │
│  │  Customer Web/Mobile UI  │  │ Compliance / Ops Console│   │
│  └──────────────┬───────────┘  └────────────┬────────────┘   │
│                 │                           │                │
│  ┌──────────────▼───────────────────────────▼────────────┐   │
│  │            FastAPI Backend (BANXE Core)               │   │
│  │  KYC · AML · Sanctions/PEP · Travel Rule · Audit      │   │
│  └───────────────────────────┬───────────────────────────┘   │
│                              │                               │
│              ┌───────────────┼───────────────────┐           │
│              │ in-scope EMI  │  reserve (CASP)   │           │
│              ▼               │                   ▼           │
│   ┌──────────────────────┐   │   ┌────────────────────────┐  │
│   │ Non-custodial swap UI│   │   │ Perp DEX (dYdX, GMX,   │  │
│   │ LI.FI / 0x / Rubic   │   │   │ Injective), Yield      │  │
│   │ Odos / ParaSwap       │   │   │ (StakeKit, Aave, Lido, │  │
│   │ + AML pre-trade check │   │   │ EigenLayer), trading   │  │
│   └──────────┬────────────┘   │   │ bots (client-facing)   │  │
│              │                │   └────────────┬───────────┘  │
│              ▼                │                ▼              │
│   ┌──────────────────────┐   │   ┌────────────────────────┐  │
│   │ EMT-стейблкоины      │   │   │ Reserved until:        │  │
│   │ (MiCA EMT Art. 48)   │   │   │ – CASP/MiCA license    │  │
│   └──────────────────────┘   │   │ – Dedicated ADR        │  │
│                              │   └────────────────────────┘  │
│              ┌───────────────┘                               │
│              ▼                                               │
│   ┌──────────────────────┐                                   │
│   │ Travel Rule execution│                                   │
│   │ (Sumsub / Notabene)  │                                   │
│   └──────────────────────┘                                   │
└──────────────────────────────────────────────────────────────┘
```

**Пояснение:**
- **Левый коридор (in-scope EMI):** non-custodial swap UI + EMT-стейблкоины + Travel Rule — вся активность проходит через KYC/AML/audit backbone BANXE. BANXE не является контрагентом по крипто-сделкам; клиент подписывает транзакции своим кошельком.
- **Правый коридор (reserve/CASP):** деривативы, yield-продукты, клиентские trading bots — активируются только при наличии CASP и/или MiFID-лицензии и выпуска отдельных ADR.
- Весь стек интегрируется с `services/events/event_bus`, `services/kyc/kyc_port`, `services/customer_lifecycle/*`, AML pipeline, ClickHouse audit trail (ADR-027).

---

## 6. Регуляторные ограничения и data-residency

### 6.1 Жёсткие запреты (current EMI, без исключений)

| Запрет | Основание |
|--------|-----------|
| Размещение клиентских средств EMI safeguarding pool в DeFi-протоколах | CASS 15 / EMD2 Art. 7 — safeguarding pool не может инвестироваться в рисковые активы |
| Маржинальная торговля / leverage от лица BANXE | EMI не имеет MiFID-инвест-лицензии |
| «Гарантированная доходность» / «pooled yield» от лица BANXE | Квалифицируется как investment product; требует MiFID/MiCA CASP |
| Кастодиальный DeFi (BANXE держит крипто-средства клиентов для DeFi-активности) | Требует CASP custody licence под MiCA |
| Предложение debit/margin против DeFi collateral без MiFID | Вне EMI-периметра |

### 6.2 GDPR и data-residency

- PII клиентов EU/EEA не маршрутизируется через внешние SaaS DeFi-агрегаторы без DPA.
- Хостед-фронтенды (Rubic widget, OpenDAX cloud, HollaEx cloud) в роли «эмбед в BANXE» рассматриваются как data processors и требуют DPA + привязки к I-32/I-33.
- Все routing-запросы к LI.FI / 0x / Rubic API — только через approved AI-plane gateway с фильтрацией PII (I-33).

**Pending invariant proposal (без правки `INVARIANTS.md` в этом PR):**
> `I-39 — DeFi UI/aggregator integrations must keep custody non-custodial and route PII through approved gateways with DPA.`

Связи с уже зафиксированными инвариантами:
- **I-02** — blocked jurisdictions: RU/BY/IR/KP/CU/MM/AF/VE/SY → применяется как pre-trade screen
- **I-08** — ClickHouse TTL ≥ 5 лет → всё DeFi-событие в audit trail
- **I-24** — append-only audit trail → DeFi events never deleted
- **I-32** — no direct cloud LLM bypass → AML/routing agents через AI-plane
- **I-33** — PII/AML deny-paths via local aliases
- **I-38** — External AI agent platforms must route via approved AI-plane (из предыдущего блока, proposal)

### 6.3 AML/Travel Rule специфика для DeFi

- Pre-trade screening: каждый swap-маршрут проверяется на blocked tokens, sanctioned DEX pools, blocked chain-IDs.
- On-chain address screening: OFAC/EU consolidated list + proprietary AML-сигналы через Moov Watchman.
- Travel Rule для переводов ≥ threshold: обязательное исполнение FATF R.16; интеграция с Travel Rule провайдером через `services/aml`.
- SAR автогенерация (будущий ADR): подозрительные DeFi-паттерны → SAR candidate → MLRO (L4 HITL, I-27).

---

## 7. Связи с ADR/Track'ами и резерв будущих ADR

### 7.1 Существующие ADR

| ADR | Связь с данным блоком |
|-----|----------------------|
| ADR-027 (audit-trail durability) | Все on-chain события, swap-маршруты, Travel Rule записи — ClickHouse append-only |
| ADR-028 (KYC re-verification) | Смена jurisdiction/UBO клиента при крипто-активности → `KycReTriggerEvent` |
| ADR-033 (alert routing) | Расхождения recon, AML-алерты по DeFi-маршрутам — по канону алертов |
| ADR-034 (webhook reliability KYC) | SumSub Travel Rule webhook гарантии |

### 7.2 Резервы будущих ADR (не создавать в этом PR)

| ADR | Тема |
|-----|------|
| **ADR-041** | External Agent Platform Integration Policy — продолжение из предыдущего блока |
| **ADR-045** | DeFi Aggregator Integration Policy (LI.FI / 0x / Rubic) — AML pre-trade, PII routing, DPA |
| **ADR-046** | Internal Analytics Use of Hummingbot/Enso (scope: non-client-facing) |
| **ADR-047** | Travel Rule Provider Selection and Integration (Sumsub / Notabene / Veriscope) |
| **ADR-048** | EMT-Stablecoin Issuance Pipeline (MiCA EMT Art. 48) — scoping, whitepaper, reserves |
| **ADR-049** | DeFi Revenue Mechanics Legal Qualification (Builder Codes / Integrator Fee / Referral) — pending-legal-review |
| **ADR-050** | CASP/MiCA Reserve Activation Protocol (perp DEX, yield, custody) — when license acquired |

---

## 8. Якоря для продолжения

| Поле | Значение |
|------|----------|
| Базовый тег | `checkpoint-2026-05-06-claude-finance-agents-block` |
| Новый тег после merge | `checkpoint-2026-05-06-defi-stack-binance-replacement-block` (ставит оператор) |
| Pending invariant | `I-39` (не добавлять в `INVARIANTS.md` до ADR-045) |
| Reserve ADR IDs | ADR-045..050 |
| Pending legal review | Revenue mechanics (Builder Codes, Integrator fee, Referral, Performance fee) |

**Возможные следующие шаги (без обязательств):**
- ADR-045: DeFi Aggregator Integration Policy — технический и AML-контракт для LI.FI/0x/Rubic
- ADR-047: Travel Rule Provider Selection
- ADR-048: EMT-Stablecoin Issuance Pipeline (стыкуется с Phase 6 Crypto Block)
- ADR-049: Legal opinion по revenue mechanics
- PoC: non-custodial swap UI поверх LI.FI на testnet с pre-trade AML screening

---

*Append slot для следующего блока → [`SNAPSHOT-2026-05-06-<next-block>.md`]*

## ADR Reservation Update (2026-05-09 canon-hygiene)

Первичный резерв `ADR-045..050`, зафиксированный в этом snapshot-документе, **переразмещён** в диапазон `ADR-050..055` для устранения collision с DAC8-блоком (`docs/sessions/SNAPSHOT-2026-05-06-dac8-tax-reporting-block.md`, PR #114, который зарезервировал `ADR-045..049` первым по дате регистрации 2026-05-06).

**Новый резерв этого блока — `ADR-050..055`** (six ADR slots для всех future architectural decisions Composable DeFi Stack, in scope EMI / out-of-scope CASP/MiFID разделения, integration policies).

Старые резервационные пометки (`045..050`) в теле этого документа считаются устаревшими и читаются с учётом этой fix-секции. Тело документа не редактируется по append-only канону §10.

Reference: PR от 2026-05-09 (canon-hygiene, ADR collision fix), branch `docs/canon-hygiene-2026-05-09-adr-numbers-collision-fix`.
