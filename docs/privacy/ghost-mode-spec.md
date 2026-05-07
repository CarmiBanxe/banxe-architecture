# Ghost Mode — Privacy Tech Stack Specification

**Тип:** Feature Spec — Ghost Mode Privacy Tech Stack
**Статус:** FEATURE SPEC / PLANNED — реализация после legal/regulatory gates
**Дата:** 2026-05-07
**Ветка:** `feature/ghost-mode-privacy-stack`
**Базовый чекпоинт:** `checkpoint-2026-05-07-customer-privacy-right-v2-base`
**Базовый документ:** `docs/privacy/customer-privacy-right-v2.md`
**ADR-резерв:** ADR-074, ADR-075, ADR-076
**Контур:** только BANXE Self-Custody (out-of-scope EMI)

---

## 1. Концепция

Математика приватности уровня Monero/Zcash — поверх стандартных токенов и адресов на публичных блокчейнах. Приватность от посторонних наблюдателей. Без privacy coins. Без mixers. Только в non-custodial кошельке BANXE Self-Custody.

**Цель:** максимальная техническая приватность от blockchain explorer / on-chain analytics / третьих сторон при полном соответствии закону на уровне EMI on/off-ramp.

**Не цель:** анонимность от регулятора или обход закона.

**Контурная привязка:** Ghost Mode реализуется исключительно в продукте BANXE Self-Custody (out-of-scope EMI). На стороне EMI BANXE ни одна из 6 технологий не активируется как пользовательская фича; EMI остаётся под полным AML/CFT/Travel-Rule/DAC8/MiCA канвейером. Любая стыковка Ghost Mode с EMI on/off-ramp пересекает границу контуров — там работает полный AML EMI (I-55).

---

## 2. Технологический стек (6 уровней)

### Уровень 1 — ERC-5564 Stealth Addresses (Ethereum / EVM)

| Параметр | Значение |
|---|---|
| **Стандарт** | ERC-5564 + ERC-6538 (Stealth Meta-Address Registry) |
| **Статус** | Final; Ethereum нативная интеграция анонсирована 18.02.2026 |
| **Крипто-схема** | SECP256k1 |
| **Singleton contract** | `0x55649E01B5Df198D18D95b5cc5051630cfD45564` |
| **Production reference** | Umbra Cash (ScopeLift) |
| **Совместимость** | Любой ERC-20 (USDC, EURC, ETH, NFT); EVM-compatible L2: Arbitrum, Polygon, Base, Optimism |
| **ADR** | ADR-074 |

**Как работает:**
- Клиент публикует stealth meta-address (статичный, один на кошелёк).
- Каждый входящий платёж → уникальный одноразовый адрес.
- Sender вызывает `announce()` → публикует ephemeral public key.
- Recipient сканирует announcements своим scan-key.
- Внешний наблюдатель: видит несвязанные адреса без возможности установить общего получателя.
- Viewing key delegation: возможна через ERC-5564 metadata.

**Ограничения и архитектурные риски:**
- Recipient должен активно сканировать blockchain для обнаружения входящих.
- Gas overhead: дополнительный вызов `announce()` (на L2 — приемлемо; на L1 — существенная стоимость).
- Light wallet scanning — open research. Мобильный клиент требует либо собственный scan-сервер, либо batched scan через стороннюю инфраструктуру.
- **Provider-side observability risk:** scan-сервер потенциально может привязать meta-address ↔ device. Зафиксировано как I-58 sub-proposal: scan-инфраструктура не должна привязывать meta-address ↔ device (privacy-by-design baseline).
- Хранение и backup scan/spend keys — отдельная угроза: потеря scan-key = потеря возможности обнаружить входящие. Recovery-флоу для Self-Custody, без custody-recovery со стороны BANXE (Self-Custody канон).

---

### Уровень 2 — BIP-352 Silent Payments (Bitcoin)

| Параметр | Значение |
|---|---|
| **Стандарт** | BIP-352 (Complete, v1.0.2, июль 2025) |
| **Статус** | Complete |
| **Авторы** | Josie Baker, Ruben Somsen |
| **Крипто-схема** | ECDH on SECP256k1 |
| **SDK** | `bdk-sp` crate (Bitcoin Dev Kit, Q2 2025) |
| **Hardware wallet** | BIP-375 (DLEQ proofs, 2025) |
| **ADR** | ADR-074 |

