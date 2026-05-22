# ADR-077 — Guardian -> GitHub webhook auth: GitHub App vs Personal Access Token

**Status:** ACCEPTED (Central decision; binding for S14.3 implementation)
**Date:** 2026-05-22
**Snapshot:** main HEAD 82da79b
**Author:** Central (Perplexity); reviewed by operator in-session
**Related:** docs/runbooks/R3-S14_3-GUARDIAN-GITHUB-WEBHOOK-DISCOVERY-2026-05-22.md (Section 4, 5, 7); IL-OPS-V2-ONE-PAGER-MERGED-MAIN-2026-05-22 (line 8792); S17 secrets rotation policy (90-day cadence)

## Context

Guardian on evo1 must post two required status checks ("guardian-factory" and "guardian-project") to the GitHub Checks/Statuses API on every commit pushed to CarmiBanxe/banxe-architecture. These contexts are mandatory under main branch protection (strict=true, enforce_admins=false), but they cannot report today because Guardian has no authenticated path to GitHub. Two credible auth options exist: a GitHub App with a long-lived private key minting short-lived installation tokens, or a Personal Access Token (PAT) held by a human owner. The cost of leaving this open is already visible: this session merged eight admin-bypass PRs (PR #294, #296–#302) under the temporary Part A canon exception, because no other merge path exists until the webhook is live.

## Decision

Default: **GitHub App**. Guardian on evo1 will authenticate to the GitHub Checks/Statuses API via a GitHub App installed on the CarmiBanxe organisation, with the private key stored on evo1 and short-lived installation tokens minted on demand. The justification is repo-internal, not abstract best practice:

- Posting targets — App scales with the factory expansion path:
  - Today, exactly one repo receives status posts: CarmiBanxe/banxe-architecture.
  - Software Factory Canon v1.0 (line 8735) anticipates additional factory-* repos under the same organisation.
  - App installation scopes extend to N repos with one declared installation; a PAT requires either a single human's scope coverage or one PAT per repo, both worse.
- Posting services — two services share one identity cleanly:
  - factory-instance :8195 (Guardian factory) and project-instance :8196 (Guardian project) both run on evo1 today.
  - App auth lets both services share one installation while each posts under its own context label ("guardian-factory" vs "guardian-project").
  - A single PAT collapses that distinction in the audit log because both posts appear under the same human identity.
- Secret-rotation cadence — App separates long-lived key from short-lived tokens:
  - S17 mandates a 90-day rotation cadence for production credentials.
  - A PAT is a single secret that must be regenerated and re-distributed every 90 days.
  - An App rotates by minting fresh installation tokens (~1h TTL) from the same private key on every call; only the private key itself falls under S17 manual rotation, and it can sit unused in cold storage between rotations.
- Audit trail — App posts are bot-identified:
  - App posts appear as a bot user in the GitHub audit log, which is what an operator wants when reviewing who-did-what.
  - PAT posts appear as the human owner of the token, which conflates service activity with human activity and complicates incident response.
- Failure mode under credential leak — App limits blast radius:
  - A PAT leak exposes everything the owning human can do across all their repos, organisations, and personal scopes.
  - An App private-key leak is limited to the App's declared scopes on the installed organisation; revocation is a single installation-level action.

UNKNOWN — operator confirmation required: whether the operator already has a Guardian PAT in production use on evo1 today.

- If yes: migration cost may justify a documented PAT-with-S17-rotation deployment as a stepping stone, with an explicit App-migration plan as a follow-up ADR.
- If unknown or no: ship the App auth directly per the default above.

## Consequences

- S14.3 implementation must use the chosen auth.
  - Default path: GitHub App, installed on the CarmiBanxe organisation, scoped to banxe-architecture initially.
  - PAT fallback path: only with operator confirmation of pre-existing production use, plus a follow-up App-migration ADR before the next S17 rotation cycle closes.
- Secret storage on evo1 follows Universal Canon Section 7.
  - The App private key (or, in the PAT fallback, the PAT itself) lives under /etc/guardian/.env with mode 600.
  - The file is owned by the Guardian service user and loaded via systemd EnvironmentFile.
  - Never in repo, never in INSTRUCTION-LEDGER.md, never in a PR body, never in a commit message.
- S17 rotation policy applies on a 90-day cadence.
  - For the App: rotate the private key every 90 days; installation tokens rotate transparently per call.
  - For the PAT fallback: rotate the PAT itself every 90 days.
  - Each rotation is paired with an IL entry naming the rotated identity (not its value).
- Required GitHub permissions are the minimal set.
  - For the App: `checks:write` only.
  - For the PAT fallback: `repo:status` only.
  - Anything broader is rejected at PR review by the Auditor (Spec-First Auditor v2).
- Implementation PR for S14.3 must include the two-layer documentation companion required by IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12.
- Reversibility — this ADR is revisable. Triggers for revisitation:
  - (a) Guardian must post to more than five repos (favours App if PAT was the initial choice).
  - (b) App provisioning friction blocks the S14.3 timeline (justifies temporary PAT with an explicit migration plan).
  - (c) GitHub changes installation-token semantics in a way that invalidates the rotation story.

## Rejected alternatives

- SSH-key auth — rejected: the GitHub Statuses API is HTTP-only and does not accept SSH credentials; SSH is for git protocol, not REST.
- Anonymous webhook signed by HMAC only — rejected: GitHub requires an authenticated identity to write statuses; HMAC alone cannot satisfy the write-side authentication.
- User OAuth flow — rejected: each rotation would require interactive user consent in a browser, which is unfit for an unattended service running on evo1.

## Open questions

- Does the operator already have a Guardian PAT in production use on evo1 today? Owner: operator.
- Does Guardian source on evo1 already contain a code path for posting to GitHub, and if so, what auth shape does it expect? Owner: Sub-B (read-only inspection of Guardian source on evo1).
- Will Guardian eventually post to factory-* repos as Software Factory Canon v1.0 expands? Owner: Central.

## References

- docs/runbooks/R3-S14_3-GUARDIAN-GITHUB-WEBHOOK-DISCOVERY-2026-05-22.md (Sections 4 "Inputs to discover", 5 "Minimum viable design", 7 "Open questions and UNKNOWN list")
- docs/canon/UNIVERSAL-CANON-2026-05-22.md (Section 7 — secrets rules)
- IL-OPS-V2-ONE-PAGER-MERGED-MAIN-2026-05-22 (line 8792) — records the systemic Guardian webhook gap that this ADR's implementation closes
- S17 secrets rotation policy (90-day cadence)
- Branch protection on main: required_status_checks_contexts = ["guardian-factory", "guardian-project"]; strict = true; enforce_admins = false

=== END OF ADR-077 (snapshot 82da79b) ===
