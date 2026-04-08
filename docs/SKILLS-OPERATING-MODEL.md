# SKILLS-OPERATING-MODEL.md — Skills Invocation, Precedence, and Integration
**Version:** 1.0 | **Date:** 2026-04-08 | **Owner:** CTIO + Claude Code
**Reference:** SKILLS-MATRIX.md, PLANES.md, INVARIANTS.md, quality-gate.sh

---

## 1. What a Skill Is

A skill is a reusable, scoped operational procedure that Claude Code (or a sub-agent) may invoke to accomplish a specific class of task. Skills are **not plugins**. They do not bypass existing governance. They operate within — and are constrained by — invariants, the IL system, quality-gate, and plane boundaries.

Skills have three enforcement modes:

| Mode | Behaviour |
|------|-----------|
| **MANDATORY** | Skill must run before the qualifying action completes. Failure blocks the action. |
| **ADVISORY** | Skill runs and produces output. Output informs a decision but does not block. |
| **CONTROLLED** | Skill is allowed under specific conditions (CEO approval, IL entry, QRAA). Default is prohibited in that context. |

---

## 2. Invocation Model

### 2.1 Who Invokes Skills

Skills are invoked by:
- **Claude Code** (Lead Orchestrator) — directly during a session
- **Aider** — when orchestrated by Claude Code with explicit skill scope
- **Agent sub-processes** — only for skills explicitly listed in their passport under `allowed_skills`

Skills are **never** self-invoked autonomously without a trigger condition (see SKILLS-MATRIX.md §Trigger conditions).

### 2.2 Invocation Sequence

```
CEO instruction → IL entry (I-28) → Trigger condition check
                                           ↓
                                    MANDATORY skill? → Run skill → PASS?
                                           ↓                         ↓
                                       No              Yes          Block (if MANDATORY)
                                           ↓
                                    Proceed with task → quality-gate.sh → commit
```

### 2.3 Skill Output Handling

| Output type | Who reviews | What happens |
|-------------|-------------|--------------|
| Blocking violation | Claude Code + CEO | STOP, fix before continuing |
| Advisory report | Claude Code | Log in session, reference in IL proof |
| Generated artifact | Claude Code | Passes quality-gate before treated as valid |
| Contract diff | Claude Code + CTIO | Review; if breaking → QRAA required |

---

## 3. Precedence Order

When a skill conflicts with an existing rule, the following precedence applies (highest wins):

```
1. FCA regulations (CASS 15, MLR 2017, PSR 2017, PS21/3)
2. Invariants I-01..I-28 (INVARIANTS.md)
3. ADRs (Architecture Decision Records)
4. Quality gate (quality-gate.sh + semgrep + ruff + tests)
5. IL discipline (I-28 — INSTRUCTION-LEDGER.md)
6. Skill MANDATORY rules (SKILLS-MATRIX.md)
7. Skill ADVISORY outputs
```

**No skill may override items 1–5.** A skill that would require relaxing an invariant, skipping quality-gate, or bypassing IL registration is **prohibited** regardless of how it is invoked.

---

## 4. Advisory vs Enforcement

| Skill | Mode | Blocking? | Override possible? |
|-------|------|-----------|-------------------|
| Context Memory Sync | MANDATORY (D+P) | No — produces output, does not block git | No override needed |
| CI/CD Quick Setup | MANDATORY (D) / CONTROLLED (P) | Yes in Developer Plane (gate must pass) | CEO explicit approval for Product Plane |
| Rapid Spec Builder | MANDATORY (D+P) | Yes — action cannot start without IL entry | No — I-28 hard rule |
| Error Handling Standardizer | MANDATORY (P) | Yes — ruff/semgrep blocks on bare-except | Fix required, no skip |
| Performance Scanner | MANDATORY (P, payment/AML path) | Advisory report; SLA test blocks if fails | Fix required for SLA test failure |
| API Contract Guardian | MANDATORY (P) | Advisory diff; breaking change = QRAA gate | CEO explicit approval |
| Dependency Optimizer | ADVISORY (all) | No | N/A |
| Smart Test Generator | CONTROLLED (P) | No — generated tests advisory until reviewed | Human review required |
| Auto Refactor Pro | CONTROLLED (P) | No — all existing tests must pass | Test regression = rejected |
| Clean Architecture Enforcer | MANDATORY advisory (all) | Blocking only where semgrep rule exists | Add rule to make it blocking |

