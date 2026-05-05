# Agent Interaction Canon

**Status:** ACCEPTED via ADR-025 (2026-05-04)
**Scope:** Все AI-агенты, работающие с любыми `CarmiBanxe/*` репозиториями.
**Living document:** обновляется при появлении новых паттернов нарушений.

---

## §1. OCAT (One-Command-At-a-Time)

> «один промт ИЛИ команда → вывод → следующий промт ИЛИ команда»
> «никогда параллельные промты или команды»

Один ход агента = одна выдача (промт ИЛИ команда). Никаких комбинаций «команда + дополнительный промт в том же ходе». Никаких параллельных action в одном сообщении.

**Между chunk'ами/частями агент НЕ ждёт подтверждения оператора.** Просто выдаёт следующую команду один за другим; оператор выполняет и присылает вывод. Уточнение от 2026-05-04 19:00 CEST.

---

## §2. Адресат каждого хода

> «ты должен говорить кому. это канон. запомни и применяй»

Каждая команда/промт явно помечается адресатом:
- **«Для Claude Code (gmktec, /data/banxe/<repo>):»** — текстовый промт, копируется в окно Claude Code.
- **«Для Legion (mark-legion shell):»** — shell-команда, вставляется в bash.

Один адресат за ход.

---

## §3. Запрет на вопросы по безопасным командам

> «в каждом промте клод коду запрет на вопросы по безопасным командам»
> «по остальным он должен сам отвечать на вопросы исходя из принципа лучшего ответа»
> «для экономии времени и ресурса»

По безопасным (read-only / каноничным) операциям — никаких уточнений «ok?», «продолжать?», «хочешь ли ты?». Агент сам выбирает и выдаёт.

---

## §4. Запрет переспрашивать у оператора

> «по канону ты должен выдавать или промт для клод код или команду для легион»
> «по канону ты всегда готовишь промт или команду, а не переспрашиваешь»
> «по канону ты должен принимать лучшее решение и выдавать промт или команду, а не учить меня и не переспрашивать»

Агент **не** задаёт оператору вопросов вида «хочешь ли ты A или B?», «жду подтверждение», «уточни приоритет», «что выбираешь?». Агент **сам** выбирает лучший вариант на основе:
- Уже зафиксированных канонов в этой сессии.
- Production CLAUDE.md.
- ADR + INVARIANTS.md.
- Read-only фактов из repo.

И сразу выдаёт промт или команду.

---

## §5. Разбиение длинных промтов на части

> «если промт или команда большие и могут быть обрезаны, то разделяй задачу на части и делай вывод промта или команды связанными частями»

Если есть риск обрезания (terminal width, message length) — агент **до** выдачи разбивает на Part k/N с **картой всех частей** в первом ходе. Каждая часть — самостоятельный ход OCAT. Между частями агент **НЕ** ждёт подтверждения (см. §1 уточнение).

---

## §6. Архитектурный стек

> «ты должен работать в архитектурном стеке»

Все действия — только в production-репозиториях `CarmiBanxe/*` на GitHub:
- `banxe-architecture` — главный архитектурный repo (canonical home для policies, ADRs, INVARIANTS, INSTRUCTION-LEDGER).
- `banxe-emi-stack` — execution-level repo для P0 CASS 15 stack.
- `vibe-coding` — compliance engine, AML stack.

**Sandbox** `/data/banxe-emi-stack` (изолированный, без remote, на gmktec) — **frozen архив**. НЕ трогать.

Перед началом любых действий — verify scope: `git remote -v` должен указывать на `CarmiBanxe/*` GitHub URL.

---

## §7. Ясность изложения

> «выражайся всегда яснее»

Без жаргона, без обтекаемых формулировок. Структура: **факт → вывод → действие**. Конкретные данные, не общие слова.

---

## §8. Никогда не печатать секреты или их метаданные

Производное от ADR-031 + production CLAUDE.md.

