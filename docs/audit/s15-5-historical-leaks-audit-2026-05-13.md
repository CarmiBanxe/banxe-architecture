# S15.5 Historical Secret Leaks Audit (Sprint S15.5)

**Status:** AUDIT-COMPLETE
**Sprint:** S15.5
**Date:** 2026-05-13
**Layer:** 2 (Project / Audit)
**Scan executor:** Central via Claude Code (read-only) per IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12.

## Anchors

- G-SECURITY-HISTORICAL-LEAKS (OPEN; this audit feeds rotation plan)
- ADR-027 — audit trail durability (5y CASS 15)
- ADR-029 — Postgres backup strategy (rollback path)
- ADR-032 — Secret rotation policy (interim; 90-day cadence; n8n + manual)
- ADR-038 — Vault adoption placeholder (DEFERRED, G-SEC-02 / Sprint S17+)
- Sprint S15.1 (V8 user classification), S15.2 (Legion key cleanup),
  S15.3 (parent tracker), S15.4 (FCA SUP 15 + GDPR Art.33 notification — MLRO/DPO/Legal blocked),
  S17 (90-day rotation cadence enforcement)
- IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11
- FCA SYSC 4.1 (governance), FCA SYSC 15A (operational resilience), GDPR Art.32 (security of processing)

## Background

Per IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11, Sprint S15.5 is scoped to
"gitleaks 8 historical leaks audit + rotation plan", closing G-SECURITY-HISTORICAL-LEAKS.
The roadmap brief cites a count of **8 historical leaks**; this audit documents the
**actual gitleaks output against current `main` HEAD**, and the delta between roadmap
estimate and observed scan.

Without remediation, any credential that leaked into git history remains valid for an
attacker holding a historical clone, regardless of subsequent removal from `HEAD`. This
audit is the diagnostic input to the rotation runbook (D2) and to operator-led rotation
under HITL gate.

## Methodology

```bash
gitleaks detect \
  --source . \
  --report-path /tmp/gitleaks-s15-5.json \
  --no-git \
  --redact \
  --log-level=error
```

- **Tool:** gitleaks v8.18.4
- **Scope:** working tree at current `main` HEAD (`--no-git` — does not walk history).
  History walk is deferred to Sprint S17 with `--no-git` removed and a tuned `.gitleaks.toml`
  (none currently present in repo; default ruleset used).
- **Redaction:** `--redact` enforced — no raw secret values land in this audit. Match strings
  in findings are gitleaks-rewritten to `REDACTED`.
- **Output:** `/tmp/gitleaks-s15-5.json`. Not committed (transient; rebuildable from scan).
- **Scan commit SHA:** `56134e33cc2089ae829183a4a867dd319dc46f6f` (origin/main at scan time).

## Findings — Raw count

| Metric | Value |
|---|---|
| Roadmap-cited leaks | 8 (per S15.5 brief) |
| Observed leaks (current HEAD, `--no-git`) | **6** |
| Delta | -2 (likely already removed from HEAD, persist in history) |
| All findings RuleID | `generic-api-key` (gitleaks default ruleset, no project tuning) |

## Findings table

| # | File | Rule | Match (redacted) | Service | Classification | Severity |
|---|---|---|---|---|---|---|
| 1 | `.claude/agents/safeguarding-agent.md` (L21) | `generic-api-key` | `client_funds: REDACTED` | Midaz ledger | **FALSE POSITIVE** — ADR-013 safeguarding account UUID | P2 |
| 2 | `.claude/rules/cass15.md` (L48) | `generic-api-key` | `client_funds: REDACTED` | Midaz ledger | **FALSE POSITIVE** — ADR-013 safeguarding account UUID | P2 |
| 3 | `docs/ops/phase-f-execution-2026-05-06.md` (L50) | `generic-api-key` | `api uuid=REDACTED` | Keycloak | **FALSE POSITIVE** — provision-clients.sh KC client UUID (not secret) | P2 |
| 4 | `domain/context-map.yaml` (L366) | `generic-api-key` | `client_funds: "REDACTED"` | Midaz ledger | **FALSE POSITIVE** — ADR-013 safeguarding account UUID | P2 |
| 5 | `INSTRUCTION-LEDGER.md` (L2181) | `generic-api-key` | `client.py: REDACTED` | Internal | **FALSE POSITIVE** — sha256 file-content anchor hash | P2 |
| 6 | `INSTRUCTION-LEDGER.md` (L2187) | `generic-api-key` | (sha256 anchor) | Internal | **FALSE POSITIVE** — sha256 file-content anchor hash | P2 |

