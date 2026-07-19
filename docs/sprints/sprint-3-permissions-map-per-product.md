# Permissions Map per Product — Sprint 3

Status: DRAFT / NOT FOR MERGE

## Purpose
Отобразить каждую продуктовую фичу на конкретную лицензию/permission/режим; audit trail «regulation → internal control → product feature». Достаточность лицензий НЕ утверждается — определяет counsel.

## Scope
Licensing inventory (Licence · Authority · Scope summary · Products relying): EMI permission [FCA] · CASP/crypto regime [?] · insurance distribution [?] · other.
Per-product mapping (Product · Feature · Licence relied on · Control/gate · Evidence doc):
- Savings v1 · storing value/interest-like — [EMI vs deposit boundary — UNCLEAR, FLAG] · [balance limits, safeguarding ring-fence] · [ADR/policy: ___]
- Insurance v1 · underwriting cover — [partner/distribution licence] · [partner agreement, disclosure controls] · [contract/KFS: ___]
- Merchant v1 · payment initiation/acquiring — [payments licence/scheme] · [merchant KYC (`kyb_agent`), tx monitoring] · [scheme docs: ___]
Gap flags: каждый «licence unknown/unclear» → строка в register #4 action-items.

## Register linkage
- Area **#4** — GREEN только когда ВСЕ активные продукты полностью замаплены с controls+evidence.

## Room linkage
- `bank-rooms/F2-payments-room/README.md`, `bank-rooms/F1-customer-ops-room/README.md`.

## Open questions / counsel placeholders
- Savings: e-money vs deposit-taking граница. Insurance: применимый режим дистрибуции. Merchant: acquiring-периметр и scheme-требования.
