# ADR-025: Agent Interaction Canon

- **Status:** ACCEPTED
- **Date:** 2026-05-04
- **Authors:** Moriel Carmi (operator), Comet/Claude (agent draft)
- **Supersedes:** —
- **Superseded by:** —
- **Related:** ADR-017 (Keycloak IAM cutover), ADR-022 (EMI mirror), ADR-024 (Guardian-shim), ADR-031 (AI plane PII/AML routing)

## Context

Между 2026-05-03 и 2026-05-04 в сессии `banxe-emi-stack (FCA / KYC / Keycloak roadmaps)` оператор (Moriel Carmi) и agent (Comet/Claude) накопили эмпирический поведенческий контракт ("канон") для взаимодействия. За одну сессию:

- Закрыты P0 пункты CASS 15 IAM cutover (PRs #50, #52, #53, #55, tag `cass15-iam-cutover-2026-05-07`).
- Обнаружено **13 категорий нарушений канона** агентом, включая длинные промты вместо одной команды, переспрашивание при наличии полномочий принимать решения, печать метаданных секретов, работу не в том репо.
- Validated, что Guardian-shim покрывает только ~10% таких нарушений (только bash-команды, не conversation-level).

Без формализации канона:
- Каждая новая сессия повторяет ошибки предыдущей.
- Conversation-level guard невозможно проектировать без письменного behavioral contract.
- Onboarding новых AI-агентов в систему (Aider, Cursor, Continue, любые MCP-клиенты) идёт без единых правил.

## Decision

Принять `docs/canon/AGENT-INTERACTION-CANON.md` как **canonical behavioral contract** для всех AI-агентов, работающих с banxe stack.

Канон состоит из **15 секций** (см. companion doc):
1. OCAT (One-Command-At-a-Time)
2. Адресат каждого хода
3. Запрет на вопросы по безопасным командам
4. Запрет переспрашивать у оператора
5. Разбиение длинных промтов на части
6. Архитектурный стек (production vs sandbox)
7. Ясность изложения
8. Никогда не печатать секреты или их метаданные
9. Разделение операций по permission level
10. ADR-031 deny-paths (binding)
11. Production CLAUDE.md cross-reference
12. Guardian-shim как backstop
13. Reference list 13 нарушений 2026-05-04
14. Минимальный чек-лист агента перед каждым ходом

## Scope

Канон применяется ко **всем AI-агентам**, взаимодействующим с любыми banxe-репозиториями:
- `banxe-architecture` (этот репо).
- `banxe-emi-stack`.
- `vibe-coding`.
- Любые будущие repos в `CarmiBanxe/*`.

Канон **дополняет**, не заменяет:
- Production `CLAUDE.md` (code/git rules).
- ADRs `017-031` (architecture decisions).
- INVARIANTS.md (I-01..I-35).
- GAP-REGISTER (live tracker).

## Enforcement

Двухуровневая модель:

### Уровень 1 — Guardian-shim (bash-level, существует с 2026-05-04)
- Перехват каждой bash-команды от агента до выполнения.
- POST на Guardian agent (`http://192.168.0.72:8195`).
- Modes: `audit` (default, log-only), `enforce` (block on `verdict=fail`), `off`.
- Покрывает: dangerous commands, deny-paths violation, secret-revealing patterns, `--admin` без opt-in.
- Источник: `infra/guardian-shim/scripts/claude-bash-shim.sh` в `banxe-emi-stack`.

### Уровень 2 — Conversation-level guard (NEW, проектируется)
Tracking item: **G-CANON-01** (закрытие до 2026-05-31 target).

- Read access к chat history через MCP server или browser-extension hook.
- LLM judge оценивает каждый output агента на соответствие 14 секциям канона.
- Output filter: if judge=fail → message не отправляется оператору, агент получает correction prompt.
- Покрывает остальные ~90% нарушений канона (semantic, не syntactic).

## Consequences

### Positive
- Письменный contract для onboarding новых agents.
- Reference list 13 нарушений как test cases для conversation-guard.
- Унификация поведения agents между repos.
- Audit trail соответствия канону через Guardian-shim audit.log + (future) conversation-guard logs.

### Negative
- Дополнительный maintenance overhead: канон должен обновляться при появлении новых паттернов нарушений.
- Risk of canon-bloat: при добавлении новых секций без удаления старых документ становится unworkable.
- Conversation-guard не существует на момент принятия ADR — это commitment to build.

### Neutral
- ADR-025 не изменяет existing code или infra. Это behavioral contract.
- Live state production stack (Keycloak realm `banxe-emi`, 4 service clients, etc.) не затронут.

## Alternatives considered

### A. Не формализовать канон
Оставить как oral tradition в каждой сессии. Отвергнуто: каждая новая сессия повторяет ошибки. Conversation-guard невозможно проектировать без written contract.

### B. Положить канон в `banxe-emi-stack/docs/`
Отвергнуто: канон — cross-repo concern. EMI-stack — execution-level repo для P0 CASS 15 stack. Канон относится ко всем repos.

### C. Положить канон в `vibe-coding/`
Отвергнуто: vibe-coding — compliance engine domain, не agent discipline.

### D. Принять как **ADR-025 в `banxe-architecture`** (ВЫБРАНО)
`banxe-architecture` — canonical home для cross-cutting policies (per CLAUDE.md production EMI: «Главный архитектурный репо: github.com/CarmiBanxe/banxe-architecture»). DRY canon: один source of truth, многие consumers.

## References

- Companion: `docs/canon/AGENT-INTERACTION-CANON.md` (full 15-section text).
- Reference: `docs/canon/violations-2026-05-04.md` (13 violations as test cases).
- Design: `docs/canon/conversation-guard-design.md` (G-CANON-01 architecture).
- Source session: `CarmiBanxe/banxe-emi-stack` 2026-05-03 → 2026-05-04, main HEAD `ee4e0d7`.
- Guardian-shim: `CarmiBanxe/banxe-emi-stack/infra/guardian-shim/`, commits `c6685c5` + `5ef4601`.
- Tag witnessing the source session's success: `cass15-iam-cutover-2026-05-07`.

## §15 Claude-Code-First (CCF) — Amendment 2026-05-05

> Added via IL-CANON-04.

**Принцип:** Все действия по умолчанию исполняются внутри Claude Code. Прямой shell используется только при выполнении одного из 5 исключений:

1. Out-of-tree probe (хост/репо вне доступа текущего CC instance).
2. Permission ceiling (admin gh ops, sudo, scp/rsync cross-host).
3. Bootstrap / recovery (CC сам недоступен).
4. Verification из независимой среды (external LAN probe).
5. Phase deadline pressure (explicit deadline + IL-record обязателен после).

**Адресация:** «Для Claude Code (...)» = default; «Для Legion shell» = fallback only.

**Запреты:** нет дублирования CC+shell в одном ходе; нет shell «потому что быстрее набрать»; нет PII/secrets через shell минуя Guardian-shim.

**Tracker:** G-CANON-15 (cover §15 in conversation-judge + V-14 test case).
