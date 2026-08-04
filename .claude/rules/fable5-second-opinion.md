# Fable-5 Second Opinion via Codex — ALWAYS ON (ADR-181)
# Source: operator instruction 2026-08-04 | Status: CANON
# Full protocol: docs/adr/ADR-181-fable5-second-opinion-codex.md

## The rule

EVERY consultation addressed to Fable-5 (Rule 11 fork, advisory-only prompt,
architecture verdict, ratification question) runs a PARALLEL second opinion:

```bash
codex exec --skip-git-repo-check -s read-only "<the same fork/question>"
```

and the advisory ends with a mandatory section:

```
## Second opinion (Codex)
Verdict: AGREE | PARTIAL | DISAGREE | UNAVAILABLE (<reason>)
Deltas: <which options/scores differ and why>
Effect: <what changed in the final recommendation, or "nothing — reasons addressed">
```

## Hard constraints

1. **Parallel, independent** — Codex gets the fork text, NEVER Fable-5's draft
   verdict (no anchoring). Sequential critique only on explicit operator request.
2. **Read-only sandbox** (`-s read-only`) — Codex advises, never executes,
   never writes.
3. **No secrets in the prompt** — no vault contents, tokens, client data;
   fork text + public canon pointers only.
4. **Fail-soft, 120s budget** — Codex down/slow/error ⇒ advisory still ships,
   marked `UNAVAILABLE (<reason>)`. Never block, never fabricate the answer.
5. **Non-delegation (ADR-145)** — final verdict stays Fable-5's; operator
   decides. Codex DISAGREE ≠ veto; it obliges an explicit rebuttal.
6. Not triggered by execution tasks, mechanical tacts, or conversation.

Skipping the second opinion on a consultation = canon violation (same class as
the ADR-177 «orchestrator-only» precedent): log it, correct course.
