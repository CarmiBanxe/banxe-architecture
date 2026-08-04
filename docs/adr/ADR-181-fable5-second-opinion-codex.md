# ADR-181: Fable-5 Second Opinion Protocol (Codex plugin)

**Date:** 2026-08-04
**Status:** Accepted (direct operator instruction, 2026-08-04)
**IL:** TBD (assigned by ledger-rebuild after merge)
**Author:** Moriel Carmi / Claude Code

refs:
  - .claude/rules/fable5-second-opinion.md (session-loaded enforcement)
  - docs/adr/ADR-177-factory-full-cycle-mandate.md (advisory = task parameter)
  - ADR-145 (authority non-delegable), ADR-102 (dedup), Rule 11 (fork -> advisory)
  - Reserved ADR-180 (Fable-5 confidence-score protocol, roadmap v3 S-01) — complementary

---

## Context

The operator instituted a working method: a second, independent opinion improves
advisory quality. Verified on this host 2026-08-04: `codex` CLI v0.146.0 is
installed and answers non-interactively (`codex exec --skip-git-repo-check
-s read-only "<prompt>"` → response received, read-only sandbox).

Until now Fable-5 advisories (Rule 11 forks, ratification questions, architecture
verdicts) were single-source: one model, one reasoning path. Systematic errors of
a single path have no internal detector. The operator's instruction: EVERY
consultation addressed to Fable-5 must run a parallel second opinion via the
Codex plugin, compare, and issue one consolidated summary.

## Decision

1. **Trigger.** Any advisory/consultation request addressed to Fable-5 —
   Rule 11 forks, «advisory-only» prompts, architecture verdicts, ratification
   questions. Not triggered by: pure execution tasks, mechanical tacts,
   conversational turns.
2. **Parallel run.** Fable-5 forms its own analysis AND launches
   `codex exec --skip-git-repo-check -s read-only` with the same fork/question
   (context redacted per §4). Parallel, not sequential: Codex must not see
   Fable-5's draft verdict (independence requirement), and Fable-5 does not
   wait for Codex to begin its own reasoning.
3. **Consolidated output.** The advisory carries a mandatory section
   **«Second opinion (Codex)»** with: verdict AGREE / PARTIAL / DISAGREE,
   the substantive deltas (which options scored differently and why), and what
   — if anything — changed in the final recommendation. Disagreements are named
   explicitly, never silently averaged.
4. **Red lines.**
   - **Read-only, advisory-plane only.** Codex never mutates state, never
     executes tacts, never writes to repos/ledger. Sandbox `read-only` flag
     mandatory.
   - **No secrets in prompts**: no vault paths' contents, passwords, tokens,
     client data. Fork text + public canon pointers only.
   - **Fail-soft**: Codex unavailable / timeout (default budget 120s) / error →
     advisory is still issued, marked `Second opinion: UNAVAILABLE (<reason>)`.
     Never block on Codex, never fabricate its answer.
   - **Non-delegation (ADR-145)**: the final verdict and its responsibility
     remain Fable-5's; the operator decides. Codex is an input, not an authority.
     A Codex DISAGREE does not veto — it obliges Fable-5 to address the argument.
5. **Relation to ADR-180 (reserved).** When the confidence-score protocol lands,
   the consolidated summary carries the confidence field; Codex agreement level
   is one of its inputs. This ADR does not pre-empt ADR-180's design.

## Consequences

- Advisory latency grows by the parallel Codex run (bounded by the 120s budget).
- Advisory quality gains an independent check against single-path systematic error.
- The protocol is written in every place the factory reads at session start
  (.claude/rules, CLAUDE.md, README) — forgetting it is a canon violation,
  same class as the ADR-177 orchestrator-only precedent.
- Cost: ~3–10k tokens per consultation on the Codex side.

## Alternatives considered

- **Sequential review (Codex critiques Fable-5's draft)** — rejected as the
  default: anchoring destroys independence. Allowed as an *additional* step when
  the operator explicitly asks for a critique pass.
- **Second opinion only on request** — rejected: the operator's instruction is
  «always»; opt-in protocols decay (same failure mode ADR-177 fixed).
- **Multi-model panel (3+ models)** — deferred: heavier, needs routing/cost
  design; the roadmap's OpenRouter Fusion track may absorb this later.