Метаданные секретов (длина, формат, hash, число entries в env-файле) — тоже выдают энтропию. Запрещено printf'ить такие значения в чат, даже косвенно (`secret_len=32`, `password_hash starts with $2b$`, etc.).

---

## §9. Разделение операций по permission level

Production CLAUDE.md рассказывает три категории:

1. **Auto-apply без вопросов**: refactoring within module, type hints, tests, linters, alembic revision.
2. **Always present plan и wait для YES**: DB schema change, cross-service interfaces, financial invariants, prod config, secrets, alembic upgrade.
3. **Auto-edit zones**: `scripts/`, `tests/`, `services/*/tests/`, `services/*/schemas/`.

Агент применяет это автоматически без вопросов оператору.

---

## §10. ADR-031 deny-paths (binding)

Никогда не отправлять в cloud LLM (или печатать в чате) содержимое путей:
```
compliance/cases/*
kyc/raw/*
secrets/*
.env*
**/*.pem
**/id_*
```

Только local LiteLLM routes (`ai`, `ai-heavy`, `glm-air`, `reasoning`) могут обрабатывать такие payloads. Violation = P0 security incident.

---

## §11. Production CLAUDE.md — ключевые rules (cross-reference)

- Branch naming: `feat/`, `fix/`, `refactor/`, `hotfix/`.
- Never push to `main` directly (branch protection enforced).
- Commit format: `type(scope): message [IL-XXX]`.
- Migrations: `ask` permission level, blocked для `*prod*`.
- Never read `.env` files или `secrets/` без explicit confirmation.
- Coverage: minimum 80% для `services/` и `api/`.
- I-01: `Decimal` only для monetary values (Semgrep enforced).
- I-02: blocked jurisdictions (RU/BY/IR/KP/CU/MM/AF/VE/SY).
- I-08: ClickHouse audit TTL minimum 5 years.

---

## §12. Guardian-shim как backstop канона

Guardian-shim (audit mode default, может быть переключён в enforce):
- Перехват каждой bash-команды от Claude Code.
- POST на Guardian agent endpoint (`http://192.168.0.72:8195`).
- Verdict: `pass` / `warn` / `fail` / `unknown`.
- Logs: `~/.claude/guardian-shim/audit.log` (JSON-lines).
- Secrets masking before POST.

Источник: `CarmiBanxe/banxe-emi-stack/infra/guardian-shim/`, commits `c6685c5` + `5ef4601` + `57797b7`.

**Покрывает только bash-команды** (~10% нарушений канона). Conversation-level guard для остальных 90% — **G-CANON-01** (см. `conversation-guard-design.md`).

---

## §13. Reference list 13 нарушений канона (2026-05-04)

См. `violations-2026-05-04.md` для полной таблицы и контекста. Используется как test cases для conversation-guard (G-CANON-01).

---

## §14. Минимальный чек-лист агента перед каждым ходом

Применяется автоматически:

1. Кому адресован ход? Поставить пометку §2.
2. Это вопрос/уточнение? Если да — переписать как решение + промт/команду §4.
3. Объём промта оценен? Если близко к лимиту — разделить на Part k/N §5.
4. Принял ли я лучшее решение сам? Если перекладываю на оператора — перерешить §4.
5. Соблюдены ли границы стека (production repos, ADR-031, OCAT)? §6, §10.
6. Ясный ли язык? §7.
7. Между chunk'ами не жду подтверждения §1.
8. Не печатаю секреты или их метаданные §8.
9. Может ли это быть выполнено в Claude Code? Если да — адресую туда §15.

---

## §15. Claude-Code-First (CCF)

> «работаем в клод коде; шелл — только по необходимости»
> «безопасно, потому что клод код открыт ещё в двух терминалах в легионе» (Operator, 2026-05-05 16:00 CEST)

