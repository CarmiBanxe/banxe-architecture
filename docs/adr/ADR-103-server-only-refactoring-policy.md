---
id: ADR-103
title: Server-only refactoring & smart-refactor promotion gate
status: ACCEPTED
date: 2026-06-16
accepted: 2026-06-16
supersedes: []
related:
  - "ADR-040-ai-execution-policy.md (meta- vs inference-plane routing — model placement, NOT exec location)"
  - "ADR-051-coding-execution-decision.md (which coder runs — Claude vs local, NOT exec location)"
  - "ADR-102-no-smart-refactor-without-duplication-verification.md (refactor discipline; same agent scope)"
il_anchor: IL-248
scope: BANXE-only
concept_only: false
---

# ADR-103: Server-only refactoring & smart-refactor promotion gate

**Status:** ACCEPTED — 2026-06-16
**IL:** IL-248
**Applies to:** Claude Code / MetaClaw / every factory agent performing refactoring,
legacy-handling, repo mutation, or secret use. Two mandatory parts — a server-only
**execution** barrier and a smart-refactor **promotion** gate (both STOP-barriers).

## Context

The current contour is hybrid: refactoring and legacy-handling have been executing
**locally on the operator's machine (`mark-legion`)** rather than on a secured server:

- **M0 track:** the legacy archive at `/mnt/c/Users/.../banxe.rar` (6.4 GB, RAR5
  encrypted) is unpacked into `/tmp/bx-legacy`, with utilities in `/tmp/bx-legacy-tools`
  — all on the local OS.
- **Fix A/B (banxe-emi-stack #36):** the factory cloned to `/tmp/emi-fix` and pushed
  from the local environment.
- **Secrets** (`BANXE_RAR_PASSWORD`, the archive password; the Tailscale authkey) were
  entered into the **local shell**.

This places legacy source, secrets, and refactor git-operations on an operator
workstation — a security exposure (local disk, local process table, local shell
history). The operator requires all such work to run **only on servers**.

## Decision — PART 1: Server-only refactoring (execution barrier)

1. **Server-only execution.** All refactoring and legacy-code handling — archive
   unpacking, snapshotting, inventory/mapping M0–Mn, analysis, and **any factory code
   edits** — run **only on a secured server** (e.g. `evo1` / a dedicated runner),
   **never on an operator's local machine.**
2. **Local machine = thin client.** An operator's local machine may only act as a thin
   client (`gh` / `ssh` to drive the server). It stores **no** legacy sources, no repo
   working copies for refactoring, and **no secrets**.
3. **Hard prohibitions.** No unpacking/processing of legacy archives, and no
   refactoring git-operations, in the local OS `/tmp` (or anywhere on a local
   workstation). No secret values entered into a local shell.
4. **Secrets live server-side only** — in a server vault or GitHub Actions secrets;
   never on local disk, local env, or local shell history.

## Decision — PART 2: Smart-refactor promotion gate

5. **Promotion only after server-side refactoring is complete.** Moving a result into
   a target repository happens **only after** the refactoring finished on the server,
   and **only** via the **smart-refactor** discipline — i.e. a mandatory repo-wide
   **Duplication Audit (ADR-102)** on the promotion PR:
   1. repo-wide (semantic + textual) search for duplicate implementations, interfaces,
      DTOs, helpers, SQL, migration fragments, and docs;
   2. identify the **source-of-truth** and **every consumer**;
   3. **no delete/merge** until absence of hidden dependencies is positively confirmed;
   4. a **"Duplication Audit"** section recording matches + decision (keep / merge / delete)
      + risks;
   5. **if in doubt → fail-closed and escalate to a human.**
6. **A promotion PR is rejected** if it carries a result that was **not** produced by
   the server-side refactor, **or** if it lacks the completed Duplication Audit.

## Canonical pipeline

```
[server workspace setup]                  # secured server; no operator local disk
  → [legacy ingest to server]             # BANXE.RAR uploaded to the server, NOT via local /mnt/c
  → [server-side refactor (M-track M0..Mn)]
  → [Duplication Audit (ADR-102)]         # repo-wide; source-of-truth + consumers; keep / merge / delete
  → [promotion PR into the target repo]   # only after the two gates above pass
  → [review / merge]                      # protected-main PR flow (no bypass)
```

The operator's local machine only **initiates** this via `gh` / `ssh`; every step
above executes on the server.

## Current-state GAP (pre-policy debt)

The following were performed **locally, before this policy**, and are flagged as
**pre-policy debt to be migrated to the server**:

- **M0 track** — archive unpack + `/tmp/bx-legacy` snapshot + `/tmp/bx-legacy-tools`
  utilities + `BANXE_RAR_PASSWORD` in the local shell, all on `mark-legion`.
- **Fix A / Fix B (banxe-emi-stack #36)** — clone to `/tmp/emi-fix` + pushes from the
  local environment; Tailscale authkey context local.

These remain valid work, but their **execution location is non-compliant** and must be
re-homed to the server contour (no re-doing of the analysis is implied — only the
workspace/secret location changes).

## Migration outline (non-binding; concretised in a later infra ADR/sprint)

- **Server workspace.** A secured server (`evo1` or a dedicated CI runner) hosts the
  refactor/legacy workspace (e.g. `/srv/banxe-legacy/…`), access-controlled and
  audited; operator local disks hold none of it.
- **Archive ingress.** `BANXE.RAR` reaches the server **without** going through a local
  `/mnt/c` step — uploaded directly to the server (e.g. scp/rsync into the vault area,
  or a server-side pull), with the manifest checksums (ADR/IL anchored) verified there.
- **Factory over SSH.** The factory drives work on the server via `ssh` (or a
  self-hosted runner job); cloning, edits, and git push happen server-side.
- **Secrets server-side only.** `BANXE_RAR_PASSWORD`, Tailscale authkeys, and any
  provider secrets live in a server vault / GH Actions secrets and are injected into the
  server job at runtime — never typed into a local shell.

## Consequences

- **Positive:** legacy sources, secrets, and refactor operations leave operator
  workstations → reduced attack surface and a single audited execution locus.
- **Cost:** a server workspace + ingress path must be stood up (a follow-up infra
  sprint); until then, the M0/Fix-A/B debt above is tracked, not silently accepted.
- **Enforcement:** new refactoring/legacy work that runs locally is a policy violation;
  the server contour is the only compliant locus.

## Duplication Audit (ADR-102)

Searched `docs/adr/`, `.claude/rules/`, `AGENTS.md`, `docs/canon/` for (a) an existing
execution-location / server-only / thin-client policy and (b) an existing
promotion-gate policy. **No duplicate of either.** Adjacent ADRs govern different
axes — **ADR-040** (meta- vs inference-**plane** model routing), **ADR-051** (which
**coder**: Claude vs local), **ADR-047** (cost-governance — matched the word
"promotion" but governs cost tiers, not refactor-result promotion), and **ADR-102**
(the Duplication-Audit rule this gate *invokes*, not duplicates). Neither defines the
physical execution **location** of refactoring nor a **promotion gate** for moving
refactor results into repos. Decision: **keep** (new policy); no merge/supersede;
risk: none (additive, tightens security). The hard rule is mirrored into `AGENTS.md`
and `.claude/rules/agents.md`.

## References

- ADR-040 (AI execution plane), ADR-051 (coding execution decision), ADR-102
  (refactor duplication discipline); IL-248.
