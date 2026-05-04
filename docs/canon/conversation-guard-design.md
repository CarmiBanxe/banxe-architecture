# Conversation-Level Canon Guard — Design (G-CANON-01)

**Tracker:** G-CANON-01
**Target close:** 2026-05-31
**Owner:** Architecture WG
**Status:** DESIGN

## Problem

Guardian-shim (см. §12 канона) покрывает только bash-команды (~10% нарушений канона). Остальные ~90% — **semantic**, происходят на уровне chat output агента (длинные промты, переспрашивание, печать метаданных секретов, неверный scope, etc.).

Без conversation-level guard каждая новая сессия повторяет ошибки предыдущей.

## Goal

Автоматически блокировать agent output, который нарушает канон, **до** того как output отправляется оператору.

## Architecture (3 варианта)

### Вариант A — MCP server для Comet/Claude Code
- MCP server hooks в lifecycle agent output.
- Перед отправкой message оператору — POST output на canon-judge endpoint.
- Canon-judge (отдельный LLM) оценивает по 14 секциям канона.
- Если verdict=fail → output **не** отправляется, агент получает correction prompt: «нарушение §X, перепиши».
- Если verdict=pass → output идёт оператору как обычно.

**Плюсы:** Native integration с Claude Code/Comet через MCP protocol.
**Минусы:** Зависит от MCP support в client; latency ~500ms-2s на каждый output.

### Вариант B — Browser-extension hook для Comet
- Перехват DOM-events в Comet UI.
- Тот же flow что A, но через browser.
- Канал коммуникации agent ↔ canon-judge через WebSocket.

**Плюсы:** Не требует MCP support.
**Минусы:** Hacky, breaks при Comet update; работает только в Comet.

### Вариант C — Reverse proxy перед LLM API
- Все LLM API calls идут через banxe proxy (LiteLLM расширение).
- Proxy intercepts response, прогоняет через canon-judge перед return клиенту.

**Плюсы:** Universal, работает с любым LLM client.
**Минусы:** Latency на каждый response, требует control над LLM API endpoint.

## Recommended: Вариант A (MCP server)

Comet и Claude Code оба поддерживают MCP. Это canonical путь для integration без hacks.

## Components to build

### 1. canon-judge LLM service
- Input: agent output text + last 10 messages from chat history.
- Output: `{verdict: pass/warn/fail, violated_sections: [§1, §4], correction: "rewrite as one command"}`.
- Backed by `glm-air` или `qwen3.5:35b` (per ADR-031, не cloud LLM, чтобы не утекали PII через canon-judge).

### 2. MCP hook
- Registered как pre-output filter в Claude Code/Comet config.
- POST на canon-judge при каждом output.
- Block + correction OR pass-through.

### 3. Audit log
- `~/.claude/canon-guard/audit.log` (JSON-lines).
- Поля: `timestamp, output_preview, verdict, violated_sections, correction`.

### 4. Test suite
- 13 violation cases из `violations-2026-05-04.md` как pytest cases.
- Each case: input chat → expected verdict.
- Coverage gate: 100% на 13 cases перед enforce rollout.

## Modes (mirror Guardian-shim)

- `audit` (default): log only, output идёт.
- `enforce`: block on `verdict=fail`, агент получает correction.
- `off`: bypass.

## Rollout plan

1. **Week 1**: build canon-judge service + 13 test cases.
2. **Week 2**: integrate MCP hook в Claude Code config (audit mode).
3. **Week 3**: collect audit data, tune prompts.
4. **Week 4**: switch to enforce mode for known-bad patterns (#1, #2, #5, #7).
5. **Post-rollout**: gradually expand enforce coverage to all 14 sections.

## Tracker

G-CANON-01 будет добавлен в `INSTRUCTION-LEDGER.md` (Part 4/4 этого handoff).

## Cross-references

- `decisions/ADR-025-agent-interaction-canon.md` (canonical ADR).
- `docs/canon/AGENT-INTERACTION-CANON.md` (живой канон).
- `docs/canon/violations-2026-05-04.md` (13 test cases).
- `CarmiBanxe/banxe-emi-stack/infra/guardian-shim/` (bash-level backstop).
- ADR-031 (PII routing — canon-judge должен жить на local LiteLLM, не cloud).
