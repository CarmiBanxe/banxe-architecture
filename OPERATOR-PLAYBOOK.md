# OPERATOR-PLAYBOOK

> **Статус:** DRAFT v1.0 — 2026-06-07  
> **Binding:** PROMPT-CANON-PROJECT §13-16, PROMPT-CANON-DEVELOPER §1-12  
> **Аудитория:** Moriel Carmi (CEO / Technical Director, BANXE EMI AI Bank)  
> **Цель:** Единый операторский справочник — принципы, промпты, команды, шаблоны для всех Perplexity / Claude Code сессий.

---

## ЧАСТЬ 1 — ОСНОВНОЙ ПРИНЦИП КАНОНА

### Принцип №1: Фабрика, а не ручная работа
Banxe использует **Software Factory** подход:
- Perplexity Comet = **главный терминал** (координатор, единственный writer).
- Claude Code = **worker** (исполнитель промптов от главного терминала).
- Один scope → один commit → один proof SHA. Никаких смешанных коммитов.

### Принцип №2: Канон выше операционного
При конфликте между "быстро сделать" и "сделать по канону" — **канон побеждает** всегда.

Иерархия приоритетов (сверху вниз):
1. FCA regulatory requirements (I-04, CASS 15, SUP 16)
2. Constitution + amendments (banxe-architecture/constitution/)
3. INVARIANTS.md (I-01..I-74+)
4. INSTRUCTION-LEDGER.md (IL-блоки, статус integrated)
5. ADRs (banxe-architecture/adrs/)
6. PROMPT-CANON-PROJECT §§
7. Операционные решения сессии

### Принцип №3: 100% или OPEN
Задача считается завершённой только когда есть:
- **proof SHA** (реальный git commit SHA)
- **quality check** пройден (ruff 0, tests 100%, coverage ≥ 35%)
- **IL-запись** в INSTRUCTION-LEDGER.md со статусом `integrated`

Иначе — фиксируется как `OPEN` с явным блокером.

### Принцип №4: Язык (§13 BINDING)
- **Оператору** — русский язык, простые формулировки.
- **Технические артефакты** — английский (commit messages, IL fields, код, CLI output).

### Принцип №5: Запрет вопросов (§16 BINDING)
- Безопасные команды (read-only, canon append) — выполняются **автоматически без вопросов**.
- Write операции — **self-answer** по BDP (лучшее решение → выполнить → отчитаться).
- Вопрос оператору допустим ТОЛЬКО для необратимых production-затрагивающих действий.

---

## ЧАСТЬ 2 — СЕССИОННЫЕ ПРОМПТЫ

### 2.1 Промпт старта новой сессии Perplexity

```
Ты работаешь в роли Perplexity Factory Terminal для проекта BANXE EMI AI Bank.

Первые действия:
1. Читай PROMPT-CANON-PROJECT.md из репо CarmiBanxe/banxe-architecture (§13-16 binding).
2. Читай SESSION-HANDOFF файл (последний по дате) из того же репо.
3. Выведи: статус IL, открытые PR, blockers, следующий шаг.
4. Приступай к следующему шагу без вопросов.

Правила:
- Русский язык для всех объяснений оператору.
- Английский для команд, IL fields, коммитов.
- Один scope = один commit = один proof SHA.
- Push = privileged action (спросить явного yes у оператора).
```

### 2.2 Промпт для Claude Code worker (Sub-terminal A)

```
Ты Claude Code worker в фабрике BANXE. Тебе даёт задачи главный терминал (Perplexity).

Правила:
- Выполняй ТОЛЬКО задачу из промпта — ни больше, ни меньше.
- НЕ создавай PR самостоятельно — только staging + commit.
- НЕ мерджи PR — это право главного терминала.
- НЕ переключай ветки в main без промпта.
- Один scope = один commit (git add только scoped files, не git add -A).
- ASCII-only в Python коде (em-dash запрещён вне комментариев).
- В конце — отчёт: что сделано, proof SHA, что НЕ сделано, blockers.
```

### 2.3 Промпт для начала работы с конкретным репо

```
Репо: CarmiBanxe/banxe-architecture (или banxe-emi-stack)

Перед началом работы:
1. git fetch --all --prune
2. git pull --ff-only origin main  
3. git log --oneline -10
4. gh pr list --state open
5. cat INSTRUCTION-LEDGER.md | tail -100

Только если все проверки чистые — начинай работу.
```

### 2.4 Промпт для создания IL-записи

```
Создай IL-запись в INSTRUCTION-LEDGER.md по норме IL-LEDGER-NORM-001.

Обязательные поля:
- id: IL-[CATEGORY]-[NAME]-[DATE]
- parent-cycle: [cycle-NNN]
- amendment-ref: [ref или n/a]
- source: [Perplexity / operator / ADR]
- status: proposed
- status-history: [дата] proposed
- scope: [что затрагивает]
- integration-rule: [правило интеграции]
- anchors: CANON / GATE / INVARIANTS / REGULATORY / HITL ROLES
- verification: triple-check + sha256-anchors реальных файлов
- deviations: n/a (или описание)
- privileged-ops: NOT EXECUTED (или EXECUTED)
- successor: n/a (или следующий IL)
- notes: [заметки]

Добавляй в конец файла (append-only — не редактировать старые записи).
```

