# Canonical vs Legacy LiteLLM — Finding 2026-05-13

Document ID: FINDING-LITELLM-CANONICAL-CONFUSION-2026-05-13
Trigger: operator-provided git-grep evidence at 23:00 CEST showing
extensive FA-1/FA-2 history, ADR-043 Aider routes, I-32 invariant.

## What I had assumed (incorrect)

- canonical LiteLLM = :8080 (litellm.service, ~/litellm-config.yaml)
- :4000 (litellm-v2.service, ~/MetaClaw/litellm/litellm-config.v2.yaml)
  was a "legacy MetaClaw LAN gateway" closed as A-8 in PR #200
- factory-fast / factory-mid / factory-heavy / factory-coder /
  project-reason were missing and added by me today via PR #273
  to :8080

## What is actually canonical (operator-supplied evidence)

- ADR-018 + INVARIANT I-32 define canonical = LiteLLM v2 on
  http://legion:4000/v1 (litellm-v2.service)
- ADR-043 (Aider/Continue Routes) wires ai/ai-heavy/reasoning to
  :4000 already, ACCEPTED
- FA-1 PR #80 (2026-05-06) added factory-fast on :4000 with the
  Legion local coder model qwen2.5-coder:14b-banxe-factory, live
- IL-FA-02-EXEC PR #88 (2026-05-06) added factory-mid / heavy /
  coder / project-reason on :4000 — already canonical
- IL-OPS-G-FACTORY-LITELLM-DUPLICATE-2026-05-06 explicitly resolved
  duplicate systemd units in favor of litellm-v2.service on :4000

## What :8080 actually is

- "legacy / undocumented parallel instance" per
  INSTRUCTION-LEDGER.md line 5515 (PID 339, 1d18h, config
  ~/litellm-config.yaml) at the time of that ledger entry
- I extended :8080 today via PR #200, #205, #234, #238, #265, #273
  — this is work in the legacy contour, not in canonical

## Impact assessment

- Production agents (Claude Code via Guardian shim, Aider per
  ADR-043, OpenClaw gateways) ALREADY use :4000 / Tailscale
  100.101.218.26:4000. They are NOT broken by my :8080 activity.
- Shadow tap classifier and Condition D ClickHouse sink wired to
  :8080 → only my sandbox traffic flows through it. Zero
  production traffic logged in audit sink yet (only my smoke
  tests). No FCA / regulated decisions were affected.
- A-8 mitigation (PR #269) bound :4000 to 127.0.0.1 — this is
  consistent with canon (gateway-on-Legion-only); no harm.

## Correct remediation (operator decision)

Three options, in order of effort:

A. Decommission :8080 entirely.
   - Stop litellm.service.
   - Move shadow tap + Condition D wiring onto canonical :4000.
   - Re-record HITL-ASK trail on the canonical contour.
   - Removes regression GAP outright.

B. Keep :8080 as "sandbox-only" forever, narrow its scope.
   - Document :8080 as the Innovation Sandbox endpoint only
     (per innovation-sandbox-roadmap-2026-05-11.md scope).
   - Add an explicit invariant: production routes go through
     :4000 only.
   - Don't add any more aliases to :8080.

C. Make :8080 the new canonical, retire :4000.
   - Requires ADR amendment to ADR-018 + I-32.
   - Migrate ADR-043 Aider routes to :8080.
   - Migrate OpenClaw gateway pinning (PA-6) to :8080.
   - Highest blast radius; NOT recommended.

## Recommendation

Option B as immediate stance, document boundary clearly, no
production-wide change tonight. Option A as planned cleanup once
shadow tap is no longer needed.

## My today's PRs that need re-classification

- PR #200 — A-8 MetaClaw "resolution". Should be amended: A-8 was
  already resolved by IL-OPS-G-FACTORY-LITELLM-DUPLICATE-2026-05-06.
  My PR #200 actually re-defined :8080 as canonical, which was a
  premise error.
- PR #265 — Shadow tap LIVE on :8080. Valid as sandbox artefact.
- PR #269 — A-8 regression on :4000. Misnamed: there was no
  regression; :4000 is canonical. The 0.0.0.0 bind change to
  127.0.0.1 is still a security improvement, kept.
- PR #271 — AI agent inventory. Needs amendment to flip
  canonical/legacy labels.
- PR #273 — factory→evo2 235B routes on :8080. Duplicates FA-2
  PR #88 on :4000. Sandbox value only; not canon.
- PR #275 — orchestration audit. Needs same canonical/legacy flip.

## Operator action required

1. Pick A / B / C above.
2. Authorise amendments to the affected PRs (re-classification
   docs, not reverts).
3. Decide whether to fold today's sandbox work into canonical
   :4000 (option A) or keep them parallel (option B).

Refs: ADR-018, ADR-043, INVARIANT I-32, INSTRUCTION-LEDGER.md
lines 3735-3768 (IL-FA-02-EXEC), lines 3884-3896
(IL-OPS-G-FACTORY-LITELLM-DUPLICATE), lines 5514-5515 (legacy
:8080 finding), today's PRs #200 #205 #234 #238 #265 #269 #271
#273 #275.
