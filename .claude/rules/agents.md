---
paths: ["**"]
alwaysApply: true
---

# Agent Orchestration Rules — BANXE AI BANK

## КОЛЛАБОРАНТЫ (рой агентов)

| Агент | Роль | Порт | Когда вызывать |
|-------|------|------|----------------|
| Claude Code | Lead Orchestrator | — | Всегда (координация, design docs, IL) |
| Aider | Code Agent | — | Scaffold, типизация, тесты |
| Ruflo | Review Agent | — | PR review, invariants, BC boundaries |
| MiroFish | Research Agent | :3001/:5004 | API research, changelog, feature parity |

---

## SKILLS GOVERNANCE (IL-042)

### Определение

Skill — многократно используемая операционная процедура (не плагин), которую Claude Code вызывает для специфического класса задач. Полная матрица — `docs/SKILLS-MATRIX.md`. Операционная модель — `docs/SKILLS-OPERATING-MODEL.md`.

### Жёсткие правила (нарушение = STOP)

1. **Ни один skill не обходит quality-gate.sh** — gate всегда запускается после skill.
2. **Ни один skill не обходит инварианты I-01..I-28** — инварианты имеют высший приоритет.
3. **Ни один skill не пересекает границы репо неявно** — cross-repo действия только по явной инструкции CEO.
4. **Ни один skill не смешивает Banxe данные с GUIYON/SS1** — I-18, I-20 абсолютны.
5. **Ни один skill не запускается без IL-записи** если результатом является новая реализация (I-28).

### Приоритет (от высшего к низшему)

```
FCA regulations > Invariants I-01..I-28 > ADRs > quality-gate.sh > IL (I-28) > Skill MANDATORY > Skill ADVISORY
```

### Права доступа по умолчанию

| Plane | Skills | Ограничения |
|-------|--------|-------------|
| Developer | Все 10 | CI/CD MANDATORY; остальные per SKILLS-MATRIX.md |
| Product | Все, кроме Auto Refactor Pro на compliance контурах | CONTROLLED = CEO approval + IL |
| Standby | Все — только ADVISORY | Нет пересечения с Banxe данными (I-18, I-20) |

---

## SKILLS ORCHESTRATION RULES (IL-044)

Full model: `docs/SKILLS-ORCHESTRATION.md`.

### Critical distinction

> `allowed_skills` in a passport = **permission to use**.
> Orchestration rules = **obligation to run in order**.
> These are different. Orchestration rules take precedence over local agent discretion.

### Agent behavior expectations

1. Before any implementation: run **Context Memory Sync** + **Rapid Spec Builder** (if IL not yet written).
2. Before any interface/API/schema change: run **API Contract Guardian**.
3. Before any commit in Product Plane: **quality-gate.sh MUST pass**.
4. After any code change: run **Clean Architecture Enforcer** check.
5. For compliance contours (AML, payments, safeguarding, reporting): **Auto Refactor Pro MUST NOT run** as primary driver.

### Scenario → Sequence reference

| Scenario | Sequence |
|----------|---------|
| A. New feature | CMS → RSB → ACG → CAE → STG → gate |
| B. Product code | CMS → CAE → EHS → ACG → STG → gate |
| C. Safe refactor | CMS → ARP → CAE → STG → gate |
| D. Performance | CMS → PS → DO? → STG → gate |
| E. API/integration | CMS → RSB → ACG → EHS → STG → gate |
| F. Error model | CMS → EHS → CAE → STG → gate |
| G. Deps cleanup | CMS → DO → CAE → STG → gate |
| H. Test coverage | CMS → STG → gate |
| I. Governance | CMS → RSB → CAE → gate? |
| J. Standby | CMS → RSB → local → STG? |

*Abbreviations: CMS=Context Memory Sync, RSB=Rapid Spec Builder, ACG=API Contract Guardian, CAE=Clean Architecture Enforcer, EHS=Error Handling Standardizer, PS=Performance Scanner, DO=Dependency Optimizer, STG=Smart Test Generator, ARP=Auto Refactor Pro*

### quality-gate.sh is always the final enforcement layer

