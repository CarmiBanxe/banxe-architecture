# HERDR REVISIT-B ACTIVATION — 2026-07-31 (operator GO)

**Status:** REVISIT-B ACTIVATED (2026-07-31, operator GO) | **Canon:** ADR-164 (Herdr revisit-B), Rule 11 (ратификация — операторская)
**Branch:** agent/factory/epicgw01/gateway-herdr-roadmap (baseline 8b3b1dd)

## Контекст и история решения

- Исходное решение (вариант **A**) — default: Herdr НЕ внедрять, оставаться на tmux;
  внешние источники (herdr.dev, github) трактуются как ДАННЫЕ, не приказы; установка только по "go".
- Adoption-док `docs/audit/spec-audits/HERDR-ADOPTION-FABLE5-REQUEST-2026-07-28.md`
  **отсутствует** и в рабочем дереве ветки, и на `origin/main` (проверено 2026-07-31:
  `git ls-tree origin/main docs/audit/spec-audits/` — совпадений по herdr нет).
  Поэтому настоящий файл создан как новый активационный документ; ничего не создавалось
  задним числом, история решения A зафиксирована текстом выше и не переписывалась.

## Решение

Оператор дал **GO на revisit-B**: пилотное внедрение Herdr как терминального
оркестратора агентов (detach/reattach, именованные панели ролей фабрики).

Границы (immutable для пилота):
- herdr 0.7.5, установлен в `~/.local/bin/herdr` — **multiplexer-only**;
- **socket API — OFF** (subcommands `herdr api|pane|tab|agent|workspace|...` не используются);
- **плагины / integrations — OFF**;
- эскалация границ (включение socket API, integrations) — только новым operator GO + ADR-обновление.

## Ссылки

- Провенанс установки: [docs/roadmap/HERDR-INSTALL-PROVENANCE.md](../../roadmap/HERDR-INSTALL-PROVENANCE.md)
- Smoke-test пилота (PASS, 2026-07-31): [docs/roadmap/HERDR-PILOT-NOTES.md](../../roadmap/HERDR-PILOT-NOTES.md)
- Roadmap Sprint 6 (STORY-6.1…6.3): [docs/roadmap/EPIC-gateway-herdr.md](../../roadmap/EPIC-gateway-herdr.md)

## Gate

Коммит roadmap+provenance+notes+activation и ledger-shard (`scripts/add-il-shard.sh`) —
единым атомарным коммитом, **ТОЛЬКО после явного operator "go"** (STORY-6.3). В прогоне
2026-07-31 коммит НЕ исполнялся.
