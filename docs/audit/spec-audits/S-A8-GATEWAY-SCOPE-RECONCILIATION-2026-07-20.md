# Context & scope

Reconciliation artefact for S-A8, produced after S-A7's `M-GATEWAY-WEB-INSTALL-AUDIT-2026-07-20.md`
surfaced a naming/scope collision rather than a code gap: the roadmap/sprint layer's use
of "M-GATEWAY" as a rail/ledger-fronting runtime gateway does not match
`M-GATEWAY-BUILD-SPEC.md`'s actual scope (a developer-platform/API-productisation layer).
This artefact does not implement code, does not re-audit runtime code from scratch, does
not rewrite any prior artefact, and does not alter the BIF verdict. It reconciles the
collision using only evidence already gathered plus one additional citation pass over the
roadmap/spec documents themselves.

# What the roadmap/sprint logic assumes (paths + citations to repo docs)

- `docs/roadmap/S-A7-EXECUTION-PLAN-M-GATEWAY-BIF-WEB-2026-07-19.md` — title itself
  bundles "M-GATEWAY / BIF / WEB CLUSTER" as one runtime-adjacent front. Line 7: *"S-A5
  and S-A6 prepared the EMI/ledger cluster and identified M-GATEWAY/BIF/web as the next
  execution front."* Lines 11–12: *"Bring the M-GATEWAY / BIF / web layer from the
  current 'planned-only' state to a clearly executable, auditable plan: clarify
  M-GATEWAY behaviour and BIF's role as stop-barrier/redirect."* Line 18: *"M-GATEWAY
  behaviour audit and spec update."* Line 29 lists *"Any production gateway
  reconfiguration"* as explicitly out-of-scope — implying "gateway" here is read as a
  runtime, reconfigurable component, consistent with a rail-fronting interpretation.
  **This document does not itself disambiguate M-gateway from I-api anywhere.**
- **Provenance note:** `git log -1` for this file returns no commit — it is an
  **untracked, uncommitted local draft**, not part of ratified canon. The collision
  originates in a draft planning artefact, not in the committed roadmap.
- This session's own prior S-A6→S-A7 execution designs (produced earlier in this
  conversation, not stored as a separate repo file) operationalised this same assumption
  explicitly, e.g. instructing the "M-GATEWAY sub-sprint" to "confirm it acts as a
  rail/gateway layer over D-GL/B-EMI, not a second ledger" — carrying the S-A7 plan's
  ambiguous framing forward into a concrete (and, per the evidence below, incorrect)
  operational assumption.

# What the specs actually define (paths + SHA where relevant)

- `docs/architecture/M-GATEWAY-BUILD-SPEC.md` (repo, `banxe-architecture`; last commit
  `ff71a1e5368d46f80d57b47ef19707aa30ba3bf3`, 2026-06-25): *"M-gateway is the
  developer-platform productisation layer — the public API product: OpenAPI/Swagger
  published spec, generated SDKs, developer portal/docs, API-key self-service onboarding,
  versioning/deprecation governance, partner DX, usage analytics + plan/tier hooks. It
  publishes through I-api... it does NOT reimplement routing, authN/authZ, or
  rate-limiting (those are I-api)."* Explicit Duplication Audit (§0) disambiguates
  against I-api by name.
- `docs/architecture/I-API-BUILD-SPEC.md` (same repo; last commit
  `ef591359bdcb78b7fc41373d6801ace3af0721ae`, 2026-06-24): *"I-api is the developer/
  partner-facing API Gateway — the single ingress that routes and secures external REST
  traffic to the banking services. It fronts D-gl, payment rails, onboarding, and other
  services."* This is the block that actually matches the roadmap/sprint's runtime-
  fronting assumption.
- `docs/ROADMAP-MATRIX.md` (same repo; last commit
  `3eac70189031250b32c7c138029b388e19ed8fd4`, 2026-07-06) — the ratified, committed
  roadmap matrix — **already correctly disambiguates the two blocks**: row `M-gateway`
  ("M — Developer Platform" category) states *"developer-platform PRODUCTISATION layer
  (NOT a second gateway)... PUBLISHES THROUGH I-api (IL-508 enforces routing/auth/
  rate-limit)"*; row `I-api` ("I — Technology & Infrastructure" category) states
  *"developer/partner-facing REST gateway... routing to banking services... fronts
  services."* The ratified canon does not contain the collision found at the sprint-draft
  level.
- `docs/audit/spec-audits/M-GATEWAY-WEB-INSTALL-AUDIT-2026-07-20.md` (this session's
  prior artefact, untracked): confirmed zero code implements M-gateway's actual
  `PublishedAPI`/`SDKArtifact`/`DeveloperApp`/`APIKeyGrant` model anywhere in
  `banxe-emi-stack`; confirmed candidate rail-adjacent infrastructure code
  (`services/api_gateway/`, `services/payment/payment_gateway_port.py`) exists under
  neither name literally, closer in role to I-api's description than to M-gateway's.
