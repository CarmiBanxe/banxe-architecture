---
id: ADR-136
title: agentmemory shared-memory substrate — Factory fork vs Project fork, sensitive-domain OUT OF SCOPE, gated rollout
status: PROPOSED
date: 2026-06-27
accepted:
supersedes: []
relates:
  - "ADR-126 (Hermes Tier-1 — 3-tier memory / self-improving skills; agentmemory is the substrate, still Tier-1 read-only)"
  - "ADR-127 (Hermes Tier-1 read-only/no-dispatch boundary — memory MUST NOT confer write/dispatch authority)"
  - "ADR-130 (SOUL persona layer — no authority expansion; memory describes, never authorizes)"
  - "ADR-135 (held-out validation gate — any project-side expansion passes the gate)"
  - "ADR-098 (sandbox session recorder & replay — adjacent observability seam; KEEP, cross-link)"
  - "ADR-059 (per-session ledger shards — canonical session memory of record; KEEP, not replaced)"
  - "docs/SKILLS-MATRIX.md Skill 1 Context Memory Sync (CMS) — process-level memory; KEEP, cross-link)"
  - "ADR-117 (factory/project perimeter — fork split rides this boundary)"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
  - "rohitg00/agentmemory (github.com/rohitg00/agentmemory) — external reference, NOT imported"
il_anchor: IL-560
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
scope: BANXE-factory-only
concept_only: true
external_ref: "github.com/rohitg00/agentmemory (Claude Code / Codex / Cursor / Hermes / OpenClaw / MCP; session+tool context capture, replay/import, shared memory server, hooks, MCP tools) — referenced, NOT imported"
---

# ADR-136 — agentmemory shared-memory substrate (Factory fork vs Project fork, gated)

## Context

`rohitg00/agentmemory` is an external project that captures session/tool context and exposes it as a
**shared memory server** with hooks and MCP tools, across Claude Code / Codex CLI / Cursor / Hermes /
OpenClaw / MCP clients (replay + import). BANXE's factory agents already have *process-level* and
*record-level* memory — **CMS** (Context Memory Sync, SKILLS-MATRIX Skill 1; IL continuity / session
handoff), **ADR-059** (per-session ledger shards = the canonical memory of record), and **ADR-098**
(sandbox session recorder/replay) — but **no shared, queryable memory substrate** that several agents
read in common. agentmemory could fill that gap.

The risk is obvious against BANXE canon: a shared memory server that ingests session/tool context can
absorb **secrets, customer PII, payment/KYC/AML/ledger state**, and — if memory were treated as
authority — let an agent "remember" a permission it was never granted. Canon already forbids authority
expansion (ADR-130) and fail-open behaviour in sensitive domains. This ADR fixes **how** agentmemory may
be adopted so it stays inside that canon. It is **docs/governance only** — the repo has no MCP/memory
config surface today, so **no config/runtime/secret is added** (point 3: stub only if a surface already
exists; it does not).

## Decision

**Adopt agentmemory only as a Tier-1, read-only-with-respect-to-authority shared memory substrate for
*factory* agents, split into two forks, with sensitive project domains OUT OF SCOPE by default and a
phased, gated rollout. No secrets, no authority, no production-state capture without a separate ADR.**

### Two forks (ADR-117 perimeter)
- **Factory fork** — serves factory-side agents (Claude Code / OpenClaw / Hermes Tier-1 per ADR-126/127)
  on the factory node only. Captures *factory* session/tool context (spec, ADR, ledger, CI signals).
  This is the only fork enabled at adoption.
- **Project fork** — a SEPARATE deployment for project agents, **disabled by default**. It may capture
  only NON-sensitive, NON-prod project context, and only after the gated rollout below. The two forks
  share no store; memory never crosses the factory↔project perimeter.

### OUT OF SCOPE by default (never captured/replayed without a separate ADR + operator + IronClaw sign-off)
- **payment-core, KYC, AML, sanctions, ledger** state; any **secrets-bearing flow** (tokens, keys,
  `.env`, credentials); customer PII. The RED zone is AI-FORBIDDEN to the substrate by default.

