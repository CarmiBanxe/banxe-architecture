# Server refactor-workspace bootstrap (ADR-103 PART 1 implementation plan)

<!-- Source: docs/runbooks/server-refactor-workspace.md | Date: 2026-06-16 | Version: 1.0 | Implements: ADR-103 PART 1 | IL: IL-250 -->

## Status

PLAN — docs-only spec. This runbook **describes** the server contour required by
ADR-103 PART 1 (server-only refactoring). It stands up **no** infrastructure, moves
**no** data, and stores **no** secrets. The real infra (evo1 / runner / vault) is
brought up by the **operator**, not the factory (see OPERATOR ACTIONS).

## Purpose

ADR-103 (ACCEPTED, IL-248) requires all refactoring, legacy-handling, factory repo
edits, and secret use to run **only on a secured server** — never on an operator's
local machine. This runbook specifies the concrete server workspace, the archive
ingress, the factory's server-side operation, the secrets model, and the **M0 re-home
plan** for the pre-policy debt (the local M0 + emi-stack Fix A/B work).

## 1. Target server & workspace

- **Server:** `evo1` (or a dedicated self-hosted CI runner) — a secured, audited host.
- **Workspace path:** `/srv/banxe-legacy/` (root for all refactor/legacy work), with
  subdirs e.g. `archive/` (encrypted source), `work/` (extraction + snapshots),
  `tools/` (m0_* utilities), `repos/` (factory clones for promotion).
- **Access control:** restricted to the factory's service account + named operators;
  no general login. Directory perms `0750`, owned by the factory service user.
- **Audit log:** every session and command on the workspace logged (shell audit /
  runner job log) and retained per the project audit retention (append-only).

## 2. Archive ingress (no local `/mnt/c`)

- `BANXE.RAR` reaches the server **without** going through a local `/mnt/c` step:
  - **direct upload** to `/srv/banxe-legacy/archive/` (scp/rsync/SFTP from the source
    of record), **or** a **server-side pull** from an operator-controlled store.
- **Verify on the server** against the manifest checksums already recorded in
  `bx-legacy-tools/docs/migration/banxe_archive_manifest.md` (and to be committed to
  the repo): **MD5 `6bf7abf52b9b2a7f8973afbd95bf2c9c`**, **SHA-256
  `420913292bf38c50543cbcecd8c2079e050f8d3fc588b1f7f145605af0e1bf13`**. Reject on
  mismatch (fail-closed).
- The four byte-identical copies and the neighbouring personal/legal `.rar` files
  (per `banxe_archive_safety_note.md`) are **out of scope** and never transferred.

## 3. Factory operation (server-side)

- The factory drives all work **on the server** via **`ssh`** or a **self-hosted
  runner job**: clone, edit, run M-track scripts, and `git push` happen server-side
  inside `/srv/banxe-legacy/repos/`.
- An operator's local machine is **only the initiator** (`gh` / `ssh`) — it triggers
  the server job and reads results; it holds no sources, no working copies, no secrets.
- Promotion into a target repo follows ADR-103 PART 2 (smart-refactor promotion gate:
  server-side refactor complete + Duplication Audit on the PR).

## 4. Secrets

- `BANXE_RAR_PASSWORD`, Tailscale authkeys, and any provider secrets live **only** in a
  **server vault / GH Actions secrets**, injected into the server job at runtime.
- **Never** typed into a local shell, written to local disk/env, or stored in repo
  artefacts. The list/extract scripts already read the password from
  `BANXE_RAR_PASSWORD` env (server-injected) and never persist it.

## 5. M0 re-home plan (pre-policy debt → server)

The current local M0 artefacts must move to the server so the **3.2–3.4 analyst pass**
runs server-side. The analysis is valid; only its location changes.

- **Tools/docs** (`/tmp/bx-legacy-tools`: `scripts/`, `tools/` (m0_* + classifier),
  `output/` index+CSV, `docs/migration/` manifest+safety-note, `BANXE_MASTER_RESEARCH.md`)
  → copy to `/srv/banxe-legacy/tools/`. These are non-secret and small; transfer is a
  plain copy (or re-clone of the eventual tools repo).
- **Snapshot** (`/tmp/bx-legacy/banxe-code`, 50 806 files): **prefer a server-side
  re-extract** — upload only the encrypted `BANXE.RAR`, then run
  `scripts/banxe_archive_list.sh` + `classify_banxe_archive.py` +
  `banxe_archive_extract_code.sh` **on the server** under the **server-injected**
  `BANXE_RAR_PASSWORD` (vault). This avoids transferring 50 806 extracted files and,
  crucially, **never moves the password to a local shell**. (Copying the already-
  extracted snapshot is allowed as a fallback, but re-extract is cleaner and re-verifies
  against the manifest.)
- **After migration**, mark the local copies for deletion:
  `/tmp/bx-legacy/`, `/tmp/bx-legacy-tools/`, `/tmp/emi-fix/`, and unset/clear the local
  `BANXE_RAR_PASSWORD`. (Deletion is an explicit operator-confirmed step — this runbook
  only flags them; per safety canon, destructive ops are verified before execution.)
- Then 3.2–3.4 (domain map, EMI mapping, risk register) run server-side via
  `m0_run.sh` + the analyst pass, and promote via ADR-103 PART 2.

## OPERATOR ACTIONS (human-only — factory cannot do these)

1. **Stand up** `evo1` (or a dedicated self-hosted runner) as the secured workspace host.
2. **Create** `/srv/banxe-legacy/` with the access control + audit logging above.
3. **Provision the vault / GH Actions secrets**: `BANXE_RAR_PASSWORD`, `TS_AUTHKEY`,
   and any provider secrets — server-side only.
4. **Grant the factory** `ssh` / self-hosted-runner access scoped to the workspace.
5. **Place `BANXE.RAR`** on the server via §2 ingress (not via local `/mnt/c`).
6. **Authorise** the local-copy deletion (§5) once the server re-home is verified.

After these, the factory runs M0 3.2–3.4 (and all future refactoring) entirely
server-side, compliant with ADR-103.

## Duplication Audit (ADR-102)

Searched `docs/runbooks/` and `docs/` for an existing server-workspace / refactor
runbook. **No duplicate.** The two evo1 runbooks govern different topics —
`fa-evo1-bios-uma-audit.md` (BIOS/RAM) and `redis-evo1-setup.md` (Redis on evo1) — and
`ADR-103` is the **policy** this runbook **implements** (not a duplicate). Decision:
**keep** (new runbook); no merge/delete; risk: none. The evo1 runbooks are referenced
as existing evo1 infra context.

## References

- `docs/adr/ADR-103-server-only-refactoring-policy.md` (the policy); IL-248, IL-250.
- `docs/runbooks/fa-evo1-bios-uma-audit.md`, `docs/runbooks/redis-evo1-setup.md`
  (existing evo1 infra context).
- `bx-legacy-tools/docs/migration/banxe_archive_manifest.md` + `banxe_archive_safety_note.md`
  (archive identity + handling constraints).
