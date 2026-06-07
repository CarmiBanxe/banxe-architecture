# ADR-051 — Coding Execution Decision (Claude vs Local)

**Status:** Proposed (awaiting operator sanction) **Date:** 2026-06-07 **Authors:** Perplexity Factory Terminal **Invariants:** I-28, I-71, I-74, I-75, I-76 **Amendments:** TBD

## Context
Аудит Central (2026-06-07) выявил архитектурный дрейф: фабрика (spec-build.sh) вызывает `claude --` (Anthropic) напрямую, в обход LiteLLM-шва (§1.bis). Local coding-стек (Legion qwen2.5-coder 14B/7B; evo qwen3-coder-next:q4_K_M 51.7GB) простаивает. Это противоречит ADR-044 (Anthropic = fallback, primary = evo) и ADR-047 (cost-governance).

## Decision (требует санкции оператора)
Два взаимоисключающих пути:

### Опция A — Canon-as-designed (Local-primary)
- Primary coding-модель: qwen3-coder-next:q4_K_M (51.7GB, уже на evo).
- Anthropic/Claude — только fallback с Guardrail-фильтром (data-residency FCA PS25/12, UK GDPR).
- spec-build маршрутизируется через LiteLLM:4000, не `claude --` напрямую.
- Плюс: соответствие ADR-044/047, data-residency, нет простоя. Минус: зависит от починки LiteLLM (P0-B) и GPU evo2 (P1-B).

### Опция B — Claude-primary (легализация факта)
- Claude Code — основной исполнитель кода.
- Удалить мёртвый Legion coder-стек (9+4.7GB), освободить VRAM.
- Обновить ADR-044 (Anthropic из fallback в primary).
- Плюс: работает сейчас, не ждёт ремонта. Минус: cost (ADR-047), data-residency риск для регулируемых нагрузок, local-пул недоиспользуется.

### Рекомендация Factory Terminal
Опция A для регулируемых нагрузок (KYC/AML/транзакции) — обязательно (data-residency). Гибрид: A для regulated, Claude-fallback для non-regulated dev. Финальный выбор — за оператором (§16 исключение: необратимое архитектурное решение).

## Consequences
После санкции — amendment к ADR-044 + обновление spec-build routing. До санкции — статус Proposed, ремонт P0-B/P1 подготавливает инфраструктуру для обеих опций.
