# AGENTS.md — Developer Core: Central Repository for Shared Components

**Repository:** `~/developer/`  
**Version:** 4.0 | 2026-04-06  
**Purpose:** Shared components, templates, and configurations distributed across all projects  
**Architecture:** Four-Partner Swarm v2.0 (Claude Code + Ruflo + Aider CLI + MiroFish)

---

## Core mission

This repository is the **central source of truth** for:

- Agent instructions (AGENTS.md, CLAUDE.md templates)
- **Four-partner swarm architecture** (Claude Code + Ruflo + Aider CLI + MiroFish)
- Compliance architecture (COMPLIANCE_ARCH.md)
- Shared scripts and automation (sync-all.sh, onboard-project.sh)
- Project templates
- MCP best practices
- **MiroFish scenario templates** (MASTER copies for all projects)

### Four-Partner Swarm Architecture (v2.0)

All projects use the same four-partner stack:

| # | Partner | Role | Entry point |
|---|---------|------|-------------|
| 1 | **Claude Code** | Architect, reviewer, orchestrator | `claude` |
| 2 | **Ruflo** | Multi-step flow orchestrator | `ruflo/start-ruflo.sh` |
| 3 | **Aider CLI** | Sole code executor | `scripts/aider-banxe.sh` |
| 4 | **MiroFish** | Behavioural + regulatory simulator | `:3001` (UI) / `:5004/health` (API) |

**LiteLLM** = infrastructure model routing layer (not a partner).  
**MetaClaw/OpenClaw** = platform layer (not a partner).

**Key principle:** MiroFish is a partner for ALL projects, not just Banxe.
- Banxe projects: banking/FCA/fraud scenarios
- Legal projects: court/judge/appeal scenarios
- Developer-core: infrastructure & sync validation

### Distribution model

Components from this repository are synced to:

| Project | Type | Sync target | MiroFish | Scenarios |
|---------|------|-------------|----------|-----------|
| vibe-coding | banxe | `/home/mmber/vibe-coding/` | ✅ | banking/FCA/fraud |
| collaboration | banxe | `/home/mmber/collaboration/` | ✅ | multi-agent conflicts |
| MetaClaw | banxe | `/home/mmber/MetaClaw/` | ✅ | orchestration scaling |
| guiyon | legal | `/home/mmber/guiyon/` | ✅ | court strategy |
| ss1 | legal | `/home/mmber/ss1/` | ✅ | appeal dynamics |
| banxe-mirofish | tool | `/home/mmber/banxe-mirofish/` | ✅ | MASTER templates |
| developer-core | core | `/home/mmber/developer/` | ✅ | ALL (MASTER) |

---

## Instruction hierarchy (for THIS repository)

1. **Explicit user instruction** (highest authority)
2. **CANON** (`~/developer/canon/`) — CORE.md, DEV.md, FR_MODULE.md
3. **Repository-level contracts**:
   - `CLAUDE.md` (project context)
   - `AGENTS.md` (this file)
   - `docs/COLLAB.md` (collaboration contract)
4. **Global defaults**: `~/.claude/CLAUDE.md`

---

## Orchestration Protocol v4.0

### Subagent patterns

Named patterns for Claude Code subagent orchestration — see `docs/subagent-patterns.md`:

| Pattern | When to use |
|---------|-------------|
| **RIV** | New feature with unknown dependencies |
| **MFR** | Refactor touching N≥3 files independently |
| **CA** | Compliance audit before PR merge |
| **PDG** | Pre-deploy gate before GMKtec production |
| **MED** | Human behaviour / fraud / regulatory design |

### Aider CLI as sole executor

All code changes go through Aider CLI via LiteLLM:

```bash
bash scripts/aider-banxe.sh --fast     # glm-4-flash — quick tasks
bash scripts/aider-banxe.sh --full     # qwen3-30b — complex tasks (default)
bash scripts/aider-banxe.sh --banxe    # qwen3-banxe — compliance domain
bash scripts/aider-banxe.sh --unrestricted  # gpt-oss-20b — no guardrails
```

### Parallel verification

Before committing compliance or security changes:

