# ADR-159 — B→A novelty auto-handoff pipeline

**Date:** 2026-07-04
**Status:** ACCEPTED (accepted 2026-07-05, operator go-live approval)
**Deciders:** Central (approved design), Terminal-B (Spec-Projects), Terminal-A (Factory)
**Replaces:** N/A
**Superseded by:** N/A
**References:** ADR-119 (stable/frozen IL numbering), ADR-060 (branch actor namespace), ADR-102 (no smart refactor without duplication verification), ADR-103 (server-only refactoring policy), ADR-120 (per-session worktree isolation), ADR-121 (destructive-action protection), ADR-153 (terminal topology A/B/Central), ADR-156 (sandbox mode / operator-gated sign-off), `.claude/rules/parallel-session-isolation.md`, `governance/COMPUTE-ROUTING-TAXONOMY.md` §5, CLAUDE.md §71 (operator-gated merge).

---

## Context

The operator requested an automated loop: Terminal-B (Spec-Projects) records a **finding** ("новизна") in `governance/NOVELTY-COLLECTION-REGISTER.md`; Central + the Software Factory (Terminal-A) then process it end-to-end, up to a draft PR — with maximum utilisation of the compute fleet (Legion / evo1 / evo2) and of the model catalogue under **factory orchestration** (Best Single Artifact canon: state-changing work runs via `[CLAUDE CODE]` on the factory, never direct shell mutation).

The pipeline must:

1. Preserve **append-only** on `NOVELTY-COLLECTION-REGISTER.md` (I-24 / I-28) — a finding is written once, never mutated.
2. Preserve **ownership boundaries** (parallel-session-isolation Rules 1–7): no contour edits another contour's SSOT.
3. Preserve **ledger discipline** (ADR-119 / ADR-060 shard-based, Redis-mint, `add-il-shard.sh` + post-merge CI rebuild — no index/monolith on branches).
4. Preserve **HITL merge** (§71 / ADR-156 sandbox) — automation stops at draft-PR; a human approves the merge.
5. Preserve **Config-over-Hardcoding** (CLAUDE.md §10) — thresholds and corpus scope live in a Central-owned config file, not in ADR prose and not in code.

This ADR describes the **design** only. Executable artefacts (workflow YAML, systemd watcher unit, populated config values) are deliberately **NOT** shipped here; they land in follow-up specproj / factory tasks after this ADR is accepted.

---

## Decision

### D-1 — Channel (SSOT split, append-only both sides)

The B→A auto-handoff uses **two** append-only files, one owned by each contour, so no contour mutates the other's file:

| File | Owner | Append semantics | Purpose |
|------|-------|------------------|---------|
| `governance/NOVELTY-COLLECTION-REGISTER.md` | Terminal-B (Spec-Projects) | Append-only journal of **findings**. A finding is added once with `status=NEW` and is **not mutated in this register afterwards** (preserves append-only invariant). | System-of-record for what B has seen. |
| `governance/NOVELTY-HANDOFF-QUEUE.md` | Terminal-A (Factory) | Append-only **event log**. A appends `picked-up` and `processed` events for each finding; the **current state** is the latest event for a given `item` key. | System-of-record for what A has done with each finding. |

**Rule:** Neither contour writes to the other's file. Both files are amended only via specproj-style PRs following the shard + Redis-mint pattern (ADR-119 / ADR-060 / `scripts/add-il-shard.sh`).

**Rationale:** collapsing the register and the queue into a single file would either force B to re-open its own row (breaking append-only) or force A to write into B's SSOT (breaking ownership). Two append-only files with a clear owner each satisfies both invariants at once.

### D-2 — Trigger (CI-detect → factory-orchestrate)

The pipeline is split into **detection** (deterministic, GitHub-hosted) and **orchestration** (long-running, evo1-hosted):

1. **Detection — GitHub Actions.** A workflow `.github/workflows/novelty-handoff.yml` fires `on: push` to `main` when files under `governance/NOVELTY-COLLECTION-REGISTER.md` change. It diffs the register against the previous `main` state, extracts newly-appended `status=NEW` rows, and appends a `picked-up` event per new row to `governance/NOVELTY-HANDOFF-QUEUE.md` (via the same shard + PR discipline, factory-actor).
2. **Orchestration — factory-watcher on evo1.** A systemd timer on evo1 (ADR-103 server-only build venue) polls `NOVELTY-HANDOFF-QUEUE.md` for `picked-up`-without-`processed` entries and dispatches `claude -p ...` runs against the factory. The **bridge** from CI to the factory is the QUEUE file itself — GitHub Actions does **not** invoke `claude -p` directly (out-of-scope for a CI runner; keeps long inference off GitHub minutes).

