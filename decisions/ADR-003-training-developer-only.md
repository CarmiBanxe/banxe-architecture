# ADR-003: Обучение модели — только разработчик/CTIO

**Статус:** ACCEPTED  
**Дата:** 2026-04-05  
**Автор:** Moriel Carmi (CEO)

---

## Контекст

Система включает training pipeline:
- `train-agent.sh` — запуск сценариев
- `feedback_loop.py --apply` — патчинг compliance_validator.py + SOUL.md
- `promptfoo eval` — еженедельный качественный eval
- `adversarial_sim.py` — adversarial тесты

Вопрос: может ли MLRO/оператор инициировать переобучение через Telegram-бот?

## Решение

Обучение модели = **только developer/CTIO** через Legion terminal.

Оператор **не имеет доступа** к:
- `train-agent.sh`, `apply-feedback.sh`
- `feedback_loop.py --apply`
- `protect-soul.sh update` (изменение SOUL.md)
- `promptfoo eval`, `adversarial sim`
- изменению `_FORBIDDEN_PATTERNS`, thresholds

## Причины

1. **Функции агента согласованы в структуре банка.** Изменение поведения агента — это архитектурное решение, не операционное.
2. **FCA accountability.** Изменения в AML/KYC логике должны быть трассируемы к developer с полным audit trail.
3. **Защита от prompt injection.** Если оператор мог бы инициировать переобучение через Telegram — злоумышленник мог бы влиять на модель через социальную инженерию оператора.
4. **Разделение ответственности.** Developer отвечает за корректность модели. Оператор отвечает за корректность решений по конкретным кейсам.

## Допустимая обратная связь от оператора

Оператор **может** (косвенно влиять на обучение):
- Reject кейс в Marble с комментарием → создаётся corpus entry с correction
- Escalate → MLRO note → разработчик видит паттерн → запускает train-agent.sh

Но **инициирует** переобучение всегда разработчик — сознательно, с review.

## Последствия

- SOUL.md, AGENTS.md, compliance_validator.py: изменения только через deploy scripts
- Обратная связь от оператора накапливается в corpus, но применяется разработчиком
- Telegram-бот не имеет skill для запуска eval/training