```bash
bash scripts/parallel-verify.sh --file src/compliance/sanctions_check.py
# 3 models in parallel: compliance / security / alternative
# Consensus: 2/3 PASS → ✅  |  <2/3 → ⚠️ NEEDS REVIEW
```

### Rule for downstream projects

When syncing components TO a project, that project's local files take precedence over these templates.

**These are templates and starting points, not immutable laws.**

---

## HARD RULE — No smart refactor without repo-wide duplication verification

A STOP-barrier for Claude Code, MetaClaw/OpenClaw, and every code-changing agent
(ADR-102). Before ANY structural change — restructuring, moving modules, deleting
code, or deduplication — complete the **Duplication Audit** and record it in the
task/ADR artefact; no structural change merges without it:

1. Repo-wide (semantic + textual) search for duplicate implementations, interfaces,
   DTOs, helpers, SQL, migration fragments, and docs — across all in-scope repos.
2. Identify the source-of-truth and every consumer of each duplicate.
3. No delete/merge until the absence of hidden dependencies is positively confirmed.
4. Attach a **"Duplication Audit"** section: matches, decision (keep / merge / delete),
   risks.
5. If in doubt → **fail-closed and escalate to a human.**

Full protocol: `.claude/rules/agents.md` and
`docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md`.

---

## HARD RULE — Refactoring runs server-only; promotion only via smart refactor

A STOP-barrier (ADR-103), two mandatory parts:

- **PART 1 — Server-only:** all refactoring + legacy-handling (archive unpack,
  snapshot, inventory/mapping M0–Mn, analysis, any code edits), repo clone/edits, and
  secret use run **only on a secured server** (evo1 / dedicated runner) — **never on an
  operator's local machine**. Local = thin client (`gh`/`ssh`), no local sources, no
  secrets; no legacy unpack or refactor git-ops in local `/tmp`. Secrets live in a
  server vault / GH Actions secrets only.
- **PART 2 — Smart-refactor promotion gate:** promote a result into a repo **only
  after** the server-side refactor completes **and only** via a completed **Duplication
  Audit (ADR-102)** on the promotion PR. A promotion PR with no server-side refactor, or
  no Duplication Audit, is **rejected**.

Full policy: `.claude/rules/agents.md` and
`docs/adr/ADR-103-server-only-refactoring-policy.md`.

---

## HARD REQUIREMENT — Three-node execution fabric (ADR-104)

`evo1`, `evo2`, and `Legion` run as **one end-to-end execution fabric**, not three
isolated boxes. `evo2` is the **reasoning brain** but never acts in isolation:

- **Node roles:** **evo1** = control/orchestration (task lifecycle + policy gate + queue/
  heartbeat); **evo2** = heavy inference/planning (reasoning brain — plans, never acts);
  **Legion** = execution/ops/tooling (the only node that runs actions).
- **Invariants:** (1) one task lifecycle + a single `correlation_id` across all three
  nodes; (2) shared task/event queue + heartbeat/health; (3) `evo2` reaches a prod action
  ONLY via the **evo1 policy gate → Legion execution gate** (reason → policy → execute);
  (4) shared context only through a controlled **sync layer**, no implicit drift; (5)
  **failover** — evo2 down → evo1 degrades to lightweight reasoning + Legion blocks risky
  actions (no split-brain); (6) **all agent, refactor, and migration tasks are three-node by
  default**.

Full contract: `docs/runbooks/three-node-execution-fabric-contract.md` and
`docs/adr/ADR-104-three-node-execution-fabric.md`.

---

## CANON — Best Single Artifact (Right Terminal output discipline)

> Behavioural canon for the **Right Terminal** (BANXE operator terminal). Concretises *how*
> the Right Terminal emits work; it adds to — and never overrides — the security canon,
> ADR-102 (Duplication Audit), ADR-103 (server-only), ADR-059-A (sharded ledger), the merge
> canon, and the approval/safety rules, all of which keep precedence.

**Right Terminal role.** The Right Terminal orchestrates **only through the Software Factory**
(the Left Terminal = the AI agents). It does **not write code itself**; it produces
operator-facing artifacts that the factory executes.

