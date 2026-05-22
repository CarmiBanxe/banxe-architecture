# R3 / S14.3 — Guardian -> GitHub webhook discovery

- Snapshot date: 2026-05-22
- main HEAD: 388ef23
- Status: REFERENCE (discovery, not binding)
- Owner: Central + Sub-B

## Purpose

This document explains WHY a Guardian -> GitHub webhook (S14.3 within R3
Observability foundation) is needed and WHAT must be in place before any
implementation work begins. Today every PR into main blocks on two required
status checks ("guardian-factory" and "guardian-project") which physically
cannot report, so the only merge path is documented admin-bypass. This
discovery captures the minimum design, the inputs that must be resolved,
the risks, and the acceptance criteria. No infrastructure is touched by
this document; it is a hand-off package for a follow-up implementation
sprint or for Sub-B.

---

## 1. Problem statement

### Current behaviour

- main branch protection requires two status check contexts on the head
  commit: guardian-factory and guardian-project, with strict=true.
- Neither context ever appears in `gh pr view --json statusCheckRollup`
  because Guardian on evo1 has no path that posts to GitHub Checks or
  Statuses API.
- Result: every PR into main is in BLOCKED state until a human applies
  documented admin-bypass (enforce_admins=false makes this policy-allowed).

### Evidence in repo

- docs/project/CANON-TRANSFER-PACKAGE-2026-05-22.md, section
  "Pipeline / branch protection reality".
