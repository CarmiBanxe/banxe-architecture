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

## See also
- Sprint 3 набор: `sprint-3-product-evidence-pack-template.md` · `sprint-3-per-product-evidence-packs.md` · `sprint-3-permissions-map-per-product.md`
- Сводка/аудит: `sprint-1-4-status-summary.md` · `sprint-1-4-shell-audit.md` · Register: `../governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`

## Приложение A (Sprint 3 deepening): non-legal wiring per product

Формат: internal actors → human gates (references, не решения) → regulator touchpoints (labels) → status.

| Product | Internal actors (agents/rooms) | Human gates (refs) | External touchpoints (labels) | Status |
|---|---|---|---|---|
| Savings v1 | SavingsAgent · F1/customer-ops · LedgerAgent (F2/ledger) | H-017; Consumer Duty review; adj-гейты ledger | “requires FCA permission [counsel]” — deposit boundary | Pre-pilot only / permissions unresolved [counsel] |
| Insurance v1 | InsuranceAgent · F1/customer-ops · Marketing (промо COBS4→MLRO) | H-017; MLRO (regulated disclosures) | “distribution regime [counsel]”; partner licence [counsel] | Pre-pilot only / permissions unresolved [counsel] |
| Merchant v1 | MerchantAgent · F2/payments · kyb_agent (F2/identity) | H-017; KYB approve (actor/CO); H-016 (крупные settlement) | “acquiring permission / scheme [counsel]” | Pre-pilot only / permissions unresolved [counsel] |
| Card v1 | CardAgent · F2/payments · risk-контур (F3/risk: fraud on CARD_TRANSACTION) | actor-гейты freeze/issue; гейт issuance — после S1 Scope Note | “BIN sponsor / scheme [counsel]” | Pre-pilot only / permissions unresolved [counsel]; register #2 RED |

## KYB perimeter note
- KYB не оценивается изолированно там, где KYB-исход гейтит активацию merchant-acquiring (`approve_kyb(actor)` — вход эквайринг-цикла).
- Product-permissions review (строка Merchant выше) и KYB-периметр читаются ВМЕСТЕ — раздельные вердикты по ним не валидны для activation-решений.
- Лицензионный/правовой исход связки — [counsel]; операционная связка модулей — факт кода (S-A5 KYB-аудит).
