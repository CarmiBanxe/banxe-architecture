# CTIO Carry-Forward — Operator-Owned Privileged / Irreversible / External Operations Registry

> **Status:** governance registry. **Date:** 2026-06-30. **Line 3 of 7.** **Pointer-first and additive** — it
> registers *which classes of operation the operator owns* and binds the rule that terminals prepare but never
> execute them. It does **not** restate the HITL, approval, or destructive-action canon it points to (ADR-102).

## 1. Purpose
This registry names the classes of **privileged, irreversible, and external** operations whose owner is
**strictly the Operator**. No terminal — A (factory), B (right), or Central — executes any operation in these
classes autonomously. The recurring "it didn't work without `sudo`" and "needs operator hands" situations
observed across the session are eliminated by making the ownership explicit and the terminal's role
preparation-only.

## 2. Operator-owned operation classes
Every class below has **`owner: Operator`**. A terminal may *prepare* the exact command or artifact; only the
operator *executes* it.

| Class | Examples (non-exhaustive) | Owner |
|---|---|---|
| **Privileged / `sudo`** | `sudo` anything · `systemctl` · package install/remove · kernel/driver/BIOS · `chattr` | **Operator** |
| **Deletions** | `rm -rf` · repository deletion · deleting/force-updating a ref or branch not owned · `git worktree remove` of a foreign session · DB `DROP`/`TRUNCATE` | **Operator** *(plus the destructive-op verify-step, §3 pointers)* |
| **External key / address binding** | provisioning external API keys · wallet / integrator addresses (e.g. the ODR-1 DeFi integrator keys) · writing secrets into a vault | **Operator** |
| **Webhook configuration** | GitHub / payment-provider / ASPSP webhook setup · endpoint registration / rotation | **Operator** |
| **GitHub App operations** | App install / permission changes · branch-protection edits · required-status-check changes · org-level settings | **Operator** |
| **Permission / access changes** | `chmod` / `chown` · IAM / Keycloak role grants · SSH-key authorization | **Operator** |
| **Financial / client-fund operations** | any movement of client funds · payment execution | **Operator** *(plus the AML/KYC + HITL gate)* |
| **Any other irreversible / privileged action** | irreversible production-state mutation without a rollback path · data-loss operations | **Operator** |

> The lists are non-exhaustive by design. A new operation that is privileged, irreversible, or external is
> **operator-owned by default**; add it here as it arises rather than executing it autonomously.

## 3. Rule — terminals prepare, the operator executes
For any operation in §2, a terminal MUST:
1. **prepare** the exact command(s) or artifact;
2. **hand it to the operator** with a one-line rationale and the expected effect;
3. let the **operator execute** it (or decline).

A terminal MUST NOT run an operator-owned operation itself, and MUST NOT work around a missing privilege (for
example, by retrying without `sudo` in a way that silently changes scope). This is the single-writer / HITL
discipline applied specifically to privileged, irreversible, and external operations.

## 4. Pointer-first — existing canon this binds (ADR-102, not restated)
- **ADR-135** — held-out adoption / skill-evolution HITL gate.
- `.claude/rules/approval-rules.md` §"Требует подтверждения CEO" — deletions, permission changes, financial
  operations require operator confirmation.
- `.claude/rules/safety-rules.md` — destructive-operation **verify-step** and the forbidden-operations list.
- `.claude/rules/parallel-session-isolation.md` **Rule 7** + **ADR-121** — never run destructive operations
  against shared or foreign-session state.
- `HITL-MATRIX.yaml` + `.claude/rules/agents.md` HITL confidence thresholds (BUG-007: AUTO/REVIEW/BLOCK).
- `CLAUDE.md` §1 and §11 (governance gates; production-state mutation gate) · `AGENTS.md` §"Central Terminal"
  (Central runs read-only diagnostics only; all state change goes through the factory; single-writer).

## 5. [НЕИЗВЕСТНО]
- Whether this registry is enforced as a CI / Guardian gate or remains an advisory registry — **operator
  decision**.
- The exhaustive enumeration of external-key, webhook, and GitHub-App endpoints — to be filled in as each is
  encountered; not invented here.

## Anchors
ADR-135 · `.claude/rules/approval-rules.md` · `.claude/rules/safety-rules.md` · `parallel-session-isolation`
Rule 7 / ADR-121 · `HITL-MATRIX.yaml` · `.claude/rules/agents.md` (HITL BUG-007) · `CLAUDE.md` §1/§11 ·
`AGENTS.md` §"Central Terminal". Complements the line-1 `TERMINAL-OWNERSHIP.md` (write-zones) and ADR-154
(shared-space arbitration). Operator directive 2026-06-30 (line 3 of 7).