**Best Single Artifact rule.** After any output (state / report / analysis), the Right
Terminal MUST emit **exactly ONE** next-action artifact — never zero, never two:

- **`[CLAUDE CODE]`** — for **any state change**: code, docs, ledger, infra, merge, ADR,
  config — anything that mutates a repo, a service, or fabric state.
- **`[SHELL]`** — for **read-only** operator/audit commands **only**: diagnostics, status,
  inspection — nothing that changes state.

**Selection criterion.** State-changing ⇒ `[CLAUDE CODE]`; read-only ⇒ `[SHELL]`. If an
output both reports and implies a change, the artifact is `[CLAUDE CODE]` (the change wins).
The Right Terminal picks the **single best/safest next action** for the current context.

**Prohibitions.**
- **No parallel/alternative artifacts** — no "Option A / Option B", no "вариант 1 / вариант 2",
  no menu of choices.
- **No clarifying question before the artifact.** Decide by best-decision (per
  `approval-rules.md` §«Правило неоднозначности» / CLAUDE.md §12). A counter-question is
  allowed ONLY at a genuine stop-barrier (data-loss / irreversible / invariant or
  governance-gate risk — `safety-rules.md`, CLAUDE.md §1, §11), and even then it replaces the
  artifact rather than accompanying alternatives.

**EXECUTE-template requirement.** Every EXECUTE prompt the Right Terminal forms must state
that the Right Terminal returns **one** artifact and **itself chooses** the type
(`[CLAUDE CODE]` vs `[SHELL]`); "вариант 1 / вариант 2" framings are forbidden in the prompt.

**Factory-Only Execution.** Concretises the selection criterion (additive; does not override it):
- **Every state change runs ONLY through the Software Factory** — code, docs, ledger, infra,
  merge, ADR, config — and is emitted as a single **`[CLAUDE CODE]`** artifact the factory
  executes. The Right Terminal never mutates state directly.
- **`[SHELL]` is permitted EXCLUSIVELY for read-only audit / diagnostics / verification**
  (reading state, status checks, inspection) and MUST NOT change state.
- **Prohibition:** no state-changing operation may be issued directly via shell, bypassing the
  factory. A direct shell mutation = canon violation.
- **Relation to Best Single Artifact:** the artifact type is still exactly one; this subpoint
  clarifies that state-change ⇒ factory (`[CLAUDE CODE]`) and read-only ⇒ shell (`[SHELL]`). It
  is additive and does **not** modify ADR-102 / ADR-103 / ADR-059-A / the merge canon / the
  security canon / Best Single Artifact.

---

## CANON — Central Focus / No Distraction (Right Terminal discipline)

- Central (read-only оркестратор) НЕ ИМЕЕТ ПРАВА ОТВЛЕКАТЬСЯ от поставленной Operator'ом задачи в побочные/governance циклы. Фокус удерживается строго на текущей задаче до её завершения.
- Язык общения — русский.
- Additive only: does not override security canon, merge canon, the stop-barriers, or ADR-102/103/059-A.

### Единое ядро канона (binding)

1. **READ-ONLY AUTHORITY / SINGLE-WRITER (I-71):** Central does NOT run `git push` / `gh pr create` / `gh pr merge` / `git tag` / direct-write to `main`. All writes go through the factory only (single-writer).
2. **PRE-FLIGHT CHECK (read-only) before every move:** `git fetch --all --prune`; `git log --oneline origin/main -3`; `gh pr list --state open`; verify no conflict-prone state.
3. **PARALLEL SESSION HALT:** on detecting parallel work on the same track — STOP, record an IL, wait.
4. **WORKTREE ISOLATION:** each task = a separate worktree + branch from `origin/main`; do not work in the main worktree; do not touch `MEMORY.md`.
5. **ЯЗЫК (bilingual):** ответы оператору — русский, простым языком, без лести/emoji; technical artifacts (commits, IL, file names, commands, GAP-IDs, Invariant-IDs) — English.
6. **ФОРМАТ ШАГА:** один шаг = одна команда ИЛИ один промпт; без параллельных операций; явное назначение (shell / Claude Code prompt / GitHub action) + цель.
7. **BEST SOLUTION PRINCIPLE (binding):** после каждого вывода — автоматически, без вопросов, ровно один Claude Code промпт ИЛИ одна shell-команда по принципу лучшего решения; основа формирования любой команды/промпта, всегда.

