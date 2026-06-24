# FACTORY STATUS REPORT — permanent operator-invocable prompt

> **Status:** GOVERNANCE ARTIFACT (permanent, reusable). Lives in the repo so it persists across
> sessions. This file is **a prompt/spec**, not a report: when the operator invokes the trigger
> below, the factory (left terminal) executes the audit and produces the structured Russian-language
> report defined in §4. **No facts are invented** — every section is gathered by read-only
> shell/audit against the live repo, never from memory.

---

## 1. Operator invocation (trigger phrase)

The operator issues exactly one of the following; the factory then produces the full report:

> **«ОТЧЁТ ФАБРИКИ»**  (canonical RU trigger)
> alias: `FACTORY STATUS REPORT`

On receiving the trigger, the factory runs §3 (read-only gather) → emits §4 (the report) → then,
per Best-Single-Artifact canon, emits **exactly one** next-action artifact. Nothing is mutated to
produce the report (it is audit-only).

---

## 2. Output contract

- **Language:** Russian, **plain academic** style. **No flattery, no marketing, no emoji-praise.**
  State facts, gaps, and evidence. Hedge only where the repo is genuinely silent (`не утверждено в репозитории`).
- **Grounding:** every claim cites its source (`file:line`, command output, PR number, IL number).
  If a fact is not in the repo, say so — do **not** fill the gap from memory.
- **Shape:** one structured document with sections **A–G** (§4). Per-agent rows (section B) iterate
  **every** `agents/passports/*.yaml` — none skipped.
- **Verdict tone:** assessments are evidence-based and may be critical; "хорошо/слабо/отсутствует"
  must each be backed by a cited reason.

---

## 3. Factory left-terminal canon (consolidated)

> Folds the operator "ЕДИНЫЙ КАНОН" left-terminal rules into one place. It **references** the existing
> ADRs and does **not** restate them (ADR-102 anti-duplication). It adds only the new rules below.
> Precedence: FCA regs > Invariants I-01..I-28 > ADRs > this section.

**Referenced (NOT duplicated here — these remain the source of truth):**
- **Worktree isolation (IV)** → `ADR-120` (one session = one worktree off `origin/main`; shared
  checkout is audit-only).
- **Destructive-action protection (RULE 7)** → `ADR-121` + `.claude/rules/parallel-session-isolation.md`
  (never `rm -rf`/delete `.git`/remove foreign worktrees; cleanup only your OWN worktree).
- **Branch namespace** → `ADR-060` (`agent/<actor>/<id>/<slug>`).
- **Operational parallel-session Rules 1–7** → `.claude/rules/parallel-session-isolation.md`.
- **One-artifact-per-step / Best Single Artifact** → `AGENTS.md` & `.claude/rules/agents.md`
  (after any output, emit exactly ONE next-action artifact: `[CLAUDE CODE]` for state change,
  `[SHELL]` for read-only).

**Added rules (new — operator "ЕДИНЫЙ КАНОН"):**
- **§71 Single-writer.** At most ONE writer per repo/branch/working-tree at a time. The left-terminal
  factory **self-orchestrates central and right** so they never write the same tree concurrently —
  each takes its own ADR-120 worktree/branch; writes are serialized, not interleaved.
- **§72 Parallel-session halt.** If a concurrent session is detected writing the same target
  (foreign worktree dirty, branch hijack, stash/commit leak), **HALT and report** — do not
  auto-stash/restore/resolve (extends parallel-session Rule 6).
- **§73 Pre-flight read-only check.** Before ANY write: `git fetch`, assert branch
  (`git branch --show-current`), `git worktree list`, `git status --short`, `python3 ledger/build_ledger.py --check`.
  Mismatch ⇒ stop before staging.
- **§74 STOP-after-block.** After completing a delimited unit of work, **STOP** and surface the
  result; do not silently roll into the next unit. The squash-**merge** is always operator-reserved.
- **Language (§13 / V).** Operator-facing answers are **Russian, plain academic, no flattery**
  (this report obeys it).
