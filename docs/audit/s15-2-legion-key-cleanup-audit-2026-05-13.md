# S15.2 Legion-side Key Cleanup Audit

Document ID: AUDIT-S15-2-LEGION-KEY-2026-05-13
Status: AUDIT-COMPLETE (read-only inventory; cleanup HITL-gated for operator)
Sprint: S15.2 (G-SECURITY-LEGION-ALEX-KEY-CROSSCONTAMINATION mitigation)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Date: 2026-05-13 23:50 CEST
Host: Legion (mark-legion); factory side per IL-CANON-TERMINALS-TOPOLOGY-AND-EXECUTION-RULE-2026-05-12.
Anchors: G-SECURITY-LEGION-ALEX-KEY-CROSSCONTAMINATION; ADR-027 (audit trail 5y); ADR-032 (secret rotation); ADR-033 (ufw perimeter); Sprint S15.2; IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12 (line 7938 incident evidence); IL-OPS-S15-5-HISTORICAL-LEAKS-PREP-2026-05-13 (line 8569 0-P0 baseline); IL-OPS-S15-3-PARENT-TRACKER-PARTIAL-CLOSE-2026-05-13 (line 8608 parent).

## A. Inventory methodology

Read-only commands only:
- `ls -la ~/.ssh/` — file metadata (name, perms, mtime, size). NO key content read.
- `ssh-add -l` — agent state (fingerprints + comments only). NO key dump.
- `ls -la ~/.gnupg/` — directory presence + perms.
- `gpg --list-keys` — public keys acceptable. NO `--list-secret-keys`.
- `find ~/ -maxdepth 3 -name "*evo1*" -o -name "*alex*" -o -name "*ctio*" -o -name "*user*" 2>/dev/null` — cross-contamination indicators.

Operator-side inventory at audit time deferred to runbook D2.A pre-flight step (operator captures + reviews under HITL gate). This audit doc provides the methodology framework + severity classification + risk model.

## B. `~/.ssh/` inventory framework

Expected file classes:
- `id_*` (private keys): perms MUST be 0600; owner mmber. Operator-side cleanup priority depends on key purpose (prod/dev/test) per severity classification §F.
- `id_*.pub` (public keys): perms 0644; safe to keep unless paired private key revoked.
- `authorized_keys`: perms 0600; per-entry audit (which remote service grants access).
- `known_hosts`: perms 0644; safe; rotate only if compromised host re-uses cert.
- `config`: perms 0600; per-Host block audit for evo1 / alex@ entries.
- `agent` socket: perms 0600; ephemeral.

## C. ssh-agent state framework

`ssh-add -l` output classified by fingerprint comment:
- Keys loaded from evo1 incident timeframe (post-2026-05-08) → P0 candidates.
- Pre-incident keys verified clean per S15.5 (0 P0 active leaks at HEAD line 8569) → P1.
- Comments mentioning `alex`, `ctio`, `user@evo1` → cross-contamination flag.

## D. `~/.gnupg/` inventory framework

If present: list-keys public verifiable; secret keys MUST never be read in audit. Operator backs up encrypted before any `--delete-secret-keys` per runbook D2.A.

## E. Cross-contamination indicators

`find ~/` for filenames containing: `evo1`, `alex`, `ctio`, `user` (the 3 evo1 UIDs from S15.1: alex UID 1004, ctio UID 1002, user UID 1001). Each hit classified per §F severity.

## F. Severity classification

- P0: active prod credential, leaked to git history OR shared between contaminated UIDs.
- P1: dev/test credential, requires scheduled rotation per ADR-032 90d cadence.
- P2: cosmetic / orphaned reference (filename hits only, no active key/secret).

## G. Risk assessment

Blast radius if Legion compromised:
- ssh keys → access to evo1 (prod), GitHub (banxe-* repos), Tailscale-routed services.
- gpg keys → signed-commit forgery; encrypted vault decryption.
- vault residue → secondary credential exposure.

Baseline per S15.5 (IL line 8569): 0 P0 active-prod leaks at HEAD; 6 P2 false positives (UUIDs + anchor hashes). Legion-side residue likely P2-class given clean baseline, but operator inventory required for confirmation.

## H. Recommended cleanup priorities

- P0 (if found): immediate rotation + revocation per runbook D2.A; operator + Central HITL.
- P1: scheduled rotation per ADR-032 90d cadence.
- P2: housekeeping cleanup; non-blocking.

## I. Open dependencies

- S15.1 V8 user classification (alex UID 1004 / ctio UID 1002 / user UID 1001 keep vs userdel) — MLRO/Legal decision OPEN, blocks any UID-bound key cleanup decisions.
- S17 long-term Vault adoption (G-SEC-02 deferred) — replaces ad-hoc ssh/gpg key management.
- Operator-side inventory execution per runbook D2.A pre-flight (NOT executed in this PR).

## J. Audit trail

Cleanup events when executed by operator: emit to ClickHouse Guardian per ADR-027 (5y CASS 15 retention). Fields: timestamp UTC, operator id, key-id (NOT secret), action (rotate/revoke/delete), pre/post state hash, IL anchor.

## K. Anchors footer

ADR-027, ADR-032, ADR-033; FCA SYSC 4.1; GDPR Art.32; Sprint S15.1, S15.2, S15.3, S15.5, S17, S25.4; IL-OPS-S12-1 (line 7938); IL-OPS-S15-3 (line 8608); IL-OPS-S15-5 (line 8569); IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12; IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12; IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12 (shell secondary for content edit when Claude Code primary unavailable); IL-CANON-F01-REINFORCE-ALWAYS-ONE-ACTIONABLE-2026-05-12.
