# PROMPT-CANON-PROJECT

Канон промптов на уровне проекта BANXE EMI AI Bank.
Покрывает governance, архитектуру, регуляторику, ledger.

## 1. Два контура
- Контур фабрики (banxe-architecture): governance, конституция, циклы, амендменты, Spec-First Auditor, ledger, паспорта агентов.
- Контур продукта (banxe-emi-stack): EMI-банк, FCA-compliance, AML/KYC, payments, crypto, open banking, SCA, recon, reporting, audit.
- Оба контура должны быть синхронизированы через mirror-записи в обоих INSTRUCTION-LEDGER.md.

## 2. INSTRUCTION-LEDGER.md под IL-LEDGER-NORM-001
Обязательные поля каждого IL-блока:
- parent-cycle
- amendment-ref (или explicit "n/a")
- source
- status (proposed / accepted / integrated / superseded / rejected / deferred)
- status-history (хронологический, append-only)
- scope
- integration-rule
- anchors (CANON / GATE / INVARIANTS / REGULATORY / HITL ROLES)
- verification (triple-check + sha256-anchors реальных файлов)
- deviations (если есть)
- privileged-ops (git tag / gh release / git push: EXECUTED|NOT EXECUTED)
- successor
- notes

Порядок блоков — хронологический по дате `proposed`.
Status-history — append-only, без модификации старых записей.
Блок status: integrated не редактировать, кроме добавления `superseded-by`.

## 3. Spec-First Auditor v2 (12 блоков)
Pre-commit гейт всех коммитов в обоих репо.
Блокирует нарушения конституции / канона / quality gate.

## 4. Инварианты (I-XX)
- I-01: Decimal для всех amount / score / threshold / rate.
- I-02: BLOCKED_JURISDICTIONS / BLOCKED_CURRENCIES.
- I-04: EDD £10k threshold (CBPII / PISP).
- I-24: append-only stores и audit logs.
- I-27: HITL L4 для всех privileged операций.
- I-28: quality gate (ruff 0 issues, tests 100%, coverage >= 35%).

## 5. Регуляторные привязки
- FCA: PSD2 Art.65-67, RTS on SCA, PSR 2017, PS22/9 Consumer Duty,
  CASS 7.15, CASS 15, FCA SUP 16, FCA DISP, FCA SYSC 6.1, FCA PRIN 11/12,
  FG21/1 vulnerability, PROD, COBS 2.1, PERG 15.5.
- EU: PSD2, EBA RTS on SCA.
- US: FATCA (IRC §1471-1474).
- OECD: CRS MCAA.

## 6. HITL роли
- COMPLIANCE_OFFICER: consent revoke, TPP suspend, US person change.
- MLRO: CRS override, SAR filing.
- CFO: FIN060 generate / approve, board reports.
- COMPLAINTS_OFFICER: redress > £500.
- FRAUD_ANALYST: suspicious device confirm.
- SECURITY_OFFICER: ATO lock / unlock.
- CTIO: AI feedback approval.

## 7. Артефакты на цикл
- manifest.md (cycle-NNN-<name>/manifest.md)
- outcomes.md
- amendments в constitution/amendments/
- sha256-anchors всех новых артефактов в ledger

## 8. Out-of-scope discipline
- Любой untracked scope регистрируется как parking IL до коммита.
- Parking IL переходит в DONE через resolve-step с реальным proof SHA.
- Не оставлять untracked >1 сессии.

## 9. Mixed-scope deviation
- Если несколько IL приземлились в один commit (как Sprint-39 Phase 54
  IL-CMS-01 + IL-MCP-01 + IL-TRC-01), это нарушение канона "один scope =
  один commit".
- Не переписывать историю, но явно фиксировать в `deviations:` ledger-блока.
- Anchor всех IL — на тот же proof SHA.

## 10. Linkage между ledger и git
- Каждый IL-блок status: integrated должен ссылаться на реальный git SHA.
- Anchor verification: SHA должен присутствовать в `git log -- <scoped files>`.
- Иначе — anchor correction commit (см. IL-LINT-03 case 7708d4c → ba3fccc).