**Rationale:** CI does what CI does well (deterministic diff, PR-shard), evo1 does what evo1 does well (multi-hour orchestration with local model access). The QUEUE file is the well-typed hand-off contract between the two.

### D-3 — Novelty check (two-stage: local pre-file + factory verification)

Novelty is checked **twice**, at different layers:

1. **B-side pre-file check (ADR-102 duplication audit).** Before B opens a PR appending a row to `NOVELTY-COLLECTION-REGISTER.md`, B runs an ADR-102-style repo-wide duplication audit against the existing register **and** against `docs/adr/` to establish `dedup=unique | duplicate-of:<X>`. This is the same discipline already documented in the register schema.
2. **Factory-side semantic verification (on pick-up).** When the factory-watcher picks up a `NEW` row, it runs a **semantic novelty score** against a knowledge corpus (D-4 defines corpus and threshold). If the score falls below the configured novelty threshold, the factory appends a `processed` event with `verdict=duplicate` (no draft-PR is opened). If the score is above threshold, the factory continues to the standard implement / STG / gate flow (per `.claude/rules/agents.md` Scenario A) and opens a **draft** PR for HITL review.

**Rationale:** the B-side check catches obvious duplicates cheaply and preserves the operator's mental model of the register; the factory-side check catches subtle semantic overlaps that a text-diff cannot see and prevents automation from spending compute on rediscovered ideas.

### D-4 — Corpus, threshold, and models (Config-over-Hardcoding)

**Novelty threshold and corpus scope are NOT hardcoded in this ADR.** They live in a Central-owned config file:

```
governance/novelty-pipeline-config.yaml
```

An example template (status `PROPOSED`) ships with this ADR for review; the file becomes authoritative once Central accepts the values. Proposed defaults for Central's consideration (not binding until config accept):

- **Corpus scope:** knowledge artefacts under `governance/`, `docs/adr/`, and `docs/agent-engine-dossier/` — deliberately **NOT** the whole `main` (whole-repo embedding would flood the score with implementation noise; the corpus is meant to represent decisions and knowledge, not code).
- **Similarity metric:** cosine similarity over sentence-transformer embeddings.
- **Novelty threshold:** `cosine < 0.85` against the nearest corpus item → **novel**; otherwise **duplicate**. Suggested as a starting point pending calibration.

**Host / model layout (orchestrated by the factory; taxonomy anchored in `governance/COMPUTE-ROUTING-TAXONOMY.md` §5):**

| Stage | Host / model | Rationale |
|-------|--------------|-----------|
| Candidate extraction (parse register row, identify likely target area) | evo1 fast lane — `glm-air` (:8081) or `qwen3-coder` | short-context, high-throughput; cheap first pass. |
| Semantic verification + novelty score (embed corpus, embed candidate, score) | evo2 async reasoning lane — `reasoning-235b` (:8082) | deep-thought lane; async is acceptable because the QUEUE decouples turnaround. |
| PR assembly (shard + config edit + narrative) | Claude Code on **evo1** (ADR-103 server-only build venue; `REDIS_HOST=127.0.0.1` for the shared IL allocator) | governance PRs must be produced on the ADR-103 build venue with fail-closed Redis. |

Each factory dispatch runs in an **ADR-120 per-session worktree**; A/B concurrent runs are isolated per `.claude/rules/parallel-session-isolation.md` (Rules 1–7).

### D-5 — Boundaries (safety / merge-gate)

1. Automation covers the pipeline **up to draft-PR + hand-off notification**. **Merge is HITL** per CLAUDE.md §71 and ADR-156 sandbox mode. No auto-merge is introduced by this ADR.
2. No live keys / no mainnet touch. All roles remain in the ADR-156 sandbox posture.
3. The pipeline never mutates client funds and never touches production state (§11 stop-barrier).
4. Any single stage that fails **stops the pipeline for that item** and appends a `processed` event with `verdict=failed:<reason>` for operator triage — the pipeline never retries silently past a stop-barrier (best-decision canon, `approval-rules.md`).