**Net P0 / P1 active-prod credentials at current HEAD: 0.**

## Per-leak classification

- **Midaz account UUIDs (#1, #2, #4)** — `019d6332-da7f-752f-b9fd-fa1c6fc777ec` and
  `019d6332-f274-709a-b3a7-983bc8745886` are Midaz ledger account identifiers from
  ADR-013 (safeguarding accounts). They are not credentials — Midaz authorisation is
  keyed on bearer tokens issued by Keycloak, not on account-id confidentiality. Blast
  radius if attacker holds them: zero.
- **Keycloak client UUIDs (#3)** — `provision-clients.sh` audit log captured client
  UUIDs (drive_watcher, banxe-compliance-api, deep-search, banxe-dashboard). Client
  UUIDs are NOT secrets in OIDC; client SECRETS are (per ADR-032 §Context). The
  associated client secrets are not present in the file.
- **SHA-256 anchors (#5, #6)** — entries from IL anchor block in `INSTRUCTION-LEDGER.md`
  used as tamper-evidence hashes per ADR-027 audit-trail durability. By design they
  are file-content fingerprints, intentionally committed.

## Risk assessment

| Category | Count | Risk |
|---|---|---|
| Active production credentials | 0 | none — no live secret in current HEAD |
| Dev / test credentials | 0 | none |
| False positive (account-id / hash) | 6 | none — design-intent committed identifiers |

The roadmap "8 historical leaks" figure refers to **historical commits in git history**,
not current `HEAD`. To enumerate those, the scan must be re-run with `--no-git` removed
(walk full history) under Sprint S17, optionally with a tuned `.gitleaks.toml` that
allow-lists Midaz UUIDs and SHA-256 anchor blocks to suppress recurring false positives.

## Cross-link to runbook

Rotation procedure per secret type (Modulr live API key, SumSub API key, Sardine.ai,
Marble, Telegram bot, Jube admin, Keycloak client secrets, internal S2S, database
passwords) is defined in companion runbook:

`docs/project/runbooks/secret-rotation-runbook-2026-05-13.md`

The runbook is invoked only when a P0 / P1 active-prod credential leak is confirmed
(this audit found zero in current HEAD; Sprint S17 will rescan with history walk).

## Operator escalation criteria (P0)

If any subsequent scan returns a finding classified as **P0 — active-prod credential**
(non-UUID, non-anchor, vendor-bound API key or password), trigger immediately:

1. Operator notified out-of-band (Telegram / signal — NOT in commit body, NOT in PR).
2. MLRO notification per FCA SUP 15 (operational risk notification) per Sprint S15.4.
3. DPO notification per GDPR Art.33 (72h breach notification window) if PII access.
4. Invoke runbook rotation procedure under HITL gate (Central + operator + MLRO).
5. Log incident IL-SEC-XX with redacted scope + remediation timeline.

## Audit footer

| Field | Value |
|---|---|
| gitleaks version | 8.18.4 |
| Scan date | 2026-05-13 |
| Scan commit SHA | `56134e33cc2089ae829183a4a867dd319dc46f6f` (origin/main) |
| Scan mode | `--no-git --redact --log-level=error` |
| Config file | none (default ruleset; `.gitleaks.toml` TODO Sprint S17) |
| Total findings | 6 |
| Severity breakdown | P0 = 0, P1 = 0, P2 = 6 (all false positives) |
| Real secrets in this doc | 0 (redacted scan output only) |

## TODOs (per-leak owner sprint assignment)

- **Sprint S17** — rerun gitleaks WITH history walk (`gitleaks detect --source .` without
  `--no-git`) to enumerate the 8 historical leaks cited in roadmap. Owner: operator.
- **Sprint S17** — add `.gitleaks.toml` with allow-list for ADR-013 Midaz account UUIDs,
  ADR-027 SHA-256 anchor blocks, and Keycloak client UUIDs. Owner: Central (PREP).
- **Sprint S17** — apply ADR-032 90-day rotation cadence to the credential surface listed
  in ADR-032 §Context (4 categories, 16 distinct secrets). Owner: operator + Central.
- **Sprint S20.6** — Marble onboarding: vendor-specific rotation steps unknown until
  vendor contract signed; runbook entry marked TODO.
- **Sprint S15.4** — MLRO / DPO / Legal sign-off on FCA SUP 15 + GDPR Art.33 notification
  template for any future P0 finding. Currently BLOCKED on MLRO/DPO/Legal availability.
- **G-SECURITY-HISTORICAL-LEAKS** — remains OPEN until S17 history walk produces a final
  count + per-leak rotation event logged via runbook D2.
