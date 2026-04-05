# banxe-architecture — Арбитр архитектурных решений

**Статус:** КАНОН  
**Владелец:** CarmiBanxe (CEO: Moriel Carmi)  
**Обновление:** 2026-04-05

---

## Назначение

Этот репозиторий — **единственный источник истины** для архитектурных решений Banxe AI Bank.

Если решение зафиксировано здесь — **ни один проект не может от него отклониться** без:
1. Создания нового ADR в `decisions/`
2. Одобрения CEO (Moriel Carmi)

## Структура

| Файл | Назначение |
|------|-----------|
| `INVARIANTS.md` | Неизменяемые правила — нельзя менять без review |
| `PRIVILEGE-MODEL.md` | Разделение: разработчик vs оператор-дублёр |
| `COMPLIANCE-ARCH.md` | AML 3-layer runtime, пороги, формулы |
| `SANCTIONS-POLICY.md` | Санкционная политика UK FCA |
| `STACK-LAYERS.md` | Слои AML стека, scoring, thresholds |
| `SOUL-TEMPLATE.md` | Эталон SOUL.md для всех агентов |
| `SERVICE-MAP.md` | Все сервисы, порты, статусы |
| `DEFERRED-PROJECTS.md` | Отложенные проекты (не делать сейчас) |
| `decisions/` | ADR — Architecture Decision Records |
| `validators/` | Скрипты проверки соответствия |

## Как использовать

### Проверить соответствие проекта
```bash
bash validators/check-compliance.sh ~/vibe-coding
bash validators/check-compliance.sh ~/developer
```

### Добавить новое архитектурное решение
1. Создай `decisions/ADR-NNN-название.md`
2. Заполни по шаблону (статус, контекст, решение, последствия)
3. Обнови соответствующий `.md` в корне
4. PR → одобрение CEO

### Изменить инвариант
Нельзя. Инварианты в `INVARIANTS.md` требуют совместного review с MLRO + CEO.

## Проекты, обязанные соответствовать

| Репозиторий | Статус проверки |
|-------------|----------------|
| `CarmiBanxe/vibe-coding` | primary |
| `CarmiBanxe/developer-core` | policy source |
| `CarmiBanxe/banxe-training-data` | corpus |
