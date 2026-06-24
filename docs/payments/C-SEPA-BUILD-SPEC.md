# C-SEPA — SEPA Credit Transfer + SEPA Instant Build-Spec (EU corridor)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-24 · **Block:** C-sepa · **Priority:** P1 · **Sprint:** 11
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` + `CarmiBanxe/banxe-payment-core` (ADR-115/116/117). This doc **specifies**; ships **no** runtime code and makes **no** cross-repo write.
**Sibling:** `docs/payments/C-FPS-BUILD-SPEC.md` (IL-494) — C-fps is the UK-domestic sibling; C-sepa is the EU-corridor sibling. Both share the `PaymentRailPort` abstraction (§3).
**Promotes:** `docs/payment-rails-research.md` (IL-012, BaaS provider SEPA coverage) + `docs/migration/MIG-M1.5-sepa-split.md` (legacy sepa-service decomposition).
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119. Additive; mutates no prior artifact.

> C-sepa integrates **SEPA Credit Transfer (SCT)** and **SEPA Instant (SCT Inst)** for EUR payments
> via a **PSP adapter** (Modulr primary — EU IBANs NL/ES/FR/IE + SCT Inst since 2024; ClearBank
> fallback — SEPA-direct participant, per `payment-rails-research.md`). It **shares** the
> `PaymentRailPort` abstraction with C-fps (referenced, not duplicated), **emits** payment events to
> **D-recon** (Leg C), and **posts** settlement journal entries to **D-gl** (via `LedgerPort`).
> It does **not** reimplement the reconciliation engine, the general ledger, or KYC/AML screening.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/payments/C-FPS-BUILD-SPEC.md` (IL-494) | UK FPS sibling — defines `PaymentRailPort` abstraction, PSP adapter model, settlement/GL posting pattern, D-recon Leg C handoff | **keep / reference** — C-sepa is the EU-corridor sibling; shares the port abstraction; does NOT duplicate C-fps scope (GBP/FPS/CoP) |
| `docs/payment-rails-research.md` (IL-012) | BaaS provider comparison — SEPA CT/Instant coverage per provider | **promote** — this build-spec consumes the SEPA-specific research findings; research retained as source |
| `docs/migration/MIG-M1.5-sepa-split.md` | Legacy sepa-service decomposition (Papaya BaaS, NestJS, webhook-driven) — target split: clean SEPA core → `banxe-payment-core` | **keep / reference** — migration advisory informs the adapter model; not duplicated |
| `docs/D-RECON-BUILD-SPEC.md` §2 Leg C | D-recon Leg C = payment rail balance (CAMT.053/CSV via `RailBalancePort`) | **keep / reference** — C-sepa **feeds** Leg C; D-recon **owns** the recon engine |
| `services/ledger/gl_service.py` (`GLService` / `LedgerPort`) in banxe-emi-stack | double-entry GL posting (IL-FIN-01) | **keep / reference** — C-sepa **posts** settlement via `LedgerPort`; does NOT reimplement GL posting |
| ROADMAP C-sepa row | SEPA CT + Instant 0% P1 Sprint 11 | **update** — status → Spec-Locked / In Progress |
No existing `C-SEPA-BUILD-SPEC` on main → new file non-duplicative.

## 1. Boundary (C-sepa vs C-fps vs D-recon vs D-gl) — drift reconciled

| Concern | Owner | This spec |
|---|---|---|
| SEPA **SCT/SCT Inst send/receive + IBAN/BIC validation** via PSP | **C-sepa** | **builds** |
| FPS send/receive + CoP (UK domestic, GBP) | **C-fps** (sibling) | out of scope — shared `PaymentRailPort`, separate adapter |
| Reconciliation engine (3-leg: ledger ↔ safeguarding ↔ **rails**) | **D-recon** (Leg C consumes rail data) | **emits to** (SEPA payment events / settlement statements) |
| General Ledger posting (double-entry, `LedgerPort`) | **D-gl** (`GLService`) | **posts to** (EUR settlement journal entries) |
| AML/sanctions screening on SEPA counterparties | **F-aml** (Marble/Watchman) | **invokes** (pre-send screening gate) |
| Legacy SEPA service decomposition | **MIG-M1.5** (advisory) | **informed by** (adapter model mirrors legacy Papaya rail seams) |

