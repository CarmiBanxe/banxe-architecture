# Secret Rotation Policy — 90-day Cadence (Sprint S17 PREP)

Document ID: POL-SEC-ROTATION-2026-05-14
Status: POLICY-PREP (S17; consumer of S12.5 / S12.6 / S12.3 / S15.5 PREP packages)
Sprint: S17 (interim 90-day cron-reminder bridge until G-SEC-02 Vault adoption)
Date: 2026-05-14
Layer: 2 (Project Plane policy per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
HITL gate: ENFORCED (cron is reminder-only — operator executes under HITL gate per D2 cron template)
Owner: Central (authoring) per IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12; operator executes rotations.
Last reviewed: 2026-05-14

## Anchors

- ADR-032 — Secret rotation policy (interim 90-day framework; Accepted)
- ADR-038 — Vault adoption placeholder (DEFERRED per G-SEC-02 / Sprint S17+; long-term replacement)
- ADR-027 — Audit-trail durability (rotation events sink to ClickHouse Guardian, 5y CASS 15 retention)
- G-SEC-02 — Vault adoption (Track F DEFERRED; this policy is the interim bridge)
- G-IAM-08 — KC DB password migration (banxe-emi-stack PR #133, PREP DONE)
- G-IAM-09 — KC backup policy (banxe-emi-stack PR #134, PREP DONE)
- Sprint S17 (this policy); S12.3 S2S tokens PREP; S12.5 G-IAM-08 prep; S12.6 G-IAM-09 prep; S15.2 Legion key audit; S15.5 historical-leaks audit + rotation runbook; S20.1 Modulr deploy; S20.4 Sardine deploy; S20.5 Telegram bot deploy; S20.6 Marble onboarding; S20.8 MLRO appointment; S25.4 quarterly review.
- IL anchors: IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12 (line 7938 — G-IAM-08/09 evidence); IL-OPS-S12-3-S2S-TOKENS-PREP-2026-05-13 (line 8508 — S2S 90d cadence); IL-OPS-S15-5-HISTORICAL-LEAKS-PREP-2026-05-13 (line 8569 — leaks audit + runbook); IL-OPS-S15-2-LEGION-KEY-CLEANUP-PREP-2026-05-13 (line 8638 — Legion key audit).
- FCA SYSC 4.1 (governance / responsibility for arrangements); FCA SYSC 15A (operational resilience); GDPR Art.32 (security of processing).
- Sibling Layer-2 runbook: docs/project/runbooks/secret-rotation-runbook-2026-05-13.md (per-secret-type procedure; this policy provides cadence + escalation; runbook provides per-event execution).

## Scope

90-day standard rotation cadence policy for all in-scope Banxe secrets, consolidating the inventories produced by S15.5 (historical leaks audit), S12.3 (S2S token inventory) and S15.2 (Legion key audit). The policy MUST be read alongside the S15.5 runbook (per-secret-type procedure) and the D2 cron-reminder template (operational delivery surface). No production rotation is executed by this PREP package — operator executes rotations per the runbook under HITL gate; this policy defines when rotations are due and who signs off.

## A. Cadence

| Class | Cadence | Trigger |
|---|---|---|
| Standard secret (interactive / vendor API / KC client / S2S / DB) | **90 days** rolling | scheduled per `rotation-due-date` field in vault metadata |
| P0 production credential (post-incident hardening) | **30 days** rolling | scheduled until 3 consecutive clean rotations, then steps back to 90 days |
| Compromise event (suspected leak, accidental disclosure, gitleaks finding cross-referenced to clone) | **on-demand** | trigger = incident ticket; rotation invoked within 24h (FCA SUP 15 same-business-day analogue per S15.4 prep) |
| GPG secret key (longer key lifecycle convention) | **365 days** | scheduled; rationale = OpenPGP key lifecycle convention, gpg subkey expiry typically annual; key revocation certificate available for emergency |

Rationale for 90-day standard: ADR-017 §5 cadence commitment (KC client secrets); ADR-032 §Decision Drivers (FCA SYSC 15A operational resilience + audit-trail completeness); industry baseline (NIST SP 800-63B explicit-rotation guidance for non-MFA shared secrets; PCI DSS 8.3.9 ≤90d for shared accounts). Rationale for 365d GPG exception: key-revocation primitives (revocation certificate, subkey expiry) provide independent risk mitigation; rotation at 90d would force re-issuance of trust chain and create operational drag without security benefit. EMERGENCY GPG rotation always on-demand on compromise.

## B. In-scope secret-type matrix

Consolidates S15.5 audit inventory + S12.3 S2S inventory + S15.2 Legion key audit. **NO actual secret values appear in this table — only secret-type identifiers, source-of-truth pointers, owners and runbook references.**

| # | Secret-type | Source-of-truth | Owner | Cadence | Rotation procedure ref |
|---|---|---|---|---|---|
| 1 | KC DB password (Keycloak Postgres backend `jdbc:postgresql://127.0.0.1:15433/keycloak`) | systemd EnvironmentFile (G-IAM-08 fix) | Central + operator | 90d | banxe-emi-stack G-IAM-08 runbook (PR #133) |
| 2 | KC S2S client_secret (6 svc clients in realm `banxe-emi`) | KC realm `banxe-emi` (admin API) | Central + operator | 90d | banxe-architecture S12.3 runbook + S15.5 §Rotation procedure step 7 (Keycloak client) |
| 3 | Modulr live API key | operator vault (TODO — interim file-based store until G-SEC-02 Vault) | MLRO + operator | 90d | TODO Sprint S20.1 (deploy) — S15.5 runbook §Vendor-specific smoke test (Modulr `GET /accounts`) |
| 4 | SumSub API key | operator vault | MLRO + operator | 90d | S15.5 runbook §Vendor-specific smoke test (SumSub `GET /resources/applicants`) |
| 5 | Sardine.ai API key | operator vault | MLRO + operator | 90d | TODO Sprint S20.4 (deploy) — S15.5 runbook §Vendor-specific smoke test (Sardine `POST /v1/customers/feedback`) |
| 6 | Marble API key + INBOX_ID | operator vault | MLRO + operator | 90d | TODO Sprint S20.6 (onboarding — vendor docs pending; S15.5 runbook §TODO #1) |
| 7 | Telegram bot token (MLRO alert chat + safeguarding chat) | operator vault | MLRO + operator | 90d | TODO Sprint S20.5 (deploy) — S15.5 runbook §Vendor-specific smoke test (`GET /bot<token>/getMe`); rotation order-of-operations TODO per S15.5 §TODO #2 (avoid circular dependency with audit-channel alerts) |
| 8 | Jube admin password | operator vault | operator | 90d | TODO — S15.5 runbook §Vendor-specific smoke test (UI login) |
| 9 | SSH private keys (Legion — mark-legion 100.101.218.26) | `~/.ssh/` + operator vault | operator | 90d | banxe-architecture S15.2 runbook (docs/project/runbooks/legion-key-cleanup-runbook-2026-05-13.md) |
| 10 | GPG secret keys (if used for commit signing / encrypted archives) | `~/.gnupg/` + operator vault | operator | 365d | banxe-architecture S15.2 runbook §gpg key section; subkey expiry convention |
| 11 | GitHub PAT (CI + admin tokens) | operator vault | operator | 90d | TODO — generic vendor PAT rotation pattern per S15.5 runbook §Rotation procedure (generate → revoke old → smoke test `gh auth status`) |

Row count: 11. Coverage: KC DB (1) + KC S2S (1) + vendor APIs (Modulr/SumSub/Sardine/Marble/Telegram/Jube = 6) + SSH/GPG (2) + GitHub PAT (1) = 11.

Out-of-scope for THIS policy (covered separately or deferred): customer-facing TLS certificates (TLS lifecycle is automated via vendor — separate scope); HSM-resident keys (none at present; deferred to G-SEC-02 Vault); FIDO2 / WebAuthn credentials (user-side, not operator-rotatable). Out-of-scope items remain tracked under G-SEC-02 long-term roadmap.

## C. Escalation chain

Reminder → operator → Central HITL → MLRO advisory (vendor compliance keys only) → execute rotation → audit emit → IL log. Concretely:

1. **Cron reminder fires** (per D2 cron template) at 80% of cadence window (= day 72 of 90d cycle; day 24 of 30d post-incident cycle; day 292 of 365d GPG cycle). Output = secret-id list + days-remaining + owner + runbook ref.
2. **Operator receives reminder** via Telegram channel (post Sprint S20.5; until then = logger / Central log only). Operator opens this policy + S15.5 runbook side-by-side.
3. **Central HITL gate engaged.** Operator confirms rotation scope with Central per IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12 (Claude Code primary surface for HITL coordination); shell secondary if Central session unavailable.
4. **MLRO advisory** for vendor-side compliance keys (matrix rows 3–7: Modulr, SumSub, Sardine, Marble, Telegram). Advisory-only on routine rotation; sign-off required for P0 vendor-side incidents per S15.5 runbook §EMERGENCY override.
5. **Execute rotation** per matrix col 6 runbook reference (per-secret-type 8-step procedure: generate → update config → restart → smoke test → revoke → verify revoked → IL log → audit emit).
6. **Audit emit** to ClickHouse Guardian per ADR-027 BufferedAuditPort (`kind=secret_rotation`, fields per §F below).
7. **IL log** entry `IL-SEC-ROTATE-<secret-type>-<YYYY-MM-DD>` recorded in INSTRUCTION-LEDGER.md per the S15.5 runbook canonical anchor.

Failure modes: if HITL gate cannot be engaged (Central unavailable + operator-only on-call), operator MAY defer rotation up to grace window = 18 days beyond cadence (i.e. effective ceiling 108d for 90d standard) provided incident ticket opened and MLRO informed; beyond the grace window the secret is treated as a P0 compromise event (§A row 3 trigger).

## D. HITL gate

Required signatures per rotation event (mirrors S15.5 runbook §HITL gate, applied at policy level):

- **Central** (Claude Code) — procedure custodian; verifies operator engaged correct runbook + matrix row; logs IL entry.
- **Operator** — execution authority on vendor consoles, evo1 prod env, Legion SSH keys, GPG keyring.
- **MLRO advisory** — informed for routine vendor-compliance-key rotation (matrix rows 3–7); sign-off required for P0 vendor-side rotations or compromise events.
- **Legal advisory** — engaged only when rotation has FCA SUP 15 reporting impact (rare; e.g. vendor key compromised by external party with customer-data exposure). Cross-link to S15.4 FCA SUP 15 + GDPR Art.33 notification PREP package.

EMERGENCY override (P0 active compromise): operator MAY execute rotation without synchronous MLRO sign-off provided retrospective Central + MLRO sign-off captured in rotation IL entry within 24h. Mirrors S15.5 runbook §EMERGENCY override and FCA SUP 15 same-business-day notification expectations. The 24h retrospective window is non-negotiable; missing it = governance incident per CLAUDE.md §11.

## E. Vault adoption (deferred — future state)

ADR-038 placeholder records the intent to adopt a managed secret store (Vault, Infisical, or equivalent) to replace this interim policy. G-SEC-02 (Track F long-term roadmap) defers the adoption decision; this Sprint S17 PREP is the interim 90-day cron-reminder bridge, NOT the Vault deployment. When ADR-038 is promoted from placeholder to Accepted:

- this policy is superseded by Vault-native rotation policy (auto-rotation for supported secret types);
- the D2 cron-reminder template is replaced by Vault scheduled rotation events;
- the operator vault file-based metadata store (interim — see §B note on Modulr / SumSub / etc. source-of-truth) migrates to Vault KV;
- this document remains as historical reference and is marked "Superseded by ADR-038 Vault adoption".

Until then, the interim policy is canonical. No partial Vault adoption permitted (one secret type Vault-managed, others file-based) — single source-of-truth invariant per IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12.

## F. Audit trail

Every rotation event (success, rollback, revoke failure, false-positive reminder mark) MUST produce an append-only ClickHouse Guardian audit record per ADR-027 BufferedAuditPort. Retention: 5 years (FCA CASS 15). Fields:

| Field | Type | Notes |
|---|---|---|
| `timestamp` | UTC ISO-8601 | event time, not reminder time |
| `secret_id` | string | secret-type identifier — NEVER the secret value (e.g. `kc-s2s-banxe-emi-client-svc-recon`) |
| `action` | enum | `rotate` / `revoke` / `rollback` / `reminder_fired` / `false_positive_mark` |
| `old_fingerprint_hash` | sha256 hex | hash of old secret (NOT the value); enables uniqueness verification |
| `new_fingerprint_hash` | sha256 hex | hash of new secret; allows replay-detection if same hash recurs across rotations |
| `operator_id` | string | operator handle (e.g. `op:mmber`) |
| `mlro_co_sign` | string \| null | MLRO handle if applicable; null for non-vendor-compliance rows |
| `central_co_sign` | string \| null | Central session id (e.g. `cc:s17:2026-05-14`) |
| `runbook_ref` | string | matrix col 6 reference (e.g. `s15-5-runbook §Vendor-specific smoke test (Modulr)`) |
| `il_ref` | string | `IL-SEC-ROTATE-<secret-type>-<YYYY-MM-DD>` |
| `outcome` | enum | `success` / `rollback` / `revoke_failed` / `false_positive` |

If ClickHouse Guardian write fails at rotation time, the rotation MUST NOT be marked complete in the operator vault metadata; abort and retry per S15.5 runbook §Rollback. Audit gap = compliance incident per ADR-027 §Context.

## G. Open dependencies

- **Vault adoption** (G-SEC-02, ADR-038 placeholder) — DEFERRED; this policy is the interim bridge.
- **MLRO appointment** (Sprint S20.8) — required for vendor-compliance-key co-sign on routine rotations and for P0 sign-off. Until appointment, Central-only HITL gate is sufficient for routine non-vendor rotations (matrix rows 1, 2, 8, 9, 10, 11); vendor-side rotations (rows 3–7) are deferred or executed under acting-MLRO designate per S15.4 prep.
- **Vendor API key procurement** — Modulr (S20.1), Sardine (S20.4), Marble (S20.6) deploy sprints land actual keys; until then matrix rows are placeholders with TODO refs.
- **Telegram bot deployment** (S20.5) — required for reminder delivery to operator; until then cron output to logger / Central log only (per D2 cron template §H open dependencies).
- **Operator vault metadata schema** — interim file-based store (TODO; awaits ADR-038 Vault adoption decision); schema MUST capture per-secret `secret_id`, `owner`, `cadence_days`, `last_rotated_at`, `rotation_due_date`, `runbook_ref`, `class` (standard / p0 / gpg / compromise-event). Schema design queued for follow-up Sprint S17 sub-deliverable.
- **n8n integration** (per ADR-032 §Implementation Plan + S15.5 runbook §TODO #4) — wire rotation invocation into n8n workflow; pending Sprint S17 enforcement deliverable (separate from this policy PREP).
- **DB password rotation interaction with PgBouncer / connection-pooler reload** (per S15.5 runbook §TODO #7 + S12.5 G-IAM-08 prep) — drain-then-reload sequence verification queued.

## H. Quarterly review (Sprint S25.4)

This policy is reviewed quarterly under Sprint S25.4 (canonical review cadence per IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11). Review scope: matrix row additions / removals (e.g. new vendor onboarding adds a row; vendor deprecation removes a row); cadence adjustments if FCA / NIST guidance changes; G-SEC-02 Vault adoption status check; aggregated audit-trail statistics (rotations executed / missed / false-positive count); HITL gate effectiveness (Central + MLRO sign-off latency distribution).

## Anchors footer

- ADR-032 (decisions/ADR-032-secret-rotation-policy.md)
- ADR-038 (decisions/ADR-038-vault-adoption-placeholder.md)
- ADR-027 (decisions/ADR-027-audit-trail-durability.md)
- G-SEC-02 (Vault adoption deferred — Track F)
- Sprint S17 (this policy + D2 cron template); S12.3, S12.5, S12.6, S15.2, S15.5, S20.1, S20.4, S20.5, S20.6, S20.8, S25.4
- banxe-emi-stack PR #133 (G-IAM-08), PR #134 (G-IAM-09)
- IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12 (line 7938)
- IL-OPS-S12-3-S2S-TOKENS-PREP-2026-05-13 (line 8508)
- IL-OPS-S15-2-LEGION-KEY-CLEANUP-PREP-2026-05-13 (line 8638)
- IL-OPS-S15-5-HISTORICAL-LEAKS-PREP-2026-05-13 (line 8569)
- FCA SYSC 4.1; FCA SYSC 15A; GDPR Art.32
- IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12
- IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12
- IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12
- IL-CANON-PERSISTENCE-SHELL-FIXATION-2026-05-12
- IL-CANON-F01-REINFORCE-ALWAYS-ONE-ACTIONABLE-2026-05-12
- IL-CANON-ALL-CLAUDE-CODE-PROMPTS-VIA-FILE-2026-05-12

## TODOs (operator + future-sprint)

- Operator vault metadata schema design (file-based interim store; awaits ADR-038 Vault decision).
- Vendor API key procurement: Modulr (Sprint S20.1), Sardine (S20.4), Marble (S20.6).
- Telegram bot deployment (Sprint S20.5) for reminder delivery channel.
- MLRO appointment (Sprint S20.8) for vendor-compliance-key co-sign authority.
- GitHub PAT rotation vendor-specific smoke test endpoint (placeholder — generic `gh auth status` may not suffice for fine-grained tokens).
- n8n workflow wire-in per ADR-032 §Implementation Plan + S15.5 runbook §TODO #4.
- Quarterly review template (Sprint S25.4) — table of matrix row diffs, rotation-event aggregate stats, HITL latency distribution.
- ADR-038 Vault adoption promotion criteria — superseding trigger for this policy.