- **One-step format (§7 / VI).** Each step yields exactly one artifact (see Best Single Artifact above).
- **Work only via the factory.** State changes happen only through the factory (code/docs/ledger/infra
  via `[CLAUDE CODE]`); shell is **audit-only / read-only** (`[SHELL]`).
- **Sub-terminal authority limits.** A sub-terminal/sub-agent may **read**, work in **its own**
  worktree, and make **local commits** — but **MUST NOT push, open PRs, or merge**. Push/PR are
  performed only by the orchestrating factory terminal; **merge is operator-reserved**.

These additions do not contradict ADR-060/120/121; conflicts resolve in favour of the ADRs.

---

## 4. The report (sections A–G) — RU output + read-only gather per section

The factory fills each section from the "Источник (read-only)" commands. Output in Russian.

### A. Фабрика в целом
Health, current tracks (central/right/left), canon-compliance, open PRs, ledger state.
```
# Источник (read-only):
git -C <repo> log --oneline -1 origin/main
git -C <repo> worktree list
git -C <repo> status --short
python3 ledger/build_ledger.py --check          # append-only health (expect exit 0)
tail -n 40 INSTRUCTION-LEDGER.md                  # latest IL state
bash scripts/install-hooks.sh                     # ADR-060/120/121 hooks self-check
git -C <repo> branch -a | grep -E 'agent/factory/(central|right)'   # active tracks
gh pr list --repo CarmiBanxe/banxe-architecture --state open --json number,title,headRefName,mergeable
```
Report: общее состояние, активные дорожки (central/right/left), соответствие канону (ADR-060/120/121,
guardian-* гейты), список открытых PR с mergeable-статусом, состояние реестра (последний IL, `--check`).

### B. По каждому агенту (итерировать ВСЕ `agents/passports/*.yaml`)
For each passport: `agent_id`; заявленные функции/возможности (`capabilities`, `description`); связанные
навыки (`allowed_skills`); оценка соответствия заявленным функциям; ГОРИЗОНТАЛЬНЫЕ + ВЕРТИКАЛЬНЫЕ связи.
```
# Источник (read-only) — поля каждого паспорта:
for f in agents/passports/*.yaml; do
  python3 - "$f" <<'PY'
import sys,yaml; d=yaml.safe_load(open(sys.argv[1]))
keys=['agent_id','level','trust_zone','autonomy','department','line_of_defence','smf_function',
      'capabilities','allowed_skills','prohibited_skills','allowed_callers','allowed_callees','ports','status']
print(sys.argv[1]); [print(' ',k,'=',d.get(k)) for k in keys]
PY
done
# Вертикаль (line of defence / департамент / уровень): governance/CANONICAL-ORG-CHART-v2.md (§3,§6,§8,§9),
#   AGENT-ORG-STRUCTURE.md, docs/ORG-STRUCTURE.md
# Горизонталь (кто вызывает / кого вызывает): allowed_callers / allowed_callees + ports.inbound/outbound
```
Report per agent: `agent_id` → функции → bound skills → оценка (выполняет ли заявленное; чем подтверждается)
→ горизонталь (callers/callees, порты) → вертикаль (line_of_defence, department, level 0–4, SMF).

### C. Анализ разрывов по навыкам (skills gap) + связь с TRAINING
Какие навыки работают хорошо, какие требуют усиления — и привязка к блоку обучения для непрерывного апскилла.
```
# Источник (read-only):
sed -n '1,230p' docs/SKILLS-MATRIX.md            # 10 навыков (Skill 1..10) + per-plane enforcement
grep -hE '^\s*- ' agents/passports/*.yaml | grep -A0 -E 'skill'  # фактические bind-ы allowed_skills
bash scripts/train.sh dry-run                     # валидация config+dataset+passport-mapping, без мутации (Makefile: make train-dry)
bash scripts/train.sh verify                      # пост-проверки обучения (Makefile: make train-verify)
```
Report: для каждого агента — навыки, которые закрыты vs не закрыты (vs 10 навыков матрицы); где bind
отсутствует или ADVISORY вместо MANDATORY; рекомендация по усилению через `scripts/train.sh`
(dry-run → run → verify) для непрерывного апскилла и роста эффективности.

