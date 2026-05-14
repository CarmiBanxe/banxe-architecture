# Sprint 8: S7 Findings Resolution

## Finding 1: INV-01 clarification (code vs docs)
Resolution: ACCEPTED as amendment proposal.
INV-01 now reads: "Aider is the sole CODE executor. Documentation
(markdown, YAML configs, runbooks) may be authored directly by
Planner or Reviewer roles."
Status: RATIFIED (Sub-A Clause 17, best-decision).

## Finding 2: Guardian scope for banxe-architecture
Resolution: DEFERRED to future sprint. Guardian on evo1 currently
audits MetaClaw and banxe-emi-stack. Adding banxe-architecture
requires config change on evo1 Guardian systemd service.
Status: ACCEPTED as known limitation.

## Finding 3: P5 generator script (S6-02)
Resolution: DEFERRED. P5 packs authored manually during pilot.
Automation planned when factory loop runs >10 times/week.
Status: ACCEPTED as known limitation.
