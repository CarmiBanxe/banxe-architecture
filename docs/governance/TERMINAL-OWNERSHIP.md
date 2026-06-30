# Terminal Ownership & Write-Zone Registry

> **Status:** governance registry (single source of terminal ownership + write-zones). **Date:** 2026-06-30.
> **Pointer-first and additive** — it registers *who owns what* and *where each terminal may write*, and it
> defers all *mechanism* (branch namespace, lease, single-writer, destructive-action protection) to the
> existing canon it points to. It does **not** restate that canon, and it complements (does not overlap) the
> in-flight terminal-topology ADR.

## 1. Ownership registry
Three terminals operate over this repository and its sibling `banxe-emi-stack`. Their roles:

| Terminal | Role | Primary responsibility |
|---|---|---|
| **A** (factory / left) | The Software Factory (AI agents that execute) | Engine work, the agent-engine dossier, and GAP-closure delivery. |
| **B** (right) | Legacy refactor + trading/recon delivery | Legacy-handling and the trading / reconciliation zone (which is cross-repo — see §2). |
| **Central** | Governance + diagnostics orchestration | Governance authorship; **read-only in every other terminal's zone** (single-writer authority is registered in `AGENTS.md`). |

## 2. Write-zone map (this repository, `banxe-architecture`)
Mapped from the actual top-level directory listing on `origin/main` (2026-06-30). A terminal **writes
exclusively** in its own zone; everywhere else it is **read-only**.

| Zone | Owner | Exists here? |
|---|---|---|
| `docs/agent-engine-dossier/` | **A** | ✅ yes |
| `docs/governance/`, `governance/`, `constitution/`, `canon/`, `.canon/`, `decisions/`, `adrs/`, `docs/adr/`, `docs/canon/` | **Central** | ✅ yes |
| `agents/` (passports / souls) | **Central** authorship under the CLASS_B governance gate; factory-assisted | ✅ yes |
| `ledger/`, `instruction-ledger/` | **shared, append-only** — any terminal appends ONLY its own session shard (ADR-059); never edits another's shard or the generated ledger | ✅ yes |
| Engine **code** (the dossier's `services/engine` subject) | **A** | **[НЕИЗВЕСТНО] here** — no `services/` directory exists in `banxe-architecture`; engine code lives in **`banxe-emi-stack`** (separate repo). A's code-write zone is cross-repo and out of this map. |
| Legacy / trading / reconciliation | **B** | **[НЕИЗВЕСТНО] here** — no `legacy/`, `trading/`, or `recon` directory exists in `banxe-architecture`; these are **`banxe-emi-stack`** zones. B has **no registered write-zone in this repository** until one is declared. |

> **No zone was invented.** Any directory not listed above is unassigned; assign it by amending this registry,
> not by ad-hoc writing.

## 3. Concurrency rule (mechanism is canon — pointer, not restatement)
**Two terminals MUST NOT write the same file or module concurrently without a declared lease.** The *mechanism*
for this already exists and is **not** restated here:

- **Branch namespace** `agent/<actor>/<id>/<slug>` (`actor ∈ {central, right, factory}`) — **ADR-060**.
- **Lease / no-foreign-write / verify-branch-before-stage / `--force-with-lease`** — `.claude/rules/parallel-session-isolation.md` **Rules 1–7**, **ADR-120** (per-session worktree isolation), **ADR-121** (destructive-action protection).
- **Single-writer authority** (Central does not push/merge directly; writes go through the factory) — `AGENTS.md` §"Central Terminal".

This registry adds only the **ownership/zone facts**; the lease and isolation **how** stays in those documents.

## 4. Owner-tag convention (new)
Each IL shard and each PR **SHOULD** carry an owner tag — **`[OWNER: A | B | Central]`** — in its body or
description, so that ownership is legible at the point of work and a cross-zone write is visible in review.
This is advisory (SHOULD, not a CI gate) pending operator decision on enforcement **[НЕИЗВЕСТНО: enforce as a
gate?]**.

## 5. Relationship to the terminal-topology ADR (#902, in-flight)
PR **#902** drafts `docs/adr/ADR-153-terminal-topology-canon.md`, which defines the terminal **topology**
(the node/role graph). **This document is the complementary ownership/zone registry** — topology answers
*what the terminals are*; this answers *who owns which write-zone*. They link; neither restates the other. When
#902 merges, cross-reference its ADR number here.

## Anchors
- `AGENTS.md` §"Central Terminal" (single-writer authority) and §"CANON — Best Single Artifact".
- **ADR-060** (multi-actor branch namespace) · `.claude/rules/parallel-session-isolation.md` (Rules 1–7, lease/isolation) · **ADR-120 / ADR-121** (worktree isolation / destructive-action protection) · **ADR-059** (append-only per-session shards).
- **#902** `docs/adr/ADR-153-terminal-topology-canon.md` (in-flight terminal topology — complementary).
- Operator directive 2026-06-30 (this registry's origin; resolves central-terminal recommendations 1, 2, and the zone part of 7).
