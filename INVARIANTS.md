# INVARIANTS.md — Архитектурные инварианты Banxe

Эти правила всегда истинны. Нарушение любого — баг архитектуры, а не допустимое исключение.

---

## Compliance инварианты

**I-01 — Sanctions first**
Санкционная проверка выполняется ПЕРВОЙ, до любого другого AML шага. Результат санкций не может быть переопределён score-based логикой.

**I-02 — Blocked jurisdictions → REJECT**
Транзакция из/в Category A юрисдикцию (RU/BY/IR/KP/CU/MM/AF/VE-gov/Crimea/DNR/LNR) → REJECT немедленно, без исключений, без score.

**I-03 — Category B → HOLD/EDD, не auto-allow**
Транзакция из/в Category B юрисдикцию (SY/IQ/LB/YE/HT/ML/...) → минимум HOLD с Enhanced Due Diligence. Не APPROVE, не REJECT по умолчанию.

**I-04 — Transaction amount thresholds**
- ≥ £10,000 → EDD + HITL обязательны
- ≥ £50,000 crypto → High-value flag + MLRO approval
- Пороги не обходятся для "известных" или VIP клиентов

**I-05 — Decision thresholds неизменны без ADR + MLRO + CEO**
- SAR: composite ≥ 85 ИЛИ sanctions_hit
- REJECT: composite ≥ 70
- HOLD: composite ≥ 40
- Изменение threshold → обязательно ADR, нельзя через операторский интерфейс

**I-06 — Hard override всегда REJECT/SAR**
`HARD_BLOCK_JURISDICTION`, `SANCTIONS_CONFIRMED`, `CRYPTO_SANCTIONS` → REJECT независимо от composite score. Нет бизнес-причины, которая это отменяет.

**I-07 — Watchman minMatch = 0.80**
Нижняя граница Jaro-Winkler. Ниже → false positives. Выше 0.92 → пропускает алиасы. Изменение требует MLRO approval.

**I-08 — ClickHouse TTL = 5 лет**
FCA MLR 2017 record-keeping. Не уменьшать.

---

## Операционные инварианты

**I-09 — Auto-verify обязателен для compliance/kyc/aml/risk/crypto ответов**
Перед отправкой любого ответа по этим темам агент вызывает `http://127.0.0.1:8094/verify`. CONFIRMED → send. REFUTED → rephrase. Нет исключений для "быстрых" или "очевидных" случаев.

**I-10 — Нет фейковых интеграций**
Если LexisNexis, SumSub, Dow Jones, Chainalysis не подключены — не упоминать их как активные источники, не генерировать данные от их имени.

**I-11 — OFAC RSS не существует с 31.01.2025**
Только HTML scraper `ofac.treasury.gov/recent-actions`. Не пытаться подписываться на RSS.

---

## Архитектурные инварианты (слои)

**I-12 — Validators = source of truth, decisions = derived outputs**
`compliance_validator.py` (developer-core) — единственный авторитетный источник policy. AML engines (vibe-coding/src/compliance/) — derived. Никакой движок не переопределяет validator без явного изменения validator.

**I-13 — BANXE runtime делегирует, не дублирует**
`banxe_aml_orchestrator.py` вызывает developer-core validators через импорт. Логика threshold/forbidden_patterns не дублируется в нескольких местах.

**I-14 — Canonical key для компаний: (jurisdiction_code, registration_number)**
Никогда не использовать `company_number` в одиночку — коллизии между юрисдикциями.

**I-15 — Jube AGPLv3 — ТОЛЬКО internal, reference only**
Jube используется исключительно для внутреннего compliance. Любой external exposure (B2B, SaaS, партнёрский API) требует ПОЛНОЙ замены Jube-зависимости на Apache 2.0 альтернативу до запуска. Изучать архитектуру Jube как reference — допустимо. Создавать техническую зависимость (код, API-контракт) — запрещено.

---

## Инварианты привилегий

**I-16 — Обучение модели = только developer/CTIO**
Оператор-дублёр (Telegram, Marble UI) не имеет доступа к promptfoo eval, adversarial sim, training pipeline, изменению SOUL.md/SKILL.md/thresholds.

**I-17 — SOUL.md изменяется только через protect-soul.sh**
Прямое редактирование workspace SOUL.md → не даёт защиту (`chattr +i`). Только `bash scripts/protect-soul.sh update`.

**I-18 — GUIYON исключён из Banxe**
Никаких shared services, cross-routing, shared ports с проектом GUIYON.

