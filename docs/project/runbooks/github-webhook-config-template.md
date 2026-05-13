# GitHub Webhook Config Template (Sprint S14.3 PREP)

Document ID: TPL-GUARDIAN-WEBHOOK-2026-05-13
Status: SKELETON (placeholders only; operator fills tailnet name + vault entries at deploy time under HITL gate)
Sprint: S14.3 (companion to docs/project/runbooks/github-webhook-guardian-deploy-2026-05-13.md)
Layer: 2 (Product Plane template per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Owner: Central per IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12; operator fills + applies under HITL gate.
Last reviewed: 2026-05-13

## Anchors

- ADR-019 — AI Guardian two-family architecture (factory + project; §6.3 webhook inputs).
- ADR-027 — Audit-trail durability (5 y CASS 15 retention; `guardian_audit_factory` + `guardian_audit_project`).
- Sprint S14.3 (this template), Sprint S14.2 (Guardian ENFORCE rollout, PR #176, downstream).
- IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11.
- Companion runbook: docs/project/runbooks/github-webhook-guardian-deploy-2026-05-13.md.

## Per-repo webhook entries (4 repos × 2 entries = 8 webhooks total)

Placeholders:
- `<TAILNET>` — operator's Tailscale tailnet DNS suffix (e.g. `tail-xxxxx.ts.net`). One value for all entries.
- `GUARDIAN_WEBHOOK_SECRET_<REPO_SLUG>` — operator vault key name (value generated per repo via `openssl rand -hex 32`; NEVER committed).

| Repo | Webhook URL (factory) | Webhook URL (project) | Secret env var (vault key) | Events | SSL verification |
|------|-----------------------|-----------------------|----------------------------|--------|------------------|
| `CarmiBanxe/banxe-architecture` | `https://evo1.<TAILNET>:8195/webhook/github` | `https://evo1.<TAILNET>:8196/webhook/github` | `GUARDIAN_WEBHOOK_SECRET_BANXE_ARCHITECTURE` | Pull requests, Pushes, Check runs, Workflow runs | Enabled |
| `CarmiBanxe/banxe-platform` | `https://evo1.<TAILNET>:8195/webhook/github` | `https://evo1.<TAILNET>:8196/webhook/github` | `GUARDIAN_WEBHOOK_SECRET_BANXE_PLATFORM` | Pull requests, Pushes, Check runs, Workflow runs | Enabled |
| `CarmiBanxe/banxe-payment-core` | `https://evo1.<TAILNET>:8195/webhook/github` | `https://evo1.<TAILNET>:8196/webhook/github` | `GUARDIAN_WEBHOOK_SECRET_BANXE_PAYMENT_CORE` | Pull requests, Pushes, Check runs, Workflow runs | Enabled |
| `CarmiBanxe/banxe-infra` | `https://evo1.<TAILNET>:8195/webhook/github` | `https://evo1.<TAILNET>:8196/webhook/github` | `GUARDIAN_WEBHOOK_SECRET_BANXE_INFRA` | Pull requests, Pushes, Check runs, Workflow runs | Enabled |

Common configuration for every entry:
- Content type: `application/json`
- Active: `true`
- Payload format: GitHub default (no transform)
- Signature header consumed by Guardian: `X-Hub-Signature-256` (HMAC-SHA256 of payload using the vault secret)

## Secret generation (per repo, operator-only)

```
openssl rand -hex 32
```

Output is a 64-character hexadecimal string (32 random bytes). Store under the vault key listed in the table above. ONE secret per repo; the same secret is used for both the factory entry and the project entry on that repo (two webhook entries, one shared secret per repo). Vault entry key convention: `GUARDIAN_WEBHOOK_SECRET_<REPO_SLUG>` where `<REPO_SLUG>` is the uppercase repo basename with underscores replacing hyphens (see table). **NEVER commit the value to any repo, log line, or IL entry.**

## GitHub UI step list (per repo, repeat 4×)

1. Open the repo on github.com → Settings → Webhooks → **Add webhook**.
2. **Payload URL**: paste the factory URL from the table for this repo (`:8195`).
3. **Content type**: `application/json`.
4. **Secret**: paste the value of the vault entry named in the table.
5. **SSL verification**: leave **Enabled** (production default). Disable ONLY in dev with explicit IL risk-acceptance entry — see runbook EDGE CASES §2.
6. **Which events would you like to trigger this webhook?** → select **Let me select individual events** → tick **Pull requests**, **Pushes**, **Check runs**, **Workflow runs**.
7. **Active**: ticked.
8. Click **Add webhook**. GitHub sends a `ping` event immediately; verify on factory Guardian per runbook deploy step 4.
9. Repeat steps 1–8 for the PROJECT entry, this time pasting the `:8196` URL from the table. Same secret value, same events, same SSL setting.
10. Screenshots TODO (D3.x follow-up — annotated screenshots of GitHub UI per step).

## Webhook payload signature verification

Guardian endpoints (both factory and project) MUST validate the `X-Hub-Signature-256` header on every incoming request:
- Compute HMAC-SHA256 of the raw request body using the per-repo secret retrieved from the vault.
- Compare in constant time against the value provided in `X-Hub-Signature-256` (format: `sha256=<hex>`).
- On mismatch: return HTTP 401, audit log the rejection with delivery id + repo + plane, do NOT process the payload.
- On match: process the event per ADR-019 §6.3 inputs and append to the relevant ClickHouse audit table per ADR-027.

The same validation logic runs on both planes against the same shared secret; only the audit sink (`guardian_audit_factory` vs `guardian_audit_project`) differs.

## Anchors footer

- ADR-019 (decisions/ADR-019-ai-guardian-two-family.md)
- ADR-027 (decisions/ADR-027-audit-trail-durability.md)
- Sprint S14.3, Sprint S14.2 (downstream)
- G-GUARDIAN-WEBHOOK-MISSING
- IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11
- IL-OPS-S12-2-KC-SESSION-TIMEOUT-PREP-2026-05-13
- IL-OPS-S12-3-S2S-TOKENS-PREP-2026-05-13
- Companion runbook: docs/project/runbooks/github-webhook-guardian-deploy-2026-05-13.md
- IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12
- IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12
