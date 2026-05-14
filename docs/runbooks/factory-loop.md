# Runbook: Factory Loop Execution
## Trigger
Any new IL entry or operator instruction.
## Steps
1. **Plan** — Claude Code decomposes task, creates IL entry (I-28).
2. **Execute** — Aider writes code via LiteLLM canonical alias.
3. **Evaluate** — `scripts/evaluate.sh` chains pytest→ruff→Guardian→Canon Judge.
4. **Review** — Claude Code reviews diff against invariants INV-01..10.
5. **Approve** — Ruflo checkpoint routes to appropriate gate (auto/operator/mlro/ctio).
6. **Promote** — If APPROVED: git commit + PR + merge. If REJECTED: defer + log reason.
## Rollback
Revert commit. Ruflo checkpoint records persist for audit trail.
