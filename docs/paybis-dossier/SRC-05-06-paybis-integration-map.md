# SRC-05/06 — Paybis × ProWallet integration map (from operator preview)

**Plane:** docs-plane only (intake; no runtime). **Track:** F-crypto-provider (PAYBIS) dossier.
**Date:** 2026-06-26 · **Sources:** SRC-05 «IT — Верхнеуровневое описание интеграции ProWallet с Paybis», SRC-06/07 «GE — Интеграция с Paybis».

- **Doc role:** структурная карта интеграции PAYBIS × ProWallet — кормит adapter-scope (`CryptoLedgerPort`) + compliance-scope (`CryptoCompliancePort`) + webhook/env слои.
- **Status:** **PARTIAL** — ingested из operator **preview** (attachment previews; бинарники **НЕ на диске**, live-audit mark-legion: PDF отсутствуют). **Latin technical identifiers в preview надёжны**; окружающая Cyrillic-проза encoding-mangled → **literal-значения (endpoint paths, signature algorithm, field schemas, fee %) НЕ выдуманы**, помечены НЕИЗВЕСТНО до чистого PDF/extraction.

---

## [FACT-from-preview] integration surface (latin identifiers, надёжно читаемы)

- **[FACT-from-preview]** Flows: **BuyCrypto**, **SellCrypto**.
- **[FACT-from-preview]** Identifiers: **requestId**, **partnerOrderId**, **transactionId**.
- **[FACT-from-preview]** Entities: **Order**, **Refund**, **WidgetSettings** / widget **signed request**.
- **[FACT-from-preview]** Order lifecycle states (as seen): **pending, completed, cancelled, rejected, expired**.
- **[FACT-from-preview]** Events / payment lifecycle: **paymentInitiated, paymentCompleted, GetPaymentCreated, Completed, Refunded, cancelled**.
- **[FACT-from-preview]** Integration mechanics: **signed request (signature)**, **widget**, **webhook/callback to partner**.
- **[FACT-from-preview]** Environments: **sandbox** referenced.
- **[FACT-from-preview]** Compliance touchpoints: **Travel Rule**, **KYB compliance**, «Neuronext, Paybis — Paybis compliance» (compliance на стороне Paybis), **Privacy Policy banxe.com**.
- **[FACT-from-preview]** Contact/governance: **Alex Guts** (Paybis side, per preview).

---

## [INFERENCE] architecture fit (привязка к code-verified seam; НЕ выдавать за literal spec)

- **[INFERENCE]** **PaybisCryptoAdapter** реализует FROZEN **CryptoLedgerPort** (`get_balance`/`create_wallet_address`/`create_tx`/`get_fee_estimate`/`health`) — рядом с **MidazCryptoAdapter** (per seam-fit findings, `services/ledger/crypto_ledger_port.py`).
- **[INFERENCE]** **BuyCrypto/SellCrypto** + **Order/Refund** ↦ `create_tx` + status polling/webhook; **widget + signedRequest** подразумевает **HMAC-style signing** (алгоритм **НЕИЗВЕСТНО**).
- **[INFERENCE]** Travel Rule на Paybis (consistent с ADR-114); BANXE consumes TR-status. Compliance/KYB на стороне Paybis (consistent с ADR-108 processor-split).
- **[INFERENCE]** Webhook/callback → BANXE экспонирует **verified callback endpoint** + **idempotency** по `partnerOrderId`/`transactionId`.
- **[INFERENCE]** sandbox vs prod → **config-as-data env switch** + **fenced live transport** (no live в тестах).

---

## НЕИЗВЕСТНО (нужен чистый PDF / Paybis spec — НЕ выдумывать) + owner

| Открытый вопрос | Owner |
|---|---|
| Exact endpoint URLs / methods | **Paybis** |
| Auth scheme; signature algorithm + signed fields | **Paybis** |
| Mandatory request/response schemas per flow (BuyCrypto/SellCrypto/Order/Refund) | **Paybis** |
| Exact webhook event names, payload schema, signature verification method | **Paybis** |
| Retry / timeout / rate-limit / SLA | **Paybis** |
| Data residency | **Paybis / operator** |
| Exact fee / settlement % (SRC-04 дал 30-day remit + shortfall; integration fee specifics) | **operator / Paybis** |
| sandbox vs prod base-URLs / credential provisioning | **Paybis / operator (I-SEC)** |

---

## Register + dossier linkage

- **REGISTER flip:** SRC-05 **BLOCKED → PARTIAL** (preview ingested); SRC-06/07 **BLOCKED → PARTIAL** (structural only, literal spec pending) — см. `SRC-INTAKE-REGISTER.md`.
- **Linkage:** ADR-108 (processor-split, distribution), ADR-114 (TR on Paybis), ADR-138 (PAYBIS sole); SRC-01/SRC-04 (contractual §8/§9.3/General); seam-fit (`crypto_ledger_port.py`).
- **Feeds dossier:** Implementation map → provider-adapter scope (`CryptoLedgerPort`), webhook/event handling, env/config, compliance (TR/KYB) — **structural** уровень; literal API spec остаётся **НЕИЗВЕСТНО** до SRC-06 чистого spec.
- **Gating:** `CryptoLedgerPort` PaybisCryptoAdapter эпик может вести **structural design** (seam/mock), но **runtime live-integration GATED** до чистого API spec + ADR-114 go-live gate.

---

### Refs
SRC-05 «IT — ProWallet×Paybis», SRC-06/07 «GE — Интеграция с Paybis» (operator previews, binaries pending); ADR-108/114/138; SRC-01 (SRC-04 contractual); `services/ledger/crypto_ledger_port.py`; ADR-119/I-28. **Бинарные PDF не на диске — literal extraction отложена.**
