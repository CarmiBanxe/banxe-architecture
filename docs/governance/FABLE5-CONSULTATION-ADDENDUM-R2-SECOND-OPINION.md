# ADDENDUM R2 — Second opinion mandatory

**Status:** canon addendum · **Classification:** DRAFT / INTERNAL / NO LEGAL STATUS
**Introduced:** operator decision 2026-08-04, on the basis of the FABLE-5 ruling of the same date.
**Extends:** the Fable-5 consultation procedure (`FABLE5-CONSULTATION-PROCEDURE-2026-07-31.md`,
BRIEF→RESPONSE two-step and §STANDING RULE "Fable-5 at every fork") and ADDENDUM R1
(relay-fork specialization). **Additive — it replaces nothing.**

> **Placement note.** The procedure file this addendum extends is not yet on `main`: it lives on
> an unlanded branch held by another session. R2 is therefore published as a standalone canon
> file so the rule takes effect immediately, and folds into §STANDING RULE of the procedure when
> that file lands. Until then, this document is the authoritative text of R2.

---

## R2.1 The rule

**Every consultant BRIEF goes to a second, independent reviewer in parallel with Fable-5.**

Default channel — the local Codex CLI, read-only, no execution:

```
codex exec --sandbox read-only --skip-git-repo-check "<the brief text>"
```

The consultation is not complete until the RESPONSE carries the four elements in R2.2.

## R2.2 What the RESPONSE must contain

**(a) The second opinion verbatim.** Reproduced in full inside the RESPONSE, or attached as a
raw transcript file and referenced by path. Summarising it is not sufficient: a summary written
by the party being reviewed is not a second opinion.

**(b) An independence label.** Taken from the reviewer's own session header, not asserted:

- `INDEPENDENT — <engine/model>` when the reviewer runs a different engine and model
  (e.g. Codex CLI, `gpt-5.6-sol`);
- `NOT-INDEPENDENT — same model, self-check only` when the second pass runs the same model as
  the primary consultant. A self-check is still worth recording, but it must never be presented
  as independent corroboration.

**(c) A Reconciliation section.** Per finding: **converge / diverge**, and where the finding is
accepted or rejected, with the reason. Divergences are stated **explicitly and are not
smoothed over**. Where a divergence touches governance authority, it is escalated to the
operator rather than resolved by either reviewer.

**(d) A NO-WAIT safety valve.** If the second reviewer is unreachable — CLI missing, auth
failure, network down, timeout — the RESPONSE carries `NO-SECOND-OPINION: <reason>` and the
consultation **proceeds**. The verdict is issued with that mark, and the mark is repeated in the
ledger line. A consultation is never blocked on the availability of the second reviewer; it is
only ever marked.

## R2.3 Why the second opinion is mandatory

Introduced after the first application of the rule, which is also its own justification. The
push-delegation charter of 2026-08-04 was drafted by Fable-5, reviewed by Codex, and returned
**"unsafe to approve as written"** with four disqualifying omissions. One of them — that
publishing a donor's `main` installs automation, and a secret scan is blind to that — was then
**confirmed empirically**: the first donor in scope would have installed a workflow triggered by
an issue comment spending an LLM API key, and another joining a private tailnet on pull-request
events.

The pattern to guard against is a consultant reviewing the consequences of its own reasoning.
The primary consultant is not less capable when doing so; it is less likely to see the class of
error it has already committed.

## R2.4 Precedent

| Case | Brief | Second opinion | Verdict | Outcome |
|---|---|---|---|---|
| Push-delegation charter, 2026-08-04 | `SPRINT0-PUSH-DELEGATION-CHARTER.md` | `codex-response-raw-push-charter-2026-08-04.txt` — `INDEPENDENT — Codex CLI 0.146.0 / gpt-5.6-sol` | unsafe as written; 4 findings + 2 downgrades | all 6 accepted by Fable-5; charter rejected in delegating form |

That exchange is the reference execution of R2: brief drafted, sent to both reviewers, second
opinion attached verbatim before approval, divergences tabled for the operator, and the primary
consultant reversing its own instrument rather than defending it.

## R2.5 Ledger obligation

One line per consultation, recording: the independence label, whether findings converged or
diverged, and the `NO-SECOND-OPINION` mark if it applies. A consultation whose ledger line omits
the second-opinion status is incomplete regardless of the quality of its verdict.

## R2.6 Anchors

- `FABLE5-CONSULTATION-PROCEDURE-2026-07-31.md` — BRIEF→RESPONSE, §STANDING RULE, ADDENDUM R1
  (currently on an unlanded branch; see the placement note above)
- `.claude/rules/agents.md` — escalation pointer
- `SPRINT0-PUSH-CHARTER-01-REPORT.md` — the precedent case in full
- `.claude/rules/approval-rules.md`, `safety-rules.md` — stop-barriers unchanged; R2 is additive

---
**This does not replace legal advice.**