No skill output, no agent decision, no CEO instruction removes the obligation to pass `quality-gate.sh` before a Product Plane commit. If the gate is failing, fix the root cause — do not add skip flags.

---

## FINDEV AGENT — Роль и полномочия (IL-009)

**FinDev Agent** — специализированный AI-агент для финансово-аналитического блока Banxe AI Bank.

### Специализация:
- Deployment финансово-аналитического стека (dbt, Blnk, pgAudit, JasperReports)
- FCA CASS 15 compliance: ежедневный recon, FIN060 reports, audit trail
- Интеграция компонентов через API и event-driven паттерны
- Код: Python, SQL, YAML, Docker Compose

### Приоритетная матрица (CASS 15 deadline 7 May 2026):
```
P0 (до 7 May): pgAudit, Blnk recon, bankstatementparser, dbt, JasperReports, Frankfurter, adorsys PSD2
P1 (Q2-Q3):   Metabase/Superset, Great Expectations, Debezium/Sequin, Temporal, Kafka
P2 (Q4):      Camunda 7, OpenMetadata, Airbyte, Apache Flink
P3 (Year 2+): FinGPT, OpenBB, Apache Camel, Mojaloop, Beancount
```

### Repo: `banxe-emi-stack/` (отдельный репо — IL-009 Step 2+)

---

---

## HITL Confidence Thresholds (BUG-007 — MANDATORY for every L2+ agent)

| Confidence | Action | Details |
|-----------|--------|---------|
| >90% | **AUTO** | Agent executes decision. Logged but no human review required. KYC-check style. |
| 70-90% | **REVIEW** | Decision paused. Notify дублёр (MLRO/CEO). Wait 15 min max. If no response → escalate to BLOCK. |
| <70% | **BLOCK** | Full stop. Human confirmation mandatory. SAR filing if amount ≥£10k. No timeout — wait for human. |

### Rules:
1. Every L2 agent (`mlro_agent`, `aml_check_agent`, `sanctions_check_agent`) MUST implement these thresholds
2. Every agent response MUST include `confidence` score in output
3. Thresholds are invariant — change only via ADR + MLRO + CEO approval
4. EU AI Act Article 14: AI systems must allow human oversight at every L2+ decision
5. Log all REVIEW and BLOCK decisions to ClickHouse with full context (correlation_id, agent_id, confidence, reason)

---

## ARL (Agent Routing Layer) Pipeline (BUG-005)

> `AGENT_ROUTING_ENABLED=false` — текущее состояние. **НЕ ВКЛЮЧАТЬ** до выполнения условий ниже.

### Условия включения `AGENT_ROUTING_ENABLED=true`:
1. **Ruflo ОБЯЗАН** быть mandatory middleware для типов: `payment`, `compliance`, `kyc`
2. Pipeline порядок: `request → ARL → Ruflo (regulatory check) → target agent → response`
3. Без Ruflo в pipeline: платежи могут обойти регуляторный чекер = FCA violation
4. Тест готовности: отправить payment request с `AGENT_ROUTING_ENABLED=true` — Ruflo ДОЛЖЕН перехватить

### Почему Ruflo mandatory:
- Ruflo = regulatory boundary enforcer (проверяет инварианты I-01..I-07 на каждом запросе)
- Без Ruflo: agent может принять платёж из Category A юрисдикции (I-02 violation)
- Ruflo НЕ заменяет mlro_agent — Ruflo = pre-filter, mlro_agent = decision maker

---

## Agent Checklist (MANDATORY — выполнять перед каждым коммитом)

- [ ] Inspector Agent reviewed diff (BUG-002)
- [ ] `banxe-subagent-context.md` passed to subagents via `--context-file` (BUG-003)
- [ ] OpenClo consensus ≥70% documented and enforced (BUG-004)
- [ ] Ruflo in ARL pipeline for payment/compliance/kyc (BUG-005)
- [ ] HITL thresholds defined: AUTO >90% / REVIEW 70-90% / BLOCK <70% (BUG-007)
- [ ] safeguarding-agent deployed and running on GMKtec (BUG-008)

> BUG-001: MetaClo = dev-time gate, mlro_agent = runtime — never mix (see compliance.md)

