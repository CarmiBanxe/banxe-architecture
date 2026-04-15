---
paths: ["**/*.test.*", "**/tests/**", "validators/**"]
---

# Testing & Verification Rules — BANXE AI BANK

## ВЕРИФИКАЦИЯ (запускать перед каждым VERIFY)

```bash
curl -sf http://localhost:8095/health
curl -sf http://localhost:8181/latest?from=GBP
docker ps | grep midaz
python -m pytest tests/ -q --tb=short
python validators/validate_contexts.py
python validators/policy_drift_check.py --verify
bash scripts/il-check.sh
```

## KEY COMMITS REFERENCE

| Commit | Что |
|--------|-----|
| 3f9c03b | v7 — ALL SPRINTS COMPLETE, 663 tests |
| ad13a6f | Sprint 8 architecture docs package |
| 22201fe | ADR-013 Midaz CBS PRIMARY |
| 4c79777 | Tasks 1-3: GAP-REGISTER Sprint 8, blocks, CTX-06 |
| 9ad147c | IL-005 DONE, IL-006 opened |
| 98ca7d7 | D-RECON-DESIGN.md |

## BLOCKED TASKS PROTOCOL

При BLOCKED статусе любой IL → ОБЯЗАТЕЛЬНО добавить запись в `docs/BLOCKED-TASKS.md`
Формат: BT-NNN, задача, IL ref, blocker, тип, unblock trigger, дата, статус BLOCKED