### Mandatory boundaries
1. **Redaction at capture** — a redaction filter strips secrets/PII before anything is stored; capture
   is deny-by-default for sensitive patterns (fail-closed: on uncertainty, drop, don't store).
2. **Retention** — bounded, configurable retention with purge; no indefinite accumulation of session
   context. Retention/redaction/replay-scope are config-as-data (operator-owned), never hardcoded.
3. **Replay boundaries** — replay/import is scoped to the same fork + the same perimeter; cross-fork or
   cross-perimeter replay is forbidden. Replay is observability, not re-execution of privileged actions.
4. **Read-only w.r.t. authority (ADR-130/127)** — memory **describes**, it never **authorizes**. A
   recalled fact confers no merge/deploy/payment/AML/dispatch right; authority stays in CI gates + ADRs.
   A recalled item is provisional and re-verified before use (mirrors `parallel-session-isolation` /
   memory-policy canon).

### Rollout phases (gated)
1. **Factory-only** — Factory fork on the factory node; non-sensitive factory context; redaction +
   retention enforced. (Adoption starts and may stop here.)
2. **Non-prod project** — Project fork in a NON-production environment only, non-sensitive context, RED
   zone still excluded. Entry requires operator approval.
3. **Gated project expansion** — any widening of project scope passes the **ADR-135 held-out validation
   gate** (no regression on boundary/redaction checks) **plus** operator + IronClaw (security-review)
   sign-off. Sensitive domains remain out of scope absent their own ADR. Fail-closed throughout.

## Duplication Audit (ADR-102)

1. **Repo-wide search** — **no prior agentmemory/rohitg00 reference** (`git grep` over `origin/main` =
   none); no shared-memory-substrate ADR. Adjacent memory canon is **distinct**, KEEP + cross-link:
   **CMS** = a *process* skill (IL continuity/handoff), not a deployed store; **ADR-059** = the *ledger*
   memory of record (append-only shards), unchanged and authoritative; **ADR-098** = *sandbox* session
   recorder/replay (observability over advisory seams), a different surface. agentmemory is a new
   *queryable shared substrate* over these — additive, not a rewrite.
2. **Source-of-truth + consumers.** The ledger (ADR-059) remains the canonical record; agentmemory is a
   convenience substrate, never the source of truth and never an authority source.
3. **No hidden dependencies / no import.** rohitg00/agentmemory is an **external reference only** — no
   code, plugin, server, hook, MCP config, or dataset is imported; no `.env`/secret introduced.
4. **Decision per match:** CMS / ADR-059 / ADR-098 / ADR-126 → **KEEP + cross-link**; ADR-136 → **ADD**
   (new substrate governance). No delete, no merge, no parallel duplicate.

## Consequences

- The factory gains a pre-bounded path to a shared memory substrate: Factory-fork-first, sensitive
  domains out of scope, redaction/retention/replay enforced, memory read-only w.r.t. authority, and any
  project expansion gated (ADR-135 + operator + IronClaw).
- Canon is preserved: no authority expansion (ADR-130), no fail-open in sensitive domains, perimeter
  intact (ADR-117), Hermes Tier-1 read-only honoured (ADR-126/127).
- **No runtime change, no secret handling.** Actual deployment (forking the repo, standing up a server,
  wiring hooks/MCP, redaction/retention config) is a **separate, gated work item** — out of scope here.

## Anchors

- External reference (not imported): `github.com/rohitg00/agentmemory`.
- KEEP + cross-link: CMS (SKILLS-MATRIX Skill 1), ADR-059 (ledger shards), ADR-098 (sandbox replay),
  ADR-126/127 (Hermes Tier-1 memory/read-only), ADR-130 (no authority expansion), ADR-135 (held-out
  gate), ADR-117 (perimeter), ADR-102 (Duplication Audit). Enforcement = CI gates + these ADRs; the
  substrate carries no authority and no secrets.
