# Agent Activation Procedure — pointer / entry-point (NOT a normative source, NOT an activation)

This document is an **index only** — a single navigation entry-point to the PROPOSED→LIVE agent-activation
canon that already exists, **scattered**, across the repository. It is **not** normative: it defines no rule,
grants no approval, and **activates nothing**. It exists because a duplication-audit (ADR-102) found the
activation procedure distributed across an ADR precedent, a conditions runbook, an ordering audit, and the
I-27/HITL gate, with no single canonical entry-point. This file only **links** to those sources.

> **The gate, in one line (authoritative text is I-27, linked below):** a PROPOSED agent goes LIVE **only** after
> **I-27 HITL-L4 sign-off** (MLRO/CTIO per the agent's HITL gates). Activation is a **production-state change
> (CLAUDE.md §11)** — it is performed by the **operator + human approvers**, never auto-applied by the factory.

## Source of Truth (links only — each is authoritative for its part)

The gate & governance:
- [`.claude/rules/compliance.md`](../../.claude/rules/compliance.md) — **I-27** (supervised / HITL, not self-activating).
- [`HITL-MATRIX.yaml`](../../HITL-MATRIX.yaml) + [`docs/adr/ADR-128-banking-agents-hitl-matrix.md`](../adr/ADR-128-banking-agents-hitl-matrix.md) — the HITL gates (which human roles must sign, per agent).
- CLAUDE.md §11 — production-state mutation gate (no automatic client-fund/production change without human approval).

The procedure & precedent:
- [`docs/runbooks/conditions-abcd-activation-runbook-2026-05-12.md`](./conditions-abcd-activation-runbook-2026-05-12.md) — the conditions (A–D) an agent must satisfy.
- [`docs/audit/activation-order-2026-05-12.md`](../audit/activation-order-2026-05-12.md) — the activation ordering across agents.
- [`docs/adr/ADR-155-design-pipeline-agent-activation.md`](../adr/ADR-155-design-pipeline-agent-activation.md) — the **worked precedent**: full activation of `design_pipeline_agent` under the I-27 gate (the reference pattern for any single-agent go-live).
- [`.canon/scripts/activate-profile.sh`](../../.canon/scripts/activate-profile.sh) — the profile-activation script (operator-run).

The fleet posture:
- [`governance/SPRINT-8-COO-DEEP-BUILD.md`](../../governance/SPRINT-8-COO-DEEP-BUILD.md) + [`governance/SPRINT-4-MLRO-LINE.md`](../../governance/SPRINT-4-MLRO-LINE.md) — canonical statement that all PROPOSED stubs are **dormant; activation ONLY after I-27 HITL-L4 sign-off**.

## How to Use (to take a single PROPOSED agent → LIVE)

1. **Gate first** — confirm the agent's HITL gates and the required approver roles → `HITL-MATRIX.yaml` + `ADR-128`; the rule is `I-27` (`compliance.md`).
2. **Check preconditions** — the agent must satisfy the activation **conditions A–D** → `conditions-abcd-activation-runbook`.
3. **Respect ordering** — activate in the canonical sequence → `activation-order`.
4. **Follow the precedent** — mirror the worked `design_pipeline_agent` go-live → `ADR-155`.
5. **Operator executes** — the operator (with MLRO/CTIO sign-off recorded) runs the activation; `activate-profile.sh` where applicable. The factory prepares materials only.

## Non-Goals

- This file **does not activate** any agent, and grants **no** I-27 approval.
- This file **does not supersede** I-27, ADR-128, ADR-155, or any HITL/governance rule — the linked sources always take precedence.
- This file **remains link-only** except for the minimal navigation text above; when the procedure changes, update the source-of-truth file, never this pointer.

## Anchors

`.claude/rules/compliance.md` (I-27) · `HITL-MATRIX.yaml` · `docs/adr/ADR-128` / `ADR-155` ·
`docs/runbooks/conditions-abcd-activation-runbook-2026-05-12.md` · `docs/audit/activation-order-2026-05-12.md` ·
`governance/SPRINT-8-COO-DEEP-BUILD.md` / `SPRINT-4-MLRO-LINE.md` · CLAUDE.md §11. Modelled on the
`docs/factory/FACTORY-OPERATING-RULES.md` pointer (#1014). ADR-102 (pointer-first, no duplication).
