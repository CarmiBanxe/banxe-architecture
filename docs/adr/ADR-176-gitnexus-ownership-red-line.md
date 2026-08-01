# ADR-176: GitNexus Ownership + Analytical Red Line

**Date:** 2026-08-01
**Status:** Proposed
**IL:** TBD (assigned by ledger-rebuild after merge)
**Author:** Moriel Carmi / Claude Code

refs:
  - docs/canon/GITNEXUS-CODE-CONTOUR-DIRECTIVE.md (p.25-26)
  - docs/canon/GITNEXUS-PHASE3-ORG-CONTOUR-VERDICT.md (B/B3)
  - docs/canon/GITNEXUS-PHASE3-CROSSLINK-INTEGRATION-NOTE.md
  - ADR-102 (dedup — no second orchestrator/owner)
  - banxe-emi-stack ADR-056 (herdr — analytical-observer precedent)
  - PR #1176 (org-contour B3 producer), PR #331 (emi-stack ENGINE graph)

---

## Context

GitNexus (PolyForm-Noncommercial-1.0.0; sandbox use only without a purchased license) is
live as a dev-plane code-graph layer: banxe-architecture graph (~41k nodes) and
banxe-emi-stack/ENGINE graph (~53k, PR #331 merged). The org-contour B3 overlay producer
(`scripts/gitnexus/build_org_contour.py`, PR #1176) is merged: staged paths resolve to
impacted departments (B2, room map) and accountable agents (B1, registry rosters +
passports), NO-MOCK. CI `gitnexus-impact` runs in informational mode.

What is NOT yet fixed in canon: who OWNS this tooling, who its beneficiaries are and in
what capacity, and where the hard boundary lies. This ADR fixes all three before any
further strengthening.

## Decision

**(i) Ownership.** GitNexus is a **FACTORY-owned, replaceable dev-plane tool**. The
factory operates it, refreshes its graphs, and may swap the underlying implementation at
any time without engine-side consequence. It is infrastructure of analysis, not of the
bank.

**(ii) Beneficiaries.** Engine, director, and project consume GitNexus output strictly as
an **ANALYTICAL layer**: PR impact reports, ownership blast-radius (departments/agents),
pre-refactor registries, freshness-stamped graphs. Consumption is read-only reporting —
never a runtime dependency.

**(iii) RED LINE (binding).** GitNexus and ALL its derivatives (graphs, overlays, impact
reports, org-contour output) **never enter**: engine runtime, payment execution,
client-instruction handling, AML/sanctions decisioning, ledger posting, or
financial-action HITL gates. Grounds: directive p.25-26 (code graph = code relations
only), the herdr analytical-observer precedent (emi ADR-056), and the PolyForm-NC
license. The org layer joins the code graph **ONLY at report time** — org data is never
written into `.gitnexus` storage.

Strengthening proceeds ONLY along the bounded surface set, each step operator-gated:
org-overlay wiring into impact reports → graph-freshness SLO → contract registry → CI
promotion (post-#1166). Any surface outside this set requires a new ADR, not an
extension of this one.

## Consequences

- Every engine change gains blast-radius + accountability visibility (departments, SMF
  lines, accountable agents) with **zero** runtime dependency on GitNexus.
- Cost: the factory carries graph-freshness upkeep, and every new integration step
  carries an explicit obligation to re-verify the red line before wiring.
- A future attempt to use GitNexus output inside a payment/compliance path must repeal
  this ADR explicitly (operator ratification), not reinterpret it.

## Alternatives considered (rejected)

1. **Runtime integration** (impact data feeding engine decisions) — crosses the red
   line: unauditable analytical artifacts inside regulated execution; violates directive
   p.25-26 and PolyForm-NC scope. Rejected.
2. **Engine-team ownership** — the factory is executor-of-record for dev-plane tooling
   (ADR-102 dedup: one owner, no parallel operator), and replaceability requires the
   owner to be the party able to swap the tool. Rejected.
3. **Status quo** (informational-only, no org overlay wiring) — strands the merged B3
   value (#1176): blast-radius reports without accountability mapping. Rejected in favor
   of bounded, operator-gated strengthening.
