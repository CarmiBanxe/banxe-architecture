# C-FPS — UK Faster Payments Build-Spec (send/receive + account validation)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-24 · **Block:** C-fps · **Priority:** P1 · **Sprint:** 10
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` + `CarmiBanxe/banxe-payment-core` (ADR-115/116/117). This doc **specifies**; ships **no** runtime code and makes **no** cross-repo write.
**Promotes:** `docs/payment-rails-research.md` (IL-012, BaaS provider comparison) → actionable FPS build-spec.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119. Additive; mutates no prior artifact.

> C-fps integrates UK Faster Payments (send, receive, account validation / Confirmation of Payee)
> via a **PSP adapter** (Modulr primary / ClearBank fallback, per `payment-rails-research.md`).
> It **emits** payment events to **D-recon** (Leg C — payment rail balance) and **posts** settlement
> journal entries to **D-gl** (via `LedgerPort` / `GLService`). It does **not** reimplement the
> reconciliation engine, the general ledger, or KYC/AML screening.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/payment-rails-research.md` (IL-012) | BaaS provider comparison: ClearBank, Modulr, Banking Circle, Railsr — API capabilities, regulatory fit, Midaz integration path | **promote** — this build-spec consumes the research and specifies the concrete FPS integration; research retained as source |
| `docs/D-RECON-BUILD-SPEC.md` §2 Leg C | D-recon Leg C = payment rail balance (CAMT.053/CSV via StatementFetcher → `RailBalancePort`) | **keep / reference** — C-fps **feeds** Leg C; D-recon **owns** the recon engine; cross-ref, no duplication |
| `services/ledger/gl_service.py` (`GLService` / `LedgerPort`) in banxe-emi-stack | double-entry GL posting (IL-FIN-01) | **keep / reference** — C-fps **posts** settlement via `LedgerPort`; does NOT reimplement GL posting |
| ROADMAP C-fps row | UK FPS 0% P1 Sprint 10 | **update** — status → Spec-Locked / In Progress |
No existing `C-FPS-BUILD-SPEC` on main → new file non-duplicative.

## 1. Boundary (C-fps vs D-recon vs D-gl) — drift reconciled

| Concern | Owner | This spec |
|---|---|---|
| FPS **send/receive + account validation (CoP)** via PSP | **C-fps** | **builds** |
| Reconciliation engine (3-leg: ledger ↔ safeguarding ↔ **rails**) | **D-recon** (Leg C consumes rail data) | **emits to** (payment events / settlement statements) |
| General Ledger posting (double-entry, `LedgerPort`) | **D-gl** (`GLService`) | **posts to** (settlement journal entries) |
| AML/sanctions screening on payment counterparties | **F-aml** (Marble/Watchman) | **invokes** (pre-send screening gate) |
| KYC/KYB customer onboarding | **A-kyc/A-kyb** | out of scope (prerequisite, not reimplemented) |

C-fps is the **FPS rail integration layer**: PSP adapter, idempotent payment lifecycle, CoP, and event emission. It sits between the customer-facing payment API and the downstream engines (D-recon, D-gl, F-aml).

## 2. Scope — UK Faster Payments

### 2.1 Outbound send (GBP, domestic)
- Customer-initiated GBP payment via FPS (up to FPS scheme limit, currently £1M per transaction).
- Pre-send validation: sufficient balance (Midaz ledger query), F-aml screening gate (HITL for flagged), account validation (CoP — §2.3).
- PSP API call: `POST /payments` (Modulr) / equivalent ClearBank endpoint.
- **Idempotency:** every send carries a client-generated `idempotency_key` (UUID v4); the PSP adapter deduplicates; the domain model enforces exactly-once semantics.
- **Status lifecycle:** `CREATED → SUBMITTED → ACCEPTED → SETTLED | REJECTED | RETURNED`.
- On `SETTLED`: emit `payment.settled` event → D-recon (Leg C source) + post settlement journal entry → D-gl (`LedgerPort`: Dr Client Account / Cr Nostro/Suspense).

### 2.2 Inbound receive (GBP, domestic)
- PSP webhook: `payment.received` (Modulr) / `TransactionSettled` (ClearBank).
- Webhook signature verification (Modulr HMAC / ClearBank DigitalSignature + Nonce).
- Parse → `InboundPaymentDTO` → credit customer account via `LedgerPort` (Dr Nostro / Cr Client Account).
- Emit `payment.received` event → D-recon (Leg C).
- **Duplicate detection:** idempotent by PSP transaction reference; reprocessing a duplicate webhook is a no-op.