C-sepa is the **EU-corridor rail integration layer**: SEPA PSP adapter (SCT + SCT Inst), ISO 20022 messaging, idempotent payment lifecycle, IBAN/BIC validation, and event emission. It shares the `PaymentRailPort` abstraction with C-fps but implements EU-specific adapters, message formats, and scheme rules.

## 2. Scope — SEPA Credit Transfer + SEPA Instant

### 2.1 Outbound SCT send (EUR)
- Customer-initiated EUR payment via SEPA Credit Transfer.
- Pre-send validation: sufficient EUR balance (Midaz ledger query), F-aml screening gate (HITL for flagged), IBAN/BIC validation (§2.3).
- ISO 20022 message: `pain.001.001.09` (CustomerCreditTransferInitiation) → PSP API.
- PSP API call: Modulr SEPA endpoint / ClearBank SEPA CT endpoint.
- **Idempotency:** every send carries a client-generated `idempotency_key` (UUID v4); PSP adapter deduplicates; domain model enforces exactly-once.
- **Status lifecycle:** `CREATED → SUBMITTED → ACCEPTED → SETTLED | REJECTED | RETURNED`.
- On `SETTLED`: emit `sepa.payment.settled` event → D-recon (Leg C) + post settlement journal entry → D-gl (`LedgerPort`: Dr Client Account / Cr EUR Nostro).
- **Settlement timing:** SCT = D+1 (next business day per EPC scheme rules); batch cut-off times apply.

### 2.2 Outbound SCT Inst send (EUR, real-time)
- Customer-initiated EUR instant payment via SEPA Instant Credit Transfer (SCT Inst).
- Same pre-send validation as SCT (§2.1).
- ISO 20022 message: `pain.001` with SCT Inst service level (`SEPA` + `INST`).
- **Timing constraint:** end-to-end < 10 seconds (EPC RT1 scheme rules); PSP must respond within timeout.
- **Amount limit:** €100,000 per transaction (EPC scheme limit, effective 2025; may increase — config-as-data).
- **Availability:** 24/7/365 (unlike SCT which follows business-day cycles).
- **Fallback:** if SCT Inst rejected due to beneficiary bank non-reachability → offer SCT fallback to customer (explicit choice, not silent downgrade).
- On `SETTLED`: same event/GL pattern as SCT (§2.1).

### 2.3 IBAN/BIC validation
- Pre-send: validate beneficiary IBAN structure (ISO 13616, country-specific length + check digits) and BIC (ISO 9362).
- IBAN validation: structural check (length, mod-97 check digit) + optional PSP-level reachability check.
- BIC lookup: resolve BIC from IBAN where possible (national IBAN-to-BIC directories); confirm beneficiary bank participates in SEPA scheme.
- **SCT Inst reachability:** verify beneficiary bank participates in RT1/TIPS before attempting instant payment; if not reachable → offer SCT fallback (§2.2).

### 2.4 Inbound SEPA receive (EUR)
- PSP webhook: `sepa.payment.received` (Modulr) / equivalent ClearBank SEPA inbound notification.
- Webhook signature verification (PSP-specific: Modulr HMAC / ClearBank crypto signature).
- ISO 20022 inbound: `pacs.008.001.08` (FIToFICustomerCreditTransfer) parsed from PSP notification.
- Parse → `InboundSEPAPaymentDTO` → credit customer EUR account via `LedgerPort` (Dr EUR Nostro / Cr Client EUR Account).
- Emit `sepa.payment.received` event → D-recon (Leg C).
- **Duplicate detection:** idempotent by PSP transaction reference / SEPA EndToEndId; reprocessing a duplicate webhook is a no-op.

