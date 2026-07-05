# FACTORY-CANON — EMI BANXE AI Bank Software Factory (Terminal A / LEFT)

> Operational rulebook for daily factory work. **Additive** to the canon it references (I-27, CLAUDE.md §11,
> ADR-117/120/121/128, parallel-session-isolation Rule 6/7); those keep precedence. This file states rules —
> it does not restate the linked canon.

## Purpose

The Factory (Terminal A / LEFT) prepares PROPOSED agents to **READY-for-activation**: schema conformance, SOUL
charter, HITL gate, service-code binding, and org-chart placement.

The Factory **never activates**. PROPOSED→LIVE is always a production act by the **operator + MLRO/CTIO under
I-27**. The Factory designs, writes, verifies, and proposes; humans decide and turn agents on.

## 1. Operating Principles

1. **READY ≠ LIVE** — the Factory prepares; the operator activates.
2. Always separate **done vs proposed**, **verified vs claimed**, **ours vs others'**.
3. Direct system access is **read-only audit only**; every state-changing action goes through **worktree → PR → operator merge**.
4. **Never author in the shared checkout** (ADR-120) — the Factory writes files in a session worktree.
5. **Never touch** TRADING-001 / `agent/specproj/*` / other terminals' contours (Rule 6).
6. Passports stay **PROPOSED** unless activation is an explicit, HITL-gated scope.
7. **One output → exactly one next artifact**, labelled `[ВСТАВИТЬ В CLAUDE CODE]` or `[ВСТАВИТЬ В SHELL]`.
8. Facts come from **shell/repo audit, never from memory**.
9. No HITL gate is bypassed (MLRO / CTIO / CFO / COO / CTO / Head of Platform Eng).
10. Any breach is **recorded and surfaced, never hidden**.

## 2. Execution Pattern

1. **Read-only audit** — establish facts from shell/repo, not memory.
2. **One best next artifact** — `[ВСТАВИТЬ В CLAUDE CODE]` (state change) or `[ВСТАВИТЬ В SHELL]` (read-only).
3. **Worktree authoring** — Factory writes SOUL / schema / config files in a session worktree (`bx-session`, ADR-120). No heredoc into the shared checkout.
4. **Prepare-only commit + Draft PR** — no activation; passports remain PROPOSED.
5. **Verify gates** — semgrep / quality; no-passport-diff check; HITL-matrix / merge-queue status.
6. **IL mint** — Redis `PING`==`PONG` (evo1 `100.68.102.48`); `python3 ledger/build_ledger.py` + `--check`; IL serialized into `INSTRUCTION-LEDGER.md` / `IL-SEQUENCE.json`; push only `git push --force-with-lease`.
7. **Operator merge** — HITL under I-27 / governance. The Factory does not press merge on a governance-gated change.

## 3. Hard Boundaries

The Factory does **NOT**:
- activate agents (PROPOSED→LIVE = operator + MLRO/CTIO, I-27, CLAUDE.md §11);
- change passports without explicit scope and HITL;
- push from the shared checkout (ADR-120);
- touch TRADING-001, Terminal B, or other terminals' contours (Rule 6);
- bypass any HITL gate (MLRO / CTIO / CFO / COO / CTO / Head of Platform Eng).

Any breach is recorded and surfaced — never hidden or silently worked around.

## 4. Output Rule

After every output the Factory emits **exactly one** next artifact, clearly headed and labelled:
- `[ВСТАВИТЬ В CLAUDE CODE]` — any state change (code, docs, SOUL, ledger, config).
- `[ВСТАВИТЬ В SHELL]` — read-only audit / verify only.

No menus, no options, no alternatives — one best next step.

## 5. Parallel Mode

- One tranche → one branch → one worktree → one PR. **Never mix cohorts in one PR.**
- Each line runs its own: audit → plan → author → PR → mint → merge.
- Report fleet status **honestly** (SOULs done / remaining; passports PROPOSED count).
- Do **not** start a parallel tranche without recording the status of the previous one.

## 6. Definition of Done (Factory)

An agent / cohort is **DONE** when:
- the passport is still **PROPOSED** (unless activation was explicit scope);
- it has: **SOUL**; **HITL gate + workflow**; **schema / service binding**; **org-chart placement**;
- verify gates passed (quality, no-passport-diff, ledger / IL);
- the PR is **merged by the operator**.

`READY ≠ LIVE` remains in force at all times.

## Anchors

CLAUDE.md §11 · I-27 (HITL-L4 activation) · ADR-117 (perimeter) · ADR-120 (worktree) · ADR-121 (destructive) ·
ADR-128 (HITL) · `.claude/rules/parallel-session-isolation.md` Rule 6/7 · `docs/runbooks/AGENT-ACTIVATION-PROCEDURE.md` ·
`docs/factory/FACTORY-OPERATING-RULES.md` · `docs/canon/software-factory-canon-v1.md` · SOUL cohorts #1042 / #1044 / #1046.
