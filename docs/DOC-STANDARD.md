# DOC-STANDARD.md — Documentation Canon

**Version:** 1.0 | **Date:** 2026-04-07 | **Invariant:** I-29
**Owner:** CEO + CTIO | **Enforced by:** Claude Code (Developer Plane)

---

## Принцип

Документация — первоклассный артефакт разработки, наравне с кодом.
Недокументированная фича = несуществующая фича с точки зрения FCA аудита.

---

## Обязательные файлы в каждом репозитории Product Plane

| Файл | Назначение | Обновлять при |
|------|-----------|--------------|
| `README.md` | Обзор, быстрый старт | Любом изменении интерфейса |
| `CHANGELOG.md` | История версий (Keep a Changelog) | Каждом IL |
| `docs/ONBOARDING.md` | Вход нового разработчика | Изменении setup/архитектуры |
| `docs/RUNBOOK.md` | Операционные процедуры | Новом инциденте или сервисе |
| `docs/API.md` | Публичные интерфейсы | Изменении публичного API |
| `QUALITY.md` | Quality scan результаты | После каждого quality sprint |

---

## Обязательные файлы Developer Plane

| Файл | Назначение |
|------|-----------|
| `banxe-architecture/INSTRUCTION-LEDGER.md` | IL дисциплина (I-28) |
| `banxe-architecture/INVARIANTS.md` | Архитектурные инварианты |
| `banxe-architecture/docs/COMPLIANCE-MATRIX.md` | FCA compliance tracking |
| `banxe-architecture/docs/PLANES.md` | Plane архитектура (I-20) |
| `banxe-architecture/docs/DOC-STANDARD.md` | Этот файл |

---

## Стандарт модульной документации (Python)

### Module docstring — обязателен для каждого файла

```python
"""
module_name.py — Краткое описание
IL-NNN | FCA RULE / PS | repo-name

WHY THIS EXISTS
---------------
Одно-два предложения: зачем этот модуль существует,
какую FCA/бизнес проблему решает.

Architecture: ссылка на ADR или design doc
CTX-NN AMBER/GREEN — указать уровень доступа к внешним системам
"""
```

### Class docstring

```python
class FooService:
    """
    Краткое описание класса.

    FCA rule: CASS X.Y / PSD2 / etc.

    Usage:
        service = FooService(dep1, dep2)
        result = service.do_thing(input)
    """
```

### Метод — docstring только если логика неочевидна

```python
def reconcile(self, recon_date: date) -> List[ReconResult]:
    """
    Run daily reconciliation for all safeguarding accounts.
    1. Pull internal balances from Midaz via LedgerPort.
    2. Pull external balances from bank statement.
    3. Compare, classify, write to ClickHouse.
    Returns list of ReconResult (one per account).
    """
```

---

## CHANGELOG.md — формат

Следует [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) + Semver.

```markdown
## [X.Y.Z] — YYYY-MM-DD · IL-NNN · (FCA RULE если применимо)
### Added
- новые фичи
### Changed
- изменения существующего поведения
### Fixed
- bug fixes
### Removed
- удалённые фичи
### Metrics
- Tests: N/N | Coverage: XX% | (после quality sprints)
```

**Версионирование:**
- Patch (0.0.X) — bug fix, doc update, качество
- Minor (0.X.0) — новая фича, новый IL
- Major (X.0.0) — breaking change, новая плоскость, FCA milestone

---

## RUNBOOK.md — структура

```markdown
## Quick Reference          ← команды быстрого доступа
## Incident Playbooks       ← по категориям P1/P2/P3
  ### P1 · Название         ← симптом + FCA rule + шаги
  ### P2 · Название
## Scheduled Tasks          ← cron таблица
## Emergency Contacts       ← CEO, CTIO, FCA RegData
```

---

## API.md — структура

Для каждого публичного класса/функции:
- Constructor (параметры + типы)
- Публичные методы (сигнатура + пример кода)
- Dataclass fields (таблица: поле, тип, описание)
- Валидационные правила
- CLI entry points (если есть)
- Test stubs (как использовать в тестах)

---

## OpenAPI — когда обязателен

Обязателен для каждого HTTP endpoint (FastAPI, Flask, любой webhook handler).

Формат: OpenAPI 3.1, YAML, рядом с кодом (`services/*/openapi.yml`).

Минимум:
- Все endpoints задокументированы
- Схемы request/response
- Примеры (examples: секция)
- Security схема (API key, HMAC, Bearer)

---

## Правила поддержки документации

1. **Doc drift = tech debt.** Устаревшая документация хуже её отсутствия.
2. **При каждом IL** → обновить CHANGELOG.md (обязательно) + API.md (если изменился интерфейс).
3. **При новом инциденте** → добавить playbook в RUNBOOK.md до закрытия IL.
4. **Code review включает doc review.** Если фича не задокументирована → PR не принят.
5. **quality-gate.sh** проверяет: наличие обязательных файлов (`CHANGELOG.md`, `docs/`) — предупреждение если отсутствуют.

---

## Нарушение стандарта = I-29

Отсутствие обязательного doc файла в Product Plane репозитории:
- При IL review → блокирует DONE статус
- При quality-gate → WARNING (не FAIL, но видно)

*"If it's not documented, it didn't happen."*
