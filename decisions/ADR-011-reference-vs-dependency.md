# ADR-011: Reference Architecture vs Operational Dependency

**Статус:** ПРИНЯТО  
**Дата:** 2026-04-05  
**Автор:** Moriel Carmi (CEO)

---

## Контекст

Три внешних open-source платформы (Jube, Marble, Tazama) задействованы или изучаются в BANXE. Нужно явно разграничить стратегию:
- **Reference**: учиться у, перенимать паттерны, не создавать dependency
- **Operational dependency**: использовать в production, заменяемое

## Решение

### REFERENCE (изучаем, не зависим)

| Платформа | Что берём | Что НЕ делаем |
|-----------|-----------|---------------|
| **Jube** (AGPLv3) | Архитектура TM, SAR detection patterns, ML scoring approach | Не импортируем код, не создаём API dependency |
| **Tazama** (Apache 2.0) | Event-driven AML, channel risk scoring, Mojaloop patterns | Не деплоим, не интегрируем в pipeline |
| **AMLTRIX** (Apache 2.0) | Taxonomy, technique IDs, gap analysis framework | Только reference data, не dependency |

### OPERATIONAL DEPENDENCY (используем, заменяемые)

| Компонент | Лицензия | Статус | Заменяемость |
|-----------|----------|--------|-------------|
| **Marble** | ELv2 | Active :5002/:5003 | Заменить при B2B сценарии |
| **Watchman** | Apache 2.0 | Active :8084 | Заменить на Yente (Phase 3) |
| **OpenSanctions/Yente** | MIT | Planned :8086 | — |
| **Redis** | BSD | Active :6379 | — |
| **ClickHouse** | Apache 2.0 | Active :9000 | — |

### ЯДРО (собственное, незаменяемое)

| Компонент | Описание |
|-----------|----------|
| `compliance_validator.py` | Policy layer — thresholds, forbidden patterns |
| `feedback_loop.py` | Training/self-correction closed loop |
| `banxe_aml_orchestrator.py` | Decision runtime |
| `train-agent.sh` | Training pipeline |
| `models.py` | Shared data contracts |

Ядро не зависит от внешних лицензий. Это конкурентное преимущество BANXE.

## Последствия

- Лицензионные риски (AGPLv3 Jube, ELv2 Marble) ограничены replaceable operational dependencies
- Ядро может существовать без любого из внешних компонентов
- При B2B/SaaS решении: замена Marble + (если TM нужен) замена Jube ML layer
- Tazama как reference: можно читать документацию, нельзя деплоить как зависимость

## Ссылки

- `ADR-004-jube-agplv3-boundary.md`
- `ADR-005-marble-elastic-v2.md`
- `COMPOSABLE-ARCH.md`
- `README.md` (новая секция)