**Принцип:** Все действия по умолчанию исполняются внутри Claude Code (или эквивалентного агентного IDE). Прямой shell используется только там, где Claude Code не может выполнить операцию сам (или где это явно дешевле/безопаснее по другим секциям канона).

### Почему это безопасно

- Claude Code открыт в двух дополнительных терминалах на Legion (mark-legion): второй и третий instance Claude Code обеспечивают out-of-band наблюдение и экстренное вмешательство, если основной поток ушёл в нежелательное состояние.
- Claude Code применяет permission-prompts на opaque/destructive операции (write, exec неизвестных бинарей) — оператор всегда видит, что именно будет запущено.
- Все bash-вызовы Claude Code проходят через Guardian-shim (ADR-024, scope `claude.bash`, agent.bash family per ADR-026): CB1 deny-path (§10), CB2 secret-leak (§8), CB3 frozen-sandbox (§6), CB4 dangerous-cmd. Прямой shell-ход оператора эту защиту обходит.
- Conversation-guard (G-CANON-01, ADR-025) применяется к chat-output Claude Code, а не к терминальным сессиям оператора.

### Адресация (взаимодействие с §2)

- **«Для Claude Code (...)»** — default. Промт копируется в окно Claude Code; он сам исполняет (включая bash, file edits, gh CLI).
- **«Для Legion (mark-legion shell):»** — fallback, выдаётся только при выполнении одного из критериев исключения ниже.

### Когда разрешён прямой shell (исключения)

Coordinator (Comet/operator) выдаёт промт «Для Legion shell» только если выполняется хотя бы одно из:

1. **Out-of-tree probe.** Действие требуется на хосте, в репо или путях, к которым у текущего Claude Code instance нет доступа (например read-only inventory на evo1: `ssh evo1 'systemctl ...'`).
2. **Permission ceiling.** Действие требует возможностей, которые Claude Code в текущей конфигурации не имеет: admin gh операции (`gh pr merge --admin`), работа с external sudo, передача файла через scp/rsync на другой хост, операции из user-shell (sudoers profile отличается).
3. **Bootstrap / recovery.** Сам Claude Code сейчас недоступен (упал, не запущен, нет MCP), и нужно выполнить minimal-step, чтобы его поднять или продиагностировать.
4. **Verification из независимой среды.** Шаг канона требует именно внешнего наблюдателя (например, проверить, что endpoint доступен из LAN, а не только локально на evo1).
5. **Phase deadline pressure.** Когда explicit deadline делает round-trip через Claude Code дороже, чем direct shell — допускается обход с обязательным IL-record после.

Любая команда вне этих 5 категорий, которая может быть выполнена в Claude Code, **должна** быть выдана как промт «Для Claude Code».

### Запреты CCF

- Запрещено дублировать одну и ту же операцию между Claude Code и Legion shell в одном ходе (нарушение §1 OCAT и §15 одновременно).
- Запрещено выдавать «Для Legion shell» только потому, что так «быстрее набрать промт» — экономия времени оператора не входит в список из 5 исключений.
- Запрещено копировать секреты, токены, выводы аудита и PII-содержащие данные через прямой shell, минуя Guardian-shim, даже если попадает под одно из исключений.

### Cross-references

- §1 OCAT — один ход = одна команда ИЛИ один промт; §15 уточняет, кому именно адресуется этот один ход.
- §2 Адресат — обязательная разметка адресата каждого хода.
- §6 Frozen sandbox — production-only repos.
- §8 Secret-leak. §10 ADR-031 deny-paths.
- ADR-024 Guardian-shim (bash-level enforcement).
- ADR-025 Agent Interaction Canon (this document).
- ADR-026 Guardian agent.bash family.
- ADR-019 Two-family Guardian (extended → three-family).

### Tracker

G-CANON-15 (новый): cover §15 in conversation-judge prompts и в 13+ regression test cases (V-14: «команда выдана в shell, хотя могла быть в Claude Code» как expected `warn`).
