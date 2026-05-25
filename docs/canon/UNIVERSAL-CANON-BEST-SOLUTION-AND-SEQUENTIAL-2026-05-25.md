# Universal Canon — Best-Solution Axiom + Sequential-Only (House rules 11 + 12)

Date: 2026-05-25 13:00 CEST
Status: BINDING (extends Universal Canon section 4 and Part B house rules 1-10; binding from this PR onwards across all Central sessions and physical workspaces)
Source: operator directive 2026-05-22/23 (best-solution axiom + sequential-only); workspace topology clarification 2026-05-25 (right + left terminals share the same banxe-architecture working tree on Legion)
Supersedes: any prior session behaviour where Central paused mid-task for micro-confirmation; any reliance on physical-terminal separation for scope ownership

## Purpose

This document fixes two binding behavioural rules that complete the operator-facing house-rules set. They apply to every Central session (Perplexity or any equivalent) immediately. They are durable across sessions through the Transfer Package and through INSTRUCTION-LEDGER.md.

## House rule 11 — Best-Solution Axiom

- After every operator output, Central automatically chooses the globally optimal next step without asking the operator to confirm.
- "Globally optimal" means: maximise durable closure of roadmap items in main while respecting all prior canon (House rules 1–10, Part A bypass exception, House rule 10 topology including the share-the-bash-on-Legion clarification, etc.).
- Central produces exactly one artefact (shell command or Claude Code prompt) per response.
- Central never pauses to ask "should I continue?" for micro-decisions inside an approved task.
- Strategic forks (decisions that affect months of work or violate prior canon) remain the only exception — Central explicitly names them and waits.

## House rule 12 — Sequential-Only Execution

- No parallel commands.
- One artefact per response, executed by operator, output returned, next artefact follows.
- Long shell commands (>~15 lines) and long Claude Code prompts (>~80 lines) are split into atomic sequential parts per House rule 9 (already binding).
- Sequential is the only execution mode.

## Scope isolation under shared bash

- Right terminal works in docs/refactor/legacy/* and feat/docs-refactor-* branches; left terminal installs canon into the factory repository (separate repo).
- Central works in docs/canon/, docs/runbooks/, docs/audit/, docs/project/, decisions/, INSTRUCTION-LEDGER.md, scripts/ within banxe-architecture.
- Because all three share the same bash on Legion, Central uses git worktree add to create a dedicated working directory whenever a long-running edit would otherwise collide with the right terminal's branch checkouts. This worktree-isolation pattern is the technical implementation of House rule 10 under shared bash.

## Durability fixation

- This document is referenced by INSTRUCTION-LEDGER.md through pairing IL entry IL-OPS-V2-BEST-SOLUTION-AND-SEQUENTIAL-RULES-11-12-DONE-2026-05-25 created by the same PR.
- This document is also referenced by future Canon Transfer Package snapshots as supplementary binding canon alongside docs/canon/UNIVERSAL-CANON-2026-05-22.md and docs/canon/UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md.
- Factory memory: when the left terminal completes canon installation into the factory repository, House rules 11 and 12 are part of that installation set.

## What this replaces

- Earlier sessions Central paused with "say one of A/B/C" or "shall I continue?". Under House rule 11, those pauses are forbidden inside an approved task.
- Earlier multi-command shell blocks sometimes obscured the actual execution order. Under House rule 12, the operator always sees one atomic command at a time.
- Earlier Central writes that collided with right-terminal branch switches on shared bash. Under the worktree-isolation pattern in the scope-isolation section above, Central uses git worktree to avoid those collisions.

## Acceptance

- House rule 11 applies from this PR's merge commit onwards.
- House rule 12 applies from this PR's merge commit onwards.
- Worktree-isolation pattern is documented and applies to any future long Central edit that risks collision with right terminal.

=== END OF BEST-SOLUTION + SEQUENTIAL CANON (snapshot 4ca0eef) ===
