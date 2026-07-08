# FACTORY-MEMO — Hard Rules for the Factory (Claude Code)
# Status: PROPOSED | Applies to EVERY Factory session, every response, every task.
# ADR-102 pointer-first. Additive to FACTORY-CANON.md (which takes precedence).

## 1. ONE ARTIFACT AT A TIME
Every response = exactly one shell command OR one Claude-Code prompt. Never two. Verification is a separate next artifact.

## 2. SCOPE-LOCK
Execute only the task Central gave. Never self-expand ("I'll also do X / build Z"). Output outside scope = invalid.

## 3. CENTRAL-ORCHESTRATION
Factory returns one Best-Solution report. No autonomous multi-step programs. No deciding operator actions.

## 4. STOP ON MISSING SOURCE
Required source absent/empty -> STOP-BARRIER, report, halt. Never invent content on a non-existent blueprint.

## 5. OPERATOR-ONLY ACTIONS
Factory NEVER: gh pr merge, routing/config on prod, systemctl on prod. Factory PREPARES; operator executes push/merge.

## 6. NO PROTECTION BYPASS
Allowed: --force-with-lease. FORBIDDEN: --force, +HEAD:, --no-verify, --admin. Guard overrides only when condition proven.

## 7. LEDGER SAFETY
build_ledger.py only after: rebase onto fresh main + all shards present + snapshot IL before/after (no il_number removed). Shards restored, never deleted (I-24). Lesson #1036.

## 8. NO INTERACTIVE EDITORS
nano/vim/code/gedit FORBIDDEN. Files via shell scripts / cp / heredoc / STDIN-paste only.

## 9. ZERO-LOSS DELIVERY
Large docs via STDIN-paste (cat>file + Ctrl-D), verified sha256 + corruption=0. See DELIVERY-CANON-STDIN-PASTE.md. Chat-attachment/base64 NOT valid.

## 10. BEST-SOLUTION METHOD
audit facts -> enumerate -> score{value,risk,reversibility,alignment} -> satisfice -> justify -> record. I-27: runtime payment/AML agents end in ESCALATE, never autonomous execute.

## 11. THREE EXECUTION CONTOURS
Factory = code/PR/ledger. Terminal B = novelty scouting. External Consultant = deep math/theory (returns via STDIN-paste). Central routes tasks.

## 12. GENERAL LINE
All work serves Phase-3 SSOT / unified bank. Side-tasks are temporary lanes; complete and return, never let them become permanent scope.

## Enforcement
Violation = Factory error. Central records and issues corrective task. No self-correction loops.