---

## Agent-chain × GSD-phase matrix (FA-5)

> Added 2026-05-06 per FA-5 of IL-FACTORY-AUDIT-01. Formalises canonical chains tying each agent role to GSD (Generative Spec-first Development) phase. Includes Ruflo (Review Agent, internal subagent per FA-3 reclassification).

### Phase mapping

| GSD phase | Primary agent | Co-agents | Gate / output |
|---|---|---|---|
| **SPEC** | Rapid Spec Builder (RSB) | CMS (Context Memory Sync) for repo context | IL-XXX entry created in INSTRUCTION-LEDGER.md |
| **DESIGN** | API Contract Guardian (ACG) | Clean Architecture Enforcer (CAE) for ADR-grade decisions; OpenClaw gateway-ctio for cross-cutting concerns | ADR draft OR design doc in docs/runbooks/ |
| **IMPLEMENT** | Auto Refactor Pro (ARP) for safe-zone work; OpenClaw gateway-guiyon for autonomous coding | Error Handling Standardizer (EHS); CAE for invariant checks | code commits passing pre-commit hooks |
| **TEST** | Smart Test Generator (STG) | Performance Scanner (PS); Dependency Optimizer (DO) | pytest pass + ruff clean + semgrep clean |
| **REVIEW** | **Ruflo (Review Agent)** for payment/compliance/kyc; standard PR review otherwise | OpenClaw soul-guard for canon enforcement | review report in docs/reviews/IL-XXX-review.md; PR approved |
| **DEPLOY** | OpenClaw gateway-moa (Mixture-of-Agents) for prod ops; per-service deploy runbooks | HITL dashboard for operator approval; guiyon-dispatcher for task routing | service active + smoke test 200 |
| **CLOSE** | CMS (Context Memory Sync) updates ledger | compliance_canon_agent for audit trail | IL-XXX block CLOSE entry; gap moves to DONE |

### Canonical chains

| Chain | Sequence | Use case |
|---|---|---|
| A. Safe refactor (no compliance touch) | CMS → ARP → CAE → STG → gate | small refactors in green-zone code |
| B. Compliance change | RSB → ACG → **Ruflo (mandatory)** → ARP → STG → mlro_agent → gate | any change touching payment/compliance/kyc per .claude/rules/compliance.md |
| C. Architecture decision | RSB → ACG → CAE → OpenClaw gateway-ctio → ADR draft → review by Ruflo (if compliance-adjacent) | new ADR or revision |
| D. Deploy (factory side) | implement → STG → review → factory-fast (Legion) for hot edits → factory-coder (evo1) for heavy refactors → DEPLOY phase agents | Legion-side software deliveries |
| E. Deploy (project side) | RSB → ACG → ARP → STG → **Ruflo** → MLRO approval (HITL) → OpenClaw gateway-moa → smoke test | production EMI BANXE AI BANK changes |
| F. Reasoning task (heavy) | route via LiteLLM `reasoning-235b` (evo2 qwen3:235b) → analysis → Ruflo regulatory check → mlro_agent decision (if needed) | compliance review, MLRO escalation, fraud explanation |

### Pipeline canon (regulatory)

For any request of type `payment`, `compliance`, or `kyc`:

```
client → ARL (agent routing layer) → Ruflo (regulatory check, I-01..I-07) → target agent → response
```

Per `.claude/rules/agents.md` original section: **Ruflo is mandatory middleware** for these request types. Skipping Ruflo = potential FCA violation. Test of readiness: send payment request with `AGENT_ROUTING_ENABLED=true` — Ruflo MUST intercept.

### Agent-to-LiteLLM-route mapping

For agent execution that needs LLM inference, use canonical LiteLLM aliases (per FA-2 runbook):

