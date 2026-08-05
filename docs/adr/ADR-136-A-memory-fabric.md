---
id: ADR-136-A
title: Unified read-only memory-access fabric over Ledger / reasoning_bank / memoir — query gateway, authority ranking, deny-by-default perimeter
status: DRAFT
date: 2026-08-05
accepted:
supersedes: []
relates:
  - "ADR-136 (agentmemory substrate — governing envelope; the fabric is an ACCESS layer over it, not a new store)"
  - "ADR-137 (memoir versioned-memory pilot — XOR precondition PRESERVED; fabric reads, never merges stores)"
  - "ADR-166 (memory layering — authority order source: Ledger SoT > reasoning_bank decision-memory > memoir working-memory)"
  - "ADR-059 (ledger shards = memory of record — fabric NEVER writes to any store)"
  - "ADR-126/127 (Tier-1 read-only — memory access confers zero write/dispatch authority)"
  - "ADR-130 (no authority expansion — memory describes, never authorizes)"
  - "ADR-117 (factory/project perimeter — fabric perimeter policy rides this boundary)"
  - "ADR-102 (no-duplication — one gateway, no per-client re-implementation of access logic)"
  - "docs/governance/MEMOIR-PILOT-PRECOND-01 (redaction-at-capture) / -02 (bounded retention) / -07 (no authority expansion)"
il_anchor: TBD
il_anchor_note: "Assigned by ledger-rebuild after merge (ADR-119 Rule 8 discipline)."
scope: BANXE-factory-only
concept_only: true
---

# ADR-136-A — Unified read-only memory-access fabric (DRAFT, concept-only)

## Context

ADR-166 fixed the layering: **Ledger** (ADR-059) is the authoritative memory of
record; **reasoning_bank** (emi-stack) is append-only project decision-memory;
**memoir** (factory) is regenerable working-memory. The stores COEXIST,
physically segregated, with the ADR-137 XOR precondition intact. What does NOT
exist is a single, governed way to ASK them questions: today each client
(agents, Fable-5 advisory, future experience-bank) would have to hand-roll its
own access path — duplicated logic (ADR-102 violation risk), inconsistent
redaction, no audit of who read what. This ADR fixes the access layer as a
concept, before any code exists.

## Decision (concept-only)

**One read-only query gateway ("memory fabric") in front of the three stores.
The fabric owns access; the stores stay exactly where and what they are.**

1. **Query gateway.** Single entry point for all memory queries. Clients never
   touch a store directly; a store reachable only through the gateway is the
   enforcement point for everything below.
2. **Authority ranking.** Every response is ranked by source authority, fixed
   by ADR-166: `Ledger (SoT) > reasoning_bank (decision-memory) > memoir
   (working-memory)`. Conflicting answers are NEVER silently merged — the
   envelope carries all hits with their rank; the consumer sees the
   disagreement and the authority order resolves it.
3. **Canonical envelope.** Uniform response schema:
   `{query_id, requested_by, hits: [{source, authority_rank, record_ref,
   excerpt, redactions_applied}], retrieval_audit_ref, generated_at}`.
   `record_ref` is a pointer (pointer-first, ADR-102) — the fabric quotes
   excerpts, it does not restate stores.
4. **Deny-by-default perimeter (rego).** Access policy is expressed as OPA/rego
   rules at the perimeter: no rule that explicitly allows
   `(client, store, record-class)` → query is DENIED. Factory/project boundary
   (ADR-117) is a hard wall: project-side clients cannot read factory
   working-memory and vice versa unless a rego rule ratified by operator says
   so. Policy files are canon-reviewed like code.
5. **Immutable retrieval-audit.** Every query — allowed OR denied — appends an
   audit record (who asked, what, which stores answered, what was redacted,
   policy decision id). Audit is append-only (I-24 discipline), stored on the
   Ledger side as the SoT, and is itself queryable through the fabric.
6. **Query-time redaction.** Redaction-at-capture (PRECOND-01) stays; the
   fabric ADDS a second redaction pass at query time (PII/secrets/
   client-instruction content per class rules), because capture-time rules age
   and stores predate them. `redactions_applied` in the envelope makes the
   pass visible, never silent.
7. **Clients.** The experience-bank **MemoHarness is ONE client of the fabric**
   — it holds no privileged path, no direct store access, same rego perimeter,
   same audit trail as every other consumer.

## Invariants preserved (unchanged by this ADR)

- **Read-only, total.** The fabric has no write path to any store. Writes keep
  their existing owners: shards → add-il-shard/ledger flow; reasoning_bank →
  project append flow; memoir → factory pilot flow (when/if entered).
- **Physical segregation + ADR-137 XOR** — stores are not merged, mirrored,
  or cross-written; the fabric is federation-at-query-time only.
- **No authority expansion (ADR-130/127, PRECOND-07)** — a memory answer never
  authorizes an action; HITL and guardian gates are untouched.
- **Ledger remains SoT (ADR-059)** — rank 1 is structural, not configurable.

## GitHub candidates — reference-only, with checklist

Any external project considered for fabric ideas (agentmemory, memoir already
referenced in ADR-136/137; future: query-gateway / envelope / policy tooling)
is **reference-only, NOT imported**, and passes this checklist BEFORE even
a concept is vendored:

- [ ] License: OSI-approved or explicitly compatible; PolyForm/NC-class →
      sandbox-only boundary recorded (GitNexus precedent, ADR-176).
- [ ] Jurisdiction: no maintainers/infrastructure from sanctioned
      jurisdictions (RU, IR, KP, BY, SY) — hard block per operator canon.
- [ ] Supply-chain: pinned refs only, no auto-updating dependencies.
- [ ] Duplication audit (ADR-102): does an in-repo mechanism already cover it?

## Consequences

- One governed door instead of N ad-hoc paths: consistent ranking, redaction
  and audit for every consumer, including future ones (MemoHarness first).
- Cost: the gateway is a new critical read-path component — it needs its own
  SLO and fail-mode canon (fabric DOWN = clients degrade to "no memory",
  NEVER to direct store access; deny-by-default survives outages).
- A future write-federation, cross-store merge, or authority reranking
  requires a NEW ADR — this one is structurally read-only.

## Out of scope (this DRAFT)

- Any implementation, schema files, rego files, or MemoHarness work.
- Changes to ADR-137 pilot preconditions or their sequencing.
- Project-side (emi-stack) enforcement wiring — separate ADR once the concept
  is ratified.
