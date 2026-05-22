# Universal Canon — EMI BANXE AI BANK
## Snapshot date: 2026-05-22
## Status: REFERENCE (читаемая сводка; binding-источники — INSTRUCTION-LEDGER.md, ADR, Software Factory Canon v1.0)
## Scope: все Perplexity central сессии, Claude Code TUI (Terminal B), Sub-B, shell на Legion / evo1 / evo2

---

## 0. Назначение документа

Readable, single-page entry point into the operating canon of the EMI
BANXE AI BANK project. REFERENCE only — binding rules live elsewhere.
The job is to seed a new Perplexity central session, a new Sub-B thread,
or a new operator shell session with the same facts without re-reading
the full INSTRUCTION-LEDGER.md. On disagreement, the binding source wins
(see section 18).

---

## 1. Иерархия источников истины

Strictly descending order of authority:

- Operator decision in the live session.
- main HEAD of CarmiBanxe/banxe-architecture (code, ADRs, runbooks, IL).
- INSTRUCTION-LEDGER.md (append-only) — binding operating decisions.
- ADR files — binding architectural decisions.
- Software Factory Canon v1.0 (docs/canon/software-factory-canon-v1.md)
  — Layer-1 factory governance.
- This document and other docs/canon/* — Layer-2 readable summaries.

---

## 2. 15 binding IL-правил (источник: INSTRUCTION-LEDGER.md)

Restated only by ID, line number, and one-sentence intent marker. Always
read the IL body for the rule itself.

- 7758 — IL-CANON-PERSISTENCE-SHELL-FIXATION-2026-05-12 — shell is the persistent surface; do not lose state across pivots.
- 7775 — IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12 — every binding artefact ships with Layer-1 source and Layer-2 readable companion.
- 7806 — IL-FACTORY-CLAUDE-CODE-PERMISSIONS-DOC-MANDATORY-2026-05-12 — .claude/settings.json is locked, documented, audited.
- 7833 — IL-CANON-TERMINALS-TOPOLOGY-AND-EXECUTION-RULE-2026-05-12 — one terminal binds to one project and one repo.
- 7851 — IL-CANON-FACTORY-ADDENDUM-SINGLE-OUTPUT-2026-05-12 — a factory step emits exactly one artefact per response.
- 7893 — IL-CANON-TERMINAL-B-AUTONOMOUS-FIXATION-2026-05-12 — Terminal B is the autonomous execution surface for Claude Code.
- 7921 — IL-CANON-EXPLICIT-TARGET-INSTRUCTION-2026-05-12 — every instruction declares its TARGET surface explicitly.
- 7983 — IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12 — documentation work is owned by Central, not by sub-threads.
- 8135 — IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12 — Claude Code primary; shell is the documented fallback.
- 8281 — IL-CANON-IL-DEDUPE-FIX-D3-2D-2-2026-05-12 — IL entries are deduplicated, not silently rewritten.
- 8296 — IL-CANON-SUB-B-PROMPT-VIA-FILE-2026-05-12 — Sub-B is driven by a prompt file, not by inline chat.
- 8314 — IL-CANON-ADR-030-ACCEPTED-FILE-STATUS-2026-05-12 — ADR status field is authoritative; file presence alone does not imply ACCEPTED.
- 8377 — IL-CANON-ALL-CLAUDE-CODE-PROMPTS-VIA-FILE-2026-05-12 — long Claude Code prompts are delivered via file.
- 8444 — IL-CANON-F01-REINFORCE-ALWAYS-ONE-ACTIONABLE-2026-05-12 — Clause F-01 reinforced: one actionable artefact per response.
- 8735 — IL-CANON-SOFTWARE-FACTORY-V1-INTEGRATION-ACKNOWLEDGE-2026-05-14 — Software Factory Canon v1.0 acknowledged as Layer-1 binding canon.

---

## 3. Operator-facing house rules для Perplexity central сессии

These eight rules are the binding operator-facing layer recorded in
IL-OPS-CANON-SESSION-LESSONS-AND-BYPASS-EXCEPTION-2026-05-22 Part B
(line 8809). They are the operating discipline Central must follow.

### 3.1 TARGET + cwd in every artefact

Every artefact declares its TARGET (CLAUDE CODE TUI / LEGION / EVO1 /
EVO2) and its working directory at the top of the block.

### 3.2 One artefact per response (Clause F-01)

Exactly one actionable artefact per response. No batched replies. No
"next-step menu" inside a single response.

### 3.3 Best-solution stance

Central proposes and executes the best-known next step. Central does
NOT wait for confirmation on micro-decisions inside a single approved
task. Macro-decisions still require explicit operator approval.

### 3.4 Answer-before-artefact

Central always answers the operator's question explicitly in prose
BEFORE producing the artefact. The artefact comes after the answer, not
instead of it.

### 3.5 Never paste TUI menu instructions into bash

Instructions for Claude Code TUI are executed by keyboard inside the
TUI, not pasted into shell. Pasting TUI text into bash silently breaks
workflow and pollutes shell history.

### 3.6 Docs-only bypass only under Part A

For docs-only PRs into main where guardian-factory / guardian-project
cannot report (S14.3 PREP), admin-bypass is allowed only under Part A
of IL-OPS-CANON-SESSION-LESSONS-AND-BYPASS-EXCEPTION-2026-05-22 and
must be paired with an IL entry recording merge SHA, reason, and
precedent chain.

### 3.7 Truncation-stop

Long Claude Code prompts are delivered via file or via a single complete
in-message block. On truncation, Claude Code STOPS and does not
improvise destructive operations (branch, commit, push). Proven correct
during the R3/S14.3 discovery doc step in this session.

### 3.8 Transparency of violations

When Central violates any rule above, Central explicitly acknowledges
the violation in the next response and records it in IL. Hidden
violations are themselves a higher-order violation.

---

## 4. Топология терминалов

- **Central** — the Perplexity session driving strategy, IL discipline,
  and operator interaction. Not a code executor.
- **Terminal A** — operator's primary shell on Legion. Used for git
  operations, gh CLI, ssh to evo1, and high-trust commands.
- **Terminal B** — Claude Code TUI running in ~/banxe-architecture on
  Legion. The autonomous execution surface for docs and code edits per
  IL-CANON-TERMINAL-B-AUTONOMOUS-FIXATION-2026-05-12.
- **Sub-B** — file-driven sub-threads launched by Central for bounded
  tasks (Guardian inspection, runbook drafts, etc.) per
  IL-CANON-SUB-B-PROMPT-VIA-FILE-2026-05-12.

Four TARGET identifiers in active use:

- `TARGET = CLAUDE CODE TUI` (Terminal B in ~/banxe-architecture).
- `TARGET = LEGION` (bash on Legion).
- `TARGET = EVO1` (bash on evo1, usually via ssh from Legion).
- `TARGET = EVO2` (bash on evo2, usually via ssh from Legion).

---

## 5. Шаблоны артефактов

### 5.1 Shell-команда (TARGET = LEGION / EVO1 / EVO2 bash)

```
[ TARGET: <LEGION | EVO1 | EVO2> bash ]
[ cwd: <absolute path> ]
<one-line description of the goal>
<command-or-pipeline>
```

Требования:

- TARGET и cwd на первых двух строках.
- Одна цель — одна команда (или один pipeline).
- Никаких sudo, deploy, network probes без отдельного IL разрешения.
- Команда копируется одним движением.
- State-changing command — следующим шагом IL pairing.

### 5.2 Claude Code-промпт (TARGET = CLAUDE CODE TUI)

```
[ TARGET: TERMINAL B — CLAUDE CODE (open in <cwd>) ]
GOAL: <single sentence>
STRICT RULES: <bounded scope; allowed files>
CONTENT REQUIREMENTS: <sections>
IMPLEMENTATION STEPS: <numbered steps; Do NOT push>
WHEN DONE, RESPOND WITH: <expected outputs>
```

Требования:

- TARGET строка обязательна.
- Промпт целостный или передан файлом.
- Явные STRICT RULES и WHEN DONE RESPOND WITH.
- HEAD, branch, scope зафиксированы явно.
- При обрыве промпта Claude Code обязан остановиться (rule 3.7).

### 5.3 IL-запись (append-only в INSTRUCTION-LEDGER.md)

```
### IL-<UPPER-KEBAB-ID>-<YYYY-MM-DD>

- Date: <YYYY-MM-DD> <HH:MM CEST>
- Phase (GSD): <short scope>
- Type: <category>
- Status: <BINDING | BINDING-TEMPORARY | PREP | DONE | REJECTED>
- Priority: <P0..P3>
- Owner: Central. Auditor: Spec-First Auditor v2.
- Executor: <Central via shell | Terminal B | Sub-B>.
- Bounded-context: <only-this-file-was-touched>.

<body — facts, decisions, evidence>

- Refs: <semicolon-separated IL IDs, PR numbers, ADRs, file paths>.
```

Требования:

- Append-only — существующие IL entries не редактируем.
- ID уникален и читаем; дата в ID = дата создания.
- Refs — одна строка, semicolon-separated, в одном явном порядке.
- Bypass entry — обязательны merge SHA + reason + precedent chain.
- Длина достаточна для durability, без воды.

### 5.4 PR в banxe-architecture

```
Title: <type>(<scope>): <short imperative> [<IL-ID-1>; <IL-ID-2>]
Body:
  Summary       — 1-3 bullets
  Files changed — paths
  Refs          — IL IDs; precedent chain if bypass
```

Требования:

- Title включает все IL-ID, к которым относится PR.
- Body короткий, ссылается на IL, не дублирует его.
- При admin-bypass — упомянуть Part A и причину inline.
- Docs-only PR — явно отметить "docs-only" в title или body.
- Никаких секретов в title или body.
- Слияние строго через --squash --delete-branch.

---

## 6. Branch protection и pipeline-реальность (на 2026-05-22)

main branch protection (verbatim):

- required_status_checks_contexts = [guardian-factory, guardian-project]
- strict = true
- enforce_admins = false
- required_reviews = null
- required_signatures = false

Consequence: until S14.3 (Guardian -> GitHub webhook) and R3 lands,
neither required context can post a status, so every PR is BLOCKED unless
admin-bypass is used. enforce_admins=false makes that bypass
policy-allowed.

Part A (temporary canon exception, source:
IL-OPS-CANON-SESSION-LESSONS-AND-BYPASS-EXCEPTION-2026-05-22 line 8809):

- Scope: PRs touching exclusively .md files under docs/ and/or
  INSTRUCTION-LEDGER.md (append-only).
- Mechanism allowed: `gh pr merge <N> --squash --delete-branch --admin`;
  `git commit --no-verify` on the source commit. Both MUST be documented
  inline.
- Required pairing: every bypass MUST be paired with an IL entry
  recording merge commit SHA on main, explicit reason (S14.3 webhook not
  deployed), and the precedent chain.
- Out of scope: code, factory canon files, ADRs, branch protection
  edits.
- Exit condition: auto-revoked on first appearance of guardian-factory
  AND guardian-project in statusCheckRollup on any main commit.

Precedent chain as currently extended (seven documented bypasses):

- PR #294 — --no-verify, Sprint 0 CH fix.
- PR #296 — --admin, R-tracks one-pager.
- PR #297 — --admin, IL pairing for #296.
- PR #298 — --admin, Canon Transfer Package.
- PR #299 — --admin, R3/S14.3 discovery runbook.
- PR #300 — --admin, session lessons + bypass exception.
- PR #301 — --admin, universal canon + exception extension (this PR).

---

## 7. Правила работы с секретами

- No keys, tokens, passwords, or private URLs in the repo, in IL, in PR
  body, or in commit messages.
- Local credentials live under `~/.claude/settings.json` with mode 600
  on Legion; backup files (`settings.json.api-backup-*`) must NOT be
  committed.
- OAuth Max subscription is preferred over a long-lived API key; an API
  key is acceptable only as a documented fallback per
  IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK.
- Rotation cadence follows S17 secrets-rotation policy (90 days). A
  rotation event is paired with an IL entry naming the rotated identity,
  not its value.
- Claude Code "bypass permissions" mode is forbidden on Legion.
- Any incident involving a leaked secret follows S15.5 historical-leak
  runbook (purge + rotate + IL incident entry).

---

## 8. Правила работы с архивами и легаси (R0-DISCOVERY)

R0-DISCOVERY (source:
IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22 line 8775; doc:
docs/project/UNVERIFIED-CLAIMS-LEGACY-DISCOVERY.md) governs how legacy
claims enter the binding roadmap.

- Seven claims are currently UNVERIFIED and gated on BANXE.RAR access:
  archive size, project count, Binance files, neuron-bitshares-ui,
  HollaEx / CCXT target, Paymentology endpoint completeness, <500ms
  payment SLA.
- Status flow per claim: UNVERIFIED → VERIFIED, REJECTED, or
  NEEDS_MORE_DATA.
- Every transition is paired with an IL entry naming the claim, the
  evidence path, and the new status.
- No legacy claim enters S12–S25 binding roadmap until VERIFIED.
- Trading-related claims (HollaEx, CCXT, neuron-bitshares-ui) require an
  ADR draft after VERIFIED before any code work begins.

---

## 9. Стандартный цикл работы (от задачи до durable артефакта)

1. Operator gives the task with TARGET + cwd + scope.
2. Central answers the operator's question in prose first.
3. Central produces exactly one artefact (Clause F-01).
4. Terminal B (Claude Code) creates or edits the file; `--no-verify` is
   used only when the bounded context is docs-only and justified.
5. Local commit on a feature branch named `feat/<short-kebab>-YYYY-MM-DD`.
6. Operator pushes, opens the PR, and (under Part A) admin-merges.
7. IL pairing entry merged into main on the same day, recording merge
   SHA, reason, and updated precedent chain.
8. Durability checklist (section 10) confirmed; Transfer Package
   refreshed if the change is concept-level.

---

## 10. Что считается "concept фиксацией" (durability checklist)

A concept is durably fixed when ALL four conditions hold:

- D1. Layer-1 source is in main HEAD (not only in IL or chat).
- D2. Layer-2 readable companion exists in docs/ per
  IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12.
- D3. IL pairing entry exists in INSTRUCTION-LEDGER.md naming the merge
  SHA and the reason for the change.
- D4. The concept is referenced by the current Transfer Package so a
  fresh Perplexity session inherits it.

The v2 concept (R0–R8 overlay, with R6 ALREADY_COVERED and R0 gated)
satisfies all four:

- D1: PR #295 (3 v2 docs) and PR #296 (operator one-pager).
- D2: docs/project/R-TRACKS-V2-ONE-PAGER.md.
- D3: PR #297 IL pairing IL-OPS-V2-ONE-PAGER-MERGED-MAIN-2026-05-22.
- D4: docs/project/CANON-TRANSFER-PACKAGE-2026-05-22.md references all
  three v2 docs and the one-pager.

---

## 11. Текущее состояние (snapshot на 2026-05-22, HEAD c224655)

- INSTRUCTION-LEDGER.md size: 8848 lines BEFORE this PR. After this PR
  it grows by the new IL entry; the new line count is recorded in the
  next Transfer Package refresh.
- Key IL anchors and their line numbers:
  - 8759 — IL-OPS-SPRINT-0-CH-PASSWORD-RESET-RUFLO-DDL-2026-05-22.
  - 8775 — IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22.
  - 8792 — IL-OPS-V2-ONE-PAGER-MERGED-MAIN-2026-05-22.
  - 8809 — IL-OPS-CANON-SESSION-LESSONS-AND-BYPASS-EXCEPTION-2026-05-22.
- v2 docs currently in main (six files):
  - docs/project/DELTA-ANALYSIS-LEGACY-REFACTOR-vs-CURRENT-ROADMAP.md
  - docs/project/SPRINT-EXTENSION-LEGACY-REFACTOR-S12-S17.md
  - docs/project/UNVERIFIED-CLAIMS-LEGACY-DISCOVERY.md
  - docs/project/R-TRACKS-V2-ONE-PAGER.md
  - docs/project/CANON-TRANSFER-PACKAGE-2026-05-22.md
  - docs/runbooks/R3-S14_3-GUARDIAN-GITHUB-WEBHOOK-DISCOVERY-2026-05-22.md
- Six PRs of this session (#295–#300):
  - PR #295 — v2 delta-analysis + sprint extension + unverified claims.
  - PR #296 — R-tracks one-pager.
  - PR #297 — IL pairing for #296.
  - PR #298 — Canon Transfer Package snapshot.
  - PR #299 — R3/S14.3 discovery runbook.
  - PR #300 — session lessons + bypass exception.
- Infra facts:
  - evo1: ClickHouse password reset, ruflo_checkpoints created (TTL 5y),
    Guardian factory :8195, Guardian project :8196, Keycloak active.
  - Legion: KC banxe-emi active, LiteLLM :4000 / :8080, Ollama :11434,
    evaluate.sh wired as pre-commit hook, Claude Code OAuth Max active.
  - Known broken: workflow-service crash-loop; midaz-ledger and
    midaz-mongodb Exited; Guardian → GitHub webhook NOT deployed
    (S14.3 PREP).

---

## 12. Открытые блокеры (operator/external territory)

- S12.4 realm provisioning — HOLD.
- S14.2 enforce — blocked on S14.3 webhook deployment.
- S14.4 / S14.5 — blocked on Architecture WG.
- S15.1 V8 user classification — blocked on MLRO / Legal.
- S20 external blockers — Modulr, SumSub, Sardine, Marble, Telegram,
  Jube, MLRO appointment, Board, Internal Audit.
- R0-DISCOVERY — 7 unverified legacy claims; gated on BANXE.RAR access.
- Pipeline blocker — Guardian → GitHub webhook (S14.3) not deployed;
  causes the merge-blocker that Part A bypass exists to work around.

---

## 13. Ранжированный next-step priority (best-solution)

1. R3 Observability foundation + S14.3 Guardian → GitHub webhook —
   directly removes the systemic merge-blocker on main; highest
   leverage.
2. R5 repo governance — clean up pre-existing pytest / ruff failures so
   evaluate.sh stops blocking docs-only commits.
3. S16.3 Redis pre-tx gate PREP — blocked on R1 Redis chain fix, but
   PREP work can advance.
4. R0-DISCOVERY — start once BANXE.RAR is available; seven claims need
   VERIFIED / REJECTED.
5. R1 Redis dependency chain — fixes midaz crash-loop at the root and
   unblocks S16.3.
6. R7 Legal boundary cleanup — GUIYON separation; non-blocking for
   production but must precede go-live.
7. Housekeeping — two stale worktrees (part8-adr035-deferred, v-xmrig);
   rotate any leftover Anthropic API key; verify
   `settings.json.api-backup-*` files are not committed.

---

## 14. Как использовать этот документ

- **Scenario A — new Perplexity central session seed.** Paste this file
  plus docs/project/CANON-TRANSFER-PACKAGE-2026-05-22.md as the first
  two seed messages. The session inherits the binding canon by
  reference, not by paraphrase.
- **Scenario B — Terminal B (Claude Code) task hand-off.** Cite
  sections 5.2 and 9 in the prompt; require the prompt to be a single
  in-message block or a file per rule 3.7.
- **Scenario C — Sub-B task hand-off.** Use file-driven prompts per
  IL-CANON-SUB-B-PROMPT-VIA-FILE-2026-05-12; ensure the prompt names
  TARGET, cwd, scope, and IL pairing requirements.
- **Scenario D — operator shell discipline.** Use sections 5.1 and 7
  before every command on Legion / evo1 / evo2; pair any state-changing
  command with an IL entry on the same day.

---

## 15. Что Канон явно запрещает

- Hidden violations: violating a canon rule without explicit
  acknowledgement in the next response.
- Batched artefacts: more than one actionable artefact per response.
- Waiting for micro-confirmation inside a single approved task.
- Ignoring a direct operator question while producing an artefact.
- Pasting Claude Code TUI menu text into bash.
- Admin-bypass on non-docs PRs without a new IL exception entry.
- `--no-verify` without inline justification linking to a pre-existing
  evaluate.sh BLOCK or to an active Part A exception.
- Secrets in repo, IL, PR body, or commit message.
- Claude Code `--dangerously-skip-permissions` (bypass-permissions) mode
  on Legion.
- Improvising destructive operations (branch, commit, push) when a
  Claude Code prompt is truncated.
- Claiming a task is complete without passing the durability checklist
  in section 10.

---

## 16. Что Канон явно обязует

- Every binding decision must be paired with an IL entry on the same
  day.
- Every commit either reaches main with durability (sections 9 + 10) or
  carries an inline justification for its non-durable state.
- Every admin-bypass must be paired with an IL entry in the same
  session.
- Every concept fixation must satisfy all four durability conditions in
  section 10.
- Every Perplexity session must end with a closing summary that names
  the IL entries created and the artefacts merged.
- Every artefact must carry TARGET, cwd, and exactly one actionable
  step.
- Every direct operator question must be answered in prose before any
  artefact is produced.
- Every canon violation by Central must be explicitly acknowledged in
  the next response.

---

## 17. Версионирование Канона

- Current version: 2026-05-22 (this file).
- Source IL anchors: 7758, 7775, 7806, 7833, 7851, 7893, 7921, 7983,
  8135, 8281, 8296, 8314, 8377, 8444, 8735 (the 15 canon IL rules) +
  8759, 8775, 8792, 8809 (operating IL anchors for the current
  session).
- Updates are made only via a PR that also appends a new IL entry; the
  PR title includes both new IL IDs.
- Older versions of this document are renamed to
  `UNIVERSAL-CANON-<YYYY-MM-DD>.md` and marked `Status: SUPERSEDED`
  inside their header block. They are NOT deleted.

---

## 18. Закрывающее правило

When this document conflicts with itself, with the current state of
main, with INSTRUCTION-LEDGER.md, with an ADR, or with the Software
Factory Canon v1.0, the order of precedence is:

1. Operator common sense in the live session.
2. main HEAD of CarmiBanxe/banxe-architecture (code, IL, ADR, Factory
   Canon v1.0 as committed).
3. This document.

=== END OF UNIVERSAL CANON (snapshot 2026-05-22, HEAD c224655) ===