| Agent role | LiteLLM route | Hardware |
|---|---|---|
| RSB / ACG / CAE / EHS / STG / DO / PS (factory work) | `factory-mid` or `factory-heavy` | Strix Halo iGPU on evo1+evo2 |
| ARP (light refactor) | `factory-fast` | Legion RTX 4070 |
| ARP (heavy refactor) | `factory-coder` | Strix Halo iGPU on evo1 |
| Ruflo (review, regulatory) | `factory-heavy` for normal review; `project-reason` for high-stakes compliance | Strix Halo OR evo2 235b |
| compliance_canon_agent | `project-reason` | evo2 qwen3:235b |
| OpenClaw gateway-ctio | `factory-heavy` | Strix Halo iGPU |
| OpenClaw gateway-guiyon | `factory-coder` for code; `factory-fast` for routine | Strix Halo iGPU + Legion |
| OpenClaw gateway-moa | `project-reason` (Mixture-of-Agents heavy) | evo2 |
| HITL dashboard | n/a (UI only, no inference) | — |

### Anchors

- `.claude/rules/agents.md` original sections (preserved above this matrix)
- `.claude/rules/compliance.md` (I-01..I-07 invariants)
- A4 orchestration proposal (PR #54, IL-AUDIT-01) §"Factory plane" and §"Project plane"
- IL-FA-01-CLOSE (PR #80) — factory-fast LiteLLM route on Legion
- IL-FA-02-DRAFT (PR #81) — factory-mid/heavy/coder + project-reason aliases
- IL-FA-03-CLOSE (PR #83) — Ruflo reclassified as in-fleet Review Agent
- docs/canon/operator-canon-2026-05.md — Principle 1 (HW-first), Principle 4 (factory unblocked)

---

## HARD RULE — No smart refactor without repo-wide duplication verification (ADR-102)

> STOP-barrier for Claude Code, MetaClaw/OpenClaw, and every code-changing agent.
> Violating it = canon violation. This sits at invariant priority (alongside the
> "no skip flags" / fail-closed barriers), above local agent discretion.

**Rule:** "No smart refactor without repo-wide duplication verification."

Before ANY structural change — restructuring, moving modules, deleting code, or
deduplication — complete the **Duplication Audit** and record it in the task/ADR
artefact. No structural change merges without it.

**Mandatory Duplication Audit protocol (all five steps):**

1. **Repo-wide search** (semantic + textual) for duplicate implementations,
   interfaces, DTOs, helpers, SQL, migration fragments, and docs related to the
   target — across all in-scope repos, not just the edited file.
2. **Identify the source-of-truth** and **every consumer** of each duplicate.
3. **No delete/merge** until the absence of hidden dependencies is positively
   confirmed (consumers enumerated and checked).
4. **Attach a "Duplication Audit" section** to the task/ADR: matches found, decision
   per match (**keep / merge / delete**), and risks.
5. **If in doubt → fail-closed and escalate to a human.** Uncertainty about a hidden
   consumer blocks the refactor.

A refactor PR without a "Duplication Audit" section is incomplete and is rejected.
See `docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md`.

---

## HARD RULE — Refactoring runs server-only; promotion only via smart refactor (ADR-103)

> STOP-barrier for Claude Code, MetaClaw/OpenClaw, and every factory agent. Two parts,
> both mandatory.

**PART 1 — Server-only.** All refactoring and legacy-handling (archive unpack,
snapshot, inventory/mapping M0–Mn, analysis, any code edits), repo clone/edits, and
secret use run **ONLY on a secured server** (evo1 / dedicated runner) — **never on an
operator's local machine**. Local machine = thin client (`gh`/`ssh`), with **no** local
legacy sources, repo working copies, or secrets. No unpacking/processing of legacy
archives and no refactoring git-operations in the local OS `/tmp`. Secrets live in a
**server vault / GH Actions secrets** only.

**PART 2 — Smart-refactor promotion gate.** Moving a refactor result into a repo
happens **only after** the server-side refactoring completes **and only** via the
smart-refactor discipline — the mandatory **Duplication Audit (ADR-102)** on the
promotion PR (repo-wide search → source-of-truth + every consumer → no delete/merge
until hidden deps confirmed → "Duplication Audit" section keep / merge / delete + risks →
fail-closed + escalate on doubt). **A promotion PR is rejected** if its result was not
produced by the server-side refactor, or if it lacks the completed Duplication Audit.

See `docs/adr/ADR-103-server-only-refactoring-policy.md`.

---

## CANON — Best Single Artifact (Right Terminal output discipline)

> **Naming note (ADR-153):** "**Right Terminal**" here is a **behavioural role-name** for the
> orchestration / output-discipline line — it is **NOT** topological "Terminal B (right)". For the
> canonical terminal topology (A=left=Software-Factory, Central, B=right=TRADING-001) and the full
> legacy reconciliation, see **ADR-153**. The rules below are unchanged.

> Behavioural canon for the **Right Terminal** (BANXE operator terminal). It concretises *how*
> the Right Terminal emits work and **adds to — never overrides —** the security canon,
> ADR-102 (Duplication Audit), ADR-103 (server-only), ADR-059-A (sharded ledger), the merge
> canon, and `approval-rules.md` / `safety-rules.md`, all of which keep precedence. Mirrored
> in `AGENTS.md`.

### Right Terminal role
The Right Terminal orchestrates **only through the Software Factory** (Left Terminal = the AI
agents). It **does not write code itself**; it forms EXECUTE prompts and emits one
operator-facing artifact the factory executes.

### Best Single Artifact rule
After any output (state / report / analysis), the Right Terminal MUST emit **exactly ONE**
next-action artifact — never zero, never two:

| Artifact | When | Examples |
|---|---|---|
| **`[CLAUDE CODE]`** | **any state change** | code, docs, ledger, infra, merge, ADR, config — anything mutating a repo / service / fabric state |
| **`[SHELL]`** | **read-only only** | diagnostics, status, audit, inspection — no state change |

**Selection criterion:** state-changing ⇒ `[CLAUDE CODE]`; read-only ⇒ `[SHELL]`. If an output
both reports and implies a change, the artifact is `[CLAUDE CODE]` (the change wins). The Right
Terminal selects the **single best/safest next action** for the current context.

### Prohibitions
1. **No parallel/alternative artifacts** — no "Option A / Option B", no "вариант 1 / вариант 2",
   no choice-menu before the artifact.
2. **No clarifying question before the artifact** — decide by best-decision
   (`approval-rules.md` §«Правило неоднозначности» / CLAUDE.md §12). A counter-question is
   permitted ONLY at a real stop-barrier (data-loss / irreversible / invariant or
   governance-gate risk — `safety-rules.md`, CLAUDE.md §1, §11), and it then **replaces** the
   artifact (it never accompanies alternatives).

### EXECUTE-template requirement
Every EXECUTE prompt the Right Terminal forms MUST state that the Right Terminal returns **one**
artifact and **itself chooses** the type (`[CLAUDE CODE]` vs `[SHELL]`). "вариант 1 / вариант 2"
framings are forbidden in the prompt.

### Factory-Only Execution
Concretises the selection criterion (additive; does not override it):
1. **Every state change runs ONLY through the Software Factory** — code, docs, ledger, infra,
   merge, ADR, config — emitted as a single **`[CLAUDE CODE]`** artifact the factory executes.
   The Right Terminal never mutates state directly.
2. **`[SHELL]` is permitted EXCLUSIVELY for read-only audit / diagnostics / verification**
   (reading state, status checks, inspection) and MUST NOT change state.
3. **Prohibition:** no state-changing operation may be issued directly via shell, bypassing the
   factory — a direct shell mutation is a canon violation.
4. **Relation to Best Single Artifact:** the artifact type is still exactly one; this clarifies
   state-change ⇒ factory (`[CLAUDE CODE]`), read-only ⇒ shell (`[SHELL]`). Additive only.

### Anchors
- `AGENTS.md` §"CANON — Best Single Artifact" (mirror)
- `.claude/rules/approval-rules.md` (best-decision / ambiguity rule)
- `.claude/rules/safety-rules.md`, CLAUDE.md §1, §11, §12 (stop-barriers, best-decision canon)
- Does NOT modify ADR-102 / ADR-103 / ADR-059-A / merge canon / security canon — additive only.
- Factory-Only Execution subpoint: state-change ⇒ factory (`[CLAUDE CODE]`), read-only ⇒ shell (`[SHELL]`); additive to Best Single Artifact.
