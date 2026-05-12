# Condition D Prepared Package

Status: PREPARED / NOT APPLIED

Contents:
- `create-banxe-audit-hitl-decisions-2026-05-12.sql` — ClickHouse DDL for HITL audit sink
- `litellm-guardrail-audit-hook-2026-05-12.py` — LiteLLM custom guardrail extension with audit emit

Apply order:
1. Review and approve HITL / Clause 17 execution authority
2. Apply ClickHouse DDL
3. Install Python dependencies if required
4. Apply guardrail hook update
5. Verify audit writes and guardrail behavior in shadow mode

This directory is a prepared artifact package only.
No file here is applied automatically.
