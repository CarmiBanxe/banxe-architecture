# GitHub Webhook to Guardian Apps Deploy Runbook (Sprint S14.3)

Document ID: RB-GUARDIAN-WEBHOOK-2026-05-13
Status: SKELETON
Sprint: S14.3 (GitHub webhook delivery to Guardian apps — G-GUARDIAN-WEBHOOK-MISSING mitigation)
Layer: 2 (Product Plane runbook per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
HITL gate: REQUIRED — Central authoring; operator configures webhook in GitHub Settings UI + verifies Guardian endpoints on evo1; MLRO advisory (security boundary change — cross-host PR-event flow + webhook secrets).
Owner: Central per IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12; operator executes under HITL gate.
Last reviewed: 2026-05-13

## Anchors

- ADR-019 — AI Guardian two-family architecture (ACCEPTED locked 2026-05-03). §6.1 Factory Guardian (`banxe-guardian-factory.service` on evo1, controls HOW we build) + §6.2 Project Guardian (`banxe-guardian-project.service` on evo1, controls WHAT we build). §6.3 common core engine — `Inputs: GitHub webhooks (PR opened/synchronize/comment), Claude Code prompt logs, operator commands`. §6.3 outputs — GitHub status check `guardian/{factory|project}/<rule-id>`, PR comment, append-only ClickHouse row, auto-append GAP-REGISTER on override, auto-append INSTRUCTION-LEDGER on new instruction.
- ADR-027 — Audit-trail durability strategy. Guardian audit sinks `guardian_audit_factory` + `guardian_audit_project` (TTL 5y CASS 15 retention per ADR-019 §6.1/§6.2). Webhook ping/PR/push/check_run events sink to those tables; the deploy + rollback events of THIS runbook also sink there.
- ADR-029 — Postgres backup strategy. Cross-referenced for HTTPS certificate provisioning posture (TODO §EDGE CASES §2) — backup strategy reference, not direct dependency.
- ADR-033 — Alert routing strategy / ufw perimeter posture. Pre-flight verifies ufw allow rules for 8195/8196 inbound from GitHub webhook IP ranges (TODO §EDGE CASES §4).
- IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11 — defines Sprint S14.3 scope (webhook delivery to Guardian apps).
- IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12 — evo1 prod evidence (Tailscale 100.101.218.26 canonical per ADR-017 KC cutover; Guardian apps reuse same Tailscale routing).
- IL-OPS-S12-2-KC-SESSION-TIMEOUT-PREP-2026-05-13 — S12.2 PREP style sibling (runbook + template pattern).
- IL-OPS-S12-3-S2S-TOKENS-PREP-2026-05-13 — S12.3 PREP style sibling (runbook + template pattern; HITL gate language re-used).
- Style sibling: docs/project/runbooks/keycloak-session-timeout-deploy-2026-05-13.md (S12.2 PREP) and docs/project/runbooks/keycloak-s2s-tokens-deploy-2026-05-13.md (S12.3 PREP) — section ordering + HITL gate phrasing.

## Scope

Configure GitHub webhook delivery on the four CarmiBanxe repos in the S14.2 ENFORCE rollout (PR #176) so that PR / push / check_run / workflow_run events reach Guardian apps on evo1:

| Repo | Plane targets | Notes |
|------|---------------|-------|
| `CarmiBanxe/banxe-architecture` | factory + project Guardian | Central territory; this PR's home. |
| `CarmiBanxe/banxe-platform` | factory + project Guardian | EMI runtime + services. |
| `CarmiBanxe/banxe-payment-core` | factory + project Guardian | Payment rails (Hyperswitch surface). |
| `CarmiBanxe/banxe-infra` | factory + project Guardian | Infra-as-code + runbooks. |

This is a config-only change in GitHub Settings UI (operator-led) plus pre-flight verification of Guardian endpoints on evo1. It is NOT a Guardian app deploy (the apps themselves are out of scope; this runbook is gated on the apps already being reachable, fail-closed).

Pre-requisite for Sprint S14.2 (Guardian ENFORCE mode rollout, PR #176) — without webhook delivery, ENFORCE mode cannot validate PRs in real-time and falls back to post-merge audit via the pre-commit hook only. G-GUARDIAN-WEBHOOK-MISSING CLOSED at first successful PR-event-receive on Guardian per repo.

### Guardian endpoint inventory

| Endpoint | Plane | systemd unit (ADR-019) | Audit sink (ADR-027) |
|----------|-------|------------------------|----------------------|
| `https://evo1.<tailnet>:8195/webhook/github` | Factory Guardian | `banxe-guardian-factory.service` | ClickHouse `guardian_audit_factory` (TTL 5y) |
| `https://evo1.<tailnet>:8196/webhook/github` | Project Guardian | `banxe-guardian-project.service` | ClickHouse `guardian_audit_project` (TTL 5y) |

Port assignment 8195 (factory) / 8196 (project) is the brief target; ADR-019 body does NOT pin exact port numbers (TODO §EDGE CASES §1 — confirm against the Guardian app deploy artefact before operator configures the webhook). Both endpoints are reachable only over Tailscale (canonical 100.101.218.26 per ADR-017); GitHub webhook delivery reaches the host via the Tailscale-fronted DNS name (operator's tailnet).

## Pre-flight (NOT executed in this PR — operator-only under HITL gate)

1. Verify Guardian apps reachable on evo1 (fail-closed; abort if either fails):
   ```
   curl -sS https://evo1.<tailnet>:8195/health
   curl -sS https://evo1.<tailnet>:8196/health
   ```
   Expected: HTTP 200 + canonical health payload per ADR-019 §6.3 (service name + plane + ruleset version). Abort if either endpoint returns non-200 or TLS handshake fails.

2. Generate per-repo webhook secret (one secret per repo, shared across the factory + project entries for that repo):
   ```
   openssl rand -hex 32
   ```
   Store in operator vault under canonical key naming `GUARDIAN_WEBHOOK_SECRET_<REPO_SLUG>` (see D2 template). **NEVER commit the value to any repo, log line, or IL entry.** The 32-byte (64-hex) length matches GitHub's recommended HMAC-SHA256 secret strength.

3. Verify GitHub repo admin access for each of the four target repos:
   ```
   gh api repos/CarmiBanxe/<repo>/hooks --jq '. | length'
   ```
   Expected: command succeeds (operator PAT or OAuth has `repo:admin` scope). Capture the existing hook count for the rollback baseline.

4. Verify GitHub webhook IP ranges allowed on evo1 firewall per ADR-033:
   ```
   curl -sS https://api.github.com/meta | jq '.hooks'
   ```
   Cross-check each CIDR is in the evo1 ufw allow-list for inbound 8195 + 8196. TODO operator confirms ufw rules via `ssh evo1 sudo ufw status numbered` (read-only; do NOT mutate ufw under this runbook — that mutation is owned by ADR-033 / Sprint S14.x ufw runbook).

5. Confirm no in-flight Guardian app redeploy or ClickHouse audit-table maintenance window. Coordinate with operator + MLRO advisory.

## Deploy steps (NOT executed in this PR — operator-led under HITL gate)

Per repo (order: banxe-architecture first as smoke-test target, then banxe-platform, banxe-payment-core, banxe-infra):

1. GitHub repo → Settings → Webhooks → Add webhook (FACTORY entry):
   - Payload URL: `https://evo1.<tailnet>:8195/webhook/github`
   - Content type: `application/json`
   - Secret: paste `GUARDIAN_WEBHOOK_SECRET_<REPO_SLUG>` from operator vault.
   - SSL verification: **Enabled** (production). If the Guardian app is fronted by a self-signed certificate during initial bring-up, see EDGE CASES §2 — short-lived disable allowed in dev only under explicit IL log entry; production MUST verify.
   - Events: **Let me select individual events** → Pull requests, Pushes, Check runs, Workflow runs (these cover the Guardian rulesets per ADR-019 §6.3 inputs).
   - Active: true.

2. GitHub repo → Settings → Webhooks → Add webhook (PROJECT entry, identical configuration except payload URL `:8196`):
   - Payload URL: `https://evo1.<tailnet>:8196/webhook/github`
   - All other fields identical to step 1.

3. Click **Add webhook** for each. GitHub sends a `ping` event immediately upon save.

4. Verify Guardian receives ping (factory side):
   ```
   ssh evo1 sudo journalctl -u banxe-guardian-factory.service -n 50 --since "5 min ago"
   ```
   Expected: `ping received from <repo_full_name>` + 200 ack. Abort + delete webhook if ping fails (X-Hub-Signature-256 mismatch = wrong secret pasted; 404 = wrong path; 5xx = Guardian internal error).

5. Verify Guardian receives ping (project side) — same as step 4 against `banxe-guardian-project.service` on :8196.

6. Smoke-test full PR event flow (operator opens a trivial doc PR on the target repo + closes it):
   - On factory Guardian log: `PR opened` event with payload signature validated + 200 ack + ClickHouse `guardian_audit_factory` row appended.
   - On project Guardian log: same `PR opened` event.
   - On PR close: `PR closed` event mirrored on both planes.

7. Log deploy event to INSTRUCTION-LEDGER.md per repo: timestamp + operator co-sign + repo + GitHub webhook id (factory + project) + IL anchor. **NEVER log the webhook secret value.**

## HITL gate

Required parties before any webhook entry is created in GitHub Settings UI:
- **Central** (this runbook + IL pairing — authoring authority).
- **Operator** (execution authority on GitHub Settings UI + evo1 verification; only the operator creates the webhook entries).
- **MLRO advisory** (security boundary change — webhook secrets land in operator vault + cross-host PR-event flow over Tailscale; auth-surface adjacent because Guardian audit feeds compliance evidence chain per ADR-027). Advisory, not blocking.

No EMERGENCY override permitted. Webhook config change without operator co-sign = P0 governance incident (CLAUDE.md §11 production-state mutation gate). Webhook secret leak into a commit/log/IL = P0 secret-leak incident (rotate immediately, vault entry invalidated, all four repo webhooks rotated in lockstep).

## Rollback (NOT executed in this PR — operator-led)

1. GitHub repo → Settings → Webhooks → click the offending webhook entry → **Delete webhook**. Repeat for factory + project entries on the affected repo.
2. Verify Guardian stops receiving events from that repo:
   ```
   ssh evo1 sudo journalctl -u banxe-guardian-factory.service --since "5 min ago" | grep <repo_full_name>
   ```
   Expected: no new events within 5 min after a typical PR action on the affected repo.
3. Invalidate the vault secret entry (`GUARDIAN_WEBHOOK_SECRET_<REPO_SLUG>`) per operator vault rotation procedure.
4. Log rollback event to INSTRUCTION-LEDGER.md (timestamp + operator co-sign + repo + reason).

If Guardian continues to receive events after deletion (unexpected): treat as evidence-integrity incident — operator escalates to Central + MLRO; check for stale GitHub Apps installation or duplicate webhook entries.

## Audit trail

Webhook ping + PR + push + check_run + workflow_run events MUST be logged to ClickHouse Guardian (`guardian_audit_factory` + `guardian_audit_project`) per ADR-027 §Decision drivers — durable evidence chain, 5 y FCA CASS 15 retention (matches ADR-019 §6.1 / §6.2 TTL spec). Event payload includes GitHub delivery id, repo full name, event type, X-Hub-Signature-256 validation outcome, rule-id verdicts, IL anchor (if Guardian auto-appends per ADR-019 §6.3).

If ClickHouse Guardian write fails at event receive time, Guardian SHOULD return 5xx so GitHub retries per webhook redelivery policy (silent audit drop = compliance incident per ADR-027 §Context). The deploy + rollback IL entries from THIS runbook also sink to the same Guardian audit tables.

**Webhook secret values MUST NEVER appear in any audit payload, log line, or IL entry.**

## Validation script (follow-up)

TODO follow-up artefact: `docs/project/runbooks/github-webhook-validate.sh` — automated wrapper that (a) lists webhook entries per repo via `gh api repos/<owner>/<repo>/hooks`, (b) curls Guardian `/health` on 8195 + 8196, (c) counts ClickHouse `guardian_audit_*` rows received in the last N hours per repo. Out of scope for this PREP package (S14.3 PREP is repo-only documentation + template). Owner queued under D3.x follow-up sprint.

## TODO list (open for operator action under HITL gate)

- TODO confirm Guardian app port assignment (8195 factory / 8196 project) against the Guardian app deploy artefact before operator configures webhook entries — ADR-019 body does NOT pin exact port numbers (EDGE CASES §1).
- TODO HTTPS cert provisioning decision per EDGE CASES §2 (self-signed vs CA-issued); document risk acceptance if dev-only PIN/disable used.
- TODO confirm ufw allow rules for inbound 8195 / 8196 from GitHub webhook IP ranges per ADR-033 (EDGE CASES §4); cross-link to Sprint S14.x ufw runbook once landed.
- TODO landing of `docs/project/runbooks/github-webhook-validate.sh` (D3.x follow-up validation script).
- TODO operator vault entry naming convention review (`GUARDIAN_WEBHOOK_SECRET_<REPO_SLUG>` — uppercase slug with underscores; D2 template fixes one convention).
- TODO confirm GitHub webhook event selection (PR + Push + Check_run + Workflow_run) against Guardian ruleset inputs once Guardian apps deployed; broaden to "Send me everything" only if explicitly required by a rule (avoid noise on the ClickHouse audit tables).

## EDGE CASES

### §1 — ADR-019 port assignment

ADR-019 §6.1 / §6.2 names the systemd units (`banxe-guardian-factory.service`, `banxe-guardian-project.service`) but does NOT pin exact TCP ports. The brief target (8195 factory / 8196 project) is the convention used here and in the D2 template; before operator configures the webhook entries, the actual ports MUST be confirmed by reading the Guardian app deploy artefact (systemd unit `ExecStart` or service config). If the deployed ports differ, update this runbook + D2 template in a follow-up PR before operator action.

### §2 — HTTPS cert provisioning

Production webhook entries require SSL verification ENABLED (GitHub default). Two cert provisioning paths:

- CA-issued (preferred for prod) — Let's Encrypt / internal CA covering the Tailscale-fronted DNS name. Guardian apps front via standard TLS terminator. No GitHub webhook config change needed.
- Self-signed (dev only) — Guardian fronts with a self-signed cert. GitHub webhook SSL verification must be DISABLED for that webhook entry. Risk: MITM possible on the path between GitHub egress and the operator's tailnet ingress (mitigated by HMAC-SHA256 signature on the payload — secret compromise still required to spoof, but TLS no longer prevents passive read of payload). Document risk acceptance in IL deploy event entry if used; production MUST upgrade to CA-issued before G-GUARDIAN-WEBHOOK-MISSING is marked CLOSED.

Cross-reference ADR-029 for backup-strategy adjacent cert handling (not a direct dependency).

### §3 — Repo not yet onboarded to S14.2

If one of the four target repos has not yet been onboarded to the S14.2 ENFORCE rollout (PR #176 still pending merge for that repo), the webhook entries can still be created — Guardian will log the events but not BLOCK PR status checks. Effectively shadow mode. Mark the D2 template row for any such repo with `_shadowMode: true` placeholder + document in deploy event IL entry. Default in this PREP package: defer the webhook config for any repo not yet at ENFORCE-ready state (avoids dangling webhook entries with no observable BLOCK behaviour).

### §4 — ufw allow rules for 8195/8196

GitHub webhook delivery originates from a published CIDR set (`curl https://api.github.com/meta | jq .hooks`). ADR-033 perimeter posture requires explicit ufw allow rules per inbound port + source CIDR. Pre-flight step 4 reads the current ufw config; if any GitHub webhook CIDR is missing from the allow-list for 8195 or 8196, STOP and route the ufw change through the Sprint S14.x ufw runbook (not yet on main; TODO cross-link once landed). Do NOT mutate ufw rules under THIS runbook — bounded context.

## Anchors footer

- ADR-019 (decisions/ADR-019-ai-guardian-two-family.md)
- ADR-027 (decisions/ADR-027-audit-trail-durability.md)
- ADR-029 (decisions/ADR-029-postgres-backup-strategy.md)
- ADR-033 (decisions/ADR-033-alert-routing-strategy.md)
- Sprint S14.3 (this runbook), Sprint S14.2 (Guardian ENFORCE rollout PR #176, downstream)
- G-GUARDIAN-WEBHOOK-MISSING (CLOSED at first successful PR-event-receive on Guardian per repo)
- IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11
- IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12
- IL-OPS-S12-2-KC-SESSION-TIMEOUT-PREP-2026-05-13
- IL-OPS-S12-3-S2S-TOKENS-PREP-2026-05-13
- IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12
- IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12
- IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12
- IL-CANON-PERSISTENCE-SHELL-FIXATION-2026-05-12
- IL-CANON-F01-REINFORCE-ALWAYS-ONE-ACTIONABLE-2026-05-12
