# LOCAL-CLOUD-ROUTING.md — Claude Code Routing Policy

**Type:** Architecture Note (ADR-style)
**IL:** IL-018 | **Status:** PROPOSED
**Date:** 2026-04-07 | **Owner:** CEO
**Replaces:** N/A (new policy)

---

## Purpose

Формализовать, когда Claude Code работает через Anthropic Cloud API (cc-cloud),
а когда — через локальную модель на GMKtec (cc-local).
Установить обязательные правила для каждого режима и для каждой плоскости (Plane).

Политика не утверждает, что локальные модели эквивалентны Claude Sonnet по качеству.
Она определяет приемлемые сценарии использования каждого режима на основе верифицированных фактов.

---

## Verified Facts

**[ФАКТ] Claude Code + Ollama совместимы через Anthropic-compatible endpoint.**

Claude Code поддерживает работу с любым Ollama-сервером через переменные окружения:
```bash
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
```
Источник: официальная документация Claude Code / Anthropic API compatibility.

---

**[ФАКТ] Актуальные кандидаты для cc-local (на 2026-04-07): qwen3-coder, qwen3-coder-next, qwen3.5.**

`qwen2.5-coder` — устаревшее поколение, не рассматривать как основную рекомендацию.
`qwen3-coder`, `qwen3-coder-next`, `qwen3.5` — текущее поколение.
Источник: официальный реестр моделей Ollama.

---

**[ФАКТ] qwen3-coder:30b требует ~250 GB unified memory согласно официальному листингу Ollama.**

GMKtec EVO-X2 имеет 128 GB RAM. Это означает:
- qwen3-coder:30b нельзя запустить на GMKtec без разгрузки других сервисов.
- Более лёгкие варианты (qwen3.5, qwen3-coder меньшего размера) — возможны, но
  не тестировались в production-нагрузке Banxe.
- [НЕИЗВЕСТНО] Точные требования к памяти для qwen3-coder-next и qwen3.5 не
  верифицированы независимо на текущий момент.

---

**[ФАКТ] Anthropic не использует coding sessions для обучения без явного opt-in.**

В cc-cloud режиме контекст задачи (код, запросы, ответы) передаётся внешнему
Anthropic API. Anthropic официально заявляет, что чаты и coding sessions
не используются для обучения моделей без явного согласия пользователя
(Development Partner Program — отдельная программа с явным opt-in).
Источник: Anthropic Privacy Policy и Claude Code documentation.

**Это не означает, что код «уходит в облако навсегда»** — это означает, что
при каждом запросе контекст передаётся API и обрабатывается согласно
политике конфиденциальности Anthropic.

---

**[ФАКТ] .claudeignore и secrets hygiene обязательны в ОБОИХ режимах.**

В cc-local режиме модель работает локально, но `.claudeignore` всё равно
нужен для исключения `.env`, `secrets/`, `*.pem` из контекста.
В cc-cloud режиме — тем более.

---

## Risks

| Risk | Mode | Severity | Mitigation |
|------|------|----------|-----------|
| Sensitive data в API request | cc-cloud | HIGH | `.claudeignore`, no secrets in context |
| Деградация качества вывода | cc-local | MEDIUM | Тестировать на конкретной задаче; для compliance-critical — только cc-cloud |
| GMKtec перегрузка памятью | cc-local | MEDIUM | Контролировать `free -h` перед запуском тяжёлых моделей |
| Недоступность Anthropic API | cc-cloud | LOW | Краткосрочный fallback на cc-local для non-critical работы |
| Модель не поддерживает tool use | cc-local | MEDIUM | [НЕИЗВЕСТНО] Поддержка tool use в qwen3-coder не верифицирована полностью |

---

## Routing Policy

### banxe-emi-stack (Product Plane)

**Default: cc-cloud (Claude Sonnet)**

| Тип работы | Режим | Обоснование |
|-----------|-------|------------|
| FCA compliance code (ReconciliationEngine, BreachDetector) | **cc-cloud только** | Ошибка = FCA нарушение |
| Financial amounts, audit trail, Decimal logic | **cc-cloud только** | I-05, I-24 |
| Новые фичи, новые модули | **cc-cloud предпочтительно** | Качество критично |
| Low-risk refactoring, переименование переменных | cc-local допустим | При условии code review |
| Routine scripts, shell wrappers | cc-local допустим | Низкий риск |

[ВЫВОД] Для critical engineering/compliance work banxe-emi-stack должен оставаться на cc-cloud.
Локальные модели — кандидаты, а не гарантированная замена Claude Sonnet.
Качество qwen3-coder / qwen3.5 на compliance-специфичных задачах независимо не верифицировано.

---

### vibe-coding / banxe-architecture (Developer Plane)

**Mixed mode — разрешён.**

| Тип работы | Режим |
|-----------|-------|
| Архитектурные решения, ADR | cc-cloud предпочтительно |
| Документация, CHANGELOG, RUNBOOK | cc-local допустим |
| Hook scripts, качественный bash | cc-local допустим |
| IL-записи, COMPLIANCE-MATRIX | cc-cloud предпочтительно |

---

### guiyon / ss1 (Standby Plane)

**Default: cc-local (local-first policy)**

[ВЫВОД] Для GUIYON и SS1 cc-local выглядит уместным по следующим причинам:
- Юридические материалы (уголовные дела, апелляции) требуют data isolation
- Документы не должны покидать локальную среду
- Французское/израильское уголовное право — специфический домен, quality delta
  с cloud может быть приемлемой для drafting/research задач

