# ЗАПРОС В FABLE-5 — Синхронизация двух терминалов (aligned to existing canon)

Дата: 2026-07-27
От: Central Terminal (Brain) через Factory
Тип: request / open-points
Статус: ANSWERED/CLOSED — оба open-point'а закрыты ADR-175 (ACCEPTED) +
SYNC-CANON P-6 DIALOGUE-SYNC (PR #1169/#1170, merged 2026-07-28)
Ревизия: v2 — приведено к ADR-102 («одно правило — в одном месте»); покрытые
каноном пункты удалены, оставлены только реальные пробелы.

## Ссылки на существующий канон (per ADR-102)

Три опорных документа-указателя (не исчерпывающий SSOT); полный перечень
источников — в таблице покрытия ниже. Настоящий запрос их НЕ рестейтит:

- `docs/canon/SYNC-CANON.md` — шесть принципов (P-1 SYNC-BEFORE-ACT,
  P-2 LEDGER-SERIALIZE, P-3 BRANCH-NAME-VALID, P-4 TRI-PARTY SYNC-POINT,
  P-5 SSOT-FIRST, P-6 DIALOGUE-SYNC) + Actor checklists.
- `docs/adr/ADR-163-sync-canon.md` — decision record SYNC-CANON.
- `docs/adr/ADR-170-cross-terminal-registration-sync.md` — writer-lock,
  stale-main HARD gate, working-file durability.

## Пункты исходного запроса, УЖЕ покрытые каноном (удалены, только указатели)

| Был пункт | Покрыт |
|---|---|
| 1. Механизм синхронизации состояния / единый источник истины | SYNC-CANON P-1 (canonical state = fresh `origin/main` через `git show`); ADR-170 (A) stale-main HARD gate |
| 2. Разграничение ролей / чей голос исходящий, чей inbound | ADR-153 (топология A/Central/B), ADR-134 (аттрибуция), TERMINAL-ROLE-IDENTITY-CANON (**PR #1160, ратифицирован оператором при merge 2026-07-27 — см. примечание ниже**) |
| 3. Протокол очередности, недопущение параллельных конфликтов | SYNC-CANON P-2 + `main-serialize.yml`; ADR-170 (B/C) advisory writer-lock; Best-Single-Artifact (`.claude/rules/agents.md`) |
| 4. Разрешение конфликта состояний двух терминалов | SYNC-CANON P-4 (divergent baseline = STOP до re-sync; main приоритетен), P-2 escalation floor (2 rebase-churn ⇒ STOP+operator), Rule 5 append-both |
| 6. Чек-лист «перед началом работы» | SYNC-CANON §Actor checklists (Step 0 каждой сессии) |

Зависимость (закрыта): пункт 2 закрыт TERMINAL-ROLE-IDENTITY-CANON —
ратифицирован оператором при merge PR #1160 (commit `2191112`, 2026-07-27;
PR body: «operator ratifies at merge»). Frontmatter-статус документа выровнен
на ACCEPTED в этом же change-set.

## Open-points для Fable-5 — ЗАКРЫТЫ (ответ: ADR-175 + SYNC-CANON P-6)

> Оба пункта ниже отвечены и ратифицированы: open-point 1 → durable-маркер
> `docs/canon/sync/TWO-TERMINAL-SYNC-MARKER.md` + live-anchor
> `~/.banxe/two-terminal-sync.json` (ADR-175); open-point 2 →
> reconcile-each-turn + критерии self-stale (a)–(d) (SYNC-CANON P-6).
> Текст ниже сохранён как история запроса.

1. **Формат sync-маркера для ДВУХтерминального диалогового контура
   (Central↔Factory), вне PR-контекста.**
   Не покрыто существующим каноном, потому что P-4 задаёт tri-party baseline
   только «at the start of a technical work item» и фиксацию «implicit via PR
   base ref / explicit rev-parse in work log» — формата маркера для
   диалогового обмена между двумя терминалами (реле через оператора, без PR)
   канон не определяет. Нужен: формат маркера «мы синхронны на точке X»
   (sha + время + кто подтвердил), где он живёт, кто его пишет.

2. **Синхронизация РАЗГОВОРНОГО/сессионного контекста двух LLM-сессий
   (не git-состояния).**
   Не покрыто существующим каноном, потому что SYNC-CANON/ADR-163/ADR-170
   синхронизируют исключительно canonical git/ledger state; рассинхрон
   контекстов двух Claude-сессий (кто что «помнит», чьё резюме состояния
   устарело) вне их scope. Нужны: reconcile-процедура контекстов (что
   является авторитетным снапшотом: ledger? операторский бриф?) и правило,
   когда сессия обязана объявить свой контекст stale.

## Требуемый ответ от Fable-5 (сужено) — ПОЛУЧЕН

- Формат и место жизни двухтерминального sync-маркера (open-point 1) —
  дан: ADR-175 §marker + `docs/canon/sync/TWO-TERMINAL-SYNC-MARKER.md`.
- Reconcile-процедура сессионных контекстов + критерий self-declare-stale
  (open-point 2) — дан: SYNC-CANON P-6 (reconcile each turn; self-stale (a)–(d)).
- Ничего из таблицы покрытых пунктов не пере-проектировано.

## Ограничения
- Documentation/governance only; no PROD. PolyForm-NC (sandbox).