### 2.5 Промпт для gap-анализа

```
Проведи gap-анализ между текущим состоянием и требованием:

1. Прочитай GAP-REGISTER.md.
2. Прочитай INVARIANTS.md (релевантные I-XX).
3. Прочитай COMPLIANCE-ARCH.md (релевантный раздел).
4. Выведи: существующие GAPs по теме, severity, owner, статус.
5. Если новый gap — добавь в GAP-REGISTER.md с ID G-[NNN] и severity HIGH/MED/LOW.
```

---

## ЧАСТЬ 3 — КОМАНДЫ БЫСТРОГО ДОСТУПА

### 3.1 Pre-flight check (обязателен перед каждым write)

```bash
# Pre-flight для banxe-architecture
git fetch --all --prune
git log --oneline origin/main -3
gh pr list -R CarmiBanxe/banxe-architecture --state open --json number,title,headRefName

# Pre-flight для banxe-emi-stack
git fetch --all --prune
git log --oneline origin/main -3  
gh pr list -R CarmiBanxe/banxe-emi-stack --state open --json number,title,headRefName
```

### 3.2 Scope-чистый коммит

```bash
# Правильно — только scoped файлы
git reset HEAD
git add path/to/scoped/file.py path/to/another/file.md
git commit -m "feat(scope): description [CANON IL-XXX]"

# Запрещено
git add -A  # ЗАПРЕЩЕНО без allowlist
```

### 3.3 PR lifecycle (через main factory terminal)

```bash
# Создать ветку
git checkout -b feat/scope-name

# После коммита — push (требует явного yes от оператора)
git push origin feat/scope-name

# Создать PR
gh pr create --title "feat(scope): description" --body "IL-ref: IL-XXX\nProof SHA: $(git rev-parse HEAD)" --base main

# Смержить (через main factory terminal только)
gh pr merge <number> --squash --admin
```

### 3.4 Handoff в конце сессии

```bash
cat > /tmp/banxe_handoff_$(date +%Y-%m-%d_%H%M).md << 'EOF'
# Handoff BANXE — [DATE TIME]

## Статус IL
- [IL-ID]: [статус] — [описание]

## Proof SHA
- [SHA]: [что закоммичено]

## Blockers
- [описание блокера или n/a]

## Parking
- [что отложено или n/a]

## Следующая сессия
- Первый шаг: [конкретное действие]
- Промпт: [промпт для старта]
EOF
echo "Handoff записан: /tmp/banxe_handoff_$(date +%Y-%m-%d_%H%M).md"
```

### 3.5 Проверка качества (quality gate)

```bash
# ruff
ruff check . --select ALL 2>&1 | head -50

# pytest
pytest --tb=short -q 2>&1 | tail -30

# coverage
pytest --cov=. --cov-report=term-missing 2>&1 | grep -E '(TOTAL|FAILED|ERROR)'

# bandit security
bandit -r . -ll 2>&1 | head -30
```

### 3.6 SHA anchor verification

```bash
# Проверить что SHA реально существует и привязан к scoped файлам
git log --oneline -- path/to/scoped/file.py | head -5

# Убедиться что sha256 совпадает
sha256sum path/to/file.md
```

---

## ЧАСТЬ 4 — HITL GATES (WHO CAN DO WHAT)

| Action | HITL Role | Канон |
|---|---|---|
| Consent revoke | COMPLIANCE_OFFICER | HITL-MATRIX |
| TPP suspend | COMPLIANCE_OFFICER | HITL-MATRIX |
| CRS override | MLRO | HITL-MATRIX |
| SAR filing | MLRO | HITL-MATRIX |
| FIN060 generate/approve | CFO | HITL-MATRIX |
| Board reports | CFO | HITL-MATRIX |
| Redress > £500 | COMPLAINTS_OFFICER | HITL-MATRIX |
| Suspicious device confirm | FRAUD_ANALYST | HITL-MATRIX |
| ATO lock/unlock | SECURITY_OFFICER | HITL-MATRIX |
| AI feedback approval | CTIO | HITL-MATRIX |
| US person change | COMPLIANCE_OFFICER | HITL-MATRIX |

> HITL L4 обязателен для всех privileged операций (I-27).

---

## ЧАСТЬ 5 — PERPLEXITY CAPABILITY TIERS (§14)

