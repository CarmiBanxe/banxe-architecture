# G1–G4 MiCA / AML Runbook (operator / MLRO)

## Status

ACTIVE — governance reference. **Docs-only and non-activating.** This runbook does
not change any ADR status (ADR-095 stays PROPOSED), does not touch the code
repositories, does not modify any `/v1` contract, and activates no live provider,
execution, billing, or gamification. It is **not legal advice** — it is an operating
map for the operator and MLRO and their qualified MiCA / AML counsel.

## Purpose & scope

This is a runbook for the **operator / MLRO**, not for the factory. It explains how
to use the governance artifacts already on `main` to take any G1–G4 track toward a
ratified decision under MiCA / AML, while the estate stays mock / advisory /
unsigned / fail-closed until an explicit, signed ratification.

Artifacts it ties together:

- **Tech spine + moat** — the delivered DSE / BaaS / preview / provider-foundation /
  product surface plus the mock-safe moat: market-making (ADR-089), dynamic fee
  engine (ADR-090), quant-moat (ADR-091), ecosystem / marketplace (ADR-092),
  multi-venue unsigned execution-preview hardening (ADR-093). Recorded as IL-223…236.
- **Scope-closure** — ADR-094 (IL-237) drops the legacy labels S6.6 / S6.7 / T7.9 /
  T8.0 as out-of-scope for 2026; the S6–T8 map has no remaining NOT CONFIRMED labels.
- **Decision-support** — ADR-095 (PROPOSED, IL-238): the G1–G4 matrix with
  factory-recommended conservative defaults and blank operator / MLRO ratification
  cells. It decides nothing; it prepares materials.
- **G1L decision-lineage logging** — IL-239: an inert, mock-safe, fail-closed audit
  logger over the advisory seams (the one safe-to-build-now item from ADR-095). It
  activates nothing.

## Regulatory context (MiCA / AML / TFR — high level, not legal advice)

The MiCA CASP regime is fully mandatory after **1 July 2026**, when the transitional
period and any grandfather clause end. From that point, providing in-scope
crypto-asset services in the EEA generally requires a **CASP authorisation**, and the
authorised entity carries the attendant obligations — including a documented
**best-execution** policy (price, cost, speed, likelihood of execution and
settlement), client classification and **suitability / appropriateness** where
relevant, and clear, fair, non-misleading marketing.

On the financial-crime side, the operator must satisfy **KYC / KYB** at onboarding
(standard due diligence as a baseline, enhanced due diligence for higher-risk
relationships), ongoing monitoring, and the **AML / CFT** framework. Under the EU
**Transfer of Funds Regulation (TFR / "travel rule")** for crypto-asset transfers,
full **originator and beneficiary** information must travel with the transfer with
**no de-minimis threshold** — so only counterparties able to satisfy the travel rule
are admissible.

This section is an orientation map only. Every classification (is a given earn
product an EMT / e-money / collective-investment arrangement? does a venue or token
fall in scope? which licences are required?) is a determination for the operator's
qualified compliance and legal advisers, recorded in a ratified ADR — not here.

## How to use ADR-095 (G1–G4 decision-support)

ADR-095 is a matrix. Each row (G1 live providers, G2 partner auth / KYB / billing,
G3 execution go-live, G4 gamification) carries:

- a **factory-recommended conservative default** (the MiCA-safe resting option), and
- a blank **`☐ ______` operator / MLRO ratification cell**.

Operator steps:

1. **Work a cell at a time**, lowest-risk first — start with the G1 advisory-only
   data feeds and the already-built G1L logging, not with execution or perps.
2. **Decide and sign the cell**: record `YES / NO / PHASED` + the conditions
   (jurisdictions, per-user / per-day caps, asset / protocol allow- and block-lists,
   leverage / suitability limits) + signer + date.
3. **Review each decision with qualified MiCA / AML compliance and legal counsel**
   before it is treated as final.
4. **Only after a cell is ratified**, open a dedicated **ACCEPTED** follow-up ADR for
   that specific change (flipping or superseding ADR-095 for that row), confirm the
   relevant licence is in force, and — where code is needed — run a standard build
   sprint. Credentials and secrets are provisioned **out-of-band** by the operator;
   the factory never holds keys.

Ratifying a cell here does **not** itself turn anything on; activation always flows
through a separate ACCEPTED ADR + IL + (if needed) build sprint.

## How to use G1L decision-lineage logging

What is logged today (advisory seams only): one append-only audit event per request
for **DSE** (`/api/v1/dss/recommend`), **market-making** (`/api/v1/mm/preview`),
**fees** (`/api/v1/fees/preview`), **quant** (`/api/v1/quant/preview`), and
**execution-preview** (`/api/v1/execution/intent-preview`).

Each event carries: `id`, `timestamp`, `layer`, `partnerId` / `userId` (only when
already present on the request), redacted `request` and `response` payloads,
`providerVersions` (mock stamps today), `correlationId`, and an optional `rationale`.
It is a **local**, **PII-limited** (defensive redaction denylist; only pre-existing
identifiers), **fail-closed** logger — a sink error is swallowed and warn-logged and
never affects the HTTP response or business behaviour.

How it helps:

- **MiCA / AML audit & explainability** — a decision-lineage trail showing what was
  asked, what was advised, and with which (mock) provider versions, per correlation
  id.
- **Future go-live readiness** — if any G-row later moves live, the same lineage
  shape supports replay and after-the-fact checks of a best-execution or suitability
  policy.

Explicitly:

- The **final retention period and PII scope are NOT defined by this runbook or by
  G1L**; they require a separate operator / MLRO policy (an open ADR-095 ratify cell).
  Today the sink writes only to the local logging stream — no external store / SIEM.
- **G1L is technical scaffolding that activates nothing by itself.**

## Runbook steps for future go-live (per G-row)

For each G1–G4 row the recommended loop is:

1. **Fill the ADR-095 ratification cell** (`YES / NO / PHASED` + conditions + signer +
   date), after compliance / legal review.
2. **Prepare a dedicated ACCEPTED ADR** for the specific change (scope, guardrails,
   fail-closed conditions, best-execution / suitability where relevant).
3. **Verify licences** — CASP / EMI / other authorisations in force for that activity.
4. **Append a new entry to `INSTRUCTION-LEDGER.md`** (append-only, ADR-056
   ledger-coupling) recording the decision and ADR.
5. **Build / enable code via a standard sprint** only where the change requires it;
   keep the mock default and fail-closed seams; provision real credentials out-of-band.

Until those steps are complete for a given row, that row stays at its conservative
default and the estate remains mock / advisory / unsigned / fail-closed.

## References

- ADR-089, ADR-090, ADR-091, ADR-092, ADR-093 (moat); ADR-094 (scope-closure);
  ADR-095 (G1–G4 decision-support, PROPOSED); ADR-056 (ledger-coupling); I-28
  (append-only ledger).
- IL-223, IL-225, IL-226, IL-227 (S12–S15), IL-236 (S16), IL-237 (S17), IL-238
  (ADR-095), IL-239 (G1L), IL-240 (this runbook).
- MiCA CASP regime (full effect after the transitional period ends 1 July 2026); EU
  Transfer of Funds Regulation (travel rule, no de-minimis for crypto transfers).
