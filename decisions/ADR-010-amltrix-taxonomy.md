# ADR-010: AMLTRIX taxonomy — industry-standard scenario labelling

**Статус:** ПРИНЯТО  
**Дата:** 2026-04-05  
**Автор:** Moriel Carmi (CEO)

---

## Контекст

Сценарии training pipeline используют внутреннюю категоризацию A-E:
- A: Hard rules, B: Edge cases, C: Red lines, D: Routing, E: Uncertainty

Это достаточно для внутреннего использования, но затрудняет:
1. Mapping на industry standards (FATF typologies, FCA typologies)
2. Gap analysis — какие AML techniques не покрыты?
3. Red-team exercises по MITRE-стилю
4. Regulatory reporting с ссылками на typology codes

**AMLTRIX (Apache 2.0)** — JSON/CSV датасет AML technique IDs, аналог MITRE ATT&CK для финансовых преступлений. Нулевая инфраструктурная стоимость — только taxonomy reference.

## Решение

AMLTRIX technique IDs как **дополнительный taxonomy layer**. Каждый сценарий получает поле `amltrix_technique` (например `AMLTRIX-T1001`). Внутренние категории A-E сохраняются как primary.

### scenario_registry.yaml

Файл-якорь для версионирования AMLTRIX pin и описания категорий. При обновлении AMLTRIX базы — upgrade-review procedure через registry.

### Версионирование

`amltrix_version: "2024.1"` pin в `scenario_registry.yaml`. При обновлении AMLTRIX — upgrade-review: проверка новых/удалённых techniques, re-run dry-run, commit с тегом.

## Последствия

- Mapping помогает: gap analysis (какие techniques не покрыты сценариями?)
- Red-team: adversarial sim по AMLTRIX matrix
- Regulatory reporting: mapping techniques → FCA/FATF typologies
- Добавление `amltrix_technique` в existing JSON — **отдельная задача маппинга**
- Infrastructure готова: `scenario_registry.yaml` создан

## Ссылки

- `developer-core/compliance/training/scenarios/scenario_registry.yaml`
- `developer-core/compliance/training/scenarios/*.json` (mapping — отдельная задача)
- AMLTRIX: `github.com/finos/AMLTRIX`
