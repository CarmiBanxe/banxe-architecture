# Legion Key Cleanup Runbook (Sprint S15.2)

Document ID: RB-LEGION-KEY-CLEANUP-2026-05-13
Status: SKELETON
Sprint: S15.2 (G-SECURITY-LEGION-ALEX-KEY-CROSSCONTAMINATION mitigation)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
HITL gate: REQUIRED (Central + operator; EMERGENCY override allowed for P0 active-leak with retrospective Central sign-off)
Anchors: G-SECURITY-LEGION-ALEX-KEY-CROSSCONTAMINATION; ADR-027 (audit trail 5y); ADR-032 (secret rotation 90d); ADR-033 (ufw perimeter); Sprint S15.2, S15.5, S17; IL-OPS-S15-3 (line 8608); IL-OPS-S15-5 (line 8569); audit doc docs/audit/s15-2-legion-key-cleanup-audit-2026-05-13.md.

## A. Pre-flight (operator only; NOT executed in this PR)

1. Verify Central is online + reachable for HITL approval.
2. Execute read-only inventory per audit doc §A methodology:
   - `ls -la ~/.ssh/` capture to operator vault (encrypted).
   - `ssh-add -l` capture (fingerprints only).
   - `ls -la ~/.gnupg/` capture.
   - `find ~/ -maxdepth 3 -name "*evo1*" -o -name "*alex*" -o -name "*ctio*" -o -name "*user*" 2>/dev/null` capture.
3. Classify per audit doc §F severity (P0/P1/P2).
4. Verify backups path available (operator vault encrypted, off-host per ADR-027 audit storage requirements).
5. Identify remote hosts that have authorized_keys entries referencing local keys (for revocation step).
6. Notify Central + operator approval before any destructive operation.

## B. Per-key-type cleanup procedure

### B.1 ssh private key (id_rsa, id_ed25519, etc.)

1. Backup encrypted to operator vault: `gpg --output ~/vault/id_<name>.gpg --symmetric ~/.ssh/id_<name>` (operator-provided passphrase).
2. Capture fingerprint: `ssh-keygen -lf ~/.ssh/id_<name>.pub > /tmp/audit-pre-cleanup.log`.
3. Remove from ssh-agent: `ssh-add -d ~/.ssh/id_<name>` (verify `ssh-add -l` no longer shows fingerprint).
4. Remove file: `rm -f ~/.ssh/id_<name> ~/.ssh/id_<name>.pub`.
5. Revoke from remote authorized_keys (per host identified in pre-flight §A.5):
   - ssh to remote → edit `~/.ssh/authorized_keys` → remove line matching fingerprint → verify line gone.
6. Verify access fails-closed: `ssh remote 'echo OK'` MUST fail with auth denied.
7. Log cleanup event to IL with fingerprint (NOT key content) + operator co-sign.

### B.2 ssh public key in authorized_keys on Legion

1. Identify entries: `grep -nE 'evo1|alex|ctio|user' ~/.ssh/authorized_keys`.
2. Backup file: `cp ~/.ssh/authorized_keys ~/vault/authorized_keys.bak-$(date +%s)`.
3. Remove matched lines (operator-side text editor, no automated regex).
4. Verify perms: `chmod 0600 ~/.ssh/authorized_keys`.
5. Smoke test: legitimate ssh login from Central still works; contaminated key login fails-closed.

### B.3 ssh-agent loaded key (no on-disk file)

1. `ssh-add -d <keyfile>` if on-disk; else `ssh-add -D` (flush all — EMERGENCY only, requires Central sign-off).
2. Verify `ssh-add -l` empty or only known-good keys.

### B.4 GPG secret key

1. List with masked output: `gpg --list-secret-keys --keyid-format LONG` (capture key-id + uid only; no `--export-secret-keys` in audit-only context).
2. If revocation decided: `gpg --export-secret-keys <key-id> > ~/vault/gpg-<key-id>.bak` (operator vault encrypted).
3. `gpg --delete-secret-keys <key-id>`.
4. `gpg --delete-keys <key-id>` (public).
5. Verify `gpg --list-keys` does not show the key.
6. Notify any service that previously trusted this key.

### B.5 Vault residue (env vars, .env files, configs with secrets)

1. Identify files via `find` per audit doc §E.
2. Backup encrypted to operator vault.
3. Redact secrets in-place (replace value with `{{REDACTED_<TYPE>}}`).
4. Commit redacted version to canonical repo path under HITL gate (separate PR per IL-CANON-DOC-MANDATORY-TWO-LAYER).
5. Rotate secret via vendor console per ADR-032 90d rotation policy.

## C. HITL gate

- Central + operator sign-off required for all P0 + P1 actions.
- NO MLRO requirement (Legion-side hygiene; not customer-data event).
- EMERGENCY override allowed for P0 active-leak with retrospective Central sign-off within 24h.
- Audit event to ClickHouse Guardian per ADR-027.

## D. Rollback

If cleanup was erroneous:
1. Restore from operator vault encrypted backup: `gpg --decrypt ~/vault/id_<name>.gpg > ~/.ssh/id_<name>`.
2. `chmod 0600 ~/.ssh/id_<name>`.
3. Re-add to ssh-agent: `ssh-add ~/.ssh/id_<name>`.
4. Re-add to remote authorized_keys (per host).
5. Verify access restored.
6. Document rollback event to IL with operator + Central co-sign + reason.

## E. Post-cleanup verification

1. gitleaks rescan: `gitleaks detect --source . --no-git --redact` → 0 new findings vs S15.5 baseline (6 P2 false positives at HEAD per IL line 8569).
2. `ssh-add -l` empty or only known-good keys.
3. `find ~/ -maxdepth 3 -name "*evo1*" -o -name "*alex*" -o -name "*ctio*" -o -name "*user*" 2>/dev/null` → 0 cross-contamination residue (or only known-acceptable references like docs/audit/).
4. ufw status per ADR-033 unchanged (no new open ports as side-effect).
5. Smoke test legitimate ssh + signed-commit + vault decrypt still work.

## F. Audit trail

All cleanup + rollback events emitted to ClickHouse Guardian per ADR-027 (5y CASS 15 retention). Fields per event: timestamp UTC, operator id, action (rotate/revoke/delete/restore), key-id or file-path (NOT secret content), pre-state hash, post-state hash, IL anchor.

## G. Open dependencies

- S15.1 V8 user classification (alex UID 1004 / ctio UID 1002 / user UID 1001 keep vs userdel) — MLRO/Legal decision OPEN; blocks any UID-bound key cleanup.
- S17 long-term Vault adoption (G-SEC-02 deferred per Track F).
- ADR-032 90d rotation cadence enforcement for P1-class keys (cron + tooling).
- Operator-side execution + post-cleanup verification + IL log per event.

## H. Anchors footer

ADR-027, ADR-032, ADR-033; FCA SYSC 4.1; GDPR Art.32; Sprint S15.1, S15.2, S15.3, S15.5, S17, S25.4; IL-OPS-S12-1 (line 7938 incident); IL-OPS-S15-3 (line 8608 parent partial-close); IL-OPS-S15-5 (line 8569 baseline); IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12; IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12; IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12 (shell secondary for content edit when Claude Code primary unavailable); IL-CANON-PERSISTENCE-SHELL-FIXATION-2026-05-12; IL-CANON-F01-REINFORCE-ALWAYS-ONE-ACTIONABLE-2026-05-12.
