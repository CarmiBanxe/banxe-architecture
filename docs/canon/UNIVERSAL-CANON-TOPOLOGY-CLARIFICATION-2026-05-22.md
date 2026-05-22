# Universal Canon — Topology Clarification (House rule 10)

Date: 2026-05-22 17:00 CEST
Status: BINDING (extends Universal Canon section 4 and Part B house rules)
Source: operator clarification 2026-05-22 17:00 CEST; Central revert incident 2026-05-22 (github_status.py on evo1, commit 42afb18)
Supersedes: any prior interpretation in this session that Central could deliver tasks to Terminal A or Terminal B for execution

## Purpose

This document corrects a topological misunderstanding observed during the 2026-05-22 session. Central (Perplexity) was treating Terminal B as a remote executor receiving prompts via the operator; this was incorrect. Each terminal works autonomously on its own bounded context and is not accepting external task assignments. Coordination between terminals happens asynchronously through merged main, not through direct delivery.

## Topology (corrected)

- **Central (Perplexity)** — coordinator. Works only inside banxe-architecture repo through docs, IL, ADR, runbooks, and scripts. Issues shell commands and Claude Code prompts that Central itself executes in its own session on Legion. Does NOT deliver work assignments to Terminal A or Terminal B.
- **Terminal A** — autonomous work on Factory integration. Bounded context is its own; reads main when needed; does not accept assignments from Central.
- **Terminal B** — autonomous work on legacy refactor. Bounded context is its own; reads main when needed; does not accept assignments from Central.
- **Parallel Central processes** — other Perplexity sessions or direct operator execution may run in parallel. Coordination is by main merge only.
- **Operator (mmber)** — directs priorities for Central. Operator does NOT relay Central's prompts into other terminals; other terminals run independently.

## House rule 10 (binding from this PR onwards)

- Central works only in its own scope: banxe-architecture repo (docs, IL, ADR, runbooks, scripts) and read-only diagnostics on evo1 (ssh inspection, no writes).
- Central does NOT write code or config in zones owned by other terminals: not in /data/banxe/guardian/ on evo1 (Guardian source), not in banxe-emi-stack production paths, not in factory integration zones owned by Terminal A.
- Central artefacts targeted at other terminals are documents (PREP, discovery, ADR) merged into main; the other terminal reads them when it chooses. No direct task delivery.
- Central markers in artefacts: TARGET = CENTRAL — bash on LEGION, or TARGET = CENTRAL — CLAUDE CODE TUI on LEGION, or TARGET = CENTRAL — ssh evo1 (read-only). Markers like TARGET = TERMINAL B are forbidden because Central does not own Terminal B's execution.
- If Central's revert on evo1 happens (e.g. commit 42afb18 reverting github_status.py), Central treats it as a signal that the zone is owned by another process and steps out. Central does NOT retry without explicit operator authorisation that the zone is free.

## What this corrects

- Earlier in this session Central used [ TARGET: TERMINAL B — CLAUDE CODE ] markers in prompts. This was a topological error. The work was actually being done by Central itself in Claude Code TUI on Legion. No tasks were ever delivered to Terminal B; the markers were a misnaming.
- Central also wrote github_status.py directly to /data/banxe/guardian/ on evo1. This was a scope violation: Guardian source is not Central's zone. The parallel revert (commit 42afb18) was the correct enforcement response. Central will not revisit that file without explicit operator authorisation that no other process owns the Guardian webhook implementation work.

## Acceptance

- All future Central artefacts use only the corrected TARGET markers above.
- Universal Canon section 4 should be read as supplemented by this document until a consolidated rewrite happens.
- House rule 10 is BINDING and durable from the merge of this PR onwards.

=== END OF TOPOLOGY CLARIFICATION (snapshot 7fae999) ===