- INSTRUCTION-LEDGER.md entry IL-OPS-V2-ONE-PAGER-MERGED-MAIN-2026-05-22
  (PR #297) records the systemic gap and the rationale for admin-bypass.
- Bypass precedents this session: PR #294 (--no-verify), PR #296 (--admin),
  PR #297 (--admin), PR #298 (--admin).

### Cost of the gap

- Repeated admin-bypass erodes the meaning of branch protection.
- Audit trail is filling up with --admin and --no-verify justifications for
  docs-only PRs that should have ridden a green pipeline.
- Future code PRs (from Sub-B and Terminal A) will hit the same wall, and
  unlike docs-only PRs they will NOT be safe to admin-bypass — code paths
  require the verdict.

---

## 2. Required outcome

Every PR (including pushes that update the merge base) must produce two
status check results on the head commit:

- context "guardian-factory" — verdict from the Guardian factory instance
  reachable at evo1:8195.
- context "guardian-project" — verdict from the Guardian project instance
  reachable at evo1:8196.

State must be one of {success, failure, pending}, mapped from the
Guardian-side verdict for the commit. The status target_url should point
to a Guardian audit page; if no UI exists, it should resolve to a
structured log entry id (for example a ClickHouse query link or a row id
in guardian_audit_events on evo1).

---

## 3. Inputs to discover

Each item below must be resolved before implementation begins. Items
marked UNKNOWN have a candidate discovery action that is NOT to be
executed from this document.

### Guardian-side

- Verdict source per commit / per PR: guardian_audit_events on evo1 is the
  known sink; ruflo_checkpoints (TTL-5y, ADR-027) is the new long-term
  table. UNKNOWN: exact schema of the row that holds a per-commit verdict;
  Sub-B to inspect on evo1 (read-only).
- HTTP endpoint exposing the verdict by SHA: UNKNOWN — discovery required.
  If Guardian already exposes `/verdict/<sha>` or similar, the webhook is
  a thin caller; if not, the minimal addition is a single read endpoint
  returning {state, description, target_url}.
- Outbound network egress from evo1 to api.github.com: UNKNOWN — discovery
  required. Probe must happen under a controlled change window from a
  Tailscale-attached host; not executed by this document.

### GitHub-side

- Identity that owns the status posts: GitHub App vs PAT. UNKNOWN —
  Central decision required before implementation begins.
- Minimum scopes: `repo:status` for a PAT, or `checks:write` for a GitHub
  App. App is preferred for installation-scoped rate limits and finer
  audit trail; PAT is faster to bootstrap.
- Secret storage: must NOT live in the repo or any IL entry. Suggested
  location is /etc/guardian/.env with mode 600, owned by the Guardian
  service user, loaded via systemd EnvironmentFile. Rotation must follow
  S17 secrets rotation policy (90 days).

### Webhook direction

Two directions are possible; only one is mandatory.

- Direction A (GitHub -> Guardian): GitHub pings Guardian on PR open or
  push; Guardian then runs its audit and posts back. Useful as an event
  trigger but NOT required for the merge gate.
- Direction B (Guardian -> GitHub): Guardian, after its audit completes,
  pushes a status update to the GitHub Statuses or Checks API. This is
  the direction that resolves the current BLOCKED state.

Recommendation: implement Direction B first. For the MVP, replace
Direction A with a polling loop that calls
`gh api repos/CarmiBanxe/banxe-architecture/commits?since=...` (or a
similar ref-walk) at a fixed cadence. Direction A can be added later as
an optimisation.

---

## 4. Minimum viable design (MVP, not implementation)

### Trigger

- On every commit pushed to any branch of CarmiBanxe/banxe-architecture,
  Guardian factory and Guardian project each compute a verdict for that
  commit SHA.
- Verdict computation reuses the existing evaluate.sh / Canon Judge /
  ruff / pytest pipeline where applicable. No new verdict logic in the
  MVP.

### Delivery

- Guardian POSTs to
  `https://api.github.com/repos/CarmiBanxe/banxe-architecture/statuses/<sha>`
  with body `{state, target_url, description, context}` where context is
  one of `"guardian-factory"` or `"guardian-project"`.
- Auth: bearer token from /etc/guardian/.env, scope `checks:write` for a
  GitHub App or `repo:status` for a PAT.

### Idempotency

- For a given (sha, context), only the latest verdict is meaningful. The
  GitHub Statuses API overwrites the previous status for the same context
  automatically.
- Local idempotency record: either a small dedicated ClickHouse table or
  guardian_audit_events with kind="github_status_post" — discovery to
  pick one, see Section 7.

### Failure mode

- If Guardian cannot reach api.github.com, it logs to
  guardian_audit_events with kind="github_status_post_failed" plus a
  retry counter, and continues running locally. The GitHub side simply
  stays without a status until reachability returns.

### Observability

- Each post emits one row in guardian_audit_events with
  kind="github_status_post" and fields {sha, context, state, http_status,
  latency_ms}.
- These rows are the basis for a later R3 Prometheus exporter:
  - counter `guardian_github_status_post_total{context,state}`
  - histogram `guardian_github_status_post_latency_seconds`

---

## 5. Risks and constraints

- Security: the GitHub PAT or App private key must never enter the repo
  or any IL entry. Rotation follows S15.5 secret-rotation runbook and
  S17 90-day policy.
- Rate limits: GitHub Statuses API rate-limits at 5000 req/hour per PAT
  (separate per-installation for GitHub Apps). Guardian must throttle and
  deduplicate by (sha, context) so a burst of recomputations does not
  exhaust the budget.
- Coupling to evaluate.sh: if evaluate.sh is the verdict source, the
  pre-existing pytest and ruff failures will make every initial PR red.
  Before turning the check from advisory to enforce, build a quarantine
  list (allowlist of pre-existing failures) under R5 repo governance.
- Reversibility: the two status checks should be activated as
  non-blocking advisory first. They must NOT be added to branch
  protection until they have been observed green for at least one
  calendar week with the quarantine list closed.
- Drift from Canon: introducing webhook code triggers the two-layer
  documentation rule (IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12). The
  implementation PR must ship with a Layer-2 product runbook alongside
  this Layer-1 discovery document.

---

## 6. Acceptance criteria for "S14.3 + R3 webhook DONE"

- For at least three consecutive PRs into main:
  - guardian-factory and guardian-project both appear in
    statusCheckRollup.
  - mergeStateStatus = CLEAN (not BLOCKED) when other rules are
    satisfied.
  - admin-bypass is NOT used.
- guardian_audit_events on evo1 contains kind="github_status_post" rows
  for those three PRs, with http_status 201 or 200 and latency_ms
  recorded.
- One IL entry is added at the end of INSTRUCTION-LEDGER.md (in a
  follow-up PR, NOT in this discovery doc) named
  `IL-OPS-S14_3-R3-WEBHOOK-LIVE-<YYYY-MM-DD>` recording the activation
  date and linking back to this discovery document.
- Branch protection on main keeps required checks unchanged:
  guardian-factory, guardian-project, strict=true, enforce_admins=false.
  Flipping enforce_admins=true is OUT OF SCOPE for S14.3; it belongs to
  a later sprint, and only after a full calendar week of green status.

---

## 7. Open questions and UNKNOWN list

Each row is question + candidate discovery action (NOT executed by this
document) + target owner.

| # | Question | Candidate discovery action | Owner |
|---|----------|----------------------------|-------|
| 1 | Does Guardian factory expose a `/verdict/<sha>` endpoint, or any HTTP path that returns the verdict for a given SHA? | Sub-B inspects Guardian factory source on evo1 (read-only) and records the answer in a follow-up runbook. | Sub-B |
| 2 | Does Guardian project expose the same shape of endpoint? | Same as above, against the project instance on :8196. | Sub-B |
| 3 | Exact schema of the per-commit verdict row in guardian_audit_events and the relationship to ruflo_checkpoints. | Sub-B runs read-only `DESCRIBE TABLE` queries on evo1 ClickHouse and copies the schema into the follow-up runbook. | Sub-B |
| 4 | Does evo1 have outbound HTTPS egress to api.github.com? | Future curl probe from a Tailscale-attached host under a controlled change window. Do NOT run it from this document. | Operator |
| 5 | Will the GitHub identity be a GitHub App or a PAT? | Central decision; record as an ADR (preferred) or an IL entry before implementation begins. | Central |
| 6 | Where will the secret live in practice (path, ownership, systemd unit), and which rotation cadence applies? | Central drafts a small spec referencing S15.5 + S17; Sub-B implements it on evo1 only after the spec is approved. | Central + Sub-B |
| 7 | Should the local idempotency record be a dedicated ClickHouse table or guardian_audit_events with kind="github_status_post"? | Decision after Q3 is resolved (depends on existing schema). | Central |

---

## 8. Next steps (post-discovery, NOT to be executed by this document)

1. Central decides GitHub App vs PAT (Q5) and records the decision as an
   ADR or IL entry.
2. Sub-B inspects Guardian source on evo1 and answers Q1, Q2, Q3 by
   adding a small follow-up runbook under docs/runbooks/ that captures
   the verdict endpoint shape (or its absence) and the verdict row
   schema.
3. Operator runs the controlled egress probe (Q4) under a change window
   and records the result in the same follow-up runbook.
4. R5 repo governance builds the evaluate.sh quarantine list so that
   pre-existing pytest / ruff failures do not poison the very first
   status posts.
5. Implementation PR ships Direction B only (Guardian -> GitHub
   Statuses), wired as a non-blocking advisory check; it must include
   the Layer-2 product runbook required by
   IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12.
6. After three consecutive PRs satisfy Section 6 and one calendar week
   of green status has been observed, add the
   `IL-OPS-S14_3-R3-WEBHOOK-LIVE-<YYYY-MM-DD>` IL entry and consider
   Direction A (GitHub -> Guardian trigger) as a Sprint-22 enhancement.
7. R3 Prometheus exporter for the two metrics defined in Section 4 is a
   separate deliverable and follows the activation of the webhook, not
   the other way around.

---

## 9. References

- docs/project/CANON-TRANSFER-PACKAGE-2026-05-22.md (transfer package
  snapshot for main e2d2f09 / 388ef23 lineage).
- docs/project/R-TRACKS-V2-ONE-PAGER.md (R3 scope and R5 governance scope).
- docs/project/SPRINT-EXTENSION-LEGACY-REFACTOR-S12-S17.md (S14.3 PREP
  scope and R3 deferral rules).
- docs/project/DELTA-ANALYSIS-LEGACY-REFACTOR-vs-CURRENT-ROADMAP.md
  (R3 = NEW track, highest-priority recommendation).
- INSTRUCTION-LEDGER.md:
  - IL-OPS-V2-ONE-PAGER-MERGED-MAIN-2026-05-22 (systemic gap recorded).
  - IL-OPS-SPRINT-0-CH-PASSWORD-RESET-RUFLO-DDL-2026-05-22 (ruflo_checkpoints
    DDL and the audit-gap diagnosis that points at S14.3).
  - IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12 (two-layer doc rule that
    will apply to the implementation PR).
- ADR-027 (5-year CASS 15 audit retention; constrains the verdict-row
  retention story).
- S15.5 historical-leak runbook and S17 secrets-rotation policy (apply
  to the GitHub credential lifecycle).

=== END OF DISCOVERY (snapshot 388ef23) ===