## Repository structure

```
~/developer/
├── AGENTS.md                        ← This file — agent instructions
├── CLAUDE.md                        ← Project context
├── canon/                           ← CANON modules (CORE, DEV, FR_MODULE …)
├── docs/
│   ├── COLLAB.md                    ← Collaboration contract (v4.0)
│   ├── subagent-patterns.md         ← Named subagent patterns
│   └── MCP-BEST-PRACTICES.md        ← MCP configuration guide
├── ruflo/
│   ├── config.yaml                  ← Ruflo orchestrator config
│   └── start-ruflo.sh               ← Stack health check + startup
├── scripts/
│   ├── aider-banxe.sh               ← Aider CLI via LiteLLM (4 modes)
│   ├── parallel-verify.sh           ← 3-model consensus gate
│   ├── start_banxe_stack.sh         ← Master startup script
│   ├── check-agent-instructions.sh  ← Diagnostic tool
│   └── sync-to-project.sh           ← Sync script
├── templates/
│   ├── project-template/            ← New project bootstrap
│   └── compliance-module/           ← AML/KYC module template
└── compliance/
    ├── COMPLIANCE_ARCH.md           ← Invariants contract
    └── api.py                       ← Reference implementation
```

---

## Component catalog

### Templates (copy to new projects)

| Component | Source | Target | Purpose |
|-----------|--------|--------|---------|
| `AGENTS.md` | `./AGENTS.md` | `{project}/AGENTS.md` | Agent instructions |
| `docs/COLLAB.md` | `./docs/COLLAB.md` | `{project}/docs/COLLAB.md` | Collaboration contract |
| `docs/subagent-patterns.md` | `./docs/subagent-patterns.md` | `{project}/docs/subagent-patterns.md` | Subagent patterns |
| `ruflo/config.yaml` | `./ruflo/config.yaml` | `{project}/ruflo/config.yaml` | Ruflo config |
| `scripts/aider-banxe.sh` | `./scripts/aider-banxe.sh` | `{project}/scripts/aider-banxe.sh` | Aider executor |
| `scripts/parallel-verify.sh` | `./scripts/parallel-verify.sh` | `{project}/scripts/parallel-verify.sh` | Verification gate |

### Compliance stack (read-only reference)

| Component | Purpose | Projects using |
|-----------|---------|----------------|
| `compliance/COMPLIANCE_ARCH.md` | Invariants contract | vibe-coding |
| `compliance/api.py` | Reference API | vibe-coding |
| `compliance/sanctions_check.py` | OFAC Watchman integration | vibe-coding |
| `compliance/audit_trail.py` | ClickHouse audit logging | vibe-coding |

