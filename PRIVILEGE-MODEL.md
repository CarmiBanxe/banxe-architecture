# Модель привилегий Banxe

**Статус:** КАНОН  
**ADR:** decisions/ADR-001-privilege-model.md

---

## Роль: РАЗРАБОТЧИК (developer / CTIO)

ТОЛЬКО разработчик имеет право:

- Изменять `SOUL.md`, `SKILL.md`, системные инструкции агентов
- Запускать обучение: `promptfoo eval`, `adversarial sim`, `train-agent.sh`, `feedback_loop.py --apply`
- Изменять scoring, thresholds, `_FORBIDDEN_PATTERNS` в `compliance_validator.py`
- Изменять конфигурацию агентов (`openclaw.json`, `AGENTS.md`)
- Деплоить новые версии compliance стека
- Изменять `_HARD_BLOCK_JURISDICTIONS`, `_HIGH_RISK_JURISDICTIONS`

**Каналы:** Legion terminal (Claude Code, Aider, bash scripts)  
**Инструменты:** `scripts/protect-soul.sh`, `scripts/train-agent.sh`, `scripts/apply-feedback.sh`

---

## Роль: ОПЕРАТОР-ДУБЛЁР (MLRO / Compliance Officer)

### Что оператор МОЖЕТ

- Видеть алерты (REFUTED / UNCERTAIN / HOLD) в реальном времени
- Принимать HITL-решения: approve / reject / escalate кейс
- Просматривать и управлять кейсами в Marble UI
- Читать CEO Dashboard (аналитика, SAR queue)
- Общаться с агентом через Telegram для справок по compliance
- Добавлять комментарии к кейсам, менять статус в Marble

### Что оператор НЕ МОЖЕТ

- Изменять поведение / функции агента (SOUL.md, SKILL.md, AGENTS.md)
- Запускать eval или adversarial simulation
- Изменять пороги (SAR=85, REJECT=70, HOLD=40)
- Изменять санкционные списки
- Обходить автоматические REJECT/HOLD решения

**Причина:** Функции агента согласованы в структуре банка. Оператор исполняет HITL-роль, не настраивает систему.

---

## Терминалы оператора-дублёра

### Терминал 1 — Telegram (@mycarmi_moa_bot)
- Алерты: REFUTED/UNCERTAIN/HOLD приходят push-уведомлениями
- HITL-решения через команды боту
- Справки по compliance (агент отвечает с авто-верификацией)
- **Ограничение:** текстовый интерфейс, нет UI для массовой работы с кейсами

### Терминал 2 — Marble UI (:5003) ← РЕКОМЕНДОВАННЫЙ для MLRO

**Почему Marble, а не n8n или OpenClaw:**

| Вариант | Назначение | Подходит для MLRO? |
|---------|-----------|-------------------|
| **Marble UI :5003** | Case management, SAR review, HOLD queue | ✅ Лучший выбор |
| n8n :5678 | Workflow automation (developer tool) | ❌ Не для оператора |
| OpenClaw :18789 | AI agent terminal (chat) | ⚠️ Дублирует Telegram |

**Marble UI — оптимальный выбор потому что:**
1. Специально создан для case management — HOLD queue, SAR review, approve/reject
2. Встроенный audit trail — каждое действие оператора логируется (FCA compliance)
3. Поддерживает комментарии, эскалацию, назначение кейсов
4. Агрегированный вид всех активных кейсов (не только текущий)
5. Отделяет операторскую работу от developer workflow

**Доступ:** `http://[gmktec-ip]:5003` (admin: mark@banxe.com)

---

## ADR-002: Telegram-бот — НЕ банковское приложение

Текущий Telegram-бот (`@mycarmi_moa_bot`) = **терминал оператора-дублёра**.

Telegram-бот как **банковское приложение** (для клиентов — платежи, баланс, KYC onboarding) — это **ОТДЕЛЬНАЯ инсталляция**, отдельный проект, отдельный OpenClaw instance. **Отложен.** См. `DEFERRED-PROJECTS.md`.

---

## Схема разделения

```
DEVELOPER/CTIO
    └── Legion terminal
        ├── Claude Code (архитектор, оркестратор)
        ├── scripts/train-agent.sh (обучение)
        ├── scripts/protect-soul.sh (SOUL.md)
        └── scripts/deploy-*.sh (деплой на GMKtec)

ОПЕРАТОР-ДУБЛЁР (MLRO)
    ├── Telegram (@mycarmi_moa_bot)  ← алерты + HITL + справки
    └── Marble UI (:5003)            ← case queue + SAR review + audit
```