### 2.3 Confirmation of Payee (CoP) — account validation
- Pre-send: validate payee name against sort code + account number via CoP (Pay.UK scheme, proxied through PSP API).
- CoP result: `MATCH | PARTIAL_MATCH | NO_MATCH | UNAVAILABLE | OPT_OUT`.
- **On `NO_MATCH`:** block payment + return reason to customer (fraud prevention). Customer may override with explicit acknowledgement (regulatory requirement).
- **On `PARTIAL_MATCH`:** warn customer, allow with acknowledgement.
- **On `UNAVAILABLE` / `OPT_OUT`:** allow with warning (scheme rules — not all institutions support CoP).

### 2.4 Payment status lifecycle
```
CREATED ──→ SUBMITTED ──→ ACCEPTED ──→ SETTLED
                │              │
                ▼              ▼
            REJECTED       RETURNED
```
- Each transition is recorded as an immutable event (append-only, I-28).
- `RETURNED`: FPS scheme return (e.g., account closed, CoP failure post-settlement); triggers reverse journal entry via `LedgerPort`.
- **Timeout:** if no PSP response within configurable `FPS_SUBMIT_TIMEOUT_SEC` (default 30s) → mark `SUBMITTED` + poll/webhook for resolution. No silent failure.

## 3. PSP adapter model (PaymentRailPort)

### 3.1 Hexagonal port
```python
class PaymentRailPort(ABC):
    """Outbound FPS payment + CoP via PSP."""
    async def send_payment(self, request: FPSSendRequest) -> FPSPaymentResult: ...
    async def confirm_payee(self, request: CoPRequest) -> CoPResult: ...
    async def get_payment_status(self, psp_reference: str) -> FPSPaymentStatus: ...
```

### 3.2 Adapters
| Adapter | PSP | Notes |
|---|---|---|
| `ModulrFPSAdapter` | **Modulr** (primary) | REST API (`modulr.readme.io`); open sandbox; FPS direct participant (FRN 900699); sub-accounts via API; webhook `payment.completed`/`payment.failed` |
| `ClearBankFPSAdapter` | **ClearBank** (fallback) | REST API (`clearbank.github.io`); simulation env; BoE clearing bank; signed webhooks (DigitalSignature + Nonce) |
| `SandboxFPSAdapter` | In-memory | Test/dev; deterministic responses; no external calls |

### 3.3 PSP selection rationale (from `payment-rails-research.md`)
- **Modulr** selected as primary: same regulatory category as Banxe (FCA EMI), open sandbox, SME-friendly onboarding, direct FPS/RTGS participant, sub-accounts via API, public docs.
- **ClearBank** as fallback: BoE clearing bank, enterprise-grade, but higher onboarding threshold (enterprise focus, needs FCA-authorised firm status).
- **Banking Circle / Railsr** excluded per research (enterprise-only / FCA-restricted respectively).

## 4. Settlement & GL posting (referenced, not duplicated)

C-fps does **not** own the general ledger. It **posts** settlement events via the existing `LedgerPort` / `GLService` (IL-FIN-01, `services/ledger/gl_service.py` in banxe-emi-stack):

| Event | Journal entry (via LedgerPort) |
|---|---|
| `payment.settled` (outbound) | Dr Client Account / Cr Nostro (Modulr/ClearBank settlement account) |
| `payment.received` (inbound) | Dr Nostro / Cr Client Account |
| `payment.returned` (reversal) | Reverse of original entry |

- All amounts: **Decimal only** (I-01, no float).
- Currency: GBP (ISO 4217).
- `LedgerPort.post_journal_entry()` is the single seam — C-fps never writes directly to Midaz.

## 5. Reconciliation handoff (D-recon Leg C — referenced, not duplicated)

C-fps **feeds** D-recon Leg C (`RailBalancePort` / `StatementFetcher` per `D-RECON-BUILD-SPEC.md` §2):
- Settlement statements (CAMT.053 / CSV) from PSP → available for `StatementFetcher` polling.
- Real-time payment events (`payment.settled`, `payment.received`, `payment.returned`) emitted to the event bus for D-recon intraday matching.
- C-fps does **not** run reconciliation — D-recon owns the 3-leg tie-out engine.

## 6. Limits, settlement timing, and scheme rules

