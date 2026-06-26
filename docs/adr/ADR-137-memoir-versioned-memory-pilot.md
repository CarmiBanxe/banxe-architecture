---
id: ADR-137
title: Memoir versioned-memory — factory-only alternative-backend PILOT under ADR-136 boundaries (resolves BL-SCRIPT-01)
status: ACCEPTED
date: 2026-06-27
accepted: 2026-06-27
acceptance_note: "ACCEPTED applies to the governance decision (Outcome B) ONLY. The executable Memoir pilot stays a SEPARATE future gated work item; it MUST NOT start until all Pilot Entry Preconditions are met."
supersedes: []
relates:
  - "ADR-136 (agentmemory substrate — the governing envelope; Memoir is a pilot UNDER it, not a replacement)"
  - "ADR-126/127 (Hermes Tier-1 read-only — Memoir stays Tier-1, read-only w.r.t. authority)"
  - "ADR-130 (no authority expansion — memory branch/merge/rollback are over memory CONTENT, never repo/authority)"
  - "ADR-135 (held-out validation gate — any expansion beyond the factory pilot passes the gate)"
  - "ADR-120 (per-session worktree isolation — Memoir's branch-awareness maps onto this)"
  - "ADR-098 (sandbox session recorder/replay) + ADR-059 (ledger shards = memory of record) — KEEP, cross-link"
  - "docs/SKILLS-MATRIX.md Skill 1 Context Memory Sync (CMS) — KEEP, cross-link"
  - "docs/backlog/FACTORY-SCRIPTS-TOOLS-BACKLOG.md BL-SCRIPT-01 (Memoir) — this ADR RESOLVES it"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
  - "zhangfengcdt/memoir (github.com/zhangfengcdt/memoir) — external reference, NOT imported"
il_anchor: IL-561
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
scope: BANXE-factory-only
concept_only: true
external_ref: "github.com/zhangfengcdt/memoir (Git-like versioned agent memory: branch/commit/merge/rollback, semantic paths, blame/checkout; Claude Code / Codex / Hermes / OpenClaw / MCP) — referenced, NOT imported"
---

# ADR-137 — Memoir versioned-memory: factory-only alternative-backend pilot (under ADR-136)

## Context

`zhangfengcdt/memoir` offers **Git-like versioned agent memory** — branch / commit / merge / rollback,
semantic paths, blame / checkout — over Claude Code / Codex / Hermes / OpenClaw / MCP. It is already a
tracked backlog candidate, **BL-SCRIPT-01** (`docs/backlog/FACTORY-SCRIPTS-TOOLS-BACKLOG.md`, PROPOSED,
flagged "Duplication Audit vs CMS — keep/extend, not new; no secrets/PII; medium trust").

**ADR-136 already merged** the BANXE shared-memory substrate decision (agentmemory): factory/project
fork split, sensitive domains OUT OF SCOPE, redaction/retention/replay, read-only-w.r.t.-authority,
gated rollout. So the live question is **Memoir vs the ADR-136 agentmemory line**, against the decision
criteria below.

### Comparison (Memoir vs ADR-136 agentmemory)

| Criterion | agentmemory (ADR-136, merged) | Memoir (BL-SCRIPT-01) |
|---|---|---|
| Core model | session/tool-context capture + replay/import; shared memory server | **Git-like versioned memory**: branch/commit/merge/rollback |
| branch/worktree awareness | implicit (per-fork) | **explicit** — maps cleanly onto ADR-120 per-session worktrees |
| memory debugging / blame / rollback | replay only | **blame / checkout / rollback** — real time-travel debugging |
| semantic paths | — | yes |
| redaction / retention / replay safety | defined by ADR-136 (must be enforced) | **NOT inherent** — same risk; ADR-136 boundaries apply equally |
| duplication risk w/ agentmemory | n/a (it is the line) | **HIGH as a 2nd substrate**; LOW as a scoped pilot for a distinct capability |
| authority | read-only w.r.t. authority | merge/rollback are over **memory content**, must NOT touch repo/authority |

**Net:** Memoir is **not strictly superior as a substrate**, but it adds a **distinct, genuinely useful
capability agentmemory lacks** — branch-aware versioned memory with blame/rollback debugging. That is
neither a pure reject (it has explicit value) nor grounds to replace the just-merged ADR-136.

## Decision — Outcome **B**: factory-only alternative-backend PILOT under ADR-136 boundaries

**Allow Memoir ONLY as a factory-only, gated PILOT / alternative memory backend, governed by the FULL
ADR-136 boundary envelope. agentmemory (ADR-136) remains the primary substrate line; Memoir does NOT
replace it and is NOT a second production substrate.** BL-SCRIPT-01 is hereby **resolved** to this
decision.

### Inherited boundaries (ADR-136, applied verbatim)
- **Factory fork first** — pilot runs on the factory node only; **Project fork disabled by default**;
  no cross-perimeter memory (ADR-117).
- **Sensitive domains OUT OF SCOPE by default** — payment-core, KYC, AML, sanctions, ledger,
  secrets-bearing flows, customer PII (RED zone AI-FORBIDDEN); no capture/replay without a separate ADR
  + operator + IronClaw sign-off.
- **Redaction at capture (fail-closed) · bounded retention+purge (config-as-data) · replay scoped to
  fork+perimeter** — identical to ADR-136; Memoir provides none of these inherently, so they are a
  precondition of the pilot.
- **Read-only w.r.t. authority (ADR-130/127)** — memory **describes, never authorizes**.

### Memoir-specific guards (additive)
1. **Memory VCS ≠ repo authority.** Memoir branch/commit/merge/rollback/checkout operate **only on
   memory content**; they confer **no** git/repo authority, no merge/deploy/payment/dispatch right. A
   memory "merge" or "rollback" never mutates code, the ledger, or production state.
