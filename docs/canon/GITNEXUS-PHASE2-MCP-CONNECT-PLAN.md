# GITNEXUS PHASE 2 — MCP-CONNECT PLAN (PROD-gate-спринт подключения)

> ⚠ SANDBOX / TRAINING (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false).
> **LICENSING / DISCLAIMER:** GitNexus = **PolyForm-Noncommercial-1.0.0**. Sandbox — без лицензии.
> **«PROD/commercial use requires a purchased GitNexus license»** — дисклеймер обязателен в конфиге и на init.
> Основание: `GITNEXUS-CODE-CONTOUR-DIRECTIVE.md` — стр.31 (внедрение hooks/CI-gate ТОЛЬКО через
> PROD-gate-спринт, не hotfix) + стр.47 (MCP подключает ОПЕРАТОР/ИНФРА, не фабрика).
> Phase 1 выдача: `GITNEXUS-PHASE1-CODE-CONTOUR-README.md` (probe-контракт 78→0).

## Граница ответственности (стр.47) — что подготовила фабрика vs что делает оператор

| Фабрика ПОДГОТОВИЛА (files-only, этот спринт-пакет) | ОПЕРАТОР/ИНФРА ВЫПОЛНЯЕТ (руками) |
|---|---|
| `config/gitnexus/mcp.gitnexus.template.json` — шаблон mcpServers (плейсхолдеры, sandbox-env) | Установка GitNexus (npm/npx) — ПОСЛЕ лицензионной развилки |
| `scripts/gitnexus/mcp_connect.md` — пошаговая инструкция (a)–(d) c rollback | Ручной merge шаблона в `~/.claude.json` (фабрика живой конфиг НЕ трогает) |
| `scripts/gitnexus/verify_mcp.sh` — read-only верификация (NO-MOCK) | Рестарт сессии; прогон verify (78→0); ToolSearch >0 tools |
| Phase 1: env-guard, `pre-commit.gitnexus` (chain-ready), `detect_impact.py` | Активация хука chain-call'ом (README Phase 1 §Activation); покупка лицензии при prod |

## Шаги PROD-gate-спринта (последовательно)

1. **Лицензия:** sandbox — свободно; prod — покупка у автора ДО установки (чек-лист ниже).
2. **Install (оператор):** gitnexus binary доступен в PATH (`gitnexus --version`).
3. **Connect (оператор):** ручной merge шаблона → `~/.claude.json`; `GITNEXUS_ENV=sandbox`.
4. **Verify:** `verify_mcp.sh` — переход **NOT-CONNECTED/78 → CONNECTED/0** (probe-контракт Phase 1);
   изнутри сессии ToolSearch «gitnexus» > 0 инструментов.
5. **Index (оператор запускает, фабрика сопровождает):** `npx gitnexus analyze` ТОЛЬКО по покрытым
   репо из матрицы PHASE 0 (`docs/audit/GITNEXUS-PHASE0-VERIFY-2026-07-27.md`: fleet Python-доминантен).
6. **Activate hooks:** chain-call `pre-commit.gitnexus` из активного pre-commit (двухстрочный блок,
   Phase 1 README) + PreToolUse/PostToolUse enrich/reindex — отдельным change-set через ревью.
7. **CI-gate:** `detect_impact` в pre-commit контуре; dry-run: high-risk коммит блокируется без
   `GITNEXUS_ACK=1`.
8. **Спринт-артефакт:** отчёт по acceptance-чек-листу директивы (PHASE 1 acceptance) → операторская приёмка.

## Definition of Done

- [ ] verify_mcp.sh = CONNECTED/0 (и честный 78 при откате) — NO-MOCK подтверждён
- [ ] покрытые репо проиндексированы; матрица PHASE 0 приложена
- [ ] hooks активны chain-call'ом; существующий LucidShark/ADR-120-гейт цел
- [ ] detect_impact dry-run блокирует high-risk без ACK
- [ ] лицензионный чек-лист закрыт (sandbox: free — зафиксировано; prod: purchase — до любого prod-включения)
- [ ] промт-напоминание enrich→impact→act действует (CLAUDE.md-секция, #1153)

## Лицензионный чек-лист

- [x] Sandbox-использование без лицензии — подтверждено оператором (PHASE 1 разблокировка)
- [ ] PROD: лицензия куплена (обязательное условие G-серии PROD-gate; без неё prod-включение ЗАПРЕЩЕНО)
- [x] Дисклеймер в шапках всех артефактов Phase 1/2 и на init (`DISCLAIMER` в detect_impact.py, guard в env.sh)

---
*PHASE 2 (путь A) | ENGREF01 | files-only, not committed | фабрика готовит — оператор подключает | 2026-07-27.*
