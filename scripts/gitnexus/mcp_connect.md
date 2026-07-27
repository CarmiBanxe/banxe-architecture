# mcp_connect.md — инструкция ОПЕРАТОРА по подключению GitNexus MCP (не автозапуск)

> LICENSE DISCLAIMER: GitNexus = **PolyForm-Noncommercial-1.0.0**. Sandbox/TRAINING — без лицензии.
> **PROD/commercial use requires a purchased GitNexus license.**
> ⚠ Это ИНСТРУКЦИЯ, не исполняемый скрипт. По директиве (GITNEXUS-CODE-CONTOUR-DIRECTIVE.md, стр.47)
> подключение MCP выполняет ОПЕРАТОР/ИНФРА — фабрика живой MCP-конфиг не трогает.
> BANXE_ENV=sandbox · data_class=TRAINING · PROD_READY=false.

## (a) Установка GitNexus (оператор)

1. Лицензионная развилка ДО установки:
   - **sandbox** (текущий режим) — установка и использование без лицензии допустимы;
   - **prod/commercial** — СНАЧАЛА покупка лицензии у автора (github.com/abhigyanpatwari/GitNexus),
     затем установка; дисклеймер обязателен в конфиге и на init.
2. Установка (пример; выбирает оператор): `npm install -g gitnexus` ЛИБО `npx gitnexus --version`
   (по политике инфры). Проверка: `command -v gitnexus && gitnexus --version`.

## (b) Применение шаблона в ~/.claude.json (оператор, вручную)

1. Открыть `config/gitnexus/mcp.gitnexus.template.json`.
2. Вручную смержить блок `mcpServers.gitnexus` в `~/.claude.json` (НЕ скриптом), заменив `<PLACEHOLDERS>`:
   команда запуска, путь реестра (`~/.gitnexus`), endpoint. `GITNEXUS_ENV` оставить `sandbox`.
3. Перезапустить сессию Claude Code (MCP-серверы читаются на старте).

## (c) Верификация (probe-контракт Phase 1)

```bash
bash scripts/gitnexus/verify_mcp.sh
```
Ожидаемый переход: ДО подключения — `NOT-CONNECTED`, exit **78** (EX_CONFIG, fail-closed);
ПОСЛЕ успешного подключения — `CONNECTED`, exit **0** (probe Phase 1: endpoint задан + binary в PATH).
Дополнительно изнутри сессии: ToolSearch по «gitnexus» должен вернуть >0 инструментов.

## (d) Rollback (оператор)

1. Удалить блок `mcpServers.gitnexus` из `~/.claude.json` (вернуть `mcpServers: {}` если он был пуст).
2. (Опционально) `npm uninstall -g gitnexus`; реестр `~/.gitnexus/` удалять только при полном отказе.
3. Проверка отката: `verify_mcp.sh` → `NOT-CONNECTED`/78.

---
*PHASE 2 (путь A) | files-only | граница: фабрика готовит — оператор подключает (стр.47).* 
