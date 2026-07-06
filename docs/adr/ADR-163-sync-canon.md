# ADR-163 — SYNC-CANON: mandatory synchronization discipline in technical work

**Date:** 2026-07-06
**Status:** PROPOSED
**Deciders:** Terminal-B (proposer), Central (ratification), Operator (accept gate)
**Replaces:** N/A
**Superseded by:** N/A
**References:** ADR-102 (no restatement of canon), ADR-060 (branch-name namespace), ADR-119 (stable IL numbering; Rule 8 merge-time freeze), ADR-120 (per-session worktree), ADR-121 (destructive-action protection), ADR-153 (terminal topology), ADR-156 (sandbox / operator-gated sign-off), ADR-159 (Terminal-B Operating Algorithm), ADR-161 (intake SSOT-persistence), ADR-162 (best-decision principle), `.claude/rules/parallel-session-isolation.md` (Rules 1–8), `.github/workflows/main-serialize.yml` (main-merge-serialize CI gate), PR #1058 (watcher v2.1 sync-before-scan), PR #1061 (watcher v2.2 ADR-060-compliant branch name), `governance/COORDINATION-NOTES.md` DIRECTIVE B-QUIET-WINDOW-001.

---

## Context

Three battle-run lessons in the current sprint window surfaced the same class defect from different angles: **sides of the fleet — factory (Left / A), Central, Terminal-B (Right / B), plus daemons (watcher, ledger-rebuild) and per-session Claude Code instances — were acting on divergent baselines of `origin/main`.** Each incident had its own instance fix; none codified the general rule.