- `docs/audit/spec-audits/D-GL-INSTALL-AUDIT-2026-07-20.md`,
  `docs/audit/spec-audits/B-EMI-INSTALL-AUDIT-2026-07-20.md`,
  `docs/audit/spec-audits/M2.5-BIF-INSTALL-AUDIT-2026-07-20.md` — reused as established
  evidence per this sprint's brief; not re-derived here (see the "Evidence baseline"
  summary carried into this session; findings preserved unchanged).

# Reconciliation notes (M-GATEWAY vs I-API vs runtime topology)

- **The block corresponding to the roadmap/sprint's runtime-routing intent is I-api**, not
  M-gateway. I-api's own spec text ("fronts D-gl, payment rails, onboarding") is the exact
  role the S-A7 execution plan and this session's derived checklists assumed M-GATEWAY
  would occupy.
- **M-gateway is a genuinely distinct, unrelated concern**: developer-platform
  productisation (OpenAPI publication, SDKs, developer portal, self-service API keys,
  versioning/deprecation, usage analytics). It has no D-GL/B-EMI/payment-rail adjacency in
  its own spec, and none was found in code.
- **"Gateway" is an overloaded term across roadmap/spec layers**, but not inconsistently
  so at the ratified level: `ROADMAP-MATRIX.md` already names and disambiguates both
  `M-gateway` and `I-api` correctly, in the same table, with cross-references between
  them. The overload/collision is specific to the **draft** S-A7 execution-plan document
  (itself uncommitted) and to how this session's derived execution checklists carried that
  draft's ambiguous sprint title into an operational assumption without cross-checking the
  ratified matrix.
- **How S-A7's OPEN POINT should now be read:** S-A7 correctly identified that
  "M-GATEWAY" (as install-audited) does not match the spec's actual scope, and correctly
  declined to silently substitute I-api's code evidence in its place. That finding stands,
  unmodified. This artefact adds the missing piece: the ratified `ROADMAP-MATRIX.md`
  already resolves the ambiguity in principle — the practical gap is that the **sprint
  execution-plan document** (S-A7's own source-of-truth for scope) did not carry that
  matrix-level disambiguation into its own text, and this session's execution checklists
  inherited the gap. S-A7's evidence is preserved and is now explained, not overturned.
- **BIF verdict, reused as supporting context only, unaltered:**

  > "BIF is a stop-barrier outside the ledger-critical path pending a redirect decision"

  This reconciliation does not change BIF's status and does not promote it to a ledger
  blocker. It does have one conceptual implication worth recording: since the actual
  rail-fronting block is I-api (not M-gateway), any future work that wants to check
  whether BIF is correctly wired at the gateway layer should look for I-api-adjacent
  integration points, not M-gateway-adjacent ones. This is a routing note for future work,
  not a re-derivation of the verdict itself.

# Gaps & risks (OPEN POINTS)

1. **Terminology/scope collision between the draft S-A7 execution-plan document and the
   ratified `ROADMAP-MATRIX.md`.** The matrix already disambiguates M-gateway from
   I-api; the S-A7 draft plan's title and scope text do not carry that disambiguation
   forward, and this session's derived execution checklists compounded the gap. Not yet
   resolved: whether the S-A7 draft plan itself should be corrected, given it remains an
   uncommitted local artefact.
2. **Ownership of runtime-gateway clarification is not established.** No Floor-2 room has
   been assigned responsibility for confirming I-api's actual implementation status
   (unaudited in this sprint) or for correcting sprint-naming going forward — this is
   itself an open assignment question, not a decision made here.
3. **The correct resolution mechanism is unresolved and posed here as a question, not a
   decision:** should this collision be corrected via (a) a new ADR formally cross-linking
   M-gateway/I-api naming discipline for future sprints, (b) a new MIG-style note
   documenting the terminology lesson (mirroring the MIG-M2.7/target-mismatch precedent
   pattern already used elsewhere in this repo), or (c) a future roadmap-text
   clarification pass over the S-A7 draft plan specifically? All three remain open;
   none is chosen here.
4. **I-api's actual runtime implementation status is unaudited.** This reconciliation
   cites I-api's spec text as the better conceptual match for the roadmap's intent, but no
   install-audit of I-api's own code has been performed in this sprint or prior ones —
   whether I-api itself is implemented, partial, or 0% remains unknown.

# Next steps / hooks into Floor-2 rooms

- **OPEN POINT 1 (draft-vs-ratified collision):** route to the governance/roadmap room —
  decide whether to correct the S-A7 draft plan's title/scope text now that the
  disambiguation is documented here, or leave it as historical record with this
  reconciliation artefact as the correcting pointer.
- **OPEN POINT 2 (ownership assignment):** route to the governance/roadmap room jointly
  with payments/tech — an explicit owner for "runtime gateway clarification" has not been
  named anywhere in existing canon and should be assigned, not assumed.
- **OPEN POINT 3 (resolution mechanism):** route to the operator/CTIO for a decision
  among the three options listed above (new ADR / new MIG note / roadmap-text
  clarification) — presented here as an open question only.
- **OPEN POINT 4 (I-api unaudited):** route to the ledger/payments room as a candidate
  future install-audit sprint (a natural "S-A9" or equivalent), separate from and not
  implied to be authorized by this reconciliation artefact.