---

## Ownership (CODEOWNERS — enforces that no contour edits another's SSOT)

To make D-1's ownership boundary machine-enforced, this ADR proposes the following `.github/CODEOWNERS` additions (applied in a follow-up PR alongside the workflow):

| Path | Owner | Rationale |
|------|-------|-----------|
| `/.github/workflows/novelty-*.yml` | `@<factory-owner>` (open item OI-3) | Terminal-A owns the CI trigger; B cannot bypass detection. |
| `/governance/NOVELTY-HANDOFF-QUEUE.md` | `@<factory-owner>` (open item OI-3) | Terminal-A owns the event log; B cannot back-write A's state. |
| `/governance/novelty-pipeline-config.yaml` | Central (existing `.claude/` code-owner canon, ADR-134) | Central owns the threshold / corpus; neither B nor A rewrites the config unilaterally. |
| `/governance/NOVELTY-COLLECTION-REGISTER.md` | Terminal-B (existing) | Terminal-A cannot mutate B's findings register. |

---

## Consequences

**Positive**

- B→A hand-off becomes deterministic (CI diff, not an operator ping) and audit-trailed (append-only on both sides).
- Compute fleet is maximally utilised because orchestration selects the right host/model per stage instead of running everything on one lane.
- The factory keeps the Best Single Artifact discipline (state-changing work → `[CLAUDE CODE]` via factory; read-only checks → `[SHELL]`).

**Negative / accepted trade-offs**

- Two append-only files instead of one — slightly higher navigational cost, offset by clean ownership boundaries.
- The factory-watcher is an additional systemd unit on evo1 to monitor; single-listener guard discipline (per specproj sp03) applies to future occupants of any port this watcher exposes.
- The B-side pre-file duplication audit adds latency to opening a finding PR, but reuses the ADR-102 flow B already runs.

**Risks (mitigations noted)**

- Threshold too tight → false positives (real novelty rejected). *Mitigation:* threshold is config, not code; calibration open item (OI-1).
- Threshold too loose → factory burns compute on rediscoveries. *Mitigation:* same as above; monitor `verdict=duplicate` rate for the first N runs.
- Queue-poll race between two factory-watchers → double-dispatch of the same finding. *Mitigation:* watcher acquires an advisory lock (documented in follow-up implementation task) before appending `picked-up`; the shard+Redis-mint discipline prevents ledger-side duplicate anyway.

---

## Open items (for Central acceptance)

- **OI-1.** Exact novelty threshold value (proposed default: `cosine < 0.85` — pending calibration on the current corpus).
- **OI-2.** Final list of corpus paths (proposed: `governance/`, `docs/adr/`, `docs/agent-engine-dossier/` — pending review).
- **OI-3.** Assign `@<factory-owner>` for the CODEOWNERS entries on `/.github/workflows/novelty-*.yml` and `/governance/NOVELTY-HANDOFF-QUEUE.md`.

---

## Implementation (out of scope for this ADR)

The following are **NOT** delivered by this PR and are queued as follow-up work after Central accepts this ADR:

1. `.github/workflows/novelty-handoff.yml` — the actual detection workflow (implementation task).
2. `factory-watcher.service` + `.timer` on evo1 — the actual systemd units (implementation task).
3. Populated (accepted) values in `governance/novelty-pipeline-config.yaml`.
4. `governance/NOVELTY-HANDOFF-QUEUE.md` initial file — created by the first `picked-up` event, per D-1.
5. `.github/CODEOWNERS` update per the Ownership table above.

Until (1)–(5) are merged (each with its own HITL sign-off), no B→A auto-handoff is active. This ADR ships **design only**.

---

## Anchors

ADR-119 (stable IL numbering; ledger discipline), ADR-060 (branch actor namespace `agent/specproj/<id>/<slug>`), ADR-102 (no smart refactor without duplication verification), ADR-103 (server-only refactoring policy / evo1 build venue), ADR-120 (per-session worktree isolation), ADR-121 (destructive-action protection), ADR-153 (terminal topology reconciliation — A/B/Central roles), ADR-156 (sandbox mode / operator-gated sign-off), `.claude/rules/parallel-session-isolation.md` (Rules 1–7), `governance/COMPUTE-ROUTING-TAXONOMY.md` §5, CLAUDE.md §71 (operator-gated merge canon).