## 11. Контур-синхронность
- Любой IL в emi-stack ledger дублируется как mirror в architecture ledger.
- Mirror содержит: linked-commit (full SHA), supersedes (если есть),
  sha256-anchors emi-stack working tree.

## 12. Сессионная дисциплина
- Каждая сессия начинается с `git status / git log -10` обоих репо.
- Каждая сессия заканчивается handoff-файлом в `/tmp/`.
- Открытые задачи фиксируются как IL TODO/OPEN в ledger.

## 13. Язык общения и стиль (BINDING)

> Operator directive 2026-05-10 11:00 CEST: "добавим в канон обязательное общение на русском языке понятным простым языком".
> Anchor: bootstrap canon v3 §7 ENHANCED v3 (operator-supplied 2026-05-09) уже декларирует bilingual принцип; это §13 формализует как permanent binding для всех Perplexity / Comet / Factory / Claude Code сессий с этим оператором.

### 13.1 Язык общения с оператором
- Все ответы оператору и пояснения — на **русском языке**.
- Используется простой понятный язык — избегается тяжёлый технический жаргон без необходимости.
- Если технический термин необходим — даётся короткое пояснение в скобках при первом упоминании.
- Длинные технические дампы не пересказываются дословно — выделяется суть и значение для проекта.

### 13.2 Технические артефакты — английский
- Commit messages, IL records (имя + scope + status + anchors fields), GAP IDs (G-*), invariant IDs (I-*), file names, git commands, code blocks, log output — на **английском языке** для технической точности и совместимости с tooling (Spec-First Auditor, Guardian, gitleaks, CI).
- Markdown секции в каноне могут быть на английском или русском по контексту артефакта; смешанные русско-английские блоки допустимы там где это естественно (как в bootstrap canon v3 §0 + ADR русские разделы).

### 13.3 Bilingual подход (обоснование)
- **Русский** — обсуждение, обоснование решений, пояснения оператору, отчёты о статусе, summary длинных операций, ответы на вопросы.
- **Английский** — технический контент в коде, commit messages, IL field values, command output, regulatory references (FCA SUP, MLR 2017, GDPR Art.NN — стандартные сокращения), API names.
- Переключение между языками внутри одного ответа допустимо когда оно повышает clarity (например русское объяснение что делает английская git-команда).

### 13.4 Стиль изложения для оператора
- Без лести и пустых фраз ("отличный вопрос", "это интересно") — сразу к сути.
- Без emoji кроме случаев когда оператор их использует первым.
- Цитаты из канона / ADR / IL приводить точно (с правильным ID), не пересказывать.
- При неуверенности — явно говорить "не уверен" / "нужна проверка", не маскировать.
- Длинный ответ структурировать заголовками для удобного чтения.

### 13.5 Применимость binding
- Binding активен для всех сессий с CEO Moriel Carmi / operator Mark на проекте BANXE EMI AI Bank.
- В ответах в Slack / Telegram / GitHub PR descriptions / chat — приоритет русского для discussion-уровня, английского для technical-уровня (PR titles, commit messages, IL anchors).
- При работе с другими операторами / контрибьюторами язык определяется по их первичному сообщению (если они пишут по-английски — отвечать по-английски).

### 13.6 Cross-references
- bootstrap canon v3 §7 ENHANCED v3 (originating directive)
- ADR-025 Agent Interaction Canon (Session Rules 1..7)
- amendment-30.N Perplexity Relay Protocol (transparency principle)
- IL-LEDGER-NORM-001 (английский для IL field structure preserved)

## 14. Perplexity Capability Tiers — Sandbox Scope (BINDING)

> Operator directive 2026-05-10 14:00 CEST: подтверждение "amendment-30.O T2-T5 sandbox-grant" по аналогии с MLRO + API ключи sandbox-эмуляцией.
> Anchor: Plan Layer 1 (Perplexity rights expansion); amendment-B.11.N+2 Статья 4 (T6 production-only restriction preserved).