---

## 5. Interaction with Existing Governance Infrastructure

### 5.1 quality-gate.sh

Skills do not replace `quality-gate.sh`. They run **before** or **alongside** tasks, and the gate runs **after**. Gate results always take precedence.

```
Skill run (advisory/mandatory) → Task execution → quality-gate.sh → git commit
```

Skills may contribute to gate input:
- Smart Test Generator → generates tests that gate then runs
- Error Handling Standardizer → fixes that ruff then validates
- Clean Architecture Enforcer → proposes semgrep rules that gate then enforces

### 5.2 Claude Code Hooks

Skills do not replace hooks. The existing 6 hooks remain active and run on every qualifying action:

| Hook | Relation to skills |
|------|--------------------|
| `il_gate.py` | Blocks action if IL not registered — Rapid Spec Builder ensures IL exists before trigger |
| `policy_guard.py` | Blocks CLASS_B/C changes — skills cannot bypass |
| `invariant_check.py` | Validates invariants — skills cannot weaken |
| `bounded_context_check.py` | Checks cross-contour imports — Clean Architecture Enforcer surfaces these |
| `load_architecture.py` | Loads CLAUDE.md context — Context Memory Sync complements this |
| `quality_gate_hook.py` | Intercepts `git commit` → runs gate — all skills must produce gate-passing output |

### 5.3 Semgrep (`.semgrep/banxe-rules.yml`)

Skills may **propose** new semgrep rules (Clean Architecture Enforcer, Error Handling Standardizer). They may never **remove** or **weaken** existing rules. Proposed rules become ADVISORY until added to the YAML and verified. Once in the YAML, they are MANDATORY.

### 5.4 Agent Passports

Agents may only invoke skills explicitly listed in their passport under `allowed_skills`. An agent that invokes an unlisted skill violates its trust zone boundary (I-20).

### 5.5 INSTRUCTION-LEDGER.md (I-28)

- Skills that produce new implementation work must be preceded by an IL entry.
- Skills that produce only reports (Performance Scanner, Dependency Optimizer) do not require an IL entry.
- Context Memory Sync writes to IL as part of its output.
- Rapid Spec Builder creates the IL entry as its primary output.

---

## 6. Repository Boundary Rules

No skill may cross repository boundaries implicitly:
- A skill running in `banxe-emi-stack` may not read or write files in `vibe-coding` or `banxe-architecture` without explicit CEO instruction.
- A skill running in any Banxe plane may not read, write, or reference files from `guiyon` or `ss1` (I-18, I-20).
- Context Memory Sync writes only to its own plane's memory files.
- CI/CD Quick Setup configures only the target repo's pipelines.

---

## 7. Standby Plane Isolation Policy

GUIYON and SS1 are Standby Plane projects. The following applies to all skills when used in those repos:

| Rule | Detail |
|------|--------|
| No Banxe data | Skills must not access or reference Banxe ClickHouse, Midaz, Redis, or `.env` values |
| No Banxe IL | Context Memory Sync in Standby context writes to a separate memory file; no Banxe IL IDs referenced |
| No shared pipelines | CI/CD Quick Setup must not create pipelines that connect to Banxe infrastructure |
| No shared dependencies | Dependency Optimizer must not add packages shared with Banxe services |
| Local-first | All skill outputs stay within the Standby repo; no propagation to Developer or Product planes |
| MiroFish activation | Separate activation per project — never share MiroFish context between planes |

---

## 8. Change Control for Skills

| Change type | Process |
|-------------|---------|
| Add new skill | IL entry → update SKILLS-MATRIX.md + SKILLS-OPERATING-MODEL.md → update CLAUDE.md → CEO approval |
| Change skill mode (e.g. ADVISORY → MANDATORY) | ADR required + IL entry |
| Remove skill | ADR required + CEO approval + IL entry |
| Add skill to agent passport | IL entry + QRAA if agent is in Product Plane |
| Add new semgrep rule proposed by skill | IL entry + CTIO review → merge to `.semgrep/banxe-rules.yml` |

---

*Document maintained: Claude Code (Developer Plane architect)*
*Update when: new skill added, enforcement mode changes, new hook or gate interaction documented.*
