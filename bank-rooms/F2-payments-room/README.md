# F2/payments-room

## Purpose / coverage
Все платёжные рельсы (FPS/SEPA/CHAPS/SWIFT/OB/PSD2), диспуты, bulk; dormant product rails (card/crypto/merchant).

## Key agents/services
`PaymentRouterAgent` (services/payment/), `card_agent`, `crypto_agent`, `merchant_agent`, `swift_agent`, `psd2_agent`, `dispute_agent`.

## Regulatory Status Notes
- Register areas: **#2 Cards/BIN (RED)** · **#3 Crypto/MiCA/Travel Rule (RED)** · **#4 New Products (AMBER)** · **#7 webhook/DORA (AMBER)**.
- Canonical source: `../../docs/governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`.
- Freeze: "Room status must not appear more GREEN than the worst register entry that affects it." · "No GREEN without evidence artefact linked in the register."

### Sprint 1 (Cards & Crypto)
Artefacts: `../../docs/sprints/sprint-1-card-functional-scope-note.md` · `sprint-1-casp-perimeter-memo.md` · `sprint-1-travel-rule-split-note.md` — DRAFT; после заполнения+отправки counsel #2/#3 могут двигаться RED→AMBER (NOT GREEN).

### Sprint 3 (New Products)
`../../docs/sprints/sprint-3-permissions-map-per-product.md` — акцент этой комнаты: licences/permissions и transaction-level controls.

### Sprint 4 (ICT/DORA/Webhooks)
`../../docs/sprints/sprint-4-webhook-event-lifecycle.md` — lifecycle платёжных событий; связка с Framework и proposed #9/#10.
