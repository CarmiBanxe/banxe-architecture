# Testing Skill

## Инструменты:
- pytest -- тестирование
- ruff -- линтинг
- semgrep -- security-анализ

## Пороги:
- Coverage: минимум 80%
- Ruff errors: 0
- Semgrep findings: 0 critical

## Команды:
```
pytest --cov --cov-report=term-missing
ruff check .
semgrep --config auto
```

## Правило:
Тесты запускаются АВТОМАТИЧЕСКИ без запроса подтверждения CEO.