[НЕИЗВЕСТНО] Насколько qwen3.5 или qwen3-coder справляется с французским/ивритом
в юридическом контексте — не тестировалось. Необходимо проверить перед
переводом в production использование.

---

## Model Matrix

| Модель | Размер | Memory (Ollama listing) | Рекомендация |
|--------|--------|------------------------|-------------|
| Claude Sonnet 4.6 | cloud | N/A | PRIMARY для Product Plane |
| qwen3-coder | TBD | [НЕИЗВЕСТНО] | Кандидат cc-local |
| qwen3-coder-next | TBD | [НЕИЗВЕСТНО] | Кандидат cc-local |
| qwen3.5 | TBD | [НЕИЗВЕСТНО] | Кандидат cc-local (текущий на GMKtec) |
| qwen3-coder:30b | 30B | ~250 GB (official) | НЕ запускать на GMKtec (128 GB RAM) |
| qwen2.5-coder | legacy | — | Устаревшее, не использовать |

**Важно:** Ни одна из локальных моделей не объявлена официально «сопоставимой с
Claude Sonnet» для coding задач. Это кандидаты с неизвестным quality delta
на compliance-specific работе.

---

## Operational Rules

### Общие (оба режима)

```bash
# .claudeignore — обязателен в корне каждого репо
.env
.env.*
secrets/
*.pem
*.key
/data/banxe/.env
```

1. `quality-gate.sh` обязателен в Product Plane **независимо от режима** (I-30 proposed).
2. Коммит только после quality gate PASS — независимо от того, cc-cloud или cc-local писал код.
3. Secrets в `.env` на GMKtec, никогда в контексте Claude Code.

### Переключение режимов

```bash
# cc-cloud (default — Anthropic API)
unset ANTHROPIC_BASE_URL
unset ANTHROPIC_AUTH_TOKEN
# claude code запускается как обычно

# cc-local (Ollama на GMKtec)
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
# Перед запуском: убедиться что нужная модель доступна
ssh gmktec "ollama list"
```

### Memory check перед cc-local (GMKtec)

```bash
ssh gmktec "free -h && ollama list"
# Убедиться что достаточно свободной памяти для модели
```

---

## Open Questions

| # | Вопрос | Приоритет |
|---|--------|----------|
| OQ-1 | Поддерживает ли qwen3-coder tool use (Edit, Bash, Read) в Claude Code? | HIGH |
| OQ-2 | Каков реальный quality delta qwen3.5 vs Sonnet на Python compliance задачах? | HIGH |
| OQ-3 | Требования к памяти для qwen3-coder (не 30b версии)? | MEDIUM |
| OQ-4 | Поддержка французского/иврита в qwen3.5 для GUIYON/SS1 юридических текстов? | MEDIUM |
| OQ-5 | Нужен ли отдельный Ollama instance для Standby Plane или достаточно текущего? | LOW |

Ответы на OQ-1 и OQ-2 необходимы перед переводом cc-local в production для Product Plane.

---

## Proposed Invariant

**I-30 (PROPOSED):** `quality-gate.sh` обязателен для Product Plane репозиториев
независимо от модельного routing режима (cc-cloud / cc-local).
Подробнее: раздел Operational Rules выше.

*Требует явного утверждения CEO перед добавлением в INVARIANTS.md.*

---

*Документ подготовлен: Claude Code | IL-018 PROPOSED | 2026-04-07*
*Источники: Anthropic Privacy Policy, Claude Code docs, Ollama model registry*

## Distributed Inference Topology (added Sprint S5 F4 2026-05-09)

> Anchor: IL-OPS-SPRINT-S5-F4-DOCUMENTATION-RECONCILIATION-2026-05-09
> Closes G-FACTORY-DISTRIBUTED-INFERENCE-NOT-IN-CANON (P2)

The BANXE LiteLLM v2 gateway routes `large`, `glm-air`, `glm-4.5-air-distributed` are backed by a **distributed inference topology** spanning evo1 + evo2 nodes via USB4 high-speed link with Vulkan compute backend.

### Components
- **glm-master.service** on evo1 (`192.168.0.72:8081/v1`) — orchestrator process serving GLM-4.5-Air 105B model (Q4_K_M quantization, gguf format `GLM-4.5-Air-Q4_K_M-00001-of-00002.gguf`).
- **llama-rpc-worker.service** on evo2 (`10.0.0.2:50052` over USB4 link) — RPC worker handling distributed shards via Vulkan compute backend.
- **api_key**: `sk-rpc-glm47-2026` (gateway-to-master).
- **Timeout**: 600s (large model inference).

### Sprint S4 F3.2 classification
- Route `large` → **project-heavy resolution candidate** per §1.bis (closes G-FACTORY-LITELLM-PROJECT-HEAVY-ROUTE-MISSING upon promotion).
- Routes `glm-air` and `glm-4.5-air-distributed` → DUPLICATE-ALIASES (recommend REMOVE per Sprint S4 F3.2 reconciliation).

### Layer assignment
- Per bootstrap canon v3 §1.bis: glm-master.service runs on evo1 (project layer node) but serves both project-heavy intent AND factory-heavy fallbacks. Operator decision pending in F3.2 phase 2 (cross-layer reconciliation).
