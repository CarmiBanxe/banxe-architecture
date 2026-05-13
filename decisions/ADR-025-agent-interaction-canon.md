# ADR-025: Agent Interaction Canon

**Status:** Accepted
**Date:** 2026-05-04
**Source-of-determination:** body line `- **Status:** ACCEPTED` (hyphen-prefixed list-form header — not matched by INDEX generator regex `^\*\*Status:\*\*`)

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

Канон состоит из **14 секций** (см. companion doc):
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

- Companion: `docs/canon/AGENT-INTERACTION-CANON.md` (full 14-section text).
- Reference: `docs/canon/violations-2026-05-04.md` (13 violations as test cases).
- Design: `docs/canon/conversation-guard-design.md` (G-CANON-01 architecture).
- Source session: `CarmiBanxe/banxe-emi-stack` 2026-05-03 → 2026-05-04, main HEAD `ee4e0d7`.
- Guardian-shim: `CarmiBanxe/banxe-emi-stack/infra/guardian-shim/`, commits `c6685c5` + `5ef4601`.
- Tag witnessing the source session's success: `cass15-iam-cutover-2026-05-07`.

---

## §3.1 Whitelist — safe commands (no confirmation required)

A command is safe (requires no operator confirmation) when ALL of the following hold:

- **Read-only / idempotent.** Does not mutate state outside process memory: `git status`, `git log`, `git diff`, `gh pr view`, `gh pr checks`, `cat`, `ls`, `grep`, `find`, `curl -X GET`, `pytest --collect-only`, `python -m json.tool`, `wc`, `head/tail`, `systemctl status`, etc.
- **Canonical for the current task.** The command was already in a roadmap, ADR, IL, handoff doc, or earlier turn of this session.
- **Within CCF surface (§15).** Can be executed inside Claude Code, or is an explicit exception from the 5 §15 categories.
- **Does not touch ADR-031 deny-paths (§10).**
- **Does not print secrets / secret metadata (§8).**

Write / commit operations are also safe when:

- `git commit` + push to a feature branch (not `main`).
- Creating/updating a file in `docs/`, `decisions/`, `tests/`, `*.md`, `*.yaml` under an already-approved task (IL record or ADR with its formulation).
- `gh pr create` (no `--draft`) and `gh pr merge --squash` for a PR on a feature branch where CI is green (PR into `main` — admin merge is canonically permitted for docs-only PRs or when explicitly requested by operator).

Claude Code **does not ask the operator** for confirmation on any of the above: no «ok?», no «continue?», no «do you want?», no «which option?».

## §3.2 Non-safe operations (require confirmation)

Operator confirmation via explicit «yes/да/ок» in chat is required for:

1. **Destructive ops:** `rm -rf`, `git push --force`, `git reset --hard origin`, `DROP TABLE`, `truncate`, `docker volume rm`, `docker system prune`, `kubectl delete`.
2. **Modifications to `main`:** direct commit to `main`, force-push, merge non-docs PR without CI.
3. **Production writes:** changes to production DB, secrets store, IAM, payment flows.
4. **Spending money / external side-effects:** purchases, sending email, social media posts, bulk calls to paid APIs.
5. **Permission/scope changes:** sudoers edit (except single NOPASSWD on already-approved systemd unit per IL), chmod on non-CCF files, sharing creds, changing access controls.
6. **Operations outside current sprint scope:** actions in repos/directories not belonging to the active roadmap item.

## §3.3 Confirmation form

When confirmation is required per §3.2, Claude Code:

- Formulates exactly ONE short confirmation (one question line + one action line), with no alternatives, no A/B/C matrix.
- Does not duplicate the confirmation across multiple turns.
- After «yes/да/ок» executes the action with a single command and asks nothing further.

## §4.1 Best-Decision Principle

For any situation not covered by §3.2 (not requiring confirmation), Claude Code **must** select the best action itself and immediately issue the command or prompt. Prohibited:

- Asking the operator «what to choose», «waiting for confirmation», «clarify priority», «which option is preferred».
- Issuing a list of options «A / B / C» and waiting for a letter from the operator.
- Delegating an architectural decision to the operator when the canon, ADR, IL, or earlier session turns provide sufficient context for a choice.

## §4.2 Decision basis

Claude Code makes decisions based on the following priority of sources (top to bottom):

1. **Direct operator instruction in the current turn.** If the operator explicitly said «do A» — do A.
2. **Canons and invariants:** ADR-025 (this document), repo CLAUDE.md, INVARIANTS.md, ADR-031 deny-paths.
3. **Current GAP-REGISTER / INSTRUCTION-LEDGER entry.** Tracker and IL give acceptance criteria and target close date.
4. **ROADMAP / handoff docs.** Current phase and P0 item determine priority.
5. **Read-only inventory from repo.** `grep`, `cat`, `git log`, `gh pr view` — for current facts.
6. **Engineering common sense + Conventional Commits / standard software engineering practices.**

If Claude Code is uncertain based on items 1–5 — it first performs a read-only inventory (one turn), then **on the next** turn makes the decision and issues the command. It does not ask the operator between these two turns.

## §4.3 Single fallback

Only in one situation is Claude Code required to stop and ask the operator with a single line: when **none** of the 6 sources in §4.2 gives an unambiguous answer AND the decision falls under §3.2 (requires confirmation). In all other cases — acts independently.

## §4.4 No teaching

Claude Code does not explain to the operator why it is uncertain, does not write out methodology, does not teach risk matrices. The operator already knows the canon. Claude Code either issues a command or a single confirmation line per §3.3.

## §16. Shell hygiene addendum (canon 2026-05-07 edition)

1. Heredoc — всегда отдельной командой, никаких `\\` line continuations.
2. Перед `cd` на новых хостах: `test -d <path> || echo MISSING:<path>`.
3. Tooling fallback: `command -v rg || GREP="grep -RIn"`.
4. Внешние команды: всегда `timeout <N> <cmd>`.
5. Kill: `pkill -9 ... ; sleep 1 ; pgrep ... && echo STILL_RUNNING || echo KILLED` — одной строкой.
6. После merge в main: `git fetch origin main` на всех активных ветках.
7. `.gitignore` для Claude Code memory artefacts (см. banxe-emi-stack/.gitignore).
8. Default merge: `gh pr merge --auto --squash --delete-branch` вместо `--admin`.
9. CI wait: `gh pr checks <N> --watch --interval 15` вместо `sleep`.
