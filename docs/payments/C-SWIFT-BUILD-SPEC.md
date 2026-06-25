# C-SWIFT — SWIFT International Wires Build-Spec (MT/MX + correspondent banking)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-25 · **Block:** C-swift · **Priority:** P2 · **Sprint:** 12 · **Promotes:** the 0% (new international-rail definition).
**Plane:** banxe-architecture = docs/payments/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` + `CarmiBanxe/banxe-payment-core` (ADR-115/116/117). This doc **specifies**; ships **no** runtime code and makes **no** cross-repo write.
**Sibling:** `docs/payments/C-FPS-BUILD-SPEC.md` (IL-494, UK domestic) + `docs/payments/C-SEPA-BUILD-SPEC.md` (IL-496, EU corridor). C-swift is the **international / correspondent-banking** sibling. All three share the `PaymentRailPort` abstraction (§3).
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> C-swift integrates **SWIFT cross-border wires** (outbound/inbound MT + MX ISO 20022) over a
> **correspondent / NOSTRO-VOSTRO** model. It implements the shared `PaymentRailPort` abstraction with
> C-fps/C-sepa (referenced, not duplicated), **screens** every counterparty via **F-aml** pre-send,
> **emits** payment events to **D-recon** (Leg C), and **posts** settlement journal entries to **D-gl**
> (via `LedgerPort`). It does **not** reimplement GL, reconciliation, or AML.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/payments/C-FPS-BUILD-SPEC.md` (IL-494) | UK FPS sibling — **defines** the `PaymentRailPort` abstraction, PSP adapter model, settlement/GL posting pattern, D-recon Leg C handoff | **keep / reference** — C-swift is the international sibling; **shares** the port abstraction; does NOT duplicate C-fps scope (GBP/FPS/CoP) |
| `docs/payments/C-SEPA-BUILD-SPEC.md` (IL-496) | EU corridor sibling — extends `PaymentRailPort` for SEPA, ISO 20022 mapping, idempotency, F-aml gate, returns | **keep / reference** — C-swift mirrors this structure for the international corridor; **shared port**, separate adapters/messages/scheme rules; not duplicated |
| `docs/D-RECON-BUILD-SPEC.md` §2 Leg C | D-recon Leg C = payment-rail balance via `RailBalancePort` | **keep / reference** — C-swift **feeds** Leg C; D-recon **owns** the recon engine |
| `services/ledger/gl_service.py` (`GLService` / `LedgerPort`) in banxe-emi-stack | double-entry GL posting (IL-FIN-01) | **keep / reference** — C-swift **posts** settlement via `LedgerPort`; does NOT reimplement GL |
| `docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` (F-aml) | sanctions/PEP screening | **keep / reference** — C-swift **invokes** F-aml pre-send (cross-border sanctions gate); screening not reimplemented |

No existing `C-SWIFT-BUILD-SPEC` / SWIFT artifact on main (live audit: `find docs -iname '*c-swift*'`/`*swift*BUILD*` ⇒ empty; `ls docs/payments` ⇒ C-FPS / C-SEPA only). New file is **non-duplicative**; it is the international sibling sharing the port, not a re-implementation.

## 1. Boundary (C-swift vs C-fps/C-sepa vs D-recon vs D-gl vs F-aml) — drift reconciled

| Capability | Owner | C-swift relationship |
|---|---|---|
| SWIFT MT/MX cross-border send/receive + correspondent banking | **C-swift** | **builds** |
| FPS send/receive + CoP (UK domestic, GBP) | **C-fps** (sibling) | out of scope — shared `PaymentRailPort`, separate adapter |
| SEPA SCT/SCT Inst (EU corridor, EUR) | **C-sepa** (sibling) | out of scope — shared `PaymentRailPort`, separate adapter |
| Reconciliation engine (3-leg: ledger ↔ safeguarding ↔ **rails**) | **D-recon** (Leg C) | **emits to** (SWIFT payment events / NOSTRO statements) |
| General Ledger posting (double-entry, `LedgerPort`) | **D-gl** (`GLService`) | **posts to** (multi-currency settlement journal entries) |
| AML/sanctions screening on cross-border counterparties | **F-aml** | **invokes** (mandatory pre-send screening gate) |

C-swift is the **international rail integration layer**: correspondent/SWIFT-access adapter, MT + MX (ISO 20022) messaging, idempotent cross-border payment lifecycle, BIC validation, cover-payment handling, gpi/UETR tracking, and event emission. It shares the `PaymentRailPort` abstraction with C-fps/C-sepa but implements SWIFT-specific adapters, message formats, and correspondent-banking rules.

## 2. Scope — SWIFT cross-border wires

