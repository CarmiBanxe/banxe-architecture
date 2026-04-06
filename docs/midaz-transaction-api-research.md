# Midaz v3.5.3 — Transaction API Research

**Source:** [LerianStudio/midaz](https://github.com/LerianStudio/midaz)
**Version:** v3.5.3 (released 2026-03-09)
**Researched:** 2026-04-06

---

## Table of Contents

1. [Transaction API Endpoints](#1-transaction-api-endpoints)
2. [Request Body Schema — Midaz DSL (JSON mode)](#2-request-body-schema--midaz-dsl-json-mode)
3. [TransactionRequest Structure](#3-transactionrequest-structure)
4. [TransactionResponse Structure](#4-transactionresponse-structure)
5. [Error Codes](#5-error-codes)
6. [Rate Limits](#6-rate-limits)
7. [Authentication Requirements](#7-authentication-requirements)
8. [DSL Examples](#8-dsl-examples)
9. [BANXE-Specific Request Example](#9-banxe-specific-request-example)
10. [Notes on the Gold DSL File Format](#10-notes-on-the-gold-dsl-file-format)

---

## 1. Transaction API Endpoints

The transaction service runs on **port 3001** (internal Docker) — exposed externally at `http://127.0.0.1:8095` in the Banxe local instance (internal Docker port 3002).

### Create Transaction Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/v1/organizations/{organization_id}/ledgers/{ledger_id}/transactions/json` | Create transaction via JSON (full source + distribute) |
| `POST` | `/v1/organizations/{organization_id}/ledgers/{ledger_id}/transactions/inflow` | Create inflow transaction (no source specified, uses `@external`) |
| `POST` | `/v1/organizations/{organization_id}/ledgers/{ledger_id}/transactions/outflow` | Create outflow transaction (no destination specified, uses `@external`) |
| `POST` | `/v1/organizations/{organization_id}/ledgers/{ledger_id}/transactions/annotation` | Create annotation transaction (records only, no balance impact, status = NOTED) |
| `POST` | `/v1/organizations/{organization_id}/ledgers/{ledger_id}/transactions/dsl` | Create transaction via DSL file upload (multipart/form-data) |

### Transaction Lifecycle Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/v1/organizations/{organization_id}/ledgers/{ledger_id}/transactions/{transaction_id}/commit` | Commit a PENDING transaction |
| `POST` | `/v1/organizations/{organization_id}/ledgers/{ledger_id}/transactions/{transaction_id}/cancel` | Cancel a PENDING transaction |
| `POST` | `/v1/organizations/{organization_id}/ledgers/{ledger_id}/transactions/{transaction_id}/revert` | Revert (reverse) a CREATED transaction |
| `PATCH` | `/v1/organizations/{organization_id}/ledgers/{ledger_id}/transactions/{transaction_id}` | Update transaction metadata/description |
| `GET`  | `/v1/organizations/{organization_id}/ledgers/{ledger_id}/transactions/{transaction_id}` | Get single transaction |
| `GET`  | `/v1/organizations/{organization_id}/ledgers/{ledger_id}/transactions` | List transactions (paginated) |

### For Banxe (substituting IDs)

```
POST http://127.0.0.1:8095/v1/organizations/019d6301-32d7-70a1-bc77-0a05379ee510/ledgers/019d632f-519e-7865-8a30-3c33991bba9c/transactions/json
```

---

## 2. Request Body Schema — Midaz DSL (JSON mode)

The primary endpoint for a bilateral transfer is `POST .../transactions/json` using the `CreateTransactionSwaggerModel`.

### Required Headers

| Header | Value | Required |
|--------|-------|----------|
| `Content-Type` | `application/json` | Yes |
| `Authorization` | `Bearer {token}` | Yes (when auth enabled) |
| `X-Request-Id` | any UUID string | No (optional request tracing) |
| `X-Idempotency` | any string key | No (idempotency via Redis/SHA256) |
| `X-TTL` | integer seconds | No (TTL for idempotency key) |

### Top-Level Fields

```json
{
  "chartOfAccountsGroupName": "string (max 256, optional)",
  "code":                     "string (max 100, optional)",
  "description":              "string (max 256, optional)",
  "pending":                  false,
  "transactionDate":          "RFC3339 datetime (optional, must not be future)",
  "metadata":                 { "key": "value" },
  "send":                     { ... }
}
```

### The `send` Object (REQUIRED)

```json
{
  "send": {
    "asset":  "GBP",
    "value":  "10000",
    "source": {
      "from": [ { ...FromEntry } ]
    },
    "distribute": {
      "to": [ { ...ToEntry } ]
    }
  }
}
```

### `from` Entry Schema (inside `source.from[]`)

```json
{
  "accountAlias":    "@alias-or-account-id",
  "amount": {
    "asset": "GBP",
    "value": "10000"
  },
  "chartOfAccounts": "string (optional, e.g. FUNDING_DEBIT)",
  "description":     "string (optional)",
  "metadata":        { "key": "value" }
}
```

### `to` Entry Schema (inside `distribute.to[]`)

```json
{
  "accountAlias":    "@alias-or-account-id",
  "amount": {
    "asset": "GBP",
    "value": "10000"
  },
  "chartOfAccounts": "string (optional, e.g. FUNDING_CREDIT)",
  "description":     "string (optional)",
  "metadata":        { "key": "value" }
}
```

### Amount Value Format

- `value` is a **string-encoded decimal** in the **smallest unit of the asset** (e.g. pence for GBP, cents for USD).
- Example: £100.00 GBP → `"value": "10000"` (pence).
- Decimal values are supported: `"50.00"`, `"1.234567890123456789"`.
- The value in `send.value` **must equal** the sum of all `from[].amount.value` **and** the sum of all `to[].amount.value`.
- Value must be **greater than zero**.

### Inflow Endpoint — `CreateTransactionInflowSwaggerModel`

Used when the source is implicit (external). No `source` block is required:

```json
{
  "send": {
    "asset": "GBP",
    "value": "10000",
    "distribute": {
      "to": [{ "accountAlias": "@client-account", "amount": { "asset": "GBP", "value": "10000" } }]
    }
  }
}
```

### Outflow Endpoint — `CreateTransactionOutflowSwaggerModel`

Used when the destination is implicit (external). No `distribute` block required:

```json
{
  "pending": false,
  "send": {
    "asset": "GBP",
    "value": "10000",
    "source": {
      "from": [{ "accountAlias": "@client-account", "amount": { "asset": "GBP", "value": "10000" } }]
    }
  }
}
```

---

## 3. TransactionRequest Structure

### Go Source Structs (from `pkg/transaction/transaction.go`)

```go
type Transaction struct {
    ChartOfAccountsGroupName string
    Description              string
    Code                     string
    Pending                  bool
    Metadata                 map[string]any
    Route                    string
    TransactionDate          *TransactionDate
    Send                     Send
}

type Send struct {
    Asset      string          // Asset code (e.g., "GBP")
    Value      decimal.Decimal // Total transaction amount
    Source     Source
    Distribute Distribute
}

type Source struct {
    Remaining string   // ":remaining" if using remaining balance
    From      []FromTo
}

type Distribute struct {
    Remaining string   // ":remaining" if distributing remaining
    To        []FromTo
}

type FromTo struct {
    AccountAlias    string          // Account alias (e.g., "@treasury")
    BalanceKey      string          // Internal balance key
    Amount          *Amount
    Share           *Share          // For percentage-based distribution
    Remaining       string          // ":remaining" for catch-all
    Rate            *Rate           // For FX transactions
    Description     string
    ChartOfAccounts string
    Metadata        map[string]any
    IsFrom          bool            // true = source, false = destination
    Route           string
}

type Amount struct {
    Asset           string
    Value           decimal.Decimal
    Operation       string          // ONHOLD, DEBIT, CREDIT
    TransactionType string          // PENDING, APPROVED, CREATED
}
```

### Field Constraints Summary

| Field | Required | Type | Constraints |
|-------|----------|------|-------------|
| `send` | Yes | object | Required for all `/json`, `/inflow`, `/outflow` |
| `send.asset` | Yes | string | ISO-4217 asset code (e.g., "GBP", "USD") |
| `send.value` | Yes | string | Decimal string > 0, in smallest unit |
| `send.source` | Yes (for `/json`) | object | Required for full transaction |
| `send.source.from` | Yes | array | At least 1 entry |
| `send.source.from[].accountAlias` | Yes | string | Account alias starting with `@` |
| `send.source.from[].amount.asset` | Yes | string | Must match `send.asset` |
| `send.source.from[].amount.value` | Yes | string | Must sum to `send.value` |
| `send.distribute` | Yes (for `/json`) | object | Required for full transaction |
| `send.distribute.to` | Yes | array | At least 1 entry |
| `send.distribute.to[].accountAlias` | Yes | string | Account alias starting with `@` |
| `send.distribute.to[].amount.asset` | Yes | string | Must match `send.asset` |
| `send.distribute.to[].amount.value` | Yes | string | Must sum to `send.value` |
| `code` | No | string | max 100 chars, alphanumeric uppercase |
| `description` | No | string | max 256 chars |
| `chartOfAccountsGroupName` | No | string | max 256 chars |
| `pending` | No | bool | default `false` |
| `transactionDate` | No | RFC3339 | Cannot be future-dated |
| `metadata` | No | object | Flat key-value (no nested objects) |

---

## 4. TransactionResponse Structure

### HTTP Status Codes on Success

| Endpoint | Success Code |
|----------|-------------|
| `/transactions/json` (non-pending) | `201 Created` |
| `/transactions/json` (pending=true) | `201 Created` (status=PENDING) |
| `/transactions/dsl` | `200 OK` |

### Transaction Response Object

```json
{
  "id":                        "uuid",
  "ledgerId":                  "uuid",
  "organizationId":            "uuid",
  "parentTransactionId":       "uuid or null",
  "amount":                    1000,
  "assetCode":                 "GBP",
  "description":               "string",
  "code":                      "string",
  "chartOfAccountsGroupName":  "string",
  "route":                     "string",
  "pending":                   false,
  "status": {
    "code":                    "CREATED",
    "description":             "string or null"
  },
  "source":       ["@account-alias-1"],
  "destination":  ["@account-alias-2"],
  "metadata":     {},
  "operations":   [ ...Operation ],
  "createdAt":    "RFC3339",
  "updatedAt":    "RFC3339",
  "deletedAt":    null
}
```

### Transaction Status Values

| Status | Meaning |
|--------|---------|
| `CREATED` | Immediately settled — balances updated |
| `PENDING` | On hold — awaiting `commit` or `cancel` |
| `NOTED` | Annotation only — no balance impact |
| `APPROVED` | Cached during async processing |
| `CANCELED` | Pending transaction was cancelled |

### Operation Object (nested in `operations[]`)

```json
{
  "id":              "uuid",
  "transactionId":   "uuid",
  "accountId":       "uuid",
  "accountAlias":    "@alias",
  "balanceId":       "uuid",
  "balanceKey":      "string",
  "type":            "DEBIT or CREDIT",
  "assetCode":       "GBP",
  "amount": {
    "value":         1000
  },
  "balance": {
    "available":     decimal,
    "onHold":        decimal,
    "scale":         2
  },
  "balanceAfter": {
    "available":     decimal,
    "onHold":        decimal,
    "scale":         2
  },
  "chartOfAccounts": "string",
  "description":     "string",
  "metadata":        {},
  "status": {
    "code":          "CREATED",
    "description":   null
  },
  "balanceAffected": true,
  "createdAt":       "RFC3339",
  "updatedAt":       "RFC3339",
  "deletedAt":       null
}
```

---

## 5. Error Codes

### HTTP Status → Meaning

| HTTP Code | Meaning |
|-----------|---------|
| `201` | Transaction created successfully |
| `200` | Transaction created (DSL endpoint) |
| `400` | Bad request — invalid input or validation error |
| `401` | Unauthorized — missing or invalid token |
| `403` | Forbidden — insufficient privileges |
| `404` | Resource not found |
| `409` | Conflict — idempotency key already used |
| `422` | Unprocessable entity — business rule violation |
| `500` | Internal server error |

### Transaction-Specific Error Codes

| Error Code | HTTP | Description |
|------------|------|-------------|
| `ErrInsufficientFunds` | 422 | Source account lacks sufficient available balance |
| `ErrInsufficientAccountBalance` | 422 | Account lacks required funds |
| `ErrAccountIneligibility` | 422 | Balances array length mismatch (from+to accounts vs balances count) |
| `ErrTransactionValueMismatch` | 422 | `source.from[]` sum ≠ `distribute.to[]` sum ≠ `send.value` |
| `ErrTransactionAmbiguous` | 422 | Same account used as both source and destination |
| `ErrAccountStatusTransactionRestriction` | 422 | Source account has `AllowSending=false` or destination has `AllowReceiving=false` |
| `ErrTransactionTimingRestriction` | 422 | `transactionDate` is in the future |
| `ErrTransactionMethodRestriction` | 422 | Transaction type forbidden for specified account |
| `ErrOnHoldExternalAccount` | 422 | External account as source in a pending transaction |
| `ErrInvalidTransactionType` | 422 | Multiple distribution types used (only one of amount/share/remaining allowed) |
| `ErrAssetCodeNotFound` | 404 | Asset code not found or balance asset mismatch |
| `ErrAccountAliasNotFound` | 404 | Account alias not in records |
| `ErrAccountAliasInvalid` | 400 | Alias contains unsupported characters |
| `ErrTransactionIDNotFound` | 404 | Transaction ID not found |
| `ErrNoTransactionsFound` | 404 | List query returned no results |
| `ErrParentTransactionIDNotFound` | 404 | Referenced parent transaction does not exist |
| `ErrIdempotencyKey` | 409 | Idempotency key already used |
| `ErrLockVersionAccountBalance` | 409 | Race condition on balance update (retry) |
| `ErrInvalidCodeFormat` | 400 | Code must be alphanumeric uppercase |
| `ErrInvalidMetadataNesting` | 400 | Metadata values cannot be nested objects |
| `ErrInvalidDateFormat` | 400 | Date must be `yyyy-mm-dd` or RFC3339 |
| `ErrTokenMissing` | 401 | No `Authorization` header |
| `ErrInvalidToken` | 401 | Token expired, invalid, or malformed |
| `ErrInsufficientPrivileges` | 403 | User lacks required operation permissions |

### Error Response Body

```json
{
  "title":      "Insufficient Funds Error",
  "code":       "ErrInsufficientFunds",
  "message":    "Detailed description of what went wrong",
  "entityType": "Transaction",
  "fields": {
    "fieldName": "validation message"
  }
}
```

---

## 6. Rate Limits

**Not explicitly documented** in the codebase or OpenAPI spec.

What is documented in `.env.example`:
- `MAX_PAGINATION_LIMIT=100` — Maximum items per page for list endpoints
- `MAX_PAGINATION_MONTH_DATE_RANGE=1` — Maximum 1-month range for date filters

No per-request or per-second rate limiting middleware was found in the transaction service source code. Redis is used for **idempotency key caching** but not rate limiting.

**[НЕИЗВЕСТНО]** — Explicit rate limits (requests/second, requests/minute) are not documented. A reverse proxy (nginx, Caddy) or API gateway in front of Midaz may impose limits at the infrastructure level.

---

## 7. Authentication Requirements

Authentication is controlled by the `PLUGIN_AUTH_ENABLED` environment variable.

- **Default in `.env.example`:** `PLUGIN_AUTH_ENABLED=false` (auth disabled for local/dev)
- **When enabled:** All endpoints require `Authorization: Bearer {token}` header
- **Token format:** JWT Bearer token
- **Authorization model:** Resource-based (`midaz` resource with actions: `post`, `patch`, `get`)

For the Banxe local instance at `http://127.0.0.1:8095`:
- **[НЕИЗВЕСТНО]** — Whether auth is currently enabled or disabled. Check the running container's env or the `docker-compose.yml` for the override.
- If auth is disabled: the `Authorization` header can be omitted or sent as an empty/dummy value.
- If auth is enabled: a valid token must be obtained from the configured auth host (`PLUGIN_AUTH_HOST`).

---

## 8. DSL Examples

### 8.1 JSON API Examples (for `/transactions/json`)

**Simple bilateral transfer (non-pending):**

```json
POST /v1/organizations/{org_id}/ledgers/{ledger_id}/transactions/json
Content-Type: application/json
Authorization: Bearer {token}

{
  "description": "Transfer from operational to client funds",
  "pending": false,
  "metadata": {
    "reference": "TXN-001",
    "type": "safeguarding_transfer"
  },
  "send": {
    "asset": "GBP",
    "value": "10000",
    "source": {
      "from": [
        {
          "accountAlias": "@operational-account",
          "amount": {
            "asset": "GBP",
            "value": "10000"
          },
          "chartOfAccounts": "FUNDING_DEBIT",
          "description": "Debit operational account"
        }
      ]
    },
    "distribute": {
      "to": [
        {
          "accountAlias": "@client-funds-account",
          "amount": {
            "asset": "GBP",
            "value": "10000"
          },
          "chartOfAccounts": "FUNDING_CREDIT",
          "description": "Credit client funds account"
        }
      ]
    }
  }
}
```

**Multi-leg distribution (1 source → 2 destinations):**

```json
{
  "send": {
    "asset": "GBP",
    "value": "10000",
    "source": {
      "from": [
        { "accountAlias": "@source", "amount": { "asset": "GBP", "value": "10000" } }
      ]
    },
    "distribute": {
      "to": [
        { "accountAlias": "@dest-a", "amount": { "asset": "GBP", "value": "7000" } },
        { "accountAlias": "@dest-b", "amount": { "asset": "GBP", "value": "3000" } }
      ]
    }
  }
}
```

**Pending transaction (commit separately):**

```json
{
  "description": "Pending safeguarding transfer",
  "pending": true,
  "send": {
    "asset": "GBP",
    "value": "5000",
    "source": {
      "from": [{ "accountAlias": "@source", "amount": { "asset": "GBP", "value": "5000" } }]
    },
    "distribute": {
      "to": [{ "accountAlias": "@destination", "amount": { "asset": "GBP", "value": "5000" } }]
    }
  }
}
```

### 8.2 Gold DSL File Format (for `/transactions/dsl`)

The Gold DSL uses a Lisp-like parenthesized syntax. The file is uploaded as multipart form-data with field name `transaction`.

**Amount notation:** `value|scale` where:
- `value` = integer in smallest unit
- `scale` = number of decimal places
- Example: `3|0` = 3.0 (no decimal places), `100|2` = 1.00, `10000|2` = 100.00

**Simple transfer (DSL):**

```lisp
(transaction V1
  (chart-of-accounts-group-name FUNDING)
  (send GBP 10000|2
    (source
      (from @operational-account :amount GBP 10000|2))
    (distribute
      (to @client-funds-account :amount GBP 10000|2))))
```

**Pending transaction with metadata (DSL):**

```lisp
(transaction V1
  (chart-of-accounts-group-name FUNDING)
  (description "Safeguarding transfer")
  (code TXN-2026-001)
  (pending true)
  (send GBP 10000|2
    (source
      (from @operational-account :amount GBP 10000|2
        (description "Debit operational")
        (chart-of-accounts FUNDING_DEBIT)))
    (distribute
      (to @client-funds-account :amount GBP 10000|2
        (description "Credit client funds")
        (chart-of-accounts FUNDING_CREDIT)))))
```

**Multi-leg with remaining balance (DSL):**

```lisp
(transaction V1
  (chart-of-accounts-group-name FUNDING)
  (send GBP 10000|2
    (source
      (from @source-a :amount GBP 5000|2)
      (from @source-b :amount GBP 5000|2))
    (distribute
      (to @destination :remaining)))
```

---

## 9. BANXE-Specific Request Example

Using the provided Banxe IDs:

- **Org ID:** `019d6301-32d7-70a1-bc77-0a05379ee510` (BANXE LTD)
- **Ledger ID:** `019d632f-519e-7865-8a30-3c33991bba9c` (Safeguarding Ledger)
- **Source account** (operational, asset): `019d6332-f274-709a-b3a7-983bc8745886`
- **Destination account** (client_funds, liability): `019d6332-da7f-752f-b9fd-fa1c6fc777ec`
- **Asset:** `GBP`

**Note on account references:** Midaz accepts account aliases (`@alias`) or account UUIDs directly. If the accounts have aliases configured, use the alias. If not, use the UUID directly (the `UUID` token in the grammar accepts UUIDs).

```bash
curl -X POST \
  "http://127.0.0.1:8095/v1/organizations/019d6301-32d7-70a1-bc77-0a05379ee510/ledgers/019d632f-519e-7865-8a30-3c33991bba9c/transactions/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "description": "Safeguarding: operational to client funds",
    "pending": false,
    "metadata": {
      "initiated_by": "banxe-api",
      "ledger_event": "safeguarding_transfer"
    },
    "send": {
      "asset": "GBP",
      "value": "10000",
      "source": {
        "from": [
          {
            "accountAlias": "019d6332-f274-709a-b3a7-983bc8745886",
            "amount": {
              "asset": "GBP",
              "value": "10000"
            },
            "description": "Debit operational account"
          }
        ]
      },
      "distribute": {
        "to": [
          {
            "accountAlias": "019d6332-da7f-752f-b9fd-fa1c6fc777ec",
            "amount": {
              "asset": "GBP",
              "value": "10000"
            },
            "description": "Credit client funds (safeguarding)"
          }
        ]
      }
    }
  }'
```

**[ВАЖНО]** The value `"10000"` = £100.00 (in pence). Adjust accordingly:
- £1.00 → `"100"`
- £100.00 → `"10000"`
- £1,000.00 → `"100000"`

**[НЕИЗВЕСТНО]** Whether the accounts above use UUID-as-alias or have a dedicated `@alias` string. Verify by calling `GET /v1/organizations/{org_id}/ledgers/{ledger_id}/accounts/{account_id}` and checking the `alias` field. If an alias exists, prefer it over the UUID.

---

## 10. Notes on the Gold DSL File Format

The DSL grammar (`pkg/gold/Transaction.g4`) is an ANTLR4 grammar. Key rules:

| DSL Token | Description |
|-----------|-------------|
| `V1` | Required version marker |
| `(chart-of-accounts-group-name NAME)` | Required grouping |
| `(description "text")` | Optional description |
| `(code UUID)` | Optional reference code |
| `(pending true\|false)` | Optional, defaults to false |
| `(metadata (key value)+)` | Optional flat key-value pairs |
| `(send ASSET value\|scale ...)` | Required send block |
| `(source ...)` | Required source block |
| `(distribute ...)` | Required distribute block |
| `(from ACCOUNT :amount ASSET value\|scale)` | Source entry |
| `(to ACCOUNT :amount ASSET value\|scale)` | Destination entry |
| `:remaining` | Use remaining balance (catch-all) |
| `:share N :of M` | Percentage-based distribution |
| `@alias` | Account alias reference |
| `$variable` | Variable reference (for templates) |

The DSL file endpoint returns `200 OK` (not `201 Created`) on success.

---

## Sources

- [LerianStudio/midaz — GitHub Repository](https://github.com/LerianStudio/midaz)
- [Transaction OpenAPI Spec — transaction_swagger.yaml](https://raw.githubusercontent.com/LerianStudio/midaz/main/components/transaction/api/transaction_swagger.yaml)
- [Transaction OpenAPI Spec — openapi.yaml](https://raw.githubusercontent.com/LerianStudio/midaz/main/components/transaction/api/openapi.yaml)
- [Gold DSL Grammar — Transaction.g4](https://raw.githubusercontent.com/LerianStudio/midaz/main/pkg/gold/Transaction.g4)
- [Transaction Domain Model — pkg/transaction/transaction.go](https://raw.githubusercontent.com/LerianStudio/midaz/main/pkg/transaction/transaction.go)
- [HTTP Routes — components/transaction/internal/adapters/http/in/routes.go](https://raw.githubusercontent.com/LerianStudio/midaz/main/components/transaction/internal/adapters/http/in/routes.go)
- [Transaction Handler — components/transaction/internal/adapters/http/in/transaction.go](https://raw.githubusercontent.com/LerianStudio/midaz/main/components/transaction/internal/adapters/http/in/transaction.go)
- [Error Codes — pkg/errors.go](https://raw.githubusercontent.com/LerianStudio/midaz/main/pkg/errors.go)
- [Transaction Validations — pkg/transaction/validations.go](https://raw.githubusercontent.com/LerianStudio/midaz/main/pkg/transaction/validations.go)
- [Integration Tests — components/transaction/internal/adapters/http/in/transaction_integration_test.go](https://raw.githubusercontent.com/LerianStudio/midaz/main/components/transaction/internal/adapters/http/in/transaction_integration_test.go)
- [DSL Parity Tests — pkg/gold/transaction/parity_test.go](https://raw.githubusercontent.com/LerianStudio/midaz/main/pkg/gold/transaction/parity_test.go)
- [Postman Workflow — postman/WORKFLOW.md](https://github.com/LerianStudio/midaz/blob/main/postman/WORKFLOW.md)
- [Environment Config — components/transaction/.env.example](https://raw.githubusercontent.com/LerianStudio/midaz/main/components/transaction/.env.example)
