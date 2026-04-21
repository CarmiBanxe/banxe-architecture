# ═══════════════════════════════════════════════════════════════════════════════
# BANXE AI BANK — CLAUDE.md (auto-context for Claude Code)
# Version: 2026-04-15 (refactored to .claude/rules/)
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

## 3. ТЕКУЩЕЕ СОСТОЯНИЕ — P0 CASS 15 COMPLETE ✅ (2026-04-06)

### IL-001..IL-011 — ALL DONE ✅
| IL | Задача | Commit |
|----|--------|--------|
| IL-001 | Midaz healthcheck fix | — |
| IL-002 | Safeguarding accounts (ADR-013) | — |
| IL-003 | LedgerPort ABC + MidazAdapter | — |
| IL-004 | Instruction Ledger System (I-28) | — |
| IL-005 | Sprint 8 итог | 4c79777 |
| IL-006 | Transaction API T-01..T-15 | 8ae7dd0 |
| IL-007 | ReconciliationEngine + T-16..T-30 | 3f7060f |
| IL-008 | COMPLIANCE-MATRIX 200+ req, Ruflo 10/10 | a8f4b99 |
| IL-009 | banxe-emi-stack P0 skeleton 24 файла | ab81ecc |
| IL-010 | Frankfurter :8181 + pgAudit 17.1 deployed | 3400839 |
| IL-011 | mock-ASPSP :8888 + E2E CAMT.053 pipeline | cb782aa |

### P1 — следующий фронт (после 7 May 2026)
- Payment Rails (ClearBank/Modulr) — S4, 0% → CRITICAL
- Real IBAN validation для FA-07 Phase 1
- dbt production run против реального ClickHouse
- FIN060 PDF → RegData upload

## 5. АРХИТЕКТУРА CBS

ADR-013: Midaz PRIMARY, Fineract FALLBACK. Composable, НЕ монолит.
LedgerPort (Hexagonal): методы определены (G-16 pattern).
I-28: все CBS операции через LedgerPort, прямые HTTP ЗАПРЕЩЕНЫ.

---

## SESSION CONTINUITY PROTOCOL (инвариант — нарушение = P1 дефект)

После завершения ЛЮБОЙ задачи: проверить незавершённый план:
```bash
grep -c "pending\|⏳\|IN_PROGRESS" /home/mmber/banxe-architecture/INSTRUCTION-LEDGER.md
```
Напомнить CEO о незавершённых задачах. При старте новой сессии — первое сообщение:
```
🔄 Восстановление контекста... Последний IL: IL-0XX | Тесты: NNN/NNN
📋 Незавершённый план: N задач (P0 дедлайн: 7 мая — safeguarding)
Продолжить с Задачи N или есть другие приоритеты?
```

### Текущий активный план:
| # | Задача | Приоритет | Статус |
|---|--------|-----------|--------|
| 1 | Safeguarding deploy GMKtec (systemd timer, n8n shortfall alert) | P0 CASS 7 May | ⏳ IL-043 |
| 2 | FastAPI REST API Layer (9 routers, JWT, dependency injection) | P1 | ⏳ |
| 3 | Notification Service S17-03 | P1 | ⏳ |
| 4 | Redis VelocityTracker (sorted sets, 24h/30d windows) | P1 | ⏳ |
| 5 | Fraud + AML Pipeline Wiring S9-05 | P1 | ⏳ |
| 6 | Consumer Duty S9-06 FCA PS22/9 | P1 | ⏳ |

---

## Полные правила: см. `.claude/rules/*.md`

- `compliance.md` — Invariants I-01..I-28, Hard Constraints, 6 контуров
- `infrastructure.md` — GMKtec ports, SERVICE-MAP, open-source stack
- `agents.md` — Skills Governance, Orchestration, FinDev Agent
- `cass15.md` — P0 Stack Map, FA-01..FA-07, safeguarding accounts
- `testing.md` — верификация, key commits, blocked tasks protocol
- `approval-rules.md` — авто-одобрение команд
- `gsd-methodology.md` — GSD 7 фаз, IL формат
- `safety-rules.md` — запрещённые действия

## Quality Hook (BUG-006)
Activate LucidShark/Semgrep pre-commit: `git config core.hooksPath .githooks`

# Агенты: читать INSTRUCTION-LEDGER.md → ACCEPTED → работать → VERIFY → DONE
