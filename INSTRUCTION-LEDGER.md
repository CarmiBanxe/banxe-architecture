# INSTRUCTION-LEDGER.md — Реестр инструкций CEO/CTIO

> **Append-only.** Claude Code обязан обновлять после КАЖДОГО шага.
> CEO проверяет перед акцептом. Инвариант I-28.
> Статус DONE только при наличии Proof (команда + вывод).

---

## Формат записи

| Поле | Описание |
|------|----------|
| IL-NNN | Уникальный ID инструкции |
| Источник | CEO / CTIO / auto |
| Дата | ISO timestamp |
| Инструкция | Дословный текст CEO |
| Шаги | Разбивка на атомарные шаги |
| Статус | PENDING → IN_PROGRESS → VERIFY → DONE / FAILED / BLOCKED |
| Proof | Команда + её вывод (доказательство исполнения) |
| Deviation | Отклонение от инструкции (если было) |
| Blocker | Что помешало (если FAILED/BLOCKED) |

---

## ТЕКУЩИЕ ИНСТРУКЦИИ

### IL-001: DEF-002 — починить midaz-ledger healthcheck
- **Источник:** CEO, 2026-04-06
- **Инструкция:** Починить midaz-ledger UNHEALTHY (distroless/static = no curl)
- **Шаги:**
  1. Диагностика: docker logs → ✅ distroless/static-debian12, нет curl
  2. Создать Dockerfile.midaz-healthcheck (alpine/curl → COPY) → ✅
  3. Попытка docker build + healthcheck YAML → ❌ musl/static несовместимость
  4. DEF-002 workaround: `healthcheck: disable: true` → ✅
  5. Внешний cron `/usr/local/bin/midaz-healthcheck.sh` каждые 2 мин → ✅
  6. Верификация: `curl http://127.0.0.1:8095/health → "healthy"` → ✅
  7. git commit + push → ✅
- **Статус:** DONE ✅
- **Proof:** `ssh gmktec "curl -sf http://127.0.0.1:8095/health"` → `"healthy"`
- **Deviation:** Попытка alpine/curl layer (провалилась из-за musl). Итоговое решение: `disable:true` + external cron.

---

### IL-002: Block J Phase 1 — Safeguarding accounts (FCA CASS 7)
- **Источник:** Архитектурный план, deadline 7 May 2026
- **Инструкция:** Создать в Midaz: BANXE LTD org → Safeguarding Ledger → GBP asset → client_funds + operational accounts
- **Шаги:**
  1. Создать организацию BANXE LTD → ✅ `019d6301-32d7-70a1-bc77-0a05379ee510`
  2. Создать Safeguarding Ledger → ✅ `019d632f-519e-7865-8a30-3c33991bba9c`
  3. Создать GBP asset → ✅ `019d632f-7c06-75e0-9a49-8249da13f609`
  4. Создать client_funds account (liability) → ✅ `019d6332-da7f-752f-b9fd-fa1c6fc777ec`
  5. Создать operational account (asset) → ✅ `019d6332-f274-709a-b3a7-983bc8745886`
  6. Задокументировать в ADR-013 → ✅
- **Статус:** DONE ✅
- **Proof:** IDs выше — реальные ответы Midaz API. ADR-013 committed.
- **Deviation:** нет

---

### IL-003: LedgerPort ABC + MidazLedgerAdapter
- **Источник:** Архитектурный план Sprint 8 (G-16)
- **Инструкция:** Создать hexagonal port для CBS + адаптер для Midaz + тесты
- **Шаги:**
  1. `src/compliance/ports/ledger_port.py` → ✅ ABC с 6 методами
  2. `src/compliance/adapters/midaz_adapter.py` → ✅ MidazLedgerAdapter
  3. `src/compliance/test_midaz_adapter.py` → ✅ 14 pytest с mock
  4. git commit → ✅
- **Статус:** DONE ✅
- **Proof:** `ls /data/vibe-coding/src/compliance/ports/` = 5 файлов включая ledger_port.py
- **Deviation:** create_transaction → NotImplementedError (Transaction API pending)

---