---

## Terminal-B Operating Algorithm (normative)

> Central-approved. Codifies the behavioural algorithm Terminal-B (Spec-Projects) MUST follow on any incoming text/file so that findings feed the B→A auto-handoff pipeline (§D-1..D-5) deterministically. Additive to — never overrides — safety-rules / approval-rules / ADR-102 / ADR-103 / ADR-119 / ADR-120 / ADR-121 / ADR-153 / ADR-156 / parallel-session-isolation / CLAUDE.md §1, §11, §12, §71.

Пошаговый алгоритм B при поступлении входящего текста/файла (Central-approved):

0. **AUTOSTART** — на входящий текст/файл B стартует автономно (best-decision внутри своей зоны; встречный вопрос только на stop-барьере `safety-rules.md`).
1. **MULTI-PASS READ** — досконально вычитать вход несколькими проходами; извлечь кандидаты-новинки. Крупный вход — тяжёлую вычитку оркеструет фабрика по lane-раскладке (§D-4).
2. **AUDIT BY FACT** — каждый кандидат сверить с фактом; не галлюцинировать (только верифицированное).
3. **DUP-CHECK (B-local, ADR-102)** — против корпуса (см. подсекцию ниже); дубли помечать `dedup=duplicate-of:<X>` и не PR-ить; реально новые → в PR.
4. **SINGLE ARTIFACT (Best-Single-Artifact)** — ровно один next-action артефакт: `[CLAUDE CODE]` для находки-PR, `[SHELL]` для read-only; без «вариант 1/2».
5. **PR НАХОДКИ** — specproj-PR: ветка `agent/specproj/<id>/<slug>` (ADR-060); append в `NOVELTY-COLLECTION-REGISTER.md` со `status=NEW`; shard+индекс вместе (ADR-119); `REDIS_HOST=127.0.0.1`; на evo1 (ADR-103); serialize rebase-before-merge (`parallel-session-isolation.md` Rule 8).
6. **INDEPENDENT-VERIFY** — по ЖИВОМУ CI, не по self-report: `guardian-ledger-shards` + `ledger-build` + `Secrets Scan` зелёные, append-only (0 удалений), 0 секретов, файлы верны. Запрещён CI-poll-loop.
7. **HITL-MERGE** — merge = оператор / §71; B никогда не авто-мержит. Hand-off = находка `status=NEW`, далее A подхватывает через `NOVELTY-HANDOFF-QUEUE.md`.

### Формат находки (следовать существующей схеме реестра)

Строка таблицы `Entries` реестра: `item | source-repo | floor | type | value | dedup | verdict | handoff | status`. B заполняет:

- `item` — уникальный kebab-slug;
- `source-repo` — репозиторий-источник входа;
- `floor` — 1..4;
- `type` — feature / subproject / analytics / compliance / infra;
- `value` — high / med / low;
- `dedup` — `unique` или `duplicate-of:<X>`;
- `verdict` — adopt / evaluate / reject (рекомендация B);
- `handoff` — GAP-NN / OD-NN / NONE;
- `status` — **NEW**.

Rationale — в строке как обоснование-новизны. **ЗАПРЕЩЕНО** мутировать / переупорядочивать / удалять чужие строки (только append); менять `status` в реестре (жизненный цикл `NEW → PICKED → PROCESSED` ведёт A в QUEUE, не B).

### Novelty на стороне B (local dup-check)

Ступень B (дешёвая, textual+conceptual): для каждого кандидата искать в корпусе существующую находку / ADR того же концепта. **Корпус B-dup-check = `governance/` + `docs/adr/`.** Ступень A (глубокая semantic-scoring, порог из `governance/novelty-pipeline-config.yaml`) — не зона B.

### Границы B vs A

**B НЕ трогает:**
- триггер `.github/workflows/novelty-handoff.yml` / factory-watcher / `NOVELTY-HANDOFF-QUEUE.md` (A-owned, CODEOWNERS);
- индекс-файлы (машинные);
- живой systemd / gateway;
- EMI-core (Central + фабрика);
- чужие ветки / сессии (parallel-session-isolation Rule 6).

