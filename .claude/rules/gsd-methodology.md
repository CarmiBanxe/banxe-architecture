# GSD Methodology Rule

## Generative Spec-first Development

Каждая задача ОБЯЗАТЕЛЬНО проходит 7 фаз:

### Фаза 1: SPEC
- Написать спецификацию в формате IL (Instruction Ledger)
- Формат: IL-XXX | Статус | Приоритет | Описание | Блокировки | Дата
- Статусы: OPEN -> IN_PROGRESS -> REVIEW -> DONE | BLOCKED

### Фаза 2: DESIGN
- ArchiMate / C4 диаграмма (если нужна архитектура)
- Обновить DEPARTMENT-MAP.md при изменениях в структуре

### Фаза 3: IMPLEMENT
- Код строго по спецификации
- Config-as-Data: никаких хардкод-значений

### Фаза 4: TEST
- pytest с coverage report (минимум 80%)
- ruff check для линтинга (0 errors)
- semgrep для security-анализа

### Фаза 5: REVIEW
- Автоматический code review агентом-ревьюером

### Фаза 6: DEPLOY
- rsync/git push по правилам одобрения

### Фаза 7: CLOSE
- Закрытие IL-записи (статус = DONE)
- Обновление COMPLIANCE-MATRIX.md
- Определение следующей задачи
