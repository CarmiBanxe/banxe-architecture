# ADR-015: Payment Processing Stack — Hyperswitch + Paymentology

**Status:** ACCEPTED (2026-04-13, approved by Moriel Carmi, CEO)
**Date:** 2026-04-12
**Deciders:** CEO (Moriel Carmi)
**Trust Zone:** AMBER
**Change Class:** CLASS_B
**Supersedes:** N/A
**Related:** ADR-013 (Midaz CBS), ADR-014 (Composable Financial Stack), ADR-011 (Reference vs Dependency)

## Context

TOMPAY UK EMI является Principal Member Mastercard. Текущий процессинг через Tribal — дорогой и vendor-locked. Необходимо заменить на open-source/composable стек, согласованный с ADR-014 (Composable Financial Stack) и использующий уже развёрнутый Midaz (ADR-013, порт 8095).

Ключевые требования:
- Mastercard acquiring/issuing через Principal Member статус TOMPAY
- Open-source payment switch (заменяемый — I-20)
- Card issuing через облачный issuer processor
- Интеграция с Midaz ledger для авторизации и settlement
- Compliance pre-screening (I-01, I-02, sanctions first)
- Append-only audit trail (I-24) через ClickHouse

## Decision

### Tier 5: Payment Switch

| Component | Role | License | Rationale |
|-----------|------|---------|-----------|
| **Hyperswitch (Juspay)** | Payment orchestration, routing, 3DS | Apache 2.0 | Open-source, Rust, 175M txn/day capacity, Mastercard native support, custom connector SDK |

### Tier 6: Issuer Processing

| Component | Role | License | Rationale |
|-----------|------|---------|-----------|
| **Paymentology** | Card issuing + transaction processing | Commercial (API) | Cloud-native, Companion API (balance stays in Midaz), Mastercard certified, simple XML/REST API |
| **CLOWD9** (FALLBACK) | Alternative issuer processor | Commercial (API) | Cloud-native, microservices, Visa+Mastercard certified, decentralized |

### Tier 7: Settlement

| Component | Role | License | Rationale |
|-----------|------|---------|-----------|
| **banxe-settlement** (custom) | Mastercard IPM/T112 parser + reconciliation | Proprietary (own) | Собственное ядро (I-20, I-12). Settlement = незаменяемое ядро |

### Classification (ADR-011 Reference vs Dependency):

- **Hyperswitch** = Operational dependency (заменяемое). Обёрнуто `PaymentSwitchPort` адаптером.
- **Paymentology/CLOWD9** = Operational dependency (заменяемое). Обёрнуто `IssuerPort` адаптером.
- **Settlement parser** = Ядро (незаменяемое). Собственный код.
- **Adapter layer** = Ядро (незаменяемое). `PaymentSwitchPort` + `IssuerPort` аналогично `LedgerPort` (ADR-014).

### Architecture (extends ADR-014 diagram):

```
┌─────────────────────────────────────────────────┐
│         banxe-platform (Web + Mobile)           │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│              API Gateway (Block M)              │
└──────┬───────────┬──────────────┬───────────────┘
       │           │              │
┌──────▼──┐ ┌─────▼────┐ ┌─────▼──────────┐
│Payment  │ │Compliance│ │ Safeguarding   │
│Switch   │ │  Stack   │ │  Engine (J)    │
│(NEW)    │ │   (F)    │ │ P0 DEADLINE    │
└────┬────┘ └─────┬────┘ └──────┬─────────┘
     │             │             │
┌────▼─────────────▼─────────────▼───────────┐
│            PaymentSwitchPort               │
│               IssuerPort                   │
│            LedgerPort (ADR-014)            │
└──────┬──────────┬───────────┬───────────────┘
       │          │           │
┌──────▼──┐ ┌────▼────┐ ┌───▼───────────┐
│Hyper-   │ │  Midaz  │ │ Paymentology  │
│switch   │ │(PRIMARY)│ │  (Companion   │
│         │ │  :8095  │ │    API)       │
└─────────┘ └────┬────┘ └───────────────┘
                 │
          ┌──────▼──────┐
          │  ClickHouse  │
          │ (audit, 5Y) │
          └─────────────┘
```

## Consequences

### Positive

1. Полный контроль: TOMPAY Principal Member + own payment switch + own ledger
2. Замена Tribal снижает costs на ~70% (no per-txn processing fee от Tribal)
3. Hyperswitch Apache 2.0 — нет лицензионных рисков (в отличие от Jube AGPLv3, I-15)
4. Paymentology Companion API — баланс остаётся в Midaz (BANXE контролирует авторизацию)
5. Adapter pattern (`PaymentSwitchPort`/`IssuerPort`) соответствует I-20 (независимые заменяемые контуры)

### Negative / Risks

1. Hyperswitch custom connector для Paymentology — build cost ~2-3 developer-weeks
2. Mastercard IPM settlement parser — собственная разработка, нет open-source аналога
3. Paymentology коммерческий — per-txn fee, но значительно ниже Tribal
4. Двойной период (dual-run) с Tribal на 2-4 недели при миграции

## Implementation Plan

| Sprint | Action |
|--------|--------|
| Sprint 9 | ADR-015 approval, `banxe-payment-core` repo scaffold, Hyperswitch Docker deploy |
| Sprint 10 | Paymentology Companion API integration, `PaymentSwitchPort` + `IssuerPort` adapters |
| Sprint 11 | Settlement parser, Midaz ↔ Hyperswitch ↔ Paymentology E2E flow |
| Sprint 12 | UAT, dual-run with Tribal, production cutover |