**Как работает:**
- Клиент публикует один статичный Silent Payment адрес.
- Sender деривирует уникальный адрес из своих transaction inputs (ECDH).
- Нет взаимодействия с получателем. Нет on-chain overhead.
- Транзакция неотличима от обычной Bitcoin-транзакции.
- Derivation path: `m/352'/0'/0'/`.
- Scan keypair (`b_scan`, `B_scan`) + Spend keypair (`b_spend`, `B_spend`).
- Label mechanism: `B_m = B_spend + SHA256(b_scan || m) * G`.
- Совместим с BIP32, BIP39 seed phrases.

**Ограничения и архитектурные риски:**
- Recipient должен сканировать blockchain для обнаружения платежей.
- Light-client поддержка: open research (Appendix A BIP-352).
- Требует полного сканирования для определения баланса.
- Потеря `b_scan` key = потеря возможности обнаружить средства. Recovery — только через seed phrase (Self-Custody канон, BANXE не восстанавливает).

---

### Уровень 3 — Async PayJoin BIP-77 (Bitcoin, защита отправителя)

| Параметр | Значение |
|---|---|
| **Стандарт** | BIP-77 (merged 2025), BIP-78 (предшественник) |
| **Статус** | Merged |
| **Крипто-схема** | Oblivious HTTP (blinded directory server) |
| **Production reference** | Cake Wallet, Bull Bitcoin Mobile; `rust-payjoin` 0.21.0 (transaction cut-through) |
| **ADR** | ADR-075 |

**Как работает:**
- Отправитель инициирует транзакцию.
- Получатель добавляет свои inputs.
- Итоговая транзакция: смешанные inputs обеих сторон.
- Внешний наблюдатель: не может определить ни сумму, ни отправителя, ни получателя.
- Async (BIP-77): стороны не обязаны быть онлайн одновременно → координация через Oblivious HTTP.
- Backwards compatible: стандартные кошельки могут платить на PayJoin-адреса без поддержки протокола.

**Ограничения и архитектурные риски:**
- Требует кооперации второй стороны (receiver flow).
- **Жёсткое правило:** PayJoin никогда не выполняется внутри EMI custody wallet — только в Self-Custody. Иначе ломается чистота attribution в EMI ledger.

---

### Уровень 4 — HD Wallet BIP-32/44/84/86 + Privacy Score

| Параметр | Значение |
|---|---|
| **Стандарт** | BIP-32 (2012), BIP-44, BIP-84, BIP-86 |
| **Статус** | Widely deployed |
| **ADR** | ADR-075 |

**Стандартная функция:** новый адрес для каждой транзакции.

**Ghost Mode расширения:**
- Принудительная ротация адресов по умолчанию (ON).
- **Privacy Score:** real-time индикатор приватности (вычисляется локально, см. §3).
- Алерт при reuse адреса.
- «Burner account» режим: отдельный sub-account для разовых транзакций, изолированный от основного.
- xPub isolation: sub-accounts не связаны внешне.

---

### Уровень 5 — RAILGUN zk-SNARK Privacy Layer (EVM)

| Параметр | Значение |
|---|---|
| **Протокол** | RAILGUN (open source, decentralized governance) |
| **Статус** | ⚠️ **PENDING LEGAL REVIEW** (ADR-076 gate) |
| **Крипто-схема** | zk-SNARKs Groth16, Merkle Tree UTXOs, Nullifiers |
| **Сети** | Ethereum, Arbitrum, Polygon |
| **TVL** | ~$70M (стабилизирован к 2025) |
| **Объём транзакций** | >$2B |
| **ADR** | ADR-076 |

**Как работает:**
- Токены «экранируются» в private Merkle Tree.
- После shield: sender, receiver, token type, amount — зашифрованы.
- zk-SNARK доказывает валидность без раскрытия деталей.
- Поддержка DeFi: swap, lend, provide liquidity — приватно.
- SDK: RAILGUN Wallet SDK (открытый, интегрируется в любой EVM-кошелёк).

**Compliance hooks:**
- **Viewing Keys:** read-only аудируемый ключ по выбору клиента.
- **Private Proofs of Innocence (PPOI):** ZK-доказательство, что токены не связаны с sanctioned actors.
- Tax exports: интеграция с crypto tax ПО.