### 2.1 Outbound wire send (multi-currency)
- Pre-send validation: sufficient currency balance (Midaz ledger query), **mandatory F-aml sanctions screening** (HITL for flagged — cross-border = elevated risk, §7), **BIC validation** (§2.3), **FATF Rec 16 / Travel Rule** completeness (full originator + beneficiary info, §7).
- Message: **MX `pacs.008`** (customer credit transfer) for the go-forward ISO 20022 corridor; **MT103** retained for legacy/correspondent compatibility (MT/MX coexistence, §2.6).
- Bank-to-bank / treasury transfers: **MX `pacs.009`** (`MT202`) ; **cover payments** via **`pacs.009 COV`** (`MT202COV`) — serial vs cover method (§2.4).
- **Idempotency:** every send carries a client-generated `idempotency_key` (UUID v4) **and a SWIFT `UETR`** (Unique End-to-end Transaction Reference, gpi); adapter/correspondent deduplicates; domain model enforces exactly-once.
- On `SETTLED` (correspondent confirmation / gpi `ACSC`): emit `swift.payment.settled` event → D-recon (Leg C) + post settlement journal entry → D-gl (`LedgerPort`: Dr Client Account / Cr NOSTRO @ correspondent).

### 2.2 STP vs repair
- **STP** (straight-through): fully-formed, validated, screened wires submit automatically.
- **Repair queue:** missing/ambiguous BIC, incomplete Travel-Rule data, or F-aml hold → routed to a **repair/HITL queue**; never silently dropped, never auto-completed.

### 2.3 BIC validation
- Validate beneficiary-bank **BIC (ISO 9362)** structure + directory existence; resolve to correspondent route; reject malformed/sanctioned-institution BIC before submission.

### 2.4 Cover payments (correspondent banking)
- **Serial method:** single MT103/pacs.008 routed bank-to-bank along the correspondent chain.
- **Cover method:** customer message (pacs.008) + separate cover (pacs.009 COV / MT202COV) to reimburse via NOSTRO. **Cover-payment transparency:** full originator + beneficiary info carried on the cover (FATF Rec 16 / Wolfsberg) — no stripping.

### 2.5 Inbound wire receive (multi-currency)
- Parse correspondent confirmation / inbound `pacs.008` / `MT103` → `InboundSWIFTPaymentDTO` → credit customer account via `LedgerPort` (Dr NOSTRO / Cr Client Account).
- Emit `swift.payment.received` event → D-recon (Leg C).
- **Duplicate detection:** idempotent by `UETR` / correspondent transaction reference; reprocessing a duplicate confirmation is a no-op.

### 2.6 MT/MX coexistence & migration
- **ISO 20022 (MX)** is the **go-forward** standard for cross-border (CBPR+; SWIFT MT-for-cross-border retirement, Nov 2025). C-swift targets **MX-first**; **MT (MT103/MT202)** retained for **inbound parsing + correspondents not yet migrated** (graceful coexistence).
- MT↔MX translation is **PSP/correspondent-internal** or via a translation library at the adapter edge; the domain model is message-format-agnostic (DTOs only).

### 2.7 Payment status lifecycle
- State machine (shared `PaymentRailPort` contract, identical to C-fps/C-sepa): `CREATED → SUBMITTED → ACCEPTED → SETTLED`, plus `REJECTED` / `RETURNED` / `IN_REPAIR`. gpi statuses (`ACSP`, `ACSC`, `RJCT`) mapped to domain states; each transition recorded as an immutable event (I-28).
- **gpi/UETR tracking:** live status via the gpi Tracker (where the correspondent supports it).
- `RETURNED`: correspondent return / recall (`camt.056` / `MT192`/`MTn99`) — triggers reverse journal entry via `LedgerPort`.

## 3. PSP / correspondent adapter model (shared PaymentRailPort)

### 3.1 Shared hexagonal port (defined in C-fps, extended for SWIFT)
The `PaymentRailPort` abstraction is **defined once** (C-fps §3.1) and **implemented per rail**. C-swift adapters implement the same port interface with SWIFT-specific request/response types:

```python
class SWIFTRailPort(PaymentRailPort):
    """SWIFT cross-border wires via correspondent/SWIFT-access provider — extends shared PaymentRailPort."""
    async def send_payment(self, request: SWIFTSendRequest) -> SWIFTPaymentResult: ...
    async def validate_bic(self, bic: str) -> BICValidationResult: ...
    async def track_payment(self, uetr: str) -> GpiTrackingStatus: ...
    async def get_payment_status(self, provider_reference: str) -> SWIFTPaymentStatus: ...
```

### 3.2 Adapters
| Adapter | Provider | Notes |
|---|---|---|
| `CorrespondentSWIFTAdapter` | **Correspondent-banking-as-a-service** (primary; e.g. ClearBank multi-currency / LHV / Banking-Circle-class — operator-selected) | NOSTRO accounts in major currencies; ISO 20022 / gpi; signed webhooks; SWIFT access via the correspondent's BIC |
| `BureauSWIFTAdapter` | **SWIFT service bureau / direct BIC** (fallback) | Direct SWIFT access via service bureau or own BIC + Alliance; MT/MX; higher onboarding/compliance threshold |
| `SandboxSWIFTAdapter` | In-memory | Test/dev; deterministic responses; no external calls |