**I-19 — Marble ELv2 — только internal compliance workflow**
Marble используется только для внутреннего MLRO workflow. Предоставление Marble как managed service третьим лицам — прямое нарушение Elastic License V2.

**I-20 — Compliance контуры независимы и заменяемы**
Каждый из 6 контуров (onboarding, screening, monitoring, triage, audit, training) может быть заменён независимо от остальных. Монолитная зависимость между контурами — баг архитектуры. Общий контракт: models.py (RiskSignal, AMLResult, EvidenceBundle).

---

## Инварианты агентной архитектуры (добавлены 2026-04-05, аудит v2)

**I-21 — feedback_loop.py НИКОГДА не изменяет SOUL.md/AGENTS.md автоматически**
`feedback_loop.py --apply` может предлагать патчи для Class B (SOUL.md, AGENTS.md),
но не применять их. Применение — только вручную через `protect-soul.sh update` после
MLRO + CTO approval. Нарушение: если `feedback_loop.py` делает commit/push
изменений в SOUL.md без явного человеческого действия.
Обоснование: `governance/change-classes.yaml` CLASS_B_SOUL_AGENTS. GAP-REGISTER G-05.

**I-22 — Агент Level 2 не пишет в policy layer**
Агенты, обрабатывающие внешние данные (транзакции, KYC-документы, ответы
от контрагентов), не имеют write-доступа к `developer-core/compliance/`.
Policy layer (compliance_validator.py) изменяется только через developer terminal.
Нарушение открывает вектор prompt injection → policy modification.
Обоснование: Orchestration Tree (NCC Group), GAP-REGISTER G-04.

**I-23 — Emergency stop state проверяется ДО любого автоматического решения**
Все screening endpoints обязаны проверять `emergency_stop.get_stop_state()`
перед выполнением. HTTP 503 при активном стопе — не опция, а обязательное поведение.
Нарушение: любой endpoint, выдающий compliance-решение без проверки stop state.
Обоснование: EU AI Act Art. 14(4)(e). GAP-REGISTER G-03.

**I-24 — Decision Event Log = append-only, без UPDATE/DELETE**
Записи аудит-трейла compliance-решений нельзя изменять или удалять.
При реализации G-01 (PostgreSQL decision_events): `REVOKE UPDATE, DELETE ON decision_events`.
До реализации G-01: ClickHouse append-only является допустимым промежуточным состоянием.
Нарушение: любой UPDATE/DELETE в audit-таблицах — немедленный alert MLRO.
Обоснование: DORA Art. 14(2), FCA MLR 2017 record-keeping. GAP-REGISTER G-01.

**I-27 — feedback_loop.py = supervised feedback loop, НЕ self-improving system**
Claim «self-improving system» в описании `feedback_loop.py` — **REFUTED**.
`feedback_loop.py` — это supervised feedback loop: он анализирует REFUTED corpus и
предлагает патчи, которые человек (MLRO/Developer) применяет явно.
Это не автономное самообучение — это инструмент для структурированного human-in-the-loop.
Любое описание системы как «autonomous self-improvement» является ложным и создаёт
регуляторный риск (FCA ожидает честного описания AI capabilities).
Зафиксировано во избежание drift в описании системы в SOUL.md, MEMORY.md и ADR.

**I-26 — Compliance incident → FCA notification в течение 72 часов**
Если prompt-injected данные привели к изменению compliance_validator.py или SOUL.md
без надлежащего governance gate (Class B approval) — это FCA-reportable compliance failure
(UK DORA requirements). Уведомление регулятора обязательно в течение 72 часов.
Практически: любое автоматически применённое изменение в policy layer без L0 approval
классифицируется как incident и запускает incident response процедуру.
Первый шаг incident response: активировать emergency stop (I-23), затем MLRO review.
Обоснование: Mastercard предупреждение об agentic AI commandeering; UK DORA Art. 19.

**I-25 — ExplanationBundle обязателен для решений > £10,000**
`BanxeAMLResult` для транзакций >= £10,000 должен содержать заполненный
`ExplanationBundle` с `top_factors`, `narrative` и `method`.
До реализации G-02: поле может быть null с `method: "pending"`.
Нарушение: REJECT/SAR > £10k без readable explanation — FCA SS1/23 нарушение.
Обоснование: UK GDPR, FCA PS7/24, EU AI Act transparency. GAP-REGISTER G-02.

