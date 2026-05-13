# Decision: Option B — :8080 is Sandbox-Only (binding)

Document ID: DECISION-LITELLM-DUAL-GATEWAY-2026-05-13
Status: ACCEPTED (operator-approved via Sub-A best-decision pick)
Trigger: PR #276 enumerated 3 remediation options; operator delegated
selection to Sub-A under Clauses 1+2 (best-decision rule).

## Decision

Keep two distinct LiteLLM gateways on Legion with formal boundary:

- **CANONICAL = `litellm-v2.service` on `127.0.0.1:4000`**
  - All production agent traffic (Aider per ADR-043, OpenClaw
    gateways CTIO/GUIYON/MOA, Claude Code via Guardian shim,
    factory-fast/mid/heavy/coder/project-reason aliases).
  - Authoritative per ADR-018, INVARIANT I-32, ADR-043,
    IL-FA-02-EXEC (PR #88).

- **SANDBOX = `litellm.service` on `127.0.0.1:8080`**
  - Innovation sandbox traffic ONLY (per innovation-sandbox-roadmap-2026-05-11.md).
  - Shadow Classifier Tap (PR #265).
  - Conditions A/B/C/D drafts (PR #225).
  - Smoke testing of new model aliases prior to canonical promotion.
  - No production agent may target :8080.

## Why Option B (not A, not C)

- Option A (decommission :8080) would force migration of working
  shadow tap + audit sink to :4000, breaking PR #265 mid-flight
  and risking the only LIVE Banxe AI audit trail in ClickHouse.
- Option C (promote :8080 as canonical) requires ADR-018 + I-32 +
  ADR-043 amendments and OpenClaw gateway / Aider re-pinning,
  with non-trivial blast radius and zero benefit beyond label.
- Option B preserves current state, formalises boundary, adds one
  new invariant; minimum sleep-disturbance for production.

## New invariant (additive to ADR-018 + I-32)

**I-37 (additive, this decision)**
> Production agent traffic MUST route through canonical LiteLLM v2
> on legion:4000 only. The :8080 instance is reserved for the
> Innovation Sandbox and MUST NOT be configured as a backend by
> Aider, OpenClaw gateways, Claude Code agents, banxe-compliance-api
> or any other production-bound consumer. Sandbox-to-canonical
> promotion of a new alias requires explicit ADR + IL pairing.

## Sub-A PRs re-classification (no reverts, label updates only)

Today's PRs are kept on `main` with label "sandbox-only":

| PR | Original framing | Re-classified framing |
|----|------------------|----------------------|
| #200 | A-8 MetaClaw "resolution" | Sandbox isolation work; A-8 was already closed earlier |
| #205 | evo2 as 2nd LiteLLM backend | Sandbox-only |
| #234 | qwen2.5:0.5b pulled on evo2 | Pilot artifact (canonical-eligible later) |
| #238 | shadow-tap activation patch | Sandbox-only |
| #265 | shadow-tap LIVE | Sandbox-only |
| #269 | A-8 regression mitigation on :4000 | Security hardening of canonical, kept |
| #271 | AI agent full inventory | Reference doc, accurate |
| #273 | factory→evo2 235B routes on :8080 | Sandbox duplicate of FA-2 PR #88 |
| #275 | factory orchestration audit | Reference doc, accurate post-correction |
| #276 | canonical vs legacy finding | This decision was made against it |

## Operational deltas applied (none yet)

- No service restart required.
- No config rewrite required.
- No revert required.

## Cleanup deferred (Option A path) — opens later if needed

When (and only when) shadow-tap evolves into production routing,
the operator may reopen Option A. Until then, :8080 stays.

## Refs

ADR-018, ADR-043, INVARIANT I-32, IL-FA-02-EXEC (PR #88),
innovation-sandbox-roadmap-2026-05-11.md (PR #215),
PR #200, #205, #234, #238, #265, #269, #271, #273, #275, #276.