### D. Классификация по рою (swarm type)
Назначить каждому агенту тип роя — **выводить из реальных доказательств репозитория, не выдумывать**.
```
# Источник (read-only): определения типов роя
sed -n '1,60p' AGENTS.md                          # Four-Partner Swarm: Claude Code + Ruflo + Aider + MiroFish
.claude/agents/openclo.md                          # OpenClaw MOA (10 агентов, GMKtec :18789)
sed -n '1,40p' .claude/rules/agents.md             # Ruflo (review/regulatory middleware), роли
.claude/rules/infrastructure.md                    # MetaClaw = LiteLLM-роутер (инфраструктура)
```
**Правило вывода (evidence-based):**

| Тип роя | Что это (репо-доказательство) | Признак для отнесения агента |
|---|---|---|
| **Ruflo** | Review/regulatory middleware (`.claude/rules/agents.md`; ADR-RUFLO-01) | агент проверяет payment/compliance/kyc, инварианты I-01..I-07, REVIEW-фаза |
| **OpenClaw (MOA)** | Mixture-of-Agents консенсус-шлюз, 10 агентов, `:18789` (`.claude/agents/openclo.md`) | runtime-консенсус/голосование/HITL-эскалация |
| **MiroFish** | Поведенческий/регуляторный симулятор сценариев, QA (`AGENTS.md`) | генерация/прогон сценариев, тест-данные, QA |
| **MetaClaw** | LiteLLM-роутер, инфраструктурный слой (`.claude/rules/infrastructure.md`) | маршрутизация инференса/инфра, без доменного reasoning |
| **other** | вне 4 типов | оркестрация/доменная логика, не попадает выше — указать причину |

Report: таблица «agent_id → тип роя → доказательство (file:line)». Если доказательства нет — `other` + причина.

### E. Утилизация оборудования
Полностью ли и эффективно ли используются вычислительные ресурсы (топология ниже)?
```
# Источник (read-only):
sed -n '1,120p' .claude/rules/infrastructure.md   # evo1/evo2 128GB, модели, порты
SERVICE-MAP.md                                     # live snapshot хостов/моделей/портов
docs/runbooks/fa-02-litellm-canonical-aliases.md   # LiteLLM-алиасы (factory-*/project-*)
# (на хосте, если доступно) ollama ps ; curl -s 127.0.0.1:4000/v1/models
```
**Топология (авторитетно, оператор; сверять с live-аудитом, не выдумывать):**
- **Legion — RAM 64 ГБ + coding-модель** (`qwen2.5-coder:14b-banxe-factory`, RTX 4070, LiteLLM `:4000`) —
  используется **ФАБРИКОЙ** для её задач (`AGENT-ORG-STRUCTURE.md`, `ADR-117`).
- **Два сервера @ 128 ГБ** (evo1, evo2) с AI-моделями — для проекта **EMI BANXE AI BANK**; один (**evo2**)
  держит тяжёлую модель (`qwen3:235b-a22b`, llama-server `:8082`) для серьёзных вычислений. Фабрика
  **МОЖЕТ заимствовать** этот компьют для более быстрого/качественного проектирования (`ADR-117`).

Report: загружены ли все три машины и каждый алиас (`factory-fast/mid/heavy/coder`, `project-reason`);
простаивающий компьют; конкретные методы повышения эффективности — например: маршрутизация лёгких задач
на Legion, тяжёлого reasoning на evo2 через `project-reason`, балансировка evo1↔evo2 (USB4 RPC),
заимствование evo2 фабрикой только на фазе проектирования; всё — в рамках канона (ADR-117, LiteLLM-алиасы).