### 3.3 Provider selection rationale
- **Correspondent-as-a-service** primary: fastest path for an EMI (no direct SWIFT membership burden); NOSTRO + gpi + ISO 20022 provided; FCA-aligned correspondent preferred. **Specific provider selection = operator-gated** (§10).
- **Direct SWIFT (bureau/own BIC)** fallback: full control + reach, higher cost/compliance — later-stage option.

### 3.4 Message mapping (MT + MX)
| Direction | Message | Usage |
|---|---|---|
| Outbound customer credit (go-forward) | `pacs.008.001.xx` | FIToFICustomerCreditTransfer (MX; replaces MT103) |
| Outbound bank/treasury transfer | `pacs.009.001.xx` | FinancialInstitutionCreditTransfer (MX; replaces MT202) |
| Cover payment | `pacs.009 COV` / `MT202COV` | Cover method with full party transparency |
| Legacy customer credit (coexistence) | `MT103` | Inbound parse / non-migrated correspondents |
| Status report | `pacs.002.001.xx` | PaymentStatusReport (acceptance/rejection; gpi) |
| Return / recall | `camt.056` / `MT192` | Cancellation/recall request |

PSP/correspondent abstracts raw MT/MX wire format; the C-swift adapter maps provider REST/API responses to domain DTOs. Direct MT/MX handling is provider-internal — C-swift consumes structured provider responses.

## 4. Settlement & GL posting (referenced, not duplicated)

C-swift does **not** own the general ledger. It **posts** settlement events via the existing `LedgerPort` / `GLService` — same pattern as C-fps/C-sepa §4:

| Event | Journal entry (via LedgerPort) |
|---|---|
| `swift.payment.settled` (outbound) | Dr Client Account / Cr NOSTRO @ correspondent (settlement currency) |
| `swift.payment.received` (inbound) | Dr NOSTRO @ correspondent / Cr Client Account |
| `swift.payment.returned` (recall/return) | Reverse of original entry |
| `swift.charges.applied` (correspondent/`OUR`/`SHA`/`BEN` charges) | Dr Charges Expense or Client (per charge-bearer) / Cr NOSTRO |

- All amounts: **Decimal only** (I-01, no float). Multi-currency (ISO 4217); **no in-rail FX conversion** (treasury/FX is a separate concern — §9).
- `LedgerPort.post_journal_entry()` is the single seam — C-swift never writes directly to Midaz.

## 5. Reconciliation handoff (D-recon Leg C — referenced, not duplicated)

C-swift **feeds** D-recon Leg C — same pattern as C-fps/C-sepa §5:
- NOSTRO statements (`camt.053` / MT940/MT950) from the correspondent → available for `StatementFetcher` polling.
- Real-time SWIFT payment events + gpi status emitted to the event bus for D-recon intraday matching.
- C-swift does **not** run reconciliation — D-recon owns the 3-leg tie-out engine.

## 6. Limits, settlement timing, and scheme rules (config-as-data)

| Parameter | Value | Source |
|---|---|---|
| Settlement cycle | Cross-border T+0…T+2 per currency/corridor/correspondent cut-off | Correspondent SLA |
| Cut-off times | Per-currency daily cut-offs (config-as-data) | Correspondent SLA |
| gpi SLA | Same-day credit to beneficiary (gpi member banks) | SWIFT gpi |
| BIC format | ISO 9362 (8 or 11 chars) | ISO |
| UETR | UUID v4, mandatory on all gpi payments | SWIFT |
| Travel Rule | Full originator + beneficiary info on all cross-border wires | FATF Rec 16 |
| Charge bearer | `OUR` / `SHA` / `BEN` (config per product/tier) | ISO 20022 |
| Return/recall window | Per correspondent / scheme | Correspondent SLA |
| Idempotency | `UETR` + client `idempotency_key` | SWIFT gpi |

Limits, cut-offs, charge-bearer defaults, corridor enablement = **config-as-data** (CLAUDE.md §10) — not hardcoded.

## 7. Security & compliance

