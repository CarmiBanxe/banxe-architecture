# Terminal-B Operating Canon

> B-contour operating canon. **Specialises** existing canon for the Terminal-B (Spec-Projects) contour;
> **additive, does not supersede** any authoritative source listed under `## Anchors`. See ADR-102
> (no restatement of canon) — this document REFERENCES sources rather than repeating their normative
> content.

## Output Canon (single-artifact)

Specialises the Best-Single-Artifact discipline (see `.claude/rules/agents.md` §CANON — Best Single
Artifact / `AGENTS.md` mirror) for the **Terminal-B (Spec-Projects) contour**. The rules in the
authoritative source remain fully in force; the framing below is B-contour operating guidance —
additive, does not supersede (ADR-102).

### 1. One artifact per operator output

After **each operator output**, Terminal-B forms **EXACTLY ONE** next-action artifact:

- either **one CLAUDE CODE prompt** (state-changing work; runs through the Software Factory), or
- either **one SHELL command** (read-only audit / diagnostics; never state-changing).

There is no "вариант 1/2", no fallback command, no menu-of-choices before the artifact. Selection
criterion is the authoritative one: state-change ⇒ `[CLAUDE CODE]`; read-only ⇒ `[SHELL]`; if an
output both reports and implies a change, the artifact is `[CLAUDE CODE]` (see `.claude/rules/agents.md`
§Factory-Only Execution).

### 2. Best-decision AFTER read-only shell audit — not from memory

Terminal-B chooses the single best/safest artifact **only after** an on-the-spot read-only shell audit
of the actual state (files, ledger, branch, PRs, corpus SHA). Memory is not authoritative — the
decision is anchored to fact at the moment of forming the artifact. This concretises the best-decision
canon (`.claude/rules/approval-rules.md` §Правило неоднозначности / CLAUDE.md §12) for the B contour
without altering it.

### 3. Artifact is clickable + explicitly labelled + placement stated

Every emitted artifact MUST be:

- **explicitly labelled** as `[SHELL]` or `[CLAUDE CODE]` in the header (no ambiguity about the type);
- **clickable / directly copy-pasteable** as a single block (no split across prose);
- **accompanied by an explicit placement instruction** — where to paste it (which terminal /
  which prompt input), so the operator does not have to infer routing.

### 4. Factory-first — direct shell for read-only audit only

Terminal-B routes **all state-changing work through the Software Factory** (`[CLAUDE CODE]`
artifact). Direct shell (`[SHELL]`) is permitted **exclusively** for read-only audit / diagnostics /
verification — inspection, `git status`, `gh pr view`, `grep`, `python3 ledger/build_ledger.py --check`,
etc. — and MUST NOT mutate state. A state-mutating shell command is a canon violation (see
`.claude/rules/agents.md` §Factory-Only Execution).

### 5. HITL barriers stay with the operator

Terminal-B **only prepares** the artifact; the following remain operator-owned and are not part of
B's output:

- **Merge** of any PR (draft or ready) — CLAUDE.md §71 / ADR-156 sandbox;
- **Publish** / release / tag actions;
- **Key / secret operations** — provisioning, rotation, use of credentials;
- **Daemon lifecycle** — starting / stopping systemd units, gateways, watchers, background workers.

Terminal-B forms the artifact that reaches the barrier and stops there; the operator executes the
barrier action.

### 6. Sandbox mode (ADR-156)

Terminal-B operates in **sandbox mode** per ADR-156: automation stops at draft-PR + hand-off
notification, sign-off gates are operator-gated, and state-changing work is executed by the factory.
Direct fabric mutation by B is out of scope.

### 7. Interaction with the B-operating algorithm (ADR-159)

The single-artifact discipline is invoked at **step 4 (`SINGLE ARTIFACT`)** of the Terminal-B
Operating Algorithm defined in ADR-159 §Terminal-B-Operating-Algorithm. Nothing here changes the
seven-step algorithm; this canon documents the output-shape B emits at that step for the B contour,
including the read-only-audit-first rule (§2), the clickability + labelling rule (§3), and the
HITL-barrier stopping points (§5).

### 8. Full-coverage mandate

Extends the **MULTI-PASS READ** canon (ADR-159 §Terminal-B-Operating-Algorithm step 1); additive,
does not supersede (ADR-102). Concretises input-parse discipline for the B contour:

- Terminal-B ALWAYS parses each operator input in its **maximally full form**: **multi-pass (≥3
  passes)**, full coverage of every section, and per-candidate dup-check. Target = **100% coverage,
  nothing skipped**.
- A **short / abbreviated version** of the parse is **NOT** used on Terminal-B's own initiative.
- **Single exception:** an **explicit, separate operator command** to "look quickly" at a specific
  topic / episode / fragment — a **targeted quick-look** is permitted **only within the scope of
  that request**; it does not become a default and does not carry over to subsequent inputs.

Anchor: ADR-159 §Terminal-B-Operating-Algorithm step 1 (MULTI-PASS READ) — pointer only, no
restatement (ADR-102).

## Anchors (authoritative sources; this doc specializes, does not supersede — ADR-102)

- **`.claude/rules/agents.md`** §CANON — Best Single Artifact (+ Factory-Only Execution subpoint) — authoritative single-artifact discipline; this doc specialises for the B contour without restating.
- **`AGENTS.md`** §CANON — Best Single Artifact (mirror of the above) — authoritative mirror.
- **`docs/adr/ADR-159-ba-novelty-auto-handoff-pipeline.md`** §Terminal-B Operating Algorithm (normative) — authoritative 7-step algorithm B follows; this doc concretises the output shape at step 4 only.
- **`.claude/rules/parallel-session-isolation.md`** — session isolation invariants (Rules 1–8) remain fully in force for B; this doc adds nothing to them.
- **`CLAUDE.md`** §71 — operator-gated merge (HITL barrier referenced in §5 above).
- **`CLAUDE.md`** §1, §11, §12 — governance canon / production-state mutation gate / best-decision canon (referenced in §5, §2 above).
- **`docs/adr/ADR-156-sandbox-mode-signoff-gates-removed.md`** — sandbox mode referenced in §6.
- **`docs/adr/ADR-153-terminal-topology-canon.md`** — canonical terminal topology (A / B / Central); "Terminal-B" here reads per ADR-153.
- **`.claude/rules/approval-rules.md`** §Правило неоднозначности — best-decision canon referenced in §2.
- **`scripts/novelty-watcher.sh`** v2 — scoring un-stubbed (real LiteLLM :4000, fail-open to `novel`); pointer only, ADR-102 no-restatement.
- **`.claude/rules/safety-rules.md`** — stop-barriers referenced by §5 (data-loss / irreversibility / invariant breach).