**Отличие от Tornado Cash (критически важно):**
- Tornado Cash: pool-based mixer → запрещён OFAC — **не поддерживается BANXE**.
- RAILGUN: UTXO-based ZK proof → не mixer. Однако регуляторная позиция EU/UK не финализирована.

**Жёсткие правила:**
- При попадании контрагента/адреса в OFAC/EU/UK санкционные списки — RAILGUN-операция блокируется на on/off-ramp и через VC-policy.
- В UI до legal clearance: `🔐 ZK Shield (RAILGUN) — PENDING LEGAL REVIEW (ADR-076)`.
- Активация только после ADR-076 = ACCEPTED (I-57).

---

### Уровень 6 — W3C Verifiable Credentials 2.0 + ZKP Identity

| Параметр | Значение |
|---|---|
| **Стандарт** | W3C VC 2.0 (май 2025), SD-JWT, JSON-LD |
| **ZKP** | BBS+ signatures, AnonCreds |
| **EU** | eIDAS 2.0 ARF (ZKP как обязательный примитив); национальная имплементация в FR/UK ещё движется |
| **SDK** | walt.id (open source identity stack) |
| **ADR** | ADR-074 |

**Как работает в Ghost Mode:**
1. BANXE EMI выдаёт клиенту VC после KYC: «holder прошёл KYC, не в санкционных списках, гражданин EU, верифицирован до [дата]».
2. Клиент хранит VC в Ghost Mode кошельке.
3. При взаимодействии с контрагентом: кошелёк предъявляет ZK-proof: `verified = true` (без имени, без даты рождения, без номера паспорта, без адреса).
4. Selective disclosure: раскрывается только запрошенный атрибут.

**Обязательные элементы:**
- **Non-PII AML-anchor:** VC включает non-PII anchor, по которому EMI BANXE может по lawful запросу регулятора восстановить связь с конкретным KYC-кейсом (через viewing-key/escrow на стороне BANXE), без раскрытия контрагенту. Это не нарушает selective disclosure для контрагента, но сохраняет lawful access на стороне EMI.
- **Expiry:** VC имеет обязательный срок действия.
- **Revocation list:** обязательна. Без revocation «не в санкционных списках» становится ложным утверждением через сутки. ADR-028 события (`JURISDICTION_CHANGED`, `ROLE_CHANGED`, `BENEFICIAL_OWNER_CHANGED`) триггерят revocation.

**Регуляторная основа:**
- GDPR Art. 25: data minimisation by design.
- eIDAS 2.0: ZKP официально требуется в EU wallet (ARF). Статус: basis, не «обязательство выполнено» — национальная имплементация в FR/UK ещё движется.
- Google ZKP open source (июль 2025): индустриальный стандарт.

---

## 3. Privacy Score — формула v1

Фиксируется в spec; уточняется при реализации.

### Бонусы (+)

| Компонент | Баллы |
|---|---|
| Silent Payments активны | +20 |
| Stealth Addresses активны | +20 |
| Address reuse = 0 (последние 30 дней) | +15 |
| PayJoin использован (последние 5 tx) | +15 |
| HD ротация активна | +10 |
| ZK-Identity активна | +10 |
| RAILGUN shield активен | +10 (только при ADR-076 = ACCEPTED; иначе 0) |

### Штрафы (-)

| Компонент | Баллы |
|---|---|
| Address reuse (каждый) | -5 |
| Известный адрес в blockchain explorer | -10 |
| Отключена ротация | -15 |

### Поведенческий принцип

Privacy Score вычисляется **локально на клиенте**. Никакая телеметрия Ghost Mode не уходит на BANXE-сервера в виде, позволяющем восстановить адресные связи. Privacy Score сам не должен стать каналом утечки.

---

## 4. UI-мокап (концептуальный)

