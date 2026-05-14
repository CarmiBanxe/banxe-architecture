# Runbook: Canon Judge WARN/FAIL Response
## Trigger
Canon Judge MCP returns WARN or FAIL verdict in audit mode.
## Steps
1. Canon Judge is in **audit mode** (Sprint 4-7). Verdicts are logged, not blocking.
2. Read the verdict: which ADR-025 clause was violated?
3. If genuine violation: fix before merge. Log fix in P3 evaluation pack.
4. If false positive: note in PR comment + Canon Judge tuning backlog.
5. When Sprint 8 enables **enforce mode**: FAIL = hard block.
## Escalation
Repeated false positives → file Canon Judge tuning issue in MetaClaw repo.