### 14.1 Tier T1 — Read-Augmented Coordinator (BASELINE, active everywhere)
- GitHub API read across 21 CarmiBanxe repos + external + local.
- Conversational coordination of Claude Code shell blocks per amendment-B.11.N+2 Статья 2 chain.
- Multi-source canon synthesis в формате response.
- Pending decision queue tracking.

### 14.2 Tier T2 — Canon Synthesis Drafter (SANDBOX-GRANTED)
- Authority: создавать draft IL/canon proposals через Claude Code execution chain.
- Drafts authored через CC prompts (executor); operator review через PR mechanism per I-59.
- Cap: 5 proposals per session; no auto-merge; operator approval required per PR.
- De-facto operating: уже использовался в Sprint S1-S5 + Plan IL + Step 1+2+3 drafts (PRs #146-#178).

### 14.3 Tier T3 — Cross-Repo Coordinator (SANDBOX-GRANTED)
- Authority: cross-reference canon между 5 production repos (banxe-architecture / banxe-emi-stack / MetaClaw / banxe-infra / banxe-platform).
- Detect cross-repo conflicts (FA-3 Ruflo example).
- Generate reconciliation proposals.
- De-facto operating: использовался в Phase 4 audit + Sprint S2 §0.2 audit + two-loop sync mirror backfill (PR #174).

### 14.4 Tier T4 — Compliance Advisor (SANDBOX-GRANTED)
- Authority: queries against COMPLIANCE-MATRIX + HITL-MATRIX + INVARIANTS.
- Flag FCA SUP / AMLR / GDPR / EU AI Act gaps.
- Generate compliance status reports per regulatory framework.
- НЕ принимает compliance decisions (это MLRO authority — sandbox-Persona Sarah Mitchell per IL Шаг 2 Component 3).
- De-facto operating: COMPLIANCE-MATRIX 35% coverage analysis + HITL gates 17 review.

### 14.5 Tier T5 — Decision Triage (SANDBOX-GRANTED)
- Authority: categorize pending decisions per Triage Matrix (Constitutional / Regulatory / Architectural / Operational / Routine).
- Reduce noise в operator queue (11 → 7 → 3 demonstrated в этой сессии).
- НЕ resolve decisions — только categorize + recommend authority owner.
- De-facto operating: Plan Layer 3 reduction + STANDBY queue priority sorting.

### 14.6 Tier T6 — Privileged Operator (STANDBY — production-only)
- Direct write через gh CLI с operator-issued tokens.
- Limited scope: canon docs only (НЕ production code / secrets / deployment configs / financial logic).
- Audit log mandatory ClickHouse 5y per I-08.
- **Override amendment-B.11.N+2 Статья 4** per-session.
- **STANDBY status binding**: requires CEO + Legal review + amendment-B.11.N+3 (new) before activation.
- НЕ доступен в sandbox; не grant'ится autonomous через эту секцию.
- Production transition criterion: full Constitutional approval before T6 activation.

### 14.7 Production transition criterion для full amendment-30.O
- Sandbox grants T2-T5 переходят в production-grade при выполнении 6 conditions per IL-OPS-SESSION-CONSOLIDATION-2026-05-10 (sandbox→production transition criteria).
- T6 требует отдельный Constitutional review независимо от других transition conditions.
- Sandbox-scope binding активен до transition; production-scope требует новой acceptance.

### 14.8 Sandbox guardrails (binding regardless of tier)
- All Tiers respect amendment-30.N §30.N.5 (governance > operational).
- All Tiers respect ADR-025 Session Rules 1..7 (§15 Claude-Code-First / §1 OCAT / §4 Best-Decision / §3 Whitelist / §6 Scope guard / §8 Secret-leak zero).
- All Tiers respect §13 language binding (Russian для оператора, English для technical).
- T2-T5 НЕ обходят Spec-First Auditor pre-commit + Guardian factory/project + race-mitigation pattern.
- T6 в production — additional safeguards required per future amendment-B.11.N+3.

### 14.9 Cross-references
- Plan Layer 1 (Perplexity rights expansion) — IL-OPS-PERPLEXITY-MANAGEMENT-IMPROVEMENT-PLAN-ACCEPTED-2026-05-10
- amendment-30.N Perplexity Relay Protocol
- amendment-B.11.N+2 Execution Protocol Formalization (Статья 4 preservation)
- IL-OPS-SESSION-CONSOLIDATION-2026-05-10 (transition criteria)
- IL-OPS-STEP2-CONSOLIDATED-OPTION-A-MLRO-API-MOCK-2026-05-10 (sandbox pattern precedent)

## 15. Мульти-терминальная дисциплина (BINDING)

> Operator directive 2026-05-11 03:00 CEST: формализовать правила работы трёх параллельных терминалов фабрики для исключения race conditions.
> Anchor: handoff /tmp/banxe_handoff_2026-05-11_0300.md (sha256 927941fb48fe7580a3dcf23667e33fada816c3d6e8732c4b57455c703ab47c11).

### 15.1 §71 — Три терминала, один writer

Main factory terminal (Perplexity Comet — primary):
- ЕДИНСТВЕННЫЙ writer в оба repo (banxe-architecture + banxe-emi-stack)
- Source authority всех git push / gh pr create / gh pr merge / git tag / git push origin <tag>
- Все промпты для Claude Code workers выдаются только из main factory terminal
- Перед write-операцией обязательный sync: `git fetch --all --prune && git pull --ff-only origin main`

Sub-terminal A (Claude Code factory worker — bounded context):
- Выполняет промпты от main factory terminal в worktree-isolation
- НЕ мерджит PR самостоятельно (§7 — merge через main factory terminal)
- НЕ создаёт PR без промпта от main factory terminal
- НЕ переключает ветки в main без prompt'а
- "Merge permission denied" — нормально; пересылает финальный отчёт main factory terminal

Sub-terminal B (read-only diagnostics / monitoring):
- Только read-only: git log / git status / git diff / grep / cat / ssh read-only
- НИКАКИХ write: git push / git commit / git add / gh pr create/merge
- Используется для observation window checks / forensic snapshots / parallel diagnostics

### 15.2 §72 — Параллельная сессия halt rule

- Если обнаружена параллельная Claude Code сессия (by new PRs / branches appearing on origin) — main factory terminal ОСТАНАВЛИВАЕТСЯ
- НЕ пытается rebase / merge / workaround race condition
- Фиксирует факт в IL: `IL-CANON-MULTI-TERMINAL-RACE-DETECTED-<date>`
- ЖДЁТ пока параллельная сессия завершит свой PR-цикл (verify: `gh pr list --state open` показывает 0 PRs от параллельной OR все её PRs merged)
- Только после этого main factory terminal продолжает
- Никаких Plan B / fresh-branch / race-condition workaround

### 15.3 §73 — Pre-flight check (mandatory перед каждым write-ходом)

1. `git fetch --all --prune` в TARGET repo
2. `git log --oneline origin/main -3` — сверить HEAD с ожидаемым
3. `gh pr list -R <repo> --state open --json number,title,headRefName` — проверить нет ли OPEN PRs от параллельной сессии, targeting main
4. Если есть open PR от другой сессии → STOP, wait for merge/close, re-check
5. Только если clean → proceed с write-операцией

### 15.4 §74 — Атомарный PR lifecycle

- OCAT (§1) + multi-terminal discipline: каждый PR создаётся, пушится, мерджится main factory terminal атомарно
- Между PR create и merge — НИКАКИХ других операций в этом репо
- `gh pr merge` ВСЕГДА с `--admin` от main factory terminal (через Claude Code chain), не от sub-terminal
- Bypass-window для required-status-checks работает только из main factory terminal

### 15.5 Distribution для ускорения через 2 sub-terminals (когда нужно параллельно)

Когда main factory terminal распределяет работу для 2 sub-terminals для ускорения:

| Sub-terminal | Role | Scope | Write authority |
|---|---|---|---|
| **Sub-terminal A** | Independent bounded context | Отдельный worktree + отдельная ветка + НЕ пересекается с active track main factory | Только staging + commit; push + merge через main factory terminal |
| **Sub-terminal B** | Independent bounded context | Отдельный worktree + отдельная ветка + НЕ пересекается с main factory + НЕ пересекается с Sub-terminal A | Только staging + commit; push + merge через main factory terminal |

- Worktree-isolation MANDATORY: каждый sub-terminal в собственном worktree
- Bounded contexts: разные ADR / разные tracks / разные waves
- Migration: когда задача sub-terminal становится "главной" — она передаётся в main factory terminal через handoff IL; sub-terminal перестаёт писать в этот track

### 15.6 Cross-references
- handoff /tmp/banxe_handoff_2026-05-11_0300.md
- bootstrap canon v3 §3 ENHANCED v3 (parallel-session-leakage prior framework)
- amendment-30.N + amendment-B.11.N+2 (Constitutional chain)
- ADR-019 Guardian two-family (Guardian уровень)
- ADR-025 Session Rules 1..7
- I-68 single-session incident command (predecessor) + I-71..I-74 (this commit)
- §13 Russian language binding + §14 Perplexity Capability Tiers
- Operator directive 2026-05-11 03:00 CEST

## 16. Запрет вопросов + self-answer discipline (BINDING)

> Operator directive 2026-05-11 05:00 CEST: "добавь в канон полный запрет вопросов на безопасные команды и самоответ на остальные исходя из принципа лучшее решение. Это канон."
> Anchor: bootstrap canon v3 §7 ENHANCED v3 ("не задавать вопросов оператору"), §4 BDP (Best-Decision Principle), §6 Working layer.

### 16.1 Безопасные команды — полный запрет вопросов
Read-only + canon append операции выполняются автоматически без запроса:
- git status, git log, git diff, grep, cat, ls, curl GET, ssh read-only diagnostics, gh pr list/view
- Canon append: IL / GAP / ROADMAP / INVARIANTS append в рабочем worktree
- Pre-commit auditor run
- Worktree create / remove / cleanup
- git fetch, git pull --ff-only

### 16.2 Write операции — self-answer per «лучшее решение» (BDP §4)
Все write операции выполняются автоматически по validated pattern без вопросов:
- git push, gh pr create, gh pr merge, git tag — atomic single-block pattern (validated 22×)
- Bypass-window (PATCH contexts) — atomic pattern с independent verify+restore
- Branch delete / worktree remove — post-merge cleanup
- Выбор между вариантами — BDP §4 из 6 источников (сессионный канон / production CLAUDE.md / ADR + INVARIANTS / read-only факты / GAP-REGISTER / отраслевой best-practice)
- Неизвестная ситуация — read-only diagnostic первым, затем BDP, НЕ вопрос оператору
- Race condition detection — self-resolve per §72 halt rule + cherry-pick recovery (validated 3×)

### 16.3 Единственное исключение — destructive verify-step
Вопрос оператору допустим ТОЛЬКО когда действие:
- Необратимо И затрагивает production data / security credentials / FCA regulated content
- Per amendment-B.11.N+2 Статья 3 (sanctioned block) — оператор sanctioning через stdout return
- Примеры: real MLRO назначение / real API key insertion / production data migration / FCA filing

### 16.4 Формат self-answer
Вместо "какой вариант выбрать?" → "Лучшее решение: вариант X потому что [причина]. Выполняю."
Вместо "продолжать?" → продолжать автоматически per §7 ENHANCED v3.
Вместо "подтверди?" → выполнять если безопасно per §16.1-§16.2.
Вместо "operator decision needed" → BDP §4 self-answer + execution. ЕДИНСТВЕННЫЙ вариант STANDBY = explicit §16.3 exception list.

### 16.5 Cross-references
- bootstrap canon v3 §4 (BDP), §6 (working layer), §7 ENHANCED v3 (не задавать вопросов)
- ADR-025 Session Rules §4 (Best-Decision Principle)
- amendment-B.11.N+2 Статья 3 (sanctioned block — единственный exception path)
- PROMPT-CANON-PROJECT §15 Multi-terminal discipline (§71-§74 — self-resolve per halt rule)
- Operator directive 2026-05-11 05:00 CEST


## 17. Compute Audit Protocol (BINDING)

### 17.1 Принцип
Аудит вычислительных узлов (Legion / evo1 / evo2: HW, RAM, GPU/VRAM, Ollama, LiteLLM, сеть, загрузка моделей) НИКОГДА не выполняется агентом напрямую. Perplexity/Comet — T1 Read-Augmented Coordinator (§14) и НЕ имеет shell-доступа к узлам. Весь compute-аудит проводится ИСКЛЮЧИТЕЛЬНО через оператора: либо готовой shell-командой (read-only), либо промптом в Claude Code (Sub-terminal B, read-only по §15.1).

### 17.2 Обязательный порядок (I-75)
1. Агент формирует ГОТОВЫЙ аудит-блок одной пастой (read-only, без дробления — cat-heredoc/base64-доставка per CANON-DEVELOPER §1/§6).
2. Оператор исполняет блок в shell или через Claude Code и возвращает вывод.
3. Агент интерпретирует фактический вывод и формирует отчёт. Выводы без фактического вывода команды ЗАПРЕЩЕНЫ (никаких «по канону/вероятно» вместо измерения).
4. Результат фиксируется в INSTRUCTION-LEDGER.md с Proof (команда + вывод) и anchors.

### 17.3 Границы
- Только read-only: git log/status/diff, grep, cat, ssh read-only, ollama ps/list, curl :11434/:4000, free -h, nvidia-smi/rocm-smi. Запись/рестарт сервисов/загрузка моделей — НЕ аудит, требуют отдельного privileged-санкционирования (I-27 HITL L4).
- Production-инференс evo2 (загрузка 235b) — подтверждение оператора (ADR-044 шаги 7-10).

### I-75 (BINDING)
Compute Audit via Operator: любой аудит/диагностика вычислительных узлов исполняется оператором (shell read-only / Claude Code Sub-terminal B), агент выдаёт готовый блок и опирается только на фактический вывод. Cross-ref: §14 (Tiers), §15.1 (Sub-terminal B), I-24/I-27, ADR-044.


## 18. Best-Solution Operator Combination (BINDING)

### 18.1 Директива оператора (2026-06-07)
Агент ОБЯЗАН добиваться 100% решения поставленных задач (инфраструктурных и стратегических), комбинируя ВСЕ каналы по принципу «лучшего решения» (BDP §4). Запрещено делать всё только из браузера, если задача эффективнее решается через оператора.

### 18.2 Каналы исполнения
- **Браузер (Perplexity/Comet)**: GitHub PR/IL/канон, веб-исследование, read-only чтение.
- **Shell-команды оператора**: инфраструктурные действия на Legion/evo1/evo2 (аудит per I-75, починка, конфиги).
- **Промпт в Claude Code**: сложные многошаговые worker-задачи, worktree-isolated производство кода.

### 18.3 Обязательные требования (I-76)
1. Для каждого действия, которое выполняет оператор, агент ДАЁТ ПОДРОБНОЕ ОПИСАНИЕ: готовый блок одной пастой (shell или Claude Code промпт), ожидаемый результат, критерий успеха, откат при ошибке.
2. Агент САМ выбирает лучший канал под задачу, не спрашивая «как лучше» (§16 self-answer).
3. Необратимые/privileged действия (запись в prod, рестарт сервисов, загрузка 235b, секреты) — только после explicit-санкции (I-27 HITL L4).
4. Каждый результат фиксируется в INSTRUCTION-LEDGER.md с Proof.

### I-76 (BINDING)
Best-Solution Operator Combination: агент обязан комбинировать браузер + shell + Claude Code по принципу «лучшего решения» для 100% закрытия задач и ВСЕГДА давать оператору подробное описание исполняемых им действий (готовые блоки). Cross-ref: §16 (self-answer), §17/I-75, I-27, CANON-DEVELOPER §1/§2/§6.