### 2.5 Payment status lifecycle
```
CREATED ──→ SUBMITTED ──→ ACCEPTED ──→ SETTLED
                │              │
                ▼              ▼
            REJECTED       RETURNED
```
- Identical state machine to C-fps (shared `PaymentRailPort` contract); each transition recorded as immutable event (I-28).
- `RETURNED`: SEPA return (R-transaction) — e.g., account closed, incorrect IBAN, AML block by beneficiary bank; triggers reverse journal entry via `LedgerPort`.
- `REJECTED`: PSP-level rejection (insufficient funds at nostro, scheme validation failure, non-reachable bank for SCT Inst).
- **SEPA Reason Codes:** map EPC reason codes (AC01–AM05, etc.) to human-readable status for customer + audit trail.
- **Timeout:** SCT = D+1 business day settlement window; SCT Inst = 10s hard timeout → `REJECTED` if no response. Configurable via `SEPA_INST_TIMEOUT_SEC` (default 10).

### 2.6 SEPA returns and R-transactions
- **Return:** beneficiary bank returns funds (within 3 business days for SCT, 10 business days for SCT from non-EEA).
- **Recall:** originator requests return of an erroneous payment (SEPA Recall, camt.056); requires beneficiary bank cooperation — not guaranteed.
- **Refund:** customer-initiated refund for Direct Debit (not in C-sepa scope — C-sepa covers Credit Transfer only).
- All R-transactions recorded as immutable events; reverse GL entries posted via `LedgerPort`.

## 3. PSP adapter model (shared PaymentRailPort)

### 3.1 Shared hexagonal port (defined in C-fps, extended for SEPA)
The `PaymentRailPort` abstraction is **defined once** (C-fps §3.1) and **implemented per rail**. C-sepa adapters implement the same port interface with SEPA-specific request/response types:

```python
class SEPARailPort(PaymentRailPort):
    """SEPA SCT/SCT Inst via PSP — extends shared PaymentRailPort."""
    async def send_payment(self, request: SEPASendRequest) -> SEPAPaymentResult: ...
    async def validate_iban(self, iban: str) -> IBANValidationResult: ...
    async def check_inst_reachability(self, bic: str) -> ReachabilityResult: ...
    async def get_payment_status(self, psp_reference: str) -> SEPAPaymentStatus: ...
```

### 3.2 Adapters
| Adapter | PSP | Notes |
|---|---|---|
| `ModulrSEPAAdapter` | **Modulr** (primary) | EU IBANs (NL, ES, FR, IE); SCT + SCT Inst (since 2024); REST API; webhook management; DNB-regulated (Netherlands) |
| `ClearBankSEPAAdapter` | **ClearBank** (fallback) | SEPA-direct participant; ISO 20022; simulation environment; signed webhooks |
| `SandboxSEPAAdapter` | In-memory | Test/dev; deterministic responses; no external calls |

### 3.3 PSP selection rationale (from `payment-rails-research.md`)
- **Modulr** primary: FCA EMI (same category as Banxe) + DNB (Netherlands); EU IBANs in 4 countries; SCT Inst launched 2024; open sandbox; SME-friendly.
- **ClearBank** fallback: SEPA-direct participant via ISO 20022; enterprise-grade; higher onboarding threshold.
- **Banking Circle** excluded: enterprise-only, no open sandbox, Luxembourg-regulated (not FCA-aligned).

### 3.4 ISO 20022 message mapping
| Direction | ISO 20022 Message | Usage |
|---|---|---|
| Outbound initiation | `pain.001.001.09` | CustomerCreditTransferInitiation (SCT + SCT Inst) |
| Interbank (reference) | `pacs.008.001.08` | FIToFICustomerCreditTransfer (inbound parse) |
| Status report | `pacs.002.001.10` | PaymentStatusReport (acceptance/rejection) |
| Return | `camt.056.001.08` | FIToFIPaymentCancellationRequest (recall) |

