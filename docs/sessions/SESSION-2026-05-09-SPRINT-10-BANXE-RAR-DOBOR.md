
---

## Classification block 4 — `banxe-digital/crypto-exchange-api`

**Files:** 665 (verified: `grep -c '^banxe-digital/crypto-exchange-api/' BANXE-RAR-LISTING-2026-05-06.txt`)
**Stack:** NestJS / TypeScript + GraphQL + TypeORM
**Top-level src modules:** account, address, auto-convert, balance, binance, binance-kyc, coins, config, crypto-api, dust-transfer, local-crypto-exchange, market, migrations, operation, order, rabbitmq-publisher, shared, trade, transaction, validations

### Per-module classification

| Module | Classification | EMI boundary | Rationale |
|---|---|---|---|
| `src/account` | **REWRITE-reference** | `services/ledger/crypto_ledger_port.py` + `services/ledger/production/midaz_crypto_adapter.py` | Crypto account semantics — cross-check vs FROZEN port |
| `src/balance` | **REWRITE-reference** | `services/ledger/crypto_ledger_port.py` (`get_balance`) | Balance projection — semantics only |
| `src/transaction` | **REWRITE-reference** | `services/ledger/crypto_ledger_port.py` (`create_tx`) + MidazCryptoAdapter | Crypto transaction domain — cross-check |
| `src/address` | **REWRITE-reference** | `services/ledger/crypto_ledger_port.py` (`create_wallet_address`) | Wallet address domain — semantics only |
| `src/crypto-api` | **REWRITE-reference** | `services/ledger/legacy/legacy_crypto_*` adapters (already exist) | Crypto API surface — already mirrored in EMI legacy adapters |
| `src/auto-convert` | **REJECT** | — | Exchange auto-convert — out of EMI scope (not an exchange) |
| `src/market` | **REJECT** | — | Market data / order book — out of EMI scope |
| `src/trade` | **REJECT** | — | Trading engine — out of EMI scope |
| `src/order` | **REJECT** | — | Exchange order book — out of EMI scope |
| `src/dust-transfer` | **REJECT** | — | Exchange micro-flow — out of EMI scope |
| `src/local-crypto-exchange` | **REJECT** | — | Exchange-specific — out of EMI scope |
| `src/binance`, `src/binance-kyc` | **REJECT** | — | Binance-specific integrations — Wave D KYC already closed; not an EMI integration target |
| `src/coins` | **REJECT** | — | Coin catalog — out of EMI core scope |
| `src/operation` | **REJECT** | — | Exchange operation aggregation — out of EMI scope |
| `src/config`, `src/migrations`, `src/rabbitmq-publisher`, `src/shared`, `src/validations` | **REJECT** | — | Generic infra — Python-native equivalents in EMI |

### Net decision

- **Overall:** REWRITE-reference (5 modules: account, balance, transaction, address, crypto-api) + REJECT (rest, mostly exchange-specific).
- **No code import** into EMI; only crypto-domain semantics cross-checked against FROZEN `CryptoLedgerPort` + `MidazCryptoAdapter` (Sprint 9).
- **No new EMI files** required from this fragment in Sprint 10. EMI is an EMI / payment institution, not a crypto exchange — exchange modules explicitly out of scope.