### Scripts (shared utilities)

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/start_banxe_stack.sh` | Master startup — all components | `bash start_banxe_stack.sh` |
| `scripts/aider-banxe.sh` | Aider CLI via LiteLLM | `bash aider-banxe.sh --full` |
| `scripts/parallel-verify.sh` | 3-model consensus gate | `bash parallel-verify.sh --file path.py` |
| `scripts/sync-all.sh` | Sync all projects from registry | `bash sync-all.sh [--dry-run]` |
| `scripts/onboard-project.sh` | Onboard new project | `./onboard-project.sh <name> <type>` |
| `scripts/check-agent-instructions.sh` | Verify instruction hierarchy | Debug agent setup |

---

## Sync protocol

### Sync protocol

#### Manual sync (current method)

```bash
cd ~/developer
bash scripts/sync-all.sh
```

#### Automatic sync (future state)

**Post-commit hook** (`~/developer/.git/hooks/post-commit`):
- On commit to `~/developer/`: auto-run sync-all.sh
- Detect changed components
- Identify affected projects
- Commit and push to all repos automatically

### Change management

### Safe changes (auto-sync allowed)

- Documentation updates
- Comment additions
- Formatting fixes
- Test additions

### Review-required changes (manual sync)

- Configuration changes (ruflo/config.yaml, AGENTS.md)
- Instruction hierarchy changes (AGENTS.md)
- Compliance invariant changes (COMPLIANCE_ARCH.md)
- Script logic changes

### Sync approval workflow

1. Change committed to `~/developer/`
2. User runs `bash scripts/sync-to-project.sh <project>`
3. Script shows diff for each target
4. User approves/rejects per project
5. Changes applied to targets

---

## Project isolation enforcement

**CRITICAL:** This repository contains SHARED templates and MASTER scenario copies.

When working IN this repository:
- Edit templates for distribution
- Test changes before syncing
- Document breaking changes
- Maintain MiroFish scenario templates (MASTER)

When working IN a target project:
- Use synced templates as starting point
- Local overrides allowed and expected (especially MIROFISH-SCENARIOS.md)
- Report useful improvements back to developer/
- Project-specific scenarios stay in the project (not synced back)

---

## Testing requirements

Before syncing any component:

| Component type | Required validation |
|----------------|---------------------|
| Config files | Syntax check + dry-run |
| Scripts | Shellcheck + manual test |
| Templates | Bootstrap test project |
| Compliance | Compare with production |
| Documentation | Link check + build |

---

## Version tracking

Each synced component should include:

```markdown
**Source:** `~/developer/{path}`  
**Synced:** YYYY-MM-DD  
**Version:** X.Y
```

---

## Rollback procedure

If a synced change breaks a project:

1. Identify the broken component
2. Restore previous version in target project
3. Report issue to `~/developer/`
4. Fix in developer repo
5. Re-sync when ready

---

## Quick start for new components

To add a new shared component:

1. Create in appropriate directory (`scripts/`, `templates/`, etc.)
2. Add documentation header with purpose and usage
3. Test in isolation
4. Commit to `~/developer/`
5. Manually sync to interested projects
6. Update this AGENTS.md if needed

---

## People and responsibilities

| Role | Person | Scope |
|------|--------|-------|
| Component author | Any developer | Create/maintain specific components |
| Sync coordinator | Moriel Carmi | Approve cross-project distribution |
| Integration tester | Aider CLI | Validate synced components work |

---

## Files reference

| File | Purpose | Sync targets |
|------|---------|--------------|
| `AGENTS.md` | This file — four-partner swarm instructions | All projects |
| `docs/COLLAB.md` | Collaboration contract v4.0 | All projects |
| `docs/subagent-patterns.md` | Named subagent patterns | All projects |
| `ruflo/config.yaml` | Ruflo orchestrator config | All projects |
| `scripts/aider-banxe.sh` | Aider CLI via LiteLLM | All projects |
| `scripts/parallel-verify.sh` | 3-model verification gate | All projects |
| `scripts/start_banxe_stack.sh` | Master startup script | All projects |
| `docs/PROJECT-REGISTRY.csv` | Project registry for sync-all.sh | Internal use |
| `scripts/sync-all.sh` | Multi-repo sync automation | Internal use |
| `scripts/onboard-project.sh` | New project onboarding | Internal use |
| `compliance/COMPLIANCE_ARCH.md` | Compliance invariants | vibe-coding |

---

## Definition of done (for component development)

A component is ready for sync when:

- [ ] Implementation complete and tested
- [ ] Documentation header added
- [ ] No project-specific assumptions
- [ ] Works in isolation
- [ ] Backward-compatible or migration documented
- [ ] Committed to `~/developer/`
- [ ] Synced to at least one target project

---

## Next steps (pending work)

- [x] Create sync-all.sh for automated distribution
- [x] Update AGENTS.md with four-partner swarm architecture (Sprint 9)
- [x] Create onboard-project.sh for new project onboarding
- [x] Create aider-banxe.sh, parallel-verify.sh, ruflo config (Sprint 9)
- [x] Create docs/subagent-patterns.md (Sprint 9)
- [ ] Create git post-commit hook for auto-sync
- [x] Deploy MiroFish to GMKtec (:5004 backend / :3001 frontend UI)
- [ ] Create project-specific MIROFISH-SCENARIOS.md for all 6 projects
- [ ] Update MEMORY.md with four-partner stack documentation
