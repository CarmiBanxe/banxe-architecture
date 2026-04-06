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

## 3. ТЕКУЩЕЕ СОСТОЯНИЕ (Sprint P2, IL-007..IL-009 in progress)

### Завершено (до 2026-04-06):
- Sprint 0-5: ALL DONE, 663 теста, 22/22 GAPs DONE
- Sprint 8 Block A: Midaz CBS DEPLOYED (midaz-ledger :8095)
- Sprint 8 Block J Phase 1: Safeguarding accounts (IL-002 DONE)
- Sprint 8 Block F: Compliance 80% DONE
- IL-006 DONE: Transaction API + T-01..T-15 (commit 8ae7dd0, Ruflo APPROVED)

### IL-007 — VERIFY (ждёт CEO акцепт):
- ReconciliationEngine + StatementFetcher + T-16..T-30 (15/15 passed)
- ClickHouse banxe.safeguarding_events table (GMKtec)
- Commit: vibe-coding 3f7060f

### IL-008 — VERIFY (ждёт CEO акцепт):
- COMPLIANCE-MATRIX.md: 15 разделов, 200+ требований (banxe-architecture a8f4b99)
- Overall EMI readiness: ~35% | Payment Rails: 0% | AI/HITL: 95%
- Ruflo: 10/10 PASS APPROVED (docs/reviews/IL-008-review.md)

### IL-009 — IN_PROGRESS (Financial Analytics Block):
- Step 1 DONE: docs/financial-analytics-research.md (47 компонентов)
- COMPLIANCE-MATRIX S16 добавлен (FA-01..FA-25)
- P0 до 7 May 2026: pgAudit, Blnk recon, bankstatementparser, dbt, JasperReports, Frankfurter, adorsys PSD2

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

### Deployed (✅ на GMKtec)
| Компонент | Решение | Порт |
|-----------|---------|------|
| CBS PRIMARY | Midaz (Lerian Studio) | :8095 |
| KYC/KYB | Ballerine | :5137/:5200/:5201 |
| KYC Rules | Marble (Checkmarble) | :5002/:5003 |
| AML/ML | Jube (AGPLv3) | :5001 |
| Sanctions | Moov Watchman + Yente | :8084/:8086 |
| Workflows | n8n | :5678 |
| AI/LLM | Ollama qwen3-banxe-v2 | :11434 |
| Audit Trail | ClickHouse (5yr TTL) | :9000 |
| PII Proxy | Presidio | :8089 |
| Agents | OpenClaw @mycarmi_moa_bot | :18789 |

### Planned / Phase 1 (P0 — до 7 May 2026)
| Компонент | Решение | IL |
|-----------|---------|-----|
| Safeguarding recon | Blnk Finance + bankstatementparser | IL-009 FA-01/02 |
| Data transforms | dbt Core + dbt-clickhouse | IL-009 FA-03 |
| DB audit | pgAudit (PostgreSQL extension) | IL-009 FA-04 |
| FCA reporting | JasperReports / WeasyPrint | IL-009 FA-05 |
| FX rates | Frankfurter (self-hosted ECB) | IL-009 FA-06 |
| Bank statement API | adorsys PSD2 gateway | IL-009 FA-07 |

### Planned / Phase 1 (P1 — Q2-Q3 2026)
| Компонент | Решение | IL |
|-----------|---------|-----|
| Payment Rails | ClearBank / Modulr BaaS | S4 |
| IDV | Sumsub + Companies House API | S5 |
| Event streaming | Apache Kafka + Flink | FA-15 |
| BI dashboards | Metabase / Apache Superset | FA-08 |
| IAM | Keycloak | FA-14 |
| Distributed tracing | Jaeger v2 | FA-13 |
| Saga/workflow | Temporal | FA-11 |

### CBS FALLBACK / Deferred
| Компонент | Решение | Trigger |
|-----------|---------|---------|
| CBS FALLBACK | Apache Fineract | Loan products needed |
| Programmable ledger | Formance Ledger | FX/marketplace flows |
| High-perf ledger | TigerBeetle | >10k TPS |
| Data lineage | OpenMetadata | Q4 2026 |
| AI finance | FinGPT / OpenBB | Q4 2026 |

## 7. FINDEV AGENT — Роль и полномочия (IL-009)

**FinDev Agent** — специализированный AI-агент для финансово-аналитического блока Banxe AI Bank.

### Специализация:
- Deployment финансово-аналитического стека (dbt, Blnk, pgAudit, JasperReports)
- FCA CASS 15 compliance: ежедневный recon, FIN060 reports, audit trail
- Интеграция компонентов через API и event-driven паттерны
- Код: Python, SQL, YAML, Docker Compose

### Hard Constraints (НЕЛЬЗЯ нарушать):
1. НИКОГДА не использовать технологии из санкционных юрисдикций (РФ, Иран, КНДР, Беларусь, Сирия)
2. НИКОГДА не использовать `float` для денежных сумм — только `Decimal`
3. НИКОГДА не хранить секреты в коде — только `.env` / Vault
4. ВСЕГДА логировать каждое действие с финансовыми данными (pgAudit / ClickHouse)
5. НИКОГДА не использовать платные SaaS без self-hosted альтернативы в production

### Приоритетная матрица (CASS 15 deadline 7 May 2026):
```
P0 (до 7 May): pgAudit, Blnk recon, bankstatementparser, dbt, JasperReports, Frankfurter, adorsys PSD2
P1 (Q2-Q3):   Metabase/Superset, Great Expectations, Debezium/Sequin, Temporal, Kafka
P2 (Q4):      Camunda 7, OpenMetadata, Airbyte, Apache Flink
P3 (Year 2+): FinGPT, OpenBB, Apache Camel, Mojaloop, Beancount
```

### Repo: `banxe-emi-stack/` (отдельный репо — IL-009 Step 2+)

## 8. ВЕРИФИКАЦИЯ (запускать перед каждым VERIFY)



```bash
curl -sf http://localhost:8095/health
docker ps | grep midaz
python -m pytest tests/ -q --tb=short
python validators/validate_contexts.py
python validators/policy_drift_check.py --verify
bash scripts/il-check.sh
```

## 9. KEY COMMITS REFERENCE

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
