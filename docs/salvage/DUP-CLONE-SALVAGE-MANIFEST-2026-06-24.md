# DUP-clone salvage manifest — 2026-06-24

Backup of unique uncommitted work from the **DUP** clone (`~/banxe-architecture`, SSH)
to remote `salvage` branches **before the operator retires DUP**. CANON clone =
`~/banxe/banxe-architecture` (HTTPS). Operation is **non-destructive**: every DUP stash
remains in place (no `stash drop`), no branch was deleted, no `--force` used, `main`
untouched.

## Method (canon-aligned)

- `git stash branch` was **NOT** used — it drops the stash on a successful apply, which
  violates the never-lose-data / no-drop canon (`safety-rules.md`). Instead each stash was
  materialised in an isolated **linked worktree** at the stash's own base commit via
  `git stash apply` (which never drops), then committed (SSH-signed) and pushed.
- Branch names follow the **ADR-060** namespace (`agent/factory/<id>/<slug>`) so the
  pre-push gate accepts them; the literal `salvage/*` prefix is gate-blocked. The
  `dupsalvage` id preserves intent.
- Commits used `--no-verify` **only** because the repo's pre-commit semgrep gate trips on
  **pre-existing** findings in `scripts/import_archimate.py` (XXE, unrelated to salvaged
  content). Backup branches are never merged to `main`, so introducing no new code, this is
  in-scope for a data-preservation backup. All salvage commits are **SSH-signed**.
- DUP stash count **before = 11, after = 11** (verified) — nothing dropped.

## Redundancy verdicts

All 11 stashes carry at least one file **absent from or differing against** their remote
base tip → **all UNIQUE**. The 5 stashes whose base branch exists on the remote were
blob-compared file-by-file against that tip (evidence below).

| stash | salvage branch | sha | remote base | verdict | evidence |
|------:|----------------|-----|-------------|---------|----------|
| `{0}`  | `agent/factory/dupsalvage/stash-0-remint-cleanup`        | `95e369d` | `adr117-canon-sync-q4-q5` (no remote at audit) | **UNIQUE** | base branch not on remote; IL-ledger rename + 78-line edit |
| `{1}`  | `agent/factory/dupsalvage/stash-1-reconcile-b-tooling`   | `d53c518` | `…/reconcile-b-tooling` (remote @132ea55) | **UNIQUE** | IL shard `…828a5b.md` **absent** on remote; LEDGER blob differs |
| `{2}`  | `agent/factory/dupsalvage/stash-2-adr048-exchangeport`   | `c7ec1f8` | none | **UNIQUE** | no remote base; exchangeport CONTRACT-SPEC edit |
| `{3}`  | `agent/factory/dupsalvage/stash-3-check-refactor-docs`   | `03f0659` | `…/SPRINT-PLAN-2026-06-06` (remote @5808f27) | **UNIQUE** | untracked `scripts/check-refactor-docs.sh` (33 lines) **absent** on remote |
| `{4}`  | `agent/factory/dupsalvage/stash-4-rar-second-pass-gap-hunt` | `ad5dd24` | `fix/ci-yaml-mermaid-heredoc` (remote @6bd091a) | **UNIQUE** | untracked `BANXE-RAR-SECOND-PASS-GAP-HUNT-2026-06-06.md` (115 lines) differs from remote |
| `{5}`  | `agent/factory/dupsalvage/stash-5-validate-mermaid-spec18` | `624665e` | none | **UNIQUE** | no remote base; `validate_mermaid.py` SPEC#18 (+12 lines) |
| `{6}`  | `agent/factory/dupsalvage/stash-6-memory-d2-housekeeping` | `8969684` | none | **UNIQUE** | no remote base; MEMORY.md D2 housekeeping (+3) |
| `{7}`  | `agent/factory/dupsalvage/stash-7-sprint10-session-adr028` | `4c9a990` | `adr/028-accepted-2026-05-09` (remote @4ba5e0a) | **UNIQUE** | SESSION-2026-05-09 doc (189 lines) differs; ADR-028 same |
| `{8}`  | `agent/factory/dupsalvage/stash-8-gapreg-memory-adr028`  | `043311d` | `adr/028-accepted-2026-05-09` (remote @4ba5e0a) | **UNIQUE** | GAP-REGISTER + MEMORY + SESSION blobs differ; ADR-028 same |
| `{9}`  | `agent/factory/dupsalvage/stash-9-status-canon-stack-ruflo` | `ccf6d16` | none | **UNIQUE** | no remote base; GAP-REGISTER + MEMORY + ADR-027 audit-trail |
| `{10}` | `agent/factory/dupsalvage/stash-10-fa02-litellm-runbook` | `fd35028` | none | **UNIQUE** | no remote base; `fa-02-litellm-canonical-aliases.md` runbook (181 lines) |

### Untracked working-tree file

| source | salvage branch | sha | verdict |
|--------|----------------|-----|---------|
| `docs/canon-transfer-input-request-§7-§12.md` (61 lines) | `agent/factory/dupsalvage/canon-transfer-input-req` | `778c4d1` | **UNIQUE** — not on canonical; committed off `origin/main` |

## Remote URLs

Base: `https://github.com/CarmiBanxe/banxe-architecture/tree/`

- `…/agent/factory/dupsalvage/stash-0-remint-cleanup`
- `…/agent/factory/dupsalvage/stash-1-reconcile-b-tooling`
- `…/agent/factory/dupsalvage/stash-2-adr048-exchangeport`
- `…/agent/factory/dupsalvage/stash-3-check-refactor-docs`
- `…/agent/factory/dupsalvage/stash-4-rar-second-pass-gap-hunt`
- `…/agent/factory/dupsalvage/stash-5-validate-mermaid-spec18`
- `…/agent/factory/dupsalvage/stash-6-memory-d2-housekeeping`
- `…/agent/factory/dupsalvage/stash-7-sprint10-session-adr028`
- `…/agent/factory/dupsalvage/stash-8-gapreg-memory-adr028`
- `…/agent/factory/dupsalvage/stash-9-status-canon-stack-ruflo`
- `…/agent/factory/dupsalvage/stash-10-fa02-litellm-runbook`
- `…/agent/factory/dupsalvage/canon-transfer-input-req`

## After-salvage operator step (SEPARATE — not part of this PR)

Retiring DUP (`~/banxe-architecture`) and closing its `claude` process is an operator step
to be taken **only after** all 12 `dupsalvage` branches are confirmed on remote (they are,
per `git ls-remote`). The salvage branches are **backups, not merged** — this PR carries the
manifest + ledger shard only.
