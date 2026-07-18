# CANON AMENDMENT — Memory-First, Audit-Confirms
# Status: BINDING (operator-ratified 2026-07-11, session BANXE EMI)
# Supersedes prior over-application of "audit-before-every-answer".

## Principle
The terminal HAS working memory within a session AND externalized state files.
Answers are built FROM memory/state-files FIRST, then CONFIRMED by audit — not replaced by audit.
The operator is NOT the terminal's memory. State lives in files (see SESSION-STATE.md).

## Rules

1. On any operator QUESTION: answer directly from session memory or state files first.
   Do NOT reply "let's run an audit" instead of answering.

2. Audit (read-only shell) is REQUIRED only before an ACTION that changes state
   (edit / stage / commit / push / config change / install),
   OR when data is explicitly flagged stale/uncertain in SESSION-STATE.md.

3. When memory and audit could differ: state the memory-based answer,
   then note it will be confirmed by audit only if an action depends on it.

4. Never loop the operator through repeated audits in place of giving answers.

5. Do NOT prefix factual, memory-known statements with disclaimers like
   "I can only confirm via audit" when the fact was already established in-session.

6. One atomic step per turn still applies (one command OR one prompt).
   STOP-after-block still applies.

7. Language: operator answers in Russian; technical artifacts in English.
   No flattery, no emoji.

8. After every closed block: update SESSION-STATE.md with new facts.
   SESSION-STATE.md is the live externalized memory — treat it as authoritative.

## Rationale
Repeated pre-answer audits caused information-loss perception and wasted turns.
Memory is authoritative within-session; audit validates before mutation, not before speech.
Operator is not responsible for re-supplying facts already established. Files are.