PSP abstracts raw ISO 20022 XML; C-sepa adapter maps PSP REST responses to domain DTOs. Direct XML handling is PSP-internal — C-sepa consumes structured PSP API responses.

## 4. Settlement & GL posting (referenced, not duplicated)

C-sepa does **not** own the general ledger. It **posts** settlement events via the existing `LedgerPort` / `GLService` — same pattern as C-fps §4:

| Event | Journal entry (via LedgerPort) |
|---|---|
| `sepa.payment.settled` (outbound SCT/SCT Inst) | Dr Client EUR Account / Cr EUR Nostro (Modulr/ClearBank settlement account) |
| `sepa.payment.received` (inbound) | Dr EUR Nostro / Cr Client EUR Account |
| `sepa.payment.returned` (R-transaction) | Reverse of original entry |

- All amounts: **Decimal only** (I-01, no float).
- Currency: EUR (ISO 4217).
- `LedgerPort.post_journal_entry()` is the single seam — C-sepa never writes directly to Midaz.

## 5. Reconciliation handoff (D-recon Leg C — referenced, not duplicated)

C-sepa **feeds** D-recon Leg C — same pattern as C-fps §5:
- Settlement statements (CAMT.053 / CSV) from PSP → available for `StatementFetcher` polling.
- Real-time SEPA payment events emitted to the event bus for D-recon intraday matching.
- C-sepa does **not** run reconciliation — D-recon owns the 3-leg tie-out engine.

## 6. Limits, settlement timing, and scheme rules

| Parameter | Value | Source |
|---|---|---|
| SCT single-transaction limit | No scheme-enforced limit (PSP/bank limits apply; typically €999,999,999.99) | EPC Rulebook |
| SCT Inst single-transaction limit | €100,000 (effective Oct 2025; subject to increase) | EPC RT1 Rulebook |
| SCT settlement cycle | D+1 (next business day, TARGET2 calendar) | EPC SCT Rulebook |
| SCT Inst settlement | < 10 seconds end-to-end, 24/7/365 | EPC RT1 / TIPS |
| SCT operating hours | TARGET2 business days (Mon–Fri, excluding TARGET holidays) | ECB |
| SCT Inst operating hours | 24/7/365 | EPC RT1 |
| SEPA return window | 3 business days (SCT); 10 business days (non-EEA originator) | EPC Rulebook |
| IBAN format | ISO 13616; country-specific length (e.g., DE=22, FR=27, NL=18) | ISO |
| Idempotency | EndToEndId (max 35 chars, unique per originator) | EPC Rulebook |
| Webhook retry | PSP retries with exponential backoff; C-sepa idempotent on receive | PSP contract |

## 7. Security & compliance

- **F-aml screening gate:** every outbound SEPA counterparty screened against sanctions lists (F-aml / Watchman / OpenSanctions) before submission. Flagged → HITL escalation (I-27), payment blocked pending review.
- **Jurisdiction exclusion (I-02):** payments to/from blocked jurisdictions (RU, IR, KP, BY, SY) → hard reject, no override. SEPA scheme geography (EEA + non-EEA participants) validated against exclusion list.
- **Webhook signature verification:** mandatory; reject unsigned/invalid webhooks.
- **PII handling:** beneficiary names/IBANs/BICs processed through PII Proxy (Presidio) where stored outside the payment lifecycle.
- **Audit trail:** every SEPA payment lifecycle event → append-only log (I-28, 5Y TTL per I-24).
- **PSD2 SCA:** Strong Customer Authentication required for customer-initiated SEPA payments; SCA flow owned by the API/auth layer (out of C-sepa scope — prerequisite).

## 8. DoD / acceptance criteria (for the banxe-emi-stack / banxe-payment-core PR)