**I-28 — Instruction Ledger Discipline (Execution Accountability)**
Каждая инструкция CEO/CTIO фиксируется в `banxe-architecture/INSTRUCTION-LEDGER.md`.
Claude Code НЕ переходит к следующей задаче при наличии >3 незавершённых IL без Proof.
Статус DONE только при наличии Proof (команда + реальный вывод).
Отклонение от инструкции (Deviation) фиксируется обязательно.
Hook `il_gate.py` (PreToolUse) программно блокирует Edit/Write/Bash при нарушении.
`scripts/il-check.sh` — CLI для CEO: мгновенный статус всех инструкций.
Нарушение = архитектурный дефект уровня P1. Требует Deviation-записи и объяснения.
Обоснование: исполнительская дисциплина агента — основа доверия и FCA governance.

**I-29 — Documentation Standard (Doc as First-Class Artifact)**
Каждый репозиторий Product Plane обязан содержать: `CHANGELOG.md`, `docs/ONBOARDING.md`,
`docs/RUNBOOK.md`, `docs/API.md`, `QUALITY.md`.
Каждый Python модуль обязан иметь module-level docstring с WHY + FCA rule.
Каждый HTTP endpoint обязан иметь OpenAPI 3.1 spec рядом с кодом.
CHANGELOG.md обновляется при каждом IL. API.md при изменении публичного интерфейса.
Устаревшая документация = tech debt уровня P2. Отсутствие обязательного файла = блокировка IL DONE.
Канон: `banxe-architecture/docs/DOC-STANDARD.md`.
Нарушение: IL не может получить статус DONE без обновлённой документации.
Обоснование: FCA audit trail требует воспроизводимости и объяснимости каждого решения.
"If it's not documented, it didn't happen."

**I-31 — BLOCKED-TASKS.md Append-Only Catalogue (PROPOSED)**
`banxe-architecture/docs/BLOCKED-TASKS.md` — единственный источник истины по заблокированным задачам.
Claude Code ОБЯЗАН добавить запись при BLOCKED статусе любой IL.
При разблокировке — обновить запись (BLOCKED → UNBLOCKED, дата, trigger).
Запрещено удалять записи — только обновлять статус (append-only, I-24 аналог для task tracking).
Формат: BT-NNN, задача, IL ref, blocker, тип блокера, unblock trigger, дата, статус.
*PROPOSED — требует явного утверждения CEO.*
Обоснование: без явного каталога блокировки накапливаются незаметно и теряются при смене контекста.

**I-30 — Quality Gate Mandatory Regardless of Model Routing (PROPOSED)**
`quality-gate.sh` обязателен для всех Product Plane репозиториев независимо от
модельного routing режима (cc-cloud / cc-local).
Коммит в Product Plane принимается только после quality gate PASS.
Режим cc-local не является основанием для пропуска gate.
Канон: `banxe-architecture/docs/LOCAL-CLOUD-ROUTING.md`, раздел Operational Rules.
*PROPOSED — требует явного утверждения CEO перед переводом в обязательный статус.*
Обоснование: деградация качества локальных моделей не должна приводить к снижению
стандарта для FCA-regulated кода. Gate одинаков для Sonnet и qwen3-coder.

---

**I-32 — No Direct Cloud LLM Calls from EMI Services (ACCEPTED)**
EMI-сервисы (banxe-emi-stack, banxe-compliance-api, banxe-dashboard, deep-search, drive_watcher и все будущие EMI-сервисы) НЕ ВПРАВЕ обращаться напрямую к внешним LLM-провайдерам (Claude, Gemini, Groq, OpenAI и т.п.).
Все AI-вызовы идут через LiteLLM v2 router (`http://legion:4000/v1`, далее evo1) по утверждённым алиасам: `ai`, `ai-heavy`, `glm-air`, `reasoning`, `banxe-general`, `fast`, `coding`.
Backing-модели — деталь реализации plane, не сервиса.
Канон: `decisions/ADR-016-ai-plane-pii-aml-routing.md`.
Enforcement: pre-commit hook + code review checklist в каждом EMI-репо.
Severity: P1 — architecture invariant breach.

**I-33 — PII/AML Deny-Paths Route Only via Local LiteLLM Aliases (ACCEPTED)**
Контент по путям `compliance/cases/*`, `kyc/raw/*`, `secrets/*`, `.env*`, `**/*.pem`, `**/id_*` обрабатывается ИСКЛЮЧИТЕЛЬНО локальными алиасами LiteLLM (`ai`, `ai-heavy`, `glm-air`, `reasoning`).
Передача такого контента во внешние LLM или незащищённые маршруты запрещена.
Source of truth: `banxe-infra/ai-routing/policy.yaml`.
Канон: `decisions/ADR-016-ai-plane-pii-aml-routing.md`.
Enforcement: policy.yaml + pre-commit hook + review checklist + runtime guard в LiteLLM router.
Severity: P0 — security incident (FCA CASS 15 + GDPR Art. 5 / Art. 32).

