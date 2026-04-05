# ADR-005: Marble Elastic License V2 — граница использования

**Статус:** ПРИНЯТО  
**Дата:** 2026-04-05  
**Автор:** Moriel Carmi (CEO)

---

## Контекст

Marble Case Management (:5002/:5003) лицензирован под Elastic License V2 (ELv2). ELv2 Section 2 запрещает предоставление Marble как managed service третьим лицам или использование его для создания конкурирующего SaaS-продукта.

## Решение

1. Marble используется ТОЛЬКО для внутреннего compliance workflow BANXE
2. Текущее использование (MLRO case management, SAR review, audit trail, HITL queue) — **полностью допустимо** под ELv2
3. Если BANXE планирует compliance-as-a-service — Marble заменяется на MIT/Apache альтернативу (или собственная реализация case manager)
4. Триггер: решение CEO о compliance-as-a-service offering
5. Marble UI :5003 остаётся **основным терминалом MLRO** для текущего использования

## ELv2 допустимо / недопустимо

| Использование | Статус |
|---------------|--------|
| Internal MLRO workflow | ✅ Допустимо |
| SAR review + audit trail | ✅ Допустимо |
| HITL case queue | ✅ Допустимо |
| B2B compliance SaaS | ❌ Нарушение ELv2 Section 2 |
| Managed service для клиентов | ❌ Нарушение ELv2 Section 2 |

## Последствия

- Marble UI :5003 — рекомендованный второй терминал MLRO (см. PRIVILEGE-MODEL.md)
- Миграционный план не нужен пока нет B2B/SaaS решения
- При миграции: case management API = единственная точка изменения (hitl-bridge.sh)
- Инвариант I-19 фиксирует это правило

## Ссылки

- `INVARIANTS.md` I-19 (новый)
- `PRIVILEGE-MODEL.md` — Marble UI как терминал 2
- `decisions/ADR-002-telegram-bot-scope.md`