### F. Эффективность моделей
На 100% ли эффективны установленные модели? Как повысить (только методы, поддержанные каноном репо).
```
# Источник (read-only):
.claude/rules/infrastructure.md                    # квантизации в проде (Q3_K_S, q4_K_M) — реальные
docs/runbooks/fa-02-litellm-canonical-aliases.md   # routing-слой
bash scripts/train.sh verify                        # eval/threshold пост-обучения (train-verify)
```
Report: фактические квантизации/модели (по доказательствам), и методы повышения эффективности,
**поддержанные каноном**: квантизация (уже Q3_K_S/q4_K_M), батчинг, маршрутизация через LiteLLM-алиасы,
карточки моделей + реестр (S-FAC-64, статус), eval/benchmark через `train-verify`. Явно отметить, что
не утверждено в репо (например, конкретный файл model-registry S-FAC-64, если отсутствует).

### G. Дополнительные обязанности фабрики
**(a) Контроль качества кода по РАСПИСАНИЮ** и **(b) генерация UI/UX в процессе и на основе кодирования.**
```
# Источник (read-only):
config/traffic-light.env ; deploy/cron/traffic-light.crontab   # cron 08:00/20:00 CEST (S-FAC-65)
.githooks/pre-commit                                            # per-commit semgrep/LucidShark + ADR-120/121 гейты
agents/passports/design_pipeline_agent.yaml                     # UI/UX генерация (реальный паспорт)
grep -n quality-gate docs/SKILLS-MATRIX.md .claude/rules/agents.md
```
**(a) Предлагаемое расписание контроля качества (best-solution, в рамках канона):**
- **Per-PR (событийно):** `.githooks/pre-commit` (semgrep/LucidShark) + `quality-gate.sh` + guardian-* гейты — блокирующие на каждый PR.
- **2×/сутки (cron 08:00 и 20:00 CEST):** прогон `scripts/traffic-light.sh` (S-FAC-65) — read-only verdict 🔴🟡🟢 по хостам/сервисам, шард в реестр + публикация в `fabric:audit:verdict`.
- **Еженедельно:** `make train-verify` (eval-порог) + сверка skills-bind ↔ SKILLS-MATRIX (skills-gap, секция C).
**(b) Генерация UI/UX:** через `design_pipeline_agent` (`agents/passports/design_pipeline_agent.yaml`) —
UI/UX порождается **в процессе и на основе кодирования**, с использованием всех механизмов фабрики
(паспорта/навыки/LiteLLM-маршруты), под теми же гейтами качества (per-PR + traffic-light).

---

## 5. Execution canon for THIS report (factory behaviour)

1. **Audit-first:** gather every section via the read-only commands above before writing a word.
2. **Best-solution & one artifact:** after the report, emit exactly one next-action artifact.
3. **Work only via the factory; shell audit-only.** Producing the report mutates nothing.
4. **Self-orchestrate central/right** (§71) so the audit never collides with an active write session;
   if a parallel writer is detected, HALT and report (§72).
5. **Russian, plain academic, no flattery** (§13/V). **STOP after the block** (§74); merge is operator-reserved.

## 6. Anchors

- `agents/passports/*.yaml` (per-agent source); `docs/SKILLS-MATRIX.md` (10 skills);
  `scripts/train.sh` + `Makefile` (`train`/`train-dry`/`train-verify`).
- `governance/CANONICAL-ORG-CHART-v2.md`, `AGENT-ORG-STRUCTURE.md`, `docs/ORG-STRUCTURE.md` (vertical/horizontal).
- `AGENTS.md`, `.claude/agents/openclo.md`, `.claude/rules/agents.md`, `.claude/rules/infrastructure.md` (swarm types + models).
- `SERVICE-MAP.md`, `docs/runbooks/fa-02-litellm-canonical-aliases.md` (hardware/models/routes); `ADR-117` (factory↔project compute).
- `scripts/traffic-light.sh`, `config/traffic-light.env`, `deploy/cron/traffic-light.crontab` (S-FAC-65 quality cadence); `.githooks/pre-commit` (per-PR gate); `agents/passports/design_pipeline_agent.yaml` (UI/UX).
- Canon: `ADR-060` (branch), `ADR-120` (worktree isolation), `ADR-121` + `.claude/rules/parallel-session-isolation.md` (RULE 7 / Rules 1–7), `AGENTS.md` (Best Single Artifact). Consolidated rules §71–§74 added in §3 (no ADR duplication).