---

**I-34 — No Direct Credentials in EMI Service Configs (ACCEPTED)**
EMI-сервисы (banxe-emi-stack, banxe-compliance-api, banxe-dashboard, deep-search, drive_watcher и все будущие EMI-сервисы) НЕ ВПРАВЕ хранить direct user/password или статические API-секреты в файлах окружения и конфигурации (`.env*`, `*.yaml`, `*.json`, `docker-compose*`).
Любые credentials выдаются только через Keycloak realm `banxe-emi` (см. I-35) как короткоживущие OIDC-токены. Master-секреты (client_secret, операторские ключи) — operator-supplied env, никогда не коммитятся.
Канон: `decisions/ADR-017-keycloak-iam-cutover.md`.
Enforcement: pre-commit hook в каждом EMI-репо (запрет direct credentials в env/yaml/json), code review checklist, Gitleaks в CI.
Severity: P0 — security incident (FCA CASS 15 + GDPR Art. 32).

**I-35 — Keycloak Realm `banxe-emi` as Single IAM Issuer (ACCEPTED)**
Все EMI-сервисы аутентифицируются и авторизуются ИСКЛЮЧИТЕЛЬНО через Keycloak realm `banxe-emi`, развёрнутый на evo1 (`http://evo1:8180/realms/banxe-emi/.well-known/openid-configuration`).
Альтернативные IAM-источники (локальный Legion `--user` IAM, hardcoded JWT, статические API-ключи, сторонние OAuth-провайдеры) запрещены для production EMI-флоу. Legion local IAM сохраняется как rollback до подтверждённого PASS на evo1, после чего декомиссионируется (см. ADR-017 §6).
Канон: `decisions/ADR-017-keycloak-iam-cutover.md`.
Enforcement: code review checklist, Keycloak audit log (retention ≥ 12 месяцев), runtime guard в API gateway / service-mesh.
Severity: P1 — architecture invariant breach. P0 если нарушение приводит к утечке клиентских данных (FCA CASS 15).

**I-36 — Claude Code Bash Routes Through Guardian Shim (ACCEPTED)**
Каждый вызов инструмента Bash в Claude Code ДОЛЖЕН проходить через `claude-bash-shim.sh` до исполнения.
Шим перехватывает команду через нативный хук `PreToolUse` (Strategy-S1, `.claude/settings.json`), маскирует секреты (sed regex), отправляет POST `/audit` на Guardian `:8195` и применяет вердикт:
`pass`/`warn`/`unknown` → proceed; `fail` + `GUARDIAN_MODE=enforce` → блокирует (exit 1).
Guardian недоступен: fail-open в режиме `audit`, fail-closed в режиме `enforce`.
Все вызовы логируются в `~/.claude/guardian-shim/audit.log` (JSON-lines).
Канон: `decisions/ADR-024-guardian-bash-shim.md`.
Enforcement: `.claude/settings.json` PreToolUse hook (banxe-emi-stack); ENFORCE rollout 2026-05-11 (compliance repos), 2026-05-18 (everywhere).
Severity: P1 — security/governance gap if bypassed.

---