- [ ] `test_sepa_sct_send_happy_path` (CREATED → SUBMITTED → ACCEPTED → SETTLED; GL posting via LedgerPort).
- [ ] `test_sepa_sct_inst_send_happy_path` (SCT Inst < 10s; GL posting).
- [ ] `test_sepa_sct_inst_timeout_rejected` (no PSP response within 10s → REJECTED).
- [ ] `test_sepa_sct_inst_fallback_to_sct` (non-reachable beneficiary → SCT fallback offered, not silent).
- [ ] `test_sepa_send_idempotent` (duplicate `idempotency_key` / EndToEndId → same result, no double-send).
- [ ] `test_sepa_send_iban_validation` (invalid IBAN structure → reject before PSP call).
- [ ] `test_sepa_send_faml_screening_gate` (flagged counterparty → HITL escalation, payment blocked).
- [ ] `test_sepa_send_jurisdiction_block` (blocked jurisdiction → hard reject I-02).
- [ ] `test_sepa_receive_webhook_valid` (signed webhook → credit customer EUR, GL posting, D-recon event).
- [ ] `test_sepa_receive_webhook_invalid_signature` (reject unsigned webhook).
- [ ] `test_sepa_receive_duplicate_webhook` (idempotent — no double credit).
- [ ] `test_sepa_return_r_transaction` (RETURNED → reverse journal entry via LedgerPort; EPC reason code mapped).
- [ ] `test_sepa_decimal_only` (no float anywhere in SEPA payment amounts — I-01).
- [ ] `test_sepa_payment_audit_trail_immutable` (append-only lifecycle log — I-28, 5Y TTL).
- [ ] Coverage ≥ 90%, Ruff + Semgrep clean.

## 9. Out of scope (fail-closed)

No runtime code in this document; no cross-repo write to `banxe-emi-stack` or `banxe-payment-core`; **no GL/recon reimplementation** (D-gl / D-recon own those); no AML/KYC/KYB screening reimplementation (F-aml); no FPS/CoP (C-fps owns UK domestic); no SWIFT (C-swift); no SEPA Direct Debit (separate scheme, future block); no card payments; no FX conversion (EUR-only rail); no Midaz production credentials; no autonomous live SEPA payment execution (operator-authorized runtime action); PROPOSED passports not activated.

## 10. Operator gates NOT crossed

- **Runtime implementation** in `banxe-emi-stack` / `banxe-payment-core` is a **separate operator-authorized action** — this spec documents the design; it does not ship code.
- **PSP contract/onboarding** (Modulr/ClearBank SEPA) — requires commercial agreement + FCA EMI authorisation; not a code concern.
- **Live SEPA payment execution** — sandbox/simulation only until operator authorizes production cutover.
- **Legacy sepa-service migration** (MIG-M1.5) — advisory-only; actual cutover is operator-gated.
- No DRAFT promotion; M2.8 Roster-C + web-next + Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 11. References

`docs/payments/C-FPS-BUILD-SPEC.md` (IL-494, UK FPS sibling — shared `PaymentRailPort`);
`docs/payment-rails-research.md` (IL-012, BaaS SEPA coverage — **promoted** into this spec);
`docs/migration/MIG-M1.5-sepa-split.md` (legacy sepa-service decomposition — **referenced**);
`docs/D-RECON-BUILD-SPEC.md` (D-recon 3-leg engine, Leg C = rail);
`services/ledger/gl_service.py` + `LedgerPort` in banxe-emi-stack (D-gl posting, IL-FIN-01);
F-aml (Marble/Watchman — ADR-005, `aml-patterns-SPEC`);
ADR-013 (Midaz), ADR-090 (D-fee), ADR-102/103/115/116/117/119;
I-01 (Decimal only), I-02 (jurisdiction exclusion), I-04 (large-value flag), I-24 (5Y TTL), I-27 (HITL), I-28 (append-only);
EPC SCT Rulebook; EPC RT1/TIPS Rulebook (SCT Inst); ISO 20022 (pain.001, pacs.008, pacs.002, camt.056);
ISO 13616 (IBAN); ISO 9362 (BIC); PSD2 SCA; FCA EMI regulatory perimeter.
