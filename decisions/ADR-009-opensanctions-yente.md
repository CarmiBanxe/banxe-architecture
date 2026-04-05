# ADR-009: OpenSanctions + Yente — primary sanctions/PEP source

**Статус:** ПРИНЯТО (Phase 3)  
**Дата:** 2026-04-05  
**Автор:** Moriel Carmi (CEO)

---

## Контекст

Текущий стек использует Moov Watchman (:8084) для sanctions screening. Watchman покрывает OFAC SDN, UK CSL, EU CSL, UN CSL — достаточно для sandbox, недостаточно для production FCA authorisation.

Gaps в текущем покрытии:
- Нет глобального PEP с relatives/associates (только Wikidata)
- Нет consolidated sanctions из 30+ юрисдикций
- Нет автоматического обновления каждые 6 часов

**OpenSanctions (MIT) + Yente (MIT)** закрывают этот gap:
- 200K+ entities из OFAC, EU, UK, UN, AU, CA, JP + 20 регуляторов
- PEP из 180+ стран, включая relatives/associates
- Автообновление каждые 6 часов
- Два Docker-контейнера, on-premise, MIT license

## Решение

1. OpenSanctions + Yente → PRIMARY sanctions/PEP source
2. Watchman :8084 → FALLBACK (offline-safe, stdlib, быстрый)
3. `sanctions_check.py` обновить: сначала Yente :8086, fallback на Watchman при недоступности

**Routing:**
```
sanctions_check.py
  → POST http://localhost:8086/match  (Yente — primary)
  → fallback: GET http://localhost:8084/search (Watchman — offline-safe)
```

## Порты и данные

- Yente API: `:8086` (рядом с Watchman :8084, Screener :8085)
- OpenSanctions data: `/data/banxe/opensanctions/`
- Auto-update cron: `0 */6 * * *` (каждые 6 часов)

## Лицензия

MIT — без ограничений. Нет ни AGPLv3, ни ELv2 рисков.

## Приоритет

Phase 3 compliance — следующий после текущего. Скрипт-заглушка: `scripts/deploy-phase3-opensanctions.sh`.

## Последствия

- Закрывает commercial gap "Global PEP with relatives/associates"
- Watchman остаётся как offline резервный вариант
- SERVICE-MAP.md: Yente добавлен как PLANNED
- Миграция `sanctions_check.py` — отдельная задача в Phase 3

## Ссылки

- `SERVICE-MAP.md` — Yente :8086 (PLANNED)
- `scripts/deploy-phase3-opensanctions.sh` (заглушка)
- `DEFERRED-PROJECTS.md` — нет, это активный Phase 3