**B делает:** вычитка входа → находки → dup-check → append-находки → specproj-PR (shard+индекс) → independent-verify → hand-off `status=NEW`.

### Two valid terminal outcomes

Алгоритм B имеет ДВА валидных терминальных исхода (оба положительные):

- **Outcome-1 — Finding(s).** Найдены реально новые элементы → append в `NOVELTY-COLLECTION-REGISTER.md` со `status=NEW` → hand-off A через `NOVELTY-HANDOFF-QUEUE.md`.
- **Outcome-2 — Coverage-confirmation.** Multi-pass вычитка подтвердила полное покрытие (delta=0, ничего не пропущено) → append в `governance/NOVELTY-COVERAGE-LOG.md`. Это ПОЛОЖИТЕЛЬНЫЙ auditable-результат (proof-of-completeness), НЕ пустой прогон. B-терминальный: hand-off A НЕ происходит (обрабатывать нечего, QUEUE не трогается). Применяется в т.ч. к уже-использованным источникам — оператор прогоняет их, чтобы удостовериться в полной вычитке.

Coverage-log (B-owned, append-only) схема: `source | passes | coverage(full|partial) | gaps-found | dup-refs | corpus-sha | timestamp`. `corpus-sha` анкерит coverage к состоянию корпуса (main HEAD) для воспроизводимости. `partial` → `gaps-found` перечисляет item-ы находок, ушедших в реестр как `status=NEW`.

### Mandatory hand-off chain (A-side, canon)

Каждая находка Outcome-1 (`status=NEW`) ОБЯЗАНА пройти следующую цепочку без пропусков:

```
NEW (в NOVELTY-COLLECTION-REGISTER.md, B-owned)
  -> QUEUE picked                     (factory-watcher поднял находку из реестра)
  -> [semantic-scoring >= порог]      (порог из governance/novelty-pipeline-config.yaml)
  -> ROADMAP-MATRIX update            (append hand-off маркера в docs/ROADMAP-MATRIX.md)
  -> sprint-task заведена             (внешняя система планирования — sprint-ref)
  -> QUEUE ack: planned -> sprint#    (roadmap-ref + sprint-ref фиксируются в QUEUE)
  -> QUEUE processed                  (терминальное событие A-side для находки)
```

Неисполнение любого звена (пропуск `planned`, отсутствие `roadmap-ref`, отсутствие `sprint-ref` при переходе в `sprint`, отсутствие терминального `processed`) → **эскалация оператору**; watcher останавливает обработку данного `finding-item` и не переходит к следующему звену цепочки (fail-stop, ADR-159 §D-5 pt.4).

**Владельцы (CODEOWNERS-enforced, `@mmber`):**

| Артефакт | Владелец | Правило |
|----------|----------|---------|
| `governance/NOVELTY-HANDOFF-QUEUE.md` | Terminal-A (Factory) | append-only, single-writer = `scripts/novelty-watcher.sh` |
| `.github/workflows/novelty-handoff.yml` | Terminal-A (Factory) | validator + detector, никогда не коммитит |
| `scripts/novelty-watcher.sh` | Terminal-A (Factory) | v1 stub scoring; реальный LiteLLM :4000 hook = TODO |
| `governance/NOVELTY-COLLECTION-REGISTER.md` | Terminal-B (Spec-Projects) | A НЕ мутирует |
| `governance/NOVELTY-COVERAGE-LOG.md` | Terminal-B (Spec-Projects) | A НЕ мутирует |
| `governance/novelty-pipeline-config.yaml` | Central | ни A, ни B unilaterally не переписывают |

**HITL-гейты (оператор, не автономно):**

1. **Accept ADR** — этот ADR остаётся `PROPOSED` до явного accept оператором; scaffolding в репо не активирует pipeline.
2. **Запуск watcher-демона** — systemd unit/timer поставляются как in-repo шаблоны; `systemctl --user enable/start novelty-watcher.timer` на evo1 = оператор.
3. **Merge** — любой draft-PR, открытый по итогу `processed`, мержит оператор (CLAUDE.md §71 / ADR-156 sandbox).

Cross-refs: §D-1 (SSOT split), §D-3 (two-stage novelty check), §D-5 (safety / merge-gate), CLAUDE.md §11 §71, `.claude/rules/parallel-session-isolation.md` Rules 1–7.
