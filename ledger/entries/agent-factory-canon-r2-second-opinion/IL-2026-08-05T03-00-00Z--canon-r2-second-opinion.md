---
il_ts: 2026-08-05T03:00:00Z
session_id: agent-factory-canon-r2-second-opinion
source: CEO
status: PREPARED
---
### ADDENDUM R2 — second opinion MANDATORY, introduced by operator decision 2026-08-04

- **Rule:** every consultant BRIEF now goes to an independent second reviewer in parallel with
  Fable-5 — default channel the local Codex CLI, read-only, no execution
  (`codex exec --sandbox read-only --skip-git-repo-check "<brief>"`). The RESPONSE is incomplete
  without four elements: **(a)** the second opinion verbatim (or attached raw and referenced by
  path — a summary written by the reviewed party is not a second opinion); **(b)** an
  independence label taken from the reviewer's own session header —
  `INDEPENDENT — <engine/model>` or `NOT-INDEPENDENT — same model, self-check only`;
  **(c)** a Reconciliation section stating converge/diverge per finding with divergences
  **explicit and unsmoothed**, escalated to the operator where they touch authority;
  **(d)** a NO-WAIT valve — an unreachable reviewer yields `NO-SECOND-OPINION: <reason>` in both
  RESPONSE and ledger, and the consultation proceeds. R2 is additive to BRIEF→RESPONSE,
  §STANDING RULE and ADDENDUM R1; it replaces nothing.
- **Precedent recorded (R2.4):** the push-delegation charter of 2026-08-04. Reviewer
  **INDEPENDENT — Codex CLI 0.146.0 / `gpt-5.6-sol`**, verdict *"unsafe to approve as written"*,
  4 disqualifying findings + 2 guard downgrades. Fable-5 accepted all six and withdrew the
  charter in its delegating form rather than defending it. One finding was confirmed
  empirically: publishing a donor's `main` installs automation a secret scan cannot see — the
  first donor in scope would have installed a workflow triggered by an issue comment spending an
  LLM API key, and another joining a private tailnet on pull-request events. Raw transcript
  attached at `docs/governance/codex-response-raw-push-charter-2026-08-04.txt`.
- **PLACEMENT DEVIATION — declared.** The task specified adding R2 inside
  `docs/governance/FABLE5-CONSULTATION-PROCEDURE-2026-07-31.md` and a line in
  `docs/governance/MASTER-TAILS-REGISTER-2026-07-31.md`. **Neither file exists on `origin/main`
  nor on any pushed branch** — both live only in the worktree held by session `sid=1577898`,
  which is out of bounds (Rule 6, 149 unlanded commits). Publishing them from that worktree would
  mean publishing another session's unlanded work. R2 is therefore issued as a **standalone canon
  file on main** (`FABLE5-CONSULTATION-ADDENDUM-R2-SECOND-OPINION.md`) carrying an explicit
  placement note, so the rule takes effect now and folds into §STANDING RULE when the procedure
  lands. **Two obligations remain owed** once that happens: fold R2 into the procedure, and add
  the register line.
- **Also corrected:** the stale routing row in `.claude/rules/agents.md` line 186 —
  `reasoning-235b` is in fact `deepseek-r1:70b @ evo-x2`; qwen3:235b is not deployed anywhere
  (P1 from the 2026-08-01 ruling, still open). Pointer to R2 added to the same file's Anchors and
  a one-line reference to `README.md`.
- **Perimeter:** work done in a **fresh clone**, never in the `sid=1577898` worktree; branch
  `agent/factory/canon/r2-second-opinion` (ADR-060 compliant); no force, no squash, no rebase;
  **no auto-merge — the PR is a proposal, merge is an operator act** (ADR-158 G-5, protected main).
- **Refs:** `docs/governance/FABLE5-CONSULTATION-ADDENDUM-R2-SECOND-OPINION.md`;
  `docs/governance/codex-response-raw-push-charter-2026-08-04.txt`;
  `SPRINT0-CANON-R2-REPORT.md`; `.claude/rules/agents.md`; `README.md`. Operator HITL.
