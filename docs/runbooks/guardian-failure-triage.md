# Runbook: Guardian Rule Failure Triage
## Trigger
Guardian returns verdict=BLOCK or verdict=WARN on any audit.
## Steps
1. Read Guardian response: `rule_id`, `verdict`, `summary`, `reasons`.
2. If BLOCK on F1-F8 (factory rules): fix the violation before re-submitting.
3. If BLOCK on P1-P8 (project rules): escalate to Operator if unclear.
4. If WARN on F9 (route alias): switch to canonical LiteLLM alias.
5. If WARN on F10 (role boundary): delegate code to Aider, review to Claude Code.
6. Re-run `scripts/evaluate.sh` after fix.
## Escalation
BLOCK that cannot be resolved → Operator override via `guardian-override-approved-{factory|project}` label on PR.