| Tier | Название | Статус | Что может |
|---|---|---|---|
| T1 | Read-Augmented Coordinator | ACTIVE | GitHub read, канон-синтез, coordination |
| T2 | Canon Synthesis Drafter | SANDBOX | Drafts IL/canon через Claude Code chain |
| T3 | Cross-Repo Coordinator | SANDBOX | Cross-reference между 5 prod repos |
| T4 | Compliance Advisor | SANDBOX | Queries COMPLIANCE-MATRIX + HITL-MATRIX |
| T5 | Decision Triage | SANDBOX | Categorize pending decisions |
| T6 | Privileged Operator | STANDBY | Direct write (только после Constitutional review) |

> Cap T2: 5 proposals per session. No auto-merge. Operator approval через PR.

---

## ЧАСТЬ 6 — МУЛЬТИ-ТЕРМИНАЛЬНАЯ ДИСЦИПЛИНА (§15)

```
Main factory terminal (Perplexity Comet)
    ├── ЕДИНСТВЕННЫЙ writer (git push, gh pr create, gh pr merge)
    ├── Координирует Sub-terminal A и B
    └── Обязательный pre-flight перед каждым write

Sub-terminal A (Claude Code worker)
    ├── Выполняет bounded-context промпты
    ├── Только staging + commit в worktree-isolation
    └── НЕ пушит, НЕ мерджит самостоятельно

Sub-terminal B (Read-only diagnostics)
    ├── git log / git status / git diff / grep / cat
    └── НИКАКИХ write операций
```

**Race condition rule:** Если обнаружена параллельная сессия (новые PRs от другой) — СТОП. Ждать завершения. Не пытаться workaround.

---

## ЧАСТЬ 7 — ШАБЛОНЫ ДОКУМЕНТОВ

### 7.1 Шаблон commit message

```
feat(scope): brief description [IL-CATEGORY-NAME-DATE]

- What: что сделано
- Scope: какие файлы затронуты
- IL ref: IL-XXX-YYY-ZZZZ
- Quality gate: ruff 0, tests pass

privileged-ops: git push origin main: EXECUTED
```

### 7.2 Шаблон PR description

```markdown
## Summary
Краткое описание что делает этот PR.

## IL Reference
- IL-ID: IL-XXX-YYY-ZZZZ
- Parent cycle: cycle-NNN
- Scope: [что затрагивает]

## Proof SHA
- Commit: [SHA]
- Files: [scoped files list]

## Quality Gate
- [ ] ruff: 0 issues
- [ ] pytest: 100% pass
- [ ] coverage: ≥ 35%
- [ ] Spec-First Auditor: pass

## HITL
- Required: [YES/NO — если YES, кто]
- Status: [PENDING/APPROVED]
```

### 7.3 Шаблон нового ADR

```markdown
# ADR-NNN: [Title]

## Status
Proposed | 2026-MM-DD

## Context
[Контекст проблемы]

## Decision
[Принятое решение]

## Consequences
### Positive
- [позитивные последствия]

### Negative / Trade-offs
- [компромиссы]

## References
- INVARIANTS: I-XX
- IL: IL-XXX
- Constitution: amendment-XX
```

---

## ЧАСТЬ 8 — ЭКСТРЕННЫЕ ПРОЦЕДУРЫ

### 8.1 Если коммит ушёл с чужим scope

```bash
# НЕ переписывать историю
# Фиксируем отклонение в ledger
# Добавляем deviations: в IL-блок
git log --oneline -5  # зафиксировать SHA
# В INSTRUCTION-LEDGER.md: deviations: mixed scope in <SHA> — not rewritten per canon §9
```

### 8.2 Если сессия прервалась без handoff

```bash
# В новой сессии:
git log --oneline -20  # последние коммиты
gh pr list --state open  # открытые PR
cat INSTRUCTION-LEDGER.md | grep -A5 'status: proposed'  # незакрытые IL
# Восстановить контекст из этих данных
```

### 8.3 Race condition recovery

```bash
# 1. НЕ трогать репо
# 2. Зафиксировать факт
echo "Race detected: $(date)" >> /tmp/banxe_race_$(date +%Y%m%d_%H%M).log
gh pr list -R CarmiBanxe/banxe-architecture --state open
# 3. Дождаться завершения параллельной сессии
# 4. git fetch --all --prune && git pull --ff-only
# 5. Только тогда продолжать
```

---

## ЧАСТЬ 9 — CHECKLIST КОНЦА СЕССИИ

```
□ Все активные IL закрыты (integrated) ИЛИ явно помечены OPEN с blocker
□ Proof SHA записан в IL-блок (реальный, после commit)
□ Quality gate пройден для всех code-коммитов
□ Открытые PR — все смержены или явно в STANDBY
□ Handoff файл создан в /tmp/banxe_handoff_<date>_<time>.md
□ Parking IL зарегистрированы для всего out-of-scope
□ Следующий шаг сформулирован конкретно
```

---

*OPERATOR-PLAYBOOK v1.0 | Создан: 2026-06-07 | Binding: PROMPT-CANON-PROJECT §13-16 | Язык: §13.1*