### IL-004: Instruction Ledger System (I-28)
- **Источник:** CEO, 2026-04-06
- **Инструкция:** Создать IL-систему с 4 уровнями принуждения: CANON → INVARIANTS → CLAUDE.md → Hook
- **Шаги:**
  1. `banxe-architecture/INSTRUCTION-LEDGER.md` (этот файл) → ✅
  2. `banxe-architecture/scripts/il-check.sh` → ✅
  3. I-28 в `INVARIANTS.md` → ✅
  4. `vibe-coding/.claude/hooks/il_gate.py` (PreToolUse) → ✅
  5. Обновить `vibe-coding/.claude/settings.json` → ✅
  6. KA-11 в `vibe-coding/canon/modules/CORE.md` → ✅
  7. `vibe-coding/.claude/CLAUDE.md` создан (EXECUTION DISCIPLINE) → ✅
  8. Обновить `load_architecture.py` (IL open count) → ✅
  9. git commit + push → ✅ vibe-coding de05204, banxe-architecture 8f9148d
- **Статус:** DONE ✅
- **Proof:** `git push` → vibe-coding de05204, banxe-architecture 8f9148d
- **Deviation:** I-27 занят (feedback_loop.py). Используется I-28. `.claude/CLAUDE.md` создан как новый файл (не prepend к корневому CLAUDE.md) — это правильная точка которую Claude Code читает как проектный override.

---

### IL-005: Итог архитектурного спринта (STOP-order)
- **Источник:** CEO STOP-order, 2026-04-06
- **Инструкция:** "нужно остановиться и подвести итог архитектурному спринту и выставленному ТЗ"
- **Шаги:**
  1. Собрать данные: порты, контексты, хуки, ADR, инварианты, контейнеры → ✅
  2. Написать отчёт в установленном формате → ✅ (отчёт выдан CEO)
  3. Акцепт CEO + verdict → ✅
  4. Task 1: GAP-REGISTER.md Sprint 8 → ✅ (diff показан CEO перед коммитом)
  5. Task 2: docs/blocks-sprint8.md → ✅ (138 строк, блоки A-J)
  6. Task 3: domain/context-map.yaml CTX-06 → ✅ (AMBER, LedgerPort, safeguarding IDs)
  7. git commit + push → ✅ 4c79777
  8. Task 4: D-recon / Transaction API → ⏳ PENDING CEO акцепт
- **Статус:** DONE ✅
- **Proof:** `git push → banxe-architecture 4c79777` (234 вставки, 4 файла)
- **CEO Акцепт:** 2026-04-06 17:15 CEST (verified commit 0cc9940)
- **Deviation:** blocks B, E, G, H, I — NOT_DEFINED в ADR-013/014. Зафиксировано явно в blocks-sprint8.md.
- **Ruflo flow il-005-sprint8-docs.yaml:** DEFERRED (описание процесса, не артефакт)

---

### IL-006 — Block D: Transaction API + Reconciliation Design
- **Источник:** CEO акцепт 2026-04-06 17:15 CEST
- **Приоритет:** P1 (Block J deadline 7 May 2026 зависит от D)
- **Шаги:**
  1. MiroFish: исследовать Midaz Transaction API endpoints + DSL → ✅ `docs/midaz-transaction-api-research.md`
  2. Aider: реализовать LedgerPort.create_transaction() + list_transactions() → ⏳
  3. Aider: frozen dataclass TransactionRequest / TransactionResponse → ⏳
  4. Aider: тесты T-01..T-15 (CTX-06 AMBER, G-16) → ⏳
  5. Claude Code: D-RECON-DESIGN.md (ClickHouse ↔ safeguarding recon) → ✅ commit 98ca7d7
  6. Ruflo: review I-28 + CTX-06 boundary + safeguarding flow → ⏳
  7. git commit + push → ⏳
  8. CEO verify → ⏳
- **Статус:** IN_PROGRESS
- **Proof:** Step 1: `docs/midaz-transaction-api-research.md` (MiroFish, 55 tool uses, endpoints + DSL + errors). Step 5: commit 98ca7d7.