2. **Semantic paths / blame respect redaction** — versioned/semantic paths and blame output are subject
   to the same OUT-OF-SCOPE redaction; rollback cannot resurrect redacted/sensitive content.
3. **One substrate per fork.** To avoid duplication, a fork runs **either** agentmemory **or** the
   Memoir pilot — never both as competing production stores; the ledger (ADR-059) stays source of truth.

### Rollout (gated)
1. **Factory-only pilot** — evaluate the versioning/blame/rollback value on factory context, under all
   inherited boundaries. (Starts and may stop here.)
2. **Non-prod project** — only via operator approval, non-sensitive/non-prod, RED zone excluded.
3. **Supersede/extend ADR-136** — Memoir may replace or extend the agentmemory line **only via a future
   ADR (Outcome C)** if the pilot proves explicit superiority AND duplication is avoided; that ADR
   passes the **ADR-135 held-out validation gate** + operator + IronClaw. Until then ADR-136 is primary.

## Pilot Entry Preconditions (gating)

> **ACCEPTED (2026-06-27) is a governance decision (Outcome B) ONLY.** It authorises the *policy* that
> Memoir may be piloted under this envelope — it does **NOT** start any executable pilot. The executable
> Memoir pilot is a **SEPARATE future gated work item** and MUST NOT begin until **every** item below is
> implemented, verified, and operator-signed. Any unmet item ⇒ **fail-closed, no pilot.**

| # | Precondition | Gate |
|---|---|---|
| 1 | **Redaction-at-capture (fail-closed)** implemented and verified — secrets/PII stripped before storage; deny-by-default on uncertainty (drop, don't store). | MUST be implemented + tested |
| 2 | **Bounded retention + purge** as **config-as-data** (operator-owned), no indefinite accumulation. | MUST be config, not hardcoded |
| 3 | **Replay scoped to fork + perimeter (ADR-117)** — no cross-fork / cross-perimeter replay; replay is observability, never re-execution of privileged actions. | MUST be enforced |
| 4 | **One-substrate-per-fork enforced** — a fork runs **agentmemory XOR Memoir**, never both as competing production stores; ledger (ADR-059) stays source of truth. | MUST be enforced |
| 5 | **Factory fork ONLY; Project fork disabled by default** — no project deployment without operator approval. | MUST default-off |
| 6 | **Sensitive domains OUT OF SCOPE** — payment-core, KYC, AML, sanctions, ledger, secrets-bearing flows, customer PII; RED zone AI-FORBIDDEN. | MUST be excluded |
| 7 | **No authority expansion (ADR-130/127)** — memory VCS (branch/merge/rollback/checkout) operates on memory content only; never code/ledger/prod/dispatch. | MUST hold |
| 8 | **Any expansion beyond the factory pilot** → **ADR-135 held-out validation gate** (no regression on boundary/redaction checks) **+ operator + IronClaw sign-off**. | MUST pass the gate |

**Entry rule:** the executable pilot may start **iff** 1–7 are implemented+verified+operator-signed; any
widening past the factory pilot additionally requires 8. Until then ADR-136/agentmemory remains the
primary substrate and **no Memoir runtime exists**. This ADR (and this acceptance) adds **no runtime, no
code, no config, no secret, no import** of `github.com/zhangfengcdt/memoir`.

## Duplication Audit (ADR-102)

1. **Repo-wide search** — Memoir is referenced only as **BL-SCRIPT-01** (backlog) + MASTER-PLAN/ROADMAP
   K-5 context-sync notes; **no prior Memoir ADR**. The duplication risk is **real and named**: Memoir
   overlaps the ADR-136 agentmemory substrate.
2. **Resolution (no duplication created).** Memoir is **not** deployed as a second competing substrate;
   it is a **scoped factory-only pilot under ADR-136's envelope**, justified solely by its distinct
   versioning/blame capability. agentmemory stays primary; "one substrate per fork" forbids running both
   as production stores. CMS / ADR-059 / ADR-098 / ADR-126 → KEEP + cross-link (process / record /
   sandbox-replay / Hermes-memory — all distinct surfaces).
3. **No import / no surface.** No code/plugin/server/MCP/dataset imported; repo has no MCP/memory config
   surface → **docs/governance only, no config stub** (no runtime/secret). BL-SCRIPT-01 status updated to
   point here (one-line pointer; not a new parallel doc).
4. **Decision per match:** ADR-136 / agentmemory line → **KEEP (primary)**; CMS/059/098/126 →
   **KEEP + cross-link**; BL-SCRIPT-01 → **RESOLVE (pointer to ADR-137)**; ADR-137 → **ADD** (the pilot
   decision). No delete, no merge, no second substrate.

## Consequences

- Memoir's distinct value (branch-aware versioned memory, blame, rollback) is captured as a **gated
  factory-only pilot** without duplicating agentmemory and without any authority expansion.
- BL-SCRIPT-01 stops being an open/ambiguous candidate; the decision and its boundaries are canon.
- **No runtime change, no secrets, no authority.** Standing up the pilot (fork, server, hooks/MCP,
  redaction/retention config) is a **separate gated work item** — out of scope here.

## Anchors

- External reference (not imported): `github.com/zhangfengcdt/memoir`.
- ADR-136 (governing envelope), ADR-126/127 (Tier-1 read-only), ADR-130 (no authority expansion),
  ADR-135 (held-out gate), ADR-120 (worktree isolation), ADR-098/059 (replay/record), CMS (Skill 1),
  BL-SCRIPT-01 (resolved), ADR-102 (Duplication Audit). Enforcement = CI gates + these ADRs; the pilot
  carries no authority and no secrets.