1. **Stale-checkout (PR #1058, watcher v2.1).** The live novelty-watcher tick executed against a checkout stuck at an old `HEAD`. `origin/main` had moved (30 freshly-merged NEW findings), the watcher never fetched, and logged "no status=NEW, nothing to do" while the findings sat live on `main`. Instance fix: `git fetch origin main` FAIL-LOUD before any register/queue read, read via `git show origin/main:…` — sync-before-scan. Class defect: **any actor reading state without first synchronizing to the current `origin/main` is operating on a stale baseline.**

2. **Ledger churn / serialize (`governance/COORDINATION-NOTES.md` DIRECTIVE B-QUIET-WINDOW-001, sp16; `.github/workflows/main-serialize.yml`).** Concurrent ledger-writing PRs (#1033/#1038/#1041/#1051 + canon-PR #1052) landed with `main` moving ~every 2 min, producing a rebase-treadmill: each PR was rebased, force-pushed, and immediately behind again. `main-serialize.yml` (IL-617) enforces one-at-a-time merges via `concurrency-group + base-drift guard`; the sp16 quiet-window directive added a coordination hub so parallel actors HOLD before piling on. Class defect: **ledger-writes are not commutative; without an explicit serialize-and-coordinate discipline they degrade to a treadmill or (worse) collide on IL numbers (ADR-119 Rule 8 duplicate-IL incident).**

3. **Branch-name validity in automation (PR #1061, watcher v2.2).** Watcher-generated worktree branch names failed the ADR-060 gate (`^agent/(central|right|factory|specproj)/[A-Za-z0-9]+/[a-z0-9._-]+$`) because the auto-derived `<id>` fragment contained a `-`. The class defect is not "watcher had a typo": **every automated actor that mints branch names MUST produce ADR-060-compliant names by construction, not by accident.**

The BANXE governance canon already carries the *ingredients* — `.claude/rules/parallel-session-isolation.md` (Rules 1–8) covers cross-terminal git hygiene; ADR-119 Rule 8 covers rebase-before-merge; ADR-120 covers per-session worktrees; the operator-canon covers Central as bilateral hub. What is missing is a single, named, cross-cutting canon that says: **synchronization is a precondition, not an afterthought**, and applies to every side (factory, Central, Terminal-B) and every actor (session, agent, daemon) uniformly.

Sibling ADRs ADR-161 (SSOT-persist BEFORE extraction) and ADR-162 (best-decision adoption-audit gate) already made the same shape of move in adjacent lanes — persistence-first and evaluation-first respectively. SYNC-CANON is the third leg: **synchronization-first**.

---

## Decision

### D-1 — Adopt SYNC-CANON as a named cross-cutting canon (PROPOSED)

The five principles below are lifted to canon and operationalised in `docs/canon/SYNC-CANON.md` (same PR). SYNC-CANON is a discipline over how sides and actors coordinate — it does not grant runtime autonomy (I-27 preserved), does not weaken any stop-barrier (`safety-rules.md`), and does not replace the machinery it references (ADR-102: reference, not restate).

**P-1 — SYNC-BEFORE-ACT (generalisation of watcher v2.1 / #1058).**
Every actor — factory session, Central, Terminal-B, watcher, ledger-rebuild, per-session Claude Code — MUST synchronize to a fresh `origin/main` **before** reading state, taking action, or writing. Reading canonical state (register, queue, ledger index) uses `git fetch` + `git show origin/main:<path>` (or equivalent) rather than a possibly-stale local working copy. A stale-checkout read is a **class-B defect**, not an incidental miss.

**P-2 — LEDGER-SERIALIZE (generalisation of main-serialize + sp16 quiet-window + ADR-119 Rule 8).**
Ledger-writes (any change that touches `INSTRUCTION-LEDGER.md`, `ledger/IL-SEQUENCE.json`, or `ledger/entries/`) are serialised: rebase-before-merge is mandatory (ADR-119 Rule 8), `main-serialize.yml` enforces one-at-a-time merges, and parallel ledger-PRs are announced through the Central coordination hub (`governance/COORDINATION-NOTES.md`) so peers HOLD rather than pile on. **Two consecutive rebase-churn cycles ⇒ escalate to operator (quiet-window), not an infinite rebase loop** — this is a stop-barrier for the treadmill, not an autonomy grant.

**P-3 — BRANCH-NAME-VALID by construction (generalisation of watcher v2.2 / #1061).**
Any automated actor minting a branch name — watcher, factory-dispatch, bx-session, ledger-rebase helpers — MUST produce a name that matches the ADR-060 pattern (`^agent/(central|right|factory|specproj)/[A-Za-z0-9]+/[a-z0-9._-]+$`) **by construction of the mint code**, not by post-hoc validation. The `<id>` fragment is `[A-Za-z0-9]+` (no dash). Automation that cannot guarantee this fails-closed at mint-time.

**P-4 — TRI-PARTY SYNC-POINT.**
At the start of a technical work item (a sprint task, an intake, an adoption-audit, a canon-write like this one), factory (Left / A), Central, and Terminal-B (Right / B) MUST agree on a **baseline `origin/main` sha** and record it (implicitly via the PR base, explicitly via `git rev-parse origin/main` in the work log when non-trivial). Central is the mandatory hub of the B↔Central↔A axis — a divergent baseline between sides is a **STOP** condition until re-sync, not a "small drift to reconcile later". This is the coordination-side of P-2: serialization is the mechanism, tri-party sync-point is the checkpoint.

**P-5 — SSOT-FIRST (pointer to ADR-161).**
Intake persists the source body verbatim BEFORE any extraction / evaluation / write of derivative artefacts. SSOT-FIRST is one instance of the sync-first shape (persistence-before-derivation) and is defined by ADR-161; SYNC-CANON references it as the intake face of the general discipline, per ADR-102 (no restatement).

### D-2 — Enforcement stance (advisory-first, machine gates already partial)

SYNC-CANON ships **PROPOSED** with an **advisory** stance for the discipline itself. Two of the five principles already have partial machine enforcement:

- P-2 is partially enforced by `.github/workflows/main-serialize.yml` (base-drift guard, concurrency-group) and by `strict` branch protection on `main`.
- P-3 is partially enforced by `guardian-branch-naming` and `scripts/install-hooks.sh` pre-push gate.

P-1 (SYNC-BEFORE-ACT for all actors), P-4 (tri-party sync-point), and the discipline framing across all five are **advisory** in this ADR. Machine enforcement (a pre-commit / CI check that a technical work item declares its baseline sha; a lint that automation branch-mints call an ADR-060 validator by construction) is out of scope for this ADR and scheduled as follow-up once the advisory rule has been exercised.

Rationale for advisory-first: the machinery to enforce P-1 and P-4 does not yet exist repo-wide; hard-enforcement without a shakedown risks blocking legitimate small work. The three battle-run lessons are addressed by naming the discipline + referencing the existing instance gates; hardening is refinement.

### D-3 — What SYNC-CANON does NOT change

- **`.claude/rules/parallel-session-isolation.md` (Rules 1–8)** is unchanged; SYNC-CANON is a superset framing that references those rules, per ADR-102 (no restatement, no second source-of-truth). If a future ADR wants to move a rule between artefacts, that is a separate governance move.
- **ADR-060 branch-name pattern** is unchanged; SYNC-CANON only says automation MUST produce compliant names by construction.
- **ADR-119 Rule 8 (IL number merge-time freeze)** is unchanged; SYNC-CANON only lifts the rebase-before-merge principle to canon-level framing.
- **`main-serialize.yml` / `strict` branch protection / `guardian-*` gates** are unchanged; SYNC-CANON references them as the enforcement machinery for P-2 and P-3.
- **I-27 fail-closed**, **`safety-rules.md`**, **SOUL.md** are untouched. SYNC-CANON is coordination discipline, not runtime autonomy.

---

## Consequences

**Positive**

- Class defects "stale-checkout read", "ledger treadmill", "invalid branch-name at mint" are addressed at the canon level, not patched instance-by-instance.
- Cross-side coordination (B↔Central↔A) has a named checkpoint (P-4) so baseline drift is a STOP condition, not a silent hazard.
- Sibling ADR-161 (SSOT-persist) and ADR-162 (adoption-audit) fit cleanly under the same "-first" family, giving the intake→adoption→write pipeline a coherent discipline vocabulary.

**Negative / accepted trade-offs**

- Advisory-first means P-1 and P-4 rely on operator + Terminal-B / Central review; a session that skips SYNC-BEFORE-ACT will not be blocked mechanically until the follow-up hardening lands.
- One more named canon to hold in the reader's head; mitigated by reference-only relationships to the instance gates (ADR-102).

**Risks (mitigations noted)**

- **Canon proliferation.** Yet another named canon on top of the existing set. *Mitigation:* SYNC-CANON is defined as pointer + framing, not as new mechanics; it defers to existing gates.
- **False-security from naming.** Naming a discipline does not enforce it. *Mitigation:* the ADR is explicitly advisory-first; the follow-up hardening task list is called out in D-2.
- **Cross-terminal misuse.** A session could invoke SYNC-CANON to justify a coordination-heavy pause on an obviously-independent piece of work. *Mitigation:* P-4 applies to *technical work items* that touch shared canonical state; independent read-only work is unaffected.

---

## Anchors

- `docs/canon/SYNC-CANON.md` — the operational canon shipped in the same PR as this ADR.
- `.claude/rules/parallel-session-isolation.md` — Rules 1–8 (rebase-before-merge, cross-session hygiene, destructive-action protection, IL merge-time freeze). SYNC-CANON references, does not restate.
- `.github/workflows/main-serialize.yml` (IL-617, PR #833) — concurrency-group + base-drift guard.
- PR #1058 (`3dff92d`) — watcher v2.1 sync-before-scan (SYNC-BEFORE-ACT evidence).
- PR #1061 (`ee77e00`) — watcher v2.2 ADR-060-compliant branch name (BRANCH-NAME-VALID evidence).
- `governance/COORDINATION-NOTES.md` DIRECTIVE B-QUIET-WINDOW-001 (sp16, `19cf12c`) — quiet-window / treadmill evidence.
- ADR-060 — branch actor namespace + pattern.
- ADR-119 — stable IL numbering, Rule 8 merge-time freeze.
- ADR-120 — per-session worktree isolation.
- ADR-153 — terminal topology (Left / Central / Right; Orchestrating Terminal alias).
- ADR-159 — Terminal-B Operating Algorithm.
- ADR-161 — intake SSOT-persistence (P-5 face of the sync-first discipline).
- ADR-162 — best-decision adoption-audit gate (sibling discipline).
- ADR-102 — no restatement of canon (governs SYNC-CANON's reference-only relationship to the instance rules).
