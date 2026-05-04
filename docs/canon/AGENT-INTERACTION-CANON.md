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