```
┌─────────────────────────────────────────────────────────────┐
│  BANXE Self-Custody                          [Ghost Mode ON]│
│                                                             │
│  Privacy Score: ████████░░  78/100                          │
│  ⓘ Вычисляется локально, без серверной телеметрии           │
│  [Что снижает оценку?]  [Улучшить]                          │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  ✅ Stealth Addresses (ERC-5564)         ACTIVE             │
│  ✅ Silent Payments (BIP-352)            ACTIVE             │
│  ✅ PayJoin (BIP-77)                     ACTIVE             │
│  ✅ HD Auto-Rotation (BIP-32/44/84/86)   ACTIVE             │
│  🔐 ZK Shield (RAILGUN)          PENDING LEGAL REVIEW      │
│                                   (ADR-076)                 │
│  ✅ ZK-Identity (W3C VC + BBS+)          ACTIVE             │
│     Контрагент получает: verified = true                    │
│     Контрагент НЕ получает: имя, паспорт, адрес            │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  > Ghost Mode не скрывает вас от закона. KYC сохранён.      │
│  > On-ramp / off-ramp под полным AML EMI. Sanctions law     │
│  > применяется к клиенту независимо от Ghost Mode.          │
│  > Stablecoin issuer freeze/denylist применяется             │
│  > без исключений.                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Что Ghost Mode НЕ делает

> **Обязательный дисклеймер (отображается в UI):**
>
> - НЕ скрывает клиента от BANXE (KYC сохранён).
> - НЕ скрывает on-ramp/off-ramp от регулятора.
> - НЕ является анонимностью от закона.
> - НЕ включает privacy coins (XMR, ZEC shielded, Dash PrivateSend — запрещены).
> - НЕ включает mixers (Tornado Cash и аналоги — запрещены).
> - Sanctions law (OFAC / EU / UK) применяется к клиенту независимо от Ghost Mode.
> - Stablecoin issuer freeze/denylist (USDC / EURC / USDT и др.) применяется без исключений; Ghost Mode не является и не позиционируется как канал обхода issuer compliance (I-56).

---

## 6. Travel Rule на границе контуров

Self↔self self-custody P2P — вне TFR (Recital 58). Однако любой переход:
- Self-Custody ↔ EMI custody (TOMPAY)
- Self-Custody ↔ другой VASP/CASP

— является Travel-Rule trigger (FATF R.16 / TFR). Ghost Mode **не маскирует** Travel-Rule поля на этой границе. Все поля originator/beneficiary заполняются в полном объёме при on/off-ramp через EMI (I-55).

---

## 7. Anti-abuse / per-KYC лимиты

Для предотвращения identity-fragmentation / structuring через множественные meta-addresses:

- **Per-KYC limit** на количество активных stealth/silent meta-addresses (I-58).
- Конкретное значение лимита определяется при реализации (conservative default).
- Scan-инфраструктура не должна привязывать meta-address ↔ device (privacy-by-design baseline).

---

## 8. Регуляторные / архитектурные риски и блокирующие milestones

| Milestone / риск | Статус | Влияние на Ghost Mode |
|---|---|---|
| **FCA CP26/13** (UK) | Ожидание финальной позиции, ~09.2026 | UK-аудитория: любая DEX/trading UI в Ghost Mode отключена через jurisdiction feature-flag до публикации |
| **TFR Art. 37 ревизия** | 2026-06-30 | Обязательный pre-launch reassessment всех out-of-scope границ и spec до релиза |
| **ACPR** (FR) | [НЕИЗВЕСТНО] | Запуск Ghost Mode / Self-Custody во FR — только после отдельной юр-консультации с ACPR |
| **RAILGUN EU/UK статус** | PENDING LEGAL REVIEW | ADR-076 gate; UI hidden/disabled до clearance (I-57) |
| **Light-client scanning** | Open research | Provider-side observability risk: scan-сервер ↔ device attribution (I-58) |
| **Key recovery** | Self-Custody канон | Потеря scan/spend keys = потеря средств; BANXE не восстанавливает (non-custodial) |

---

## 9. Pending Invariant Proposals (без правки INVARIANTS.md)

| ID | Формулировка | ADR |
|---|---|---|
| **I-54** | Ghost Mode реализуется только внутри out-of-scope продукта BANXE Self-Custody; ни один из 6 слоёв не активируется на EMI-стороне как клиентская фича. | ADR-074 |
| **I-55** | Любая стыковка Ghost Mode с EMI on/off-ramp подчиняется полному AML EMI (CDD, sanctions screening, Travel Rule, DAC8, blockchain analytics); Ghost Mode не маскирует Travel-Rule / sanctions / DAC8 поля на этой границе. | ADR-074/075 |
| **I-56** | Stablecoin issuer freeze/denylist applies to Ghost Mode wallets без исключений; Ghost Mode не позиционируется как канал обхода issuer compliance. | ADR-074 |
| **I-57** | RAILGUN активируется только после ADR-076 legal clearance в EU/UK; до этого — UI hidden / disabled. | ADR-076 |
| **I-58** | Per-KYC limit на количество активных stealth/silent meta-addresses; scan-инфраструктура не должна привязывать meta-address ↔ device (privacy-by-design baseline). | ADR-074/075 |

---

## 10. Roadmap Entry (внутри spec, не в ROADMAP.md)

### [PLANNED] Ghost Mode — Privacy Tech Stack

**Зависимость:** `docs/privacy/customer-privacy-right-v2.md` (PR #128, `checkpoint-2026-05-07-customer-privacy-right-v2-base`)

| Phase | Содержание | ADR | Gate |
|---|---|---|---|
| **Phase 1** | HD-ротация (BIP-32/44/84/86) + BIP-352 Silent Payments + ERC-5564 Stealth Addresses + базовый Privacy Score | ADR-074 | Tech |
| **Phase 2** | PayJoin BIP-77 + W3C VC ZK-Identity (BBS+/AnonCreds) + per-KYC limit + revocation/expiry | ADR-075 | Tech + Legal (VC issuance) |
| **Phase 3** | RAILGUN zk-SNARK (после legal clearance) | ADR-076 | Legal (EU/UK RAILGUN status) |

**Блокирующие gates:**
- **Tech-gate:** ADR-074 / ADR-075 / ADR-076.
- **Legal-gate:** RAILGUN EU/UK status (ADR-076).
- **Regulatory-gate:** FCA CP26/13 (UK, ~09.2026), TFR Art. 37 (EU, 2026-06-30), ACPR (FR, отдельная юр-консультация).

---

## 11. Связи с другими блоками roadmap и invariants

| Артефакт | Связь с Ghost Mode |
|---|---|
| `customer-privacy-right-v2.md` (PR #128, `checkpoint-2026-05-07-customer-privacy-right-v2-base`) | Обязательная база; без неё spec не валиден |
| DAC8-блок (`checkpoint-2026-05-06-dac8-tax-reporting-block`) | Customer-Operations и Tax-Reporting Function поставляют KYC/anchor для VC; `JURISDICTION_CHANGED` (ADR-028) триггерит revocation VC |
| OSS-Sumsub-блок (`checkpoint-2026-05-06-oss-sumsub-replacement-block`) | Стек источников AML на on/off-ramp (Ballerine, Yente/Watchman, Jube, Marble) |
| DeFi-стек-блок (`checkpoint-2026-05-06-defi-stack-binance-replacement-block`) | Non-custodial UI канон; reserve пометки (CASP/MiFID-обвязка) применяются к Ghost Mode dex-функциям |
| Owner-Control-Agent-блок (`checkpoint-2026-05-06-owner-control-agent-block`) | Observer-only KPI; Ghost Mode не отчитывается перед Owner-агентом по PII клиента, только агрегатами |
| ADR-027 (audit-trail durability) | Все события Ghost Mode на стыке EMI ↔ Self-Custody логируются через canonical audit-канал |
| ADR-028 (KYC re-trigger events) | `JURISDICTION_CHANGED` / `ROLE_CHANGED` / `BENEFICIAL_OWNER_CHANGED` инициируют пересмотр VC и revocation |
| ADR-033 / ADR-034 (alert routing / webhook reliability) | Alerts по issuer-freeze / sanctions-hit на стыке проходят через канонический канал, а не через клиента |
| I-32 / I-33 (no direct cloud LLM, PII-routes через локальные алиасы) | Любые AI-помощники в Ghost Mode UI маршрутизируются через утверждённый AI-plane (LiteLLM v2 / EU-managed Claude / Bedrock-EU с DPA) |
| I-36 (Claude Code bash via Guardian shim) | Все автоматизации, связанные с этой spec, проходят shim |
| I-49 (запрет privacy coins / mixers / coin-join) | Ghost Mode использует только стандартные токены на публичных блокчейнах; privacy coins и mixers запрещены |

---

## 12. Skeleton ADR-записи

Skeleton-версии ADR-074, ADR-075, ADR-076 размещены в `decisions/`:

- `decisions/ADR-074-stealth-and-silent-payments.md` — Status: PROPOSED
- `decisions/ADR-075-payjoin-and-hd-privacy-score.md` — Status: PROPOSED
- `decisions/ADR-076-railgun-integration-decision-gate.md` — Status: PENDING LEGAL REVIEW