- **F-aml screening gate (mandatory pre-send):** every outbound counterparty **and** every intermediary/beneficiary **BIC/institution** screened against sanctions lists (F-aml / Watchman / OpenSanctions) before submission. Flagged → HITL escalation (I-27), payment held in repair, blocked pending review.
- **Jurisdiction exclusion (I-02):** wires to/from blocked jurisdictions (RU, IR, KP, BY, SY) → **hard reject, no override**; correspondent-chain + beneficiary geography validated against the exclusion list (cross-border = primary enforcement point).
- **FATF Rec 16 / Travel Rule:** full originator + beneficiary information mandatory and **carried on cover payments** (no stripping); incomplete info → repair queue, not send.
- **Webhook/confirmation signature verification:** mandatory; reject unsigned/invalid provider callbacks.
- **PII handling:** beneficiary names/accounts/BICs processed through PII Proxy (Presidio) where stored outside the payment lifecycle.
- **Audit trail:** every SWIFT payment lifecycle event + gpi status → append-only log (I-28, 5Y TTL per I-24).
- **PSD2 SCA:** Strong Customer Authentication for customer-initiated wires — owned by the API/auth layer (prerequisite, out of C-swift scope).

## 8. DoD / acceptance criteria (for the banxe-emi-stack / banxe-payment-core PR)

- [ ] `test_swift_send_happy_path_mx` (pacs.008; CREATED → SUBMITTED → ACCEPTED → SETTLED; GL posting via LedgerPort; UETR assigned).
- [ ] `test_swift_send_mt_coexistence` (MT103 legacy path / inbound MT parse maps to same domain DTO).
- [ ] `test_swift_cover_payment_transparency` (pacs.009 COV carries full originator+beneficiary; no stripping — FATF Rec 16).
- [ ] `test_swift_send_idempotent` (duplicate `idempotency_key` / `UETR` → same result, no double-send).
- [ ] `test_swift_send_bic_validation` (invalid/sanctioned BIC → reject before submission).
- [ ] `test_swift_send_faml_screening_gate` (flagged counterparty/intermediary → HITL, held in repair).
- [ ] `test_swift_send_jurisdiction_block` (blocked jurisdiction in chain → hard reject I-02).
- [ ] `test_swift_send_travel_rule_incomplete_to_repair` (missing originator/beneficiary info → repair queue, not send).
- [ ] `test_swift_stp_vs_repair_routing` (clean wire = STP; ambiguous = repair, never silent-drop/auto-complete).
- [ ] `test_swift_receive_inbound_credit` (inbound pacs.008/MT103 → credit customer, GL posting, D-recon event).
- [ ] `test_swift_receive_duplicate_uetr` (idempotent — no double credit).
- [ ] `test_swift_gpi_status_tracking` (UETR → gpi ACSP/ACSC/RJCT mapped to domain states).
- [ ] `test_swift_return_recall` (camt.056/MT192 → reverse journal entry via LedgerPort).
- [ ] `test_swift_charges_our_sha_ben` (charge-bearer posting per config).
- [ ] `test_swift_decimal_only` (no float in any wire amount — I-01).
- [ ] `test_swift_payment_audit_trail_immutable` (append-only lifecycle log — I-28, 5Y TTL).
- [ ] Coverage ≥ 90%, Ruff + Semgrep clean.

## 9. Out of scope (fail-closed)

No runtime code in this document; no cross-repo write to `banxe-emi-stack` or `banxe-payment-core`; **no GL/recon reimplementation** (D-gl / D-recon own those); **no AML/KYC screening reimplementation** (F-aml; C-swift only invokes the gate); no FPS/CoP (C-fps) or SEPA (C-sepa) — separate siblings; **no FX conversion** (treasury/FX is a separate concern; C-swift is multi-currency settlement, not a dealing desk); no direct SWIFT-network message crafting where the correspondent abstracts it; no card payments; no Midaz production credentials; **no autonomous live wire execution** (operator-authorized runtime action); PROPOSED passports not activated.

## 10. Operator gates NOT crossed

- **Cross-repo runtime** — implementing C-swift in `banxe-emi-stack` / `banxe-payment-core` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Correspondent/provider selection + onboarding + live SWIFT access (BIC enrolment)** = operator-authorized action — not done here.
- **Live wire execution / production NOSTRO movement** = operator-authorized + HITL — not crossed.
- No passport activation; no DRAFT promotion; no operator-gated PR touched; Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 11. References

`docs/payments/C-FPS-BUILD-SPEC.md` (IL-494 — defines shared `PaymentRailPort`), `docs/payments/C-SEPA-BUILD-SPEC.md` (IL-496 — EU sibling, mirrored structure);
`docs/D-RECON-BUILD-SPEC.md` (Leg C consumer); `services/ledger` `LedgerPort`/`GLService` (D-gl settlement posting);
`docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` (F-aml pre-send screening);
ISO 20022 (pacs.008/009/002, camt.053/056); SWIFT MT (MT103/MT202/MT202COV/MT940); SWIFT gpi (UETR/Tracker); FATF Rec 16 (Travel Rule); ISO 9362 (BIC);
ADR-027 (audit), ADR-102/103/115/116/117/119; I-01/I-02/I-24/I-27/I-28; CLAUDE.md §9/§10/§11; PII Proxy (Presidio).