| Parameter | Value | Source |
|---|---|---|
| FPS single-transaction limit | £1,000,000 | Pay.UK scheme rules (as of 2026) |
| FPS settlement cycle | Near-real-time (typically < 2 hours, often seconds) | Pay.UK |
| Operating hours | 24/7/365 | Pay.UK |
| CoP scheme | Pay.UK CoP (mandatory for FPS/CHAPS since 2020) | PSR/Pay.UK |
| Idempotency window | 24 hours (PSP-specific; Modulr default) | PSP contract |
| Webhook retry | PSP retries with exponential backoff; C-fps idempotent on receive | PSP contract |

## 7. Security & compliance

- **F-aml screening gate:** every outbound payment counterparty screened against sanctions lists (F-aml / Watchman / OpenSanctions) before submission. Flagged → HITL escalation (I-27), payment blocked pending review.
- **Jurisdiction exclusion (I-02):** payments to/from blocked jurisdictions (RU, IR, KP, BY, SY) → hard reject, no override.
- **Webhook signature verification:** mandatory; reject unsigned/invalid webhooks (Modulr HMAC / ClearBank crypto signature).
- **PII handling:** customer names/sort codes/account numbers processed through PII Proxy (Presidio) where stored outside the payment lifecycle.
- **Audit trail:** every payment lifecycle event → append-only log (I-28, 5Y TTL per I-24).

## 8. DoD / acceptance criteria (for the banxe-emi-stack / banxe-payment-core PR)

- [ ] `test_fps_send_happy_path` (CREATED → SUBMITTED → ACCEPTED → SETTLED; GL posting via LedgerPort).
- [ ] `test_fps_send_idempotent` (duplicate `idempotency_key` → same result, no double-send).
- [ ] `test_fps_send_cop_no_match_blocks` (CoP NO_MATCH → payment blocked).
- [ ] `test_fps_send_cop_partial_match_warns` (CoP PARTIAL_MATCH → allow with acknowledgement).
- [ ] `test_fps_send_faml_screening_gate` (flagged counterparty → HITL escalation, payment blocked).
- [ ] `test_fps_send_jurisdiction_block` (blocked jurisdiction → hard reject I-02).
- [ ] `test_fps_receive_webhook_valid` (signed webhook → credit customer, GL posting, D-recon event).
- [ ] `test_fps_receive_webhook_invalid_signature` (reject unsigned webhook).
- [ ] `test_fps_receive_duplicate_webhook` (idempotent — no double credit).
- [ ] `test_fps_return_reversal` (RETURNED → reverse journal entry via LedgerPort).
- [ ] `test_fps_decimal_only` (no float anywhere in payment amounts — I-01).
- [ ] `test_fps_payment_audit_trail_immutable` (append-only lifecycle log — I-28, 5Y TTL).
- [ ] Coverage ≥ 90%, Ruff + Semgrep clean.

## 9. Out of scope (fail-closed)

No runtime code in this document; no cross-repo write to `banxe-emi-stack` or `banxe-payment-core`; **no GL/recon reimplementation** (D-gl / D-recon own those); no AML/KYC/KYB screening reimplementation (F-aml); no SEPA/SWIFT rails (C-sepa/C-swift); no card payments; no FX conversion; no Midaz production credentials; no autonomous live payment execution (operator-authorized runtime action); PROPOSED passports not activated.

## 10. Operator gates NOT crossed

- **Runtime implementation** in `banxe-emi-stack` / `banxe-payment-core` is a **separate operator-authorized action** — this spec documents the design; it does not ship code.
- **PSP contract/onboarding** (Modulr/ClearBank) — requires commercial agreement + FCA EMI authorisation; not a code concern.
- **Live payment execution** — sandbox/simulation only until operator authorizes production cutover.
- No DRAFT promotion; M2.8 Roster-C + web-next + Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 11. References

`docs/payment-rails-research.md` (IL-012, BaaS research — **promoted** into this spec);
`docs/D-RECON-BUILD-SPEC.md` (D-recon 3-leg engine, Leg C = rail);
`services/ledger/gl_service.py` + `LedgerPort` in banxe-emi-stack (D-gl posting, IL-FIN-01);
`docs/migration/MIG-ABS-posting-BLOCKER-gl-service-already-exists.md` (GL subsystem audit);
F-aml (Marble/Watchman — ADR-005, `aml-patterns-SPEC`);
ADR-013 (Midaz), ADR-090 (D-fee), ADR-102/103/115/116/117/119;
I-01 (Decimal only), I-02 (jurisdiction exclusion), I-04 (large-value flag), I-24 (5Y TTL), I-27 (HITL), I-28 (append-only);
Pay.UK FPS scheme rules; PSR CoP regulations; FCA EMI regulatory perimeter.
