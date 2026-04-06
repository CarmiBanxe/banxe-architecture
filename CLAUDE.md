# ═══════════════════════════════════════════════════════════════════════════════
# BANXE AI BANK — CLAUDE.md (auto-context for Claude Code)
# Version: 2026-04-06 17:20 CEST
# ═══════════════════════════════════════════════════════════════════════════════

## 0. ПРЕАМБУЛА — ЧИТАЙ ПЕРВЫМ

GAP-REGISTER.md: 22/22 gaps DONE (G-09 DEFERRED), 663 теста, v7.
INVARIANTS I-21..I-28 — нарушение = БЛОКИРОВКА.
INSTRUCTION-LEDGER.md: единственный источник истины по задачам.

## 1. GOVERNANCE КАНОНЫ (НАРУШЕНИЕ = STOP)

1. Вопрос CEO → Ответ с объяснением → Акцепт CEO → Действие
2. Формат ответа: ВСЕГДА как промпт для Claude Code + коллаборанты
3. Максимальная утилизация: Task(), Bash(), Agent subspawn
4. НЕ галлюцинировать — только верифицированная информация
5. IL lifecycle: INSTRUCTION → ACCEPTED → IN_PROGRESS → VERIFY → DONE/FAILED
6. НЕТ действий без записи в IL. НЕТ "DONE" без proof.
7. CLASS_B/C (SOUL.md, rego, compliance_config) → governance gate
8. Zone RED: AI-FORBIDDEN. Zone AMBER: CLAUDE_CODE_ONLY + hooks. Zone GREEN: free.

## 2. КОЛЛАБОРАНТЫ (рой агентов)

| Агент | Роль | Порт | Когда вызывать |
|-------|------|------|----------------|
| Claude Code | Lead Orchestrator | — | Всегда (координация, design docs, IL) |
| Aider | Code Agent | — | Scaffold, типизация, тесты |
| Ruflo | Review Agent | — | PR review, invariants, BC boundaries |
| MiroFish | Research Agent | :3001/:5004 | API research, changelog, feature parity |

## 3. ТЕКУЩЕЕ СОСТОЯНИЕ (Sprint 8, Block D in progress)

### Завершено:
- Sprint 0-5: ALL DONE, 663 теста
- Sprint 8 Block A: Midaz CBS DEPLOYED (midaz-ledger :8095)
- Sprint 8 Block J Phase 1: Safeguarding accounts created
- Sprint 8 Block F: Compliance 80% DONE
- IL-005: DONE (GAP-REGISTER Sprint 8, blocks-sprint8.md, CTX-06)
- D-RECON-DESIGN.md: DONE (commit 98ca7d7)

### В работе (IL-006):
- Step 1: MiroFish — Midaz Transaction API research → 🔄
- Steps 2-4: Aider — LedgerPort.create_transaction() + tests → ⏳
- Step 5: D-RECON-DESIGN.md → ✅
- Step 6: Ruflo review → ⏳
- Steps 7-8: commit + CEO verify → ⏳

### NOT_DEFINED блоки (ждут CEO):
- B (Infra/DevOps), E, G, H, I — не определены в ADR-013/014

## 4. ИНФРАСТРУКТУРА (GMKtec EVO-X2)

Источник истины: docs/SYSTEM-STATE.md (auto-updated */5 min)
- PostgreSQL 17: :5432 — DBs: banxe_compliance, midaz_onboarding, midaz_transaction
- Redis Stack: :6379 — DB0 compliance, DB1 Midaz
- ClickHouse: :8123/:9000 — DB banxe (15 таблиц)
- Midaz Ledger: :8095→:3002 (lerianstudio/midaz-ledger:latest, 54MB)
- MongoDB 8: :5703→:27017 (replica set rs0)
- RabbitMQ 4.1.3: :3004/:3003
- Ollama: :11434 (qwen3-banxe-v2, 17.3GB)
- Marble: :5003/:5002/:15433 | Ballerine: :5137/:5200/:5201
- Jube: :5001 | n8n: :5678 | MiroFish: :3001

## 5. АРХИТЕКТУРА CBS

ADR-013: Midaz PRIMARY, Fineract FALLBACK. Composable, НЕ монолит.
LedgerPort (Hexagonal): методы определены (G-16 pattern).
CTX-06 CBS: AMBER trust zone.
I-28: все CBS операции через LedgerPort, прямые HTTP ЗАПРЕЩЕНЫ.

## 6. OPEN-SOURCE АБС СТЕК

| Компонент | Решение | Статус |
|-----------|---------|--------|
| CBS PRIMARY | Midaz (Lerian Studio) | DEPLOYED |
| CBS FALLBACK | Apache Fineract | PLANNED |
| KYC/KYB | Ballerine | DEPLOYED |
| KYC Rules | Marble (Checkmarble) | DEPLOYED |
| AML Rules | Jube | DEPLOYED |
| Sanctions | OpenSanctions/Yente | INTEGRATED |
| Workflows | n8n | DEPLOYED |
| AI/LLM | Ollama qwen3-banxe-v2 | DEPLOYED |
| Observability | ClickHouse | DEPLOYED |
| Agents | OpenClaw/MetaClaw | DEPLOYED |

## 7. ВЕРИФИКАЦИЯ (запускать перед каждым VERIFY)

```bash
curl -sf http://localhost:8095/health
docker ps | grep midaz
python -m pytest tests/ -q --tb=short
python validators/validate_contexts.py
python validators/policy_drift_check.py --verify
bash scripts/il-check.sh
```

## 8. KEY COMMITS REFERENCE

| Commit | Что |
|--------|-----|
| 3f9c03b | v7 — ALL SPRINTS COMPLETE, 663 tests |
| ad13a6f | Sprint 8 architecture docs package |
| 22201fe | ADR-013 Midaz CBS PRIMARY |
| 4c79777 | Tasks 1-3: GAP-REGISTER Sprint 8, blocks, CTX-06 |
| 9ad147c | IL-005 DONE, IL-006 opened |
| 98ca7d7 | D-RECON-DESIGN.md |

# ═══════════════════════════════════════════════════════════════════════════════
# Агенты: читать INSTRUCTION-LEDGER.md → записать ACCEPTED → работать → VERIFY → DONE
# ═══════════════════════════════════════════════════════════════════════════════