**I-37 — Factory↔Project Layer Binding (PROPOSED)**
Двухуровневая AI-инфраструктура (bootstrap canon v3 §0.1, §1.bis) immutable:
factory layer = Legion (производство BANXE EMI banking platform); project layer
= evo1 + evo2 unified (операционная работа банка как live financial institution).
Factory-агенты НЕ ходят на project-узлы. Project-агенты НЕ ходят на Legion.
Cross-layer вызовы — ИСКЛЮЧИТЕЛЬНО через LiteLLM v2 gateway
(http://legion:4000/v1, master_key=sk-banxe-llm-gateway-2026) с canonical routes:
factory-fast / factory-mid / factory-heavy / factory-coder / project-mid /
project-heavy / project-reason. Регулируемые маршруты (project layer regulated)
обязаны проходить через Ruflo proxy chain (request → ARL → Ruflo → target → response).
Канон: bootstrap canon v3 §0.1 + §0.5 + §1.bis + §10 Phase F1.
Источники истины: /home/mmber/MetaClaw/litellm/litellm-config.v2.yaml (config),
IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09 (factual baseline).
Связь с существующими invariants: I-32 (no direct cloud LLM calls from EMI),
I-33 (PII/AML deny-paths via local aliases), I-35 (Keycloak realm banxe-emi as
single IAM issuer), I-36 (Claude Code Bash through Guardian shim).
Severity: P0 — architecture invariant breach + §0.5 distribution discipline violation.
Enforcement: factory overseer agent (Phase F2.4), Ruflo deployment (Phase F1),
LiteLLM systemd unit + routes reconciliation (Phase F3.1 + F3.2),
guardian-factory + guardian-project services (already running on evo1:8195/8196).
*PROPOSED — требует явного утверждения CEO перед переводом в обязательный статус.*
Обоснование: без явного binding факторий-агенты могут уходить на проектные узлы
с regulated данными в обход Ruflo, нарушая §0.5 + I-32/I-33; project-агенты
могут вызывать factory-модели для production задач, нарушая FCA SUP layer
separation для regulated EMI операций.

**I-71 — Single-Writer Terminal Discipline (ACCEPTED)**
Main factory terminal (Perplexity Comet — primary) — ЕДИНСТВЕННЫЙ writer в banxe-architecture + banxe-emi-stack repos. Sub-terminals (Claude Code factory worker + read-only diagnostics) НЕ выполняют git push / gh pr create / gh pr merge / git tag без promtа из main factory terminal. Все промпты для sub-terminals формируются только в main factory terminal.
Канон: PROMPT-CANON-PROJECT.md §15.1 §71.
Enforcement: pre-commit hook check + Guardian conversation-judge prompt + IL audit (IL-CANON-MULTI-TERMINAL-RACE-DETECTED format при violation).
Severity: P0 — multi-terminal race condition leading to canon corruption.

**I-72 — Parallel Session Halt Rule (ACCEPTED)**
При обнаружении параллельной Claude Code сессии (new PRs / branches appearing on origin от other source) main factory terminal ОСТАНАВЛИВАЕТСЯ. НЕ выполняет rebase / merge / workaround race condition. Фиксирует факт в IL формате `IL-CANON-MULTI-TERMINAL-RACE-DETECTED-<date>`. Ждёт пока параллельная сессия завершит свой PR-цикл (gh pr list --state open = 0 от другой сессии). Только после этого продолжает.
Канон: PROMPT-CANON-PROJECT.md §15.2 §72.
Enforcement: gh pr list pre-flight check (per I-73) + IL audit.
Severity: P0 — race condition prevention.

**I-73 — Pre-flight Check Mandatory (ACCEPTED)**
Перед каждой write-операцией main factory terminal выполняет: (1) git fetch --all --prune; (2) git log --oneline origin/main -3 сверить HEAD; (3) gh pr list --state open --json number,title,headRefName проверить параллельные open PRs; (4) если есть open PR от другой сессии → STOP, wait, re-check; (5) только если clean → proceed.
Канон: PROMPT-CANON-PROJECT.md §15.3 §73.
Enforcement: shell-block template обязательно начинается с pre-flight check sequence.
Severity: P1 — process discipline violation.

**I-74 — Atomic PR Lifecycle (ACCEPTED)**
Каждый PR проходит lifecycle atomically: create → push → merge (без интервалов / других операций в same repo между этими шагами). gh pr merge ВСЕГДА с --admin от main factory terminal (через Claude Code chain). Bypass-window для required-status-checks работает только из main factory terminal. Sub-terminals не имеют прав bypass.
Канон: PROMPT-CANON-PROJECT.md §15.4 §74.
Enforcement: atomic single-block shell pattern (validated 20× в session 2026-05-09 → 2026-05-11).
Severity: P0 — atomic merge integrity preservation.

**I-75 — No-Signal-Equals-Incident (PROPOSED)**
Отсутствие heartbeat сигнала от любого критичного узла/сервиса/агента в течение
2× heartbeat interval (default 2×15m = 30 минут) автоматически классифицируется
как INCIDENT и эскалируется. Не допускается "тихий сбой" — no signal = incident.
Каждая критичная сущность обязана иметь: owner, heartbeat endpoint, smoke-test,
remediation policy, escalation path.
Канон: ADR-WDG-01 Factory Watchdog.
Связь: I-37 (factory/project layer binding), ADR-033 (alert routing), G-WDG-01..04.
Severity: P1 — operational invariant.
Enforcement: ops/watchdog/ heartbeat daemon + alert routing via ADR-033 channel.
*PROPOSED — требует явного утверждения CEO перед переводом в обязательный статус.*
