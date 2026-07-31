# Herdr Pilot Notes — smoke-test STORY-6.1 (Sprint 6)

**Date:** 2026-07-31 | **Host:** mark-legion (WSL2) | **herdr:** 0.7.5 (`~/.local/bin/herdr`, stable, protocol 17)
**Mode:** multiplexer-only (канон ADR-164 / provenance): socket-API helpers НЕ использовались, плагины/integrations НЕ включались.
**Related:** [HERDR-INSTALL-PROVENANCE.md](HERDR-INSTALL-PROVENANCE.md), [EPIC-gateway-herdr.md](EPIC-gateway-herdr.md) §Sprint 6.

## Верdict: PASS (с задокументированными ограничениями)

## Что выполнено (фактические команды)

Config: `~/.config/herdr/config.toml` отсутствует → действуют дефолты
(prefix `ctrl+b`; detach `prefix+q`; split `prefix+v` / `prefix+minus`; rename pane `prefix+shift+p`).

1. **Старт named-сессии** (herdr-клиенту нужен TTY → обёртка tmux 3.4):
   ```
   tmux new-session -d -s herdr-smoke -x 200 -y 50 "herdr --session factory-pilot"
   ```
   Результат: сервер сессии поднялся; `herdr session list` → `factory-pilot  running  ~/.config/herdr/sessions/factory-pilot`.

2. **4 именованные панели** (keybindings через `tmux send-keys`, т.е. эмуляция оператора):
   - `C-b c` (новый tab), затем 3 сплита `C-b v` / `C-b -` и rename `C-b P <имя> Enter` для каждой панели.
   - Итоговый layout 2×2, имена видны в рамках панелей: `coding-agent`, `gateway-logs`, `watchdog`, `ops-shell`.

3. **Detach:** `C-b q` → клиент завершился (tmux-хост опустел), сервер жив:
   `herdr session list` → `factory-pilot ... running`.

4. **Reattach:** `herdr session attach factory-pilot` (в новой tmux-обёртке) →
   все 4 панели восстановлены с именами и scrollback. PASS.

5. **Cleanup:** повторный detach + `herdr session stop factory-pilot` →
   `factory-pilot  stopped`; ни одного процесса herdr не осталось.
   Повторный запуск пилота: `herdr --session factory-pilot` (или `herdr session attach factory-pilot`).

## Ограничения и наблюдения

- **Non-interactive detach/управление панелями.** У herdr ЕСТЬ CLI для панелей
  (`herdr pane split|rename|send-keys|...`, `herdr tab ...`, `herdr agent ...`), но все они
  работают «over the socket API» — вне канона multiplexer-only, поэтому НЕ применялись.
  Скриптовое управление в этом прогоне достигнуто внешней эмуляцией клавиш
  (`tmux send-keys` в tmux-обёртку, где живёт herdr-клиент). `herdr --help` подтверждает:
  detach как отдельной non-interactive команды нет; detach = keybinding `prefix+q` либо
  завершение клиента; персистентность обеспечивает server named-сессии.
- **Quirk rename:** первый `C-b P` сразу после создания tab попал в заголовок таба
  (получилось `Pcoding-agent` в tab bar) — повторный rename на сфокусированной панели
  отработал корректно. Для чистоты давать панели фокус перед `prefix+shift+p`.
- **Side effect окружения (не herdr):** каждая новая панель стартует shell, который на этом
  хосте исполняет операторский rc-скрипт (`~/OpenManus`: OLLAMA_HOST + попытка старта
  TOR-сервиса). Порождённые PID (436130/436356/436607/437230) завершились немедленно —
  устойчивый экземпляр один, давний PID 364 (существовал ДО пилота; пилот его не создавал
  и не трогал). Рекомендация для боевого layout: нейтральный cwd (`new_cwd` в config.toml)
  или отдельный rc-профиль для панелей фабрики.
- **Наследованный workspace:** сайдбар показал ранее зарегистрированный workspace
  `OpenManus` — реестр workspace-ов у herdr глобальный, named-сессия его видит.
  Для фабрики завести отдельный workspace при боевом развёртывании.

## Итог по AC STORY-6.1

| AC | Статус |
|---|---|
| herdr стартует named-сессией, status=running | PASS |
| >=4 панели с ролями coding-agent/gateway-logs/watchdog/ops-shell | PASS (4/4, имена в рамках) |
| detach `ctrl+b q` → сервер жив | PASS |
| reattach восстанавливает панели | PASS (имена + scrollback) |
| результат записан в Pilot Notes | PASS (этот файл) |
