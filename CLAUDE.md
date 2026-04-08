# ═══════════════════════════════════════════════════════════════════════════════
# BANXE AI BANK — CLAUDE.md (auto-context for Claude Code)
# Version: 2026-04-06 21:30 CEST
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

## 1a. SKILLS GOVERNANCE (добавлено 2026-04-08, IL-042)

### Определение

Skill — многократно используемая операционная процедура (не плагин), которую Claude Code вызывает для специфического класса задач. Полная матрица — `docs/SKILLS-MATRIX.md`. Операционная модель — `docs/SKILLS-OPERATING-MODEL.md`.

### Жёсткие правила (нарушение = STOP)

1. **Ни один skill не обходит quality-gate.sh** — gate всегда запускается после skill.
2. **Ни один skill не обходит инварианты I-01..I-28** — инварианты имеют высший приоритет.
3. **Ни один skill не пересекает границы репо неявно** — cross-repo действия только по явной инструкции CEO.
4. **Ни один skill не смешивает Banxe данные с GUIYON/SS1** — I-18, I-20 абсолютны.
5. **Ни один skill не запускается без IL-записи** если результатом является новая реализация (I-28).

### Приоритет (от высшего к низшему)

```
FCA regulations > Invariants I-01..I-28 > ADRs > quality-gate.sh > IL (I-28) > Skill MANDATORY > Skill ADVISORY
```

### Права доступа по умолчанию

| Plane | Skills | Ограничения |
|-------|--------|-------------|
| Developer | Все 10 | CI/CD MANDATORY; остальные per SKILLS-MATRIX.md |
| Product | Все, кроме Auto Refactor Pro на compliance контурах | CONTROLLED = CEO approval + IL |
| Standby | Все — только ADVISORY | Нет пересечения с Banxe данными (I-18, I-20) |

---

## 2. КОЛЛАБОРАНТЫ (рой агентов)

| Агент | Роль | Порт | Когда вызывать |
|-------|------|------|----------------|
| Claude Code | Lead Orchestrator | — | Всегда (координация, design docs, IL) |
| Aider | Code Agent | — | Scaffold, типизация, тесты |
| Ruflo | Review Agent | — | PR review, invariants, BC boundaries |
| MiroFish | Research Agent | :3001/:5004 | API research, changelog, feature parity |

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
| IL-007 | ReconciliationEngine + T-16..T-30 | vibe-coding 3f7060f |
| IL-008 | COMPLIANCE-MATRIX 200+ req, Ruflo 10/10 | banxe-arch a8f4b99 |
| IL-009 | banxe-emi-stack P0 skeleton 24 файла | emi ab81ecc |
| IL-010 | Frankfurter :8181 + pgAudit 17.1 deployed | emi 3400839 |
| IL-011 | mock-ASPSP :8888 + E2E CAMT.053 pipeline | emi cb782aa |

### P0 FA-01..FA-07 — все DEPLOYED ✅
| FA | Компонент | Порт / Артефакт | Статус |
|----|-----------|-----------------|--------|
| FA-01 | ReconciliationEngine (Midaz vs bank) | vibe-coding 3f7060f | ✅ |
| FA-02 | bankstatementparser CAMT.053 wrapper | services/recon/ | ✅ |
| FA-03 | dbt staging→safeguarding→fin060 | dbt/models/ (3) | ✅ |
| FA-04 | pgAudit 17.1 on banxe_compliance | postgres :5432 | ✅ |
| FA-05 | WeasyPrint FIN060 PDF generator | services/reporting/ | ✅ code |
| FA-06 | Frankfurter FX (self-hosted ECB) | :8181 | ✅ live |
| FA-07 | mock-ASPSP PSD2 (FastAPI sandbox) | :8888 | ✅ live |

### P1 — следующий фронт (после 7 May 2026)
- Payment Rails (ClearBank/Modulr) — S4, 0% → CRITICAL
- Real IBAN validation для FA-07 Phase 1 (logging + env + network isolation)
- dbt production run против реального ClickHouse
- FIN060 PDF → RegData upload
- Metabase/Superset, Great Expectations, Debezium, Temporal, Kafka

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
- **Frankfurter FX: :8181** (IL-010, 2026-04-06) | nginx: :443/:80/:8080

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
| FX rates | Frankfurter (self-hosted ECB) | ✅ IL-010 :8181 |
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

## 8. ИНВАРИАНТЫ I-01..I-28 (полный список)

> Источник истины: `INVARIANTS.md`. Нарушение любого = архитектурный дефект.

### Compliance
| # | Название | Суть |
|---|----------|------|
| I-01 | Sanctions first | Санкционная проверка — ПЕРВОЙ, до любого AML. Не переопределяется score-логикой. |
| I-02 | Blocked → REJECT | Category A (RU/BY/IR/KP/CU/MM/AF/VE-gov/Crimea/DNR/LNR) → немедленный REJECT, без score. |
| I-03 | Category B → HOLD | SY/IQ/LB/YE/HT/ML/... → минимум HOLD + EDD. Не auto-allow, не auto-reject. |
| I-04 | Amount thresholds | ≥£10k → EDD + HITL обязательны. ≥£50k crypto → High-value + MLRO. VIP не обходят. |
| I-05 | Thresholds неизменны | SAR≥85/sanctions_hit, REJECT≥70, HOLD≥40 — менять только через ADR + MLRO + CEO. |
| I-06 | Hard override | HARD_BLOCK / SANCTIONS_CONFIRMED / CRYPTO_SANCTIONS → REJECT независимо от score. |
| I-07 | Watchman minMatch=0.80 | Jaro-Winkler нижняя граница. Изменение — MLRO approval. |
| I-08 | ClickHouse TTL=5Y | FCA MLR 2017 record-keeping. Не уменьшать. |

### Операционные
| # | Название | Суть |
|---|----------|------|
| I-09 | Auto-verify | Ответы compliance/kyc/aml/risk/crypto → `localhost:8094/verify` до отправки. |
| I-10 | Нет фейков | Не упоминать LexisNexis/SumSub/Chainalysis как активные, если не подключены. |
| I-11 | OFAC RSS мёртв | С 31.01.2025 — только HTML scraper `ofac.treasury.gov/recent-actions`. |

### Архитектурные
| # | Название | Суть |
|---|----------|------|
| I-12 | Validators = SoT | `compliance_validator.py` (developer-core) — единственный policy authority. |
| I-13 | Делегирует, не дублирует | `banxe_aml_orchestrator.py` импортирует validators. Логика не дублируется. |
| I-14 | Canonical key компаний | `(jurisdiction_code, registration_number)` — не `company_number` в одиночку. |
| I-15 | Jube = internal only | AGPLv3. Любой external exposure → заменить до запуска. Reference, не dependency. |

### Привилегий
| # | Название | Суть |
|---|----------|------|
| I-16 | Training = developer/CTIO | Операторы не имеют доступа к promptfoo/adversarial/SOUL.md/thresholds. |
| I-17 | SOUL.md — только protect-soul.sh | Прямое редактирование workspace → `chattr +i` заблокирует. |
| I-18 | GUIYON исключён | Никаких shared services/routing/ports с GUIYON. |
| I-19 | Marble = internal only | ELv2 — только внутренний MLRO workflow. Managed service третьим лицам = нарушение. |
| I-20 | Контуры независимы | Каждый из 6 контуров заменяем независимо. Монолитная зависимость = баг. |

### Агентная архитектура
| # | Название | Суть |
|---|----------|------|
| I-21 | feedback_loop.py = supervised | Не применяет патчи автоматически. `--apply` предлагает → человек применяет. |
| I-22 | Level 2 не пишет в policy | Агенты внешних данных — no write в `developer-core/compliance/`. |
| I-23 | Emergency stop FIRST | Все endpoints → `emergency_stop.get_stop_state()` ДО решения. HTTP 503 при стопе. |
| I-24 | Audit log append-only | Нет UPDATE/DELETE в `safeguarding_events` / `compliance_screenings`. |
| I-25 | ExplanationBundle > £10k | `BanxeAMLResult` ≥£10k → заполненный `ExplanationBundle`. Null = FCA SS1/23 нарушение. |
| I-26 | FCA notification 72ч | Автоматическое изменение policy layer без L0 approval → incident → уведомить FCA в 72ч. |
| I-27 | Supervised, не self-improving | `feedback_loop.py` — структурированный HITL, НЕ автономное самообучение. |
| I-28 | Instruction Ledger Discipline | IL обязателен. DONE только с Proof. Hook `il_gate.py` блокирует при нарушении. |

---

## 9. COMPOSABLE-ARCH — 6 контуров

> Источник истины: `COMPOSABLE-ARCH.md`. Каждый контур независим и заменяем (I-20).

```
Request → [1 KYC] → [2 Screening] → [3 TM] → Orchestrator → AMLResult
                                                    ↓
                                HOLD/SAR → [4 Case Mgmt] → Marble case_id
                                                    ↓
                                Always  → [5 Audit] → ClickHouse
Offline:
                                [6 Training] → patches → улучшает 1-3
```

| # | Контур | Стек | Статус |
|---|--------|------|--------|
| 1 | **Onboarding / KYC** | CustomerProfile dataclass → manual workflow | ✅ baseline, Phase 3: PassportEye+DeepFace |
| 2 | **Screening (Sanctions+PEP)** | Watchman :8084 → Screener :8085 → sanctions_check.py | ✅ active; Yente :8086 → Phase 3 |
| 3 | **Transaction Monitoring** | tx_monitor.py (9 rules + Redis 24h velocity) | ✅ active; Jube :5001 = reference only |
| 4 | **Case Management / Triage** | Marble :5002/:5003 (ELv2 internal only, ADR-005) | ✅ active |
| 5 | **Audit / Reporting** | ClickHouse banxe.compliance_screenings (TTL 5Y) | ✅ active |
| 6 | **Training / Feedback Loop** | train-agent.sh → feedback_loop.py → deploy | ✅ GAP 1-5 DONE; конкурентное преимущество |

**Лицензионный риск при B2B:** Marble (ELv2) + Jube (AGPLv3) → заменить. Остальные — Apache/MIT/BSD.

---

## 10. SERVICE-MAP — GMKtec (192.168.0.72)

> Полная карта: `SERVICE-MAP.md`. Здесь — snapshot для быстрой навигации.

| Сервис | Порт | Лицензия | Статус |
|--------|------|----------|--------|
| Ollama (qwen3-banxe-v2) | 11434 | MIT | ✅ |
| OpenClaw moa-bot (@mycarmi_moa_bot) | 18789 | Commercial | ✅ |
| OpenClaw ctio-bot (Олег) | 18791 | Commercial | ✅ |
| FastAPI compliance API | 8093 | — | ✅ |
| Auto-Verify API | 8094 | — | ✅ |
| Midaz Ledger (CBS PRIMARY) | 8095 | Apache 2.0 | ✅ |
| Moov Watchman | 8084 | Apache 2.0 | ✅ |
| Banxe Screener | 8085 | — | ✅ |
| PII Proxy (Presidio) | 8089 | MIT | ✅ |
| **Frankfurter FX (ECB rates)** | **8181** | MIT | **✅ IL-010** |
| Jube TM | 5001 | AGPLv3 | ✅ ref |
| Marble API | 5002 | Apache 2.0 | ✅ |
| Marble UI | 5003 | Apache 2.0 | ✅ |
| MiroFish UI / API | 3001 / 5004 | — | ✅ |
| n8n workflows | 5678 | Fair-code | ✅ |
| ClickHouse | 9000 / 8123 | Apache 2.0 | ✅ |
| PostgreSQL (compliance) | 5432 | PostgreSQL | ✅ |
| PostgreSQL (Jube) | 15432 | PostgreSQL | ✅ |
| PostgreSQL (Marble) | 15433 | PostgreSQL | ✅ |
| Redis Stack | 6379 | BSD | ✅ |
| MongoDB rs0 (Midaz) | 5703→27017 | SSPL | ✅ |
| RabbitMQ (Midaz) | 3003 / 3004 | MPL 2.0 | ✅ |
| Ballerine KYC | 5137 / 5200 / 5201 | Apache 2.0 | ✅ |
| nginx | 443 / 80 / 8080 | MIT | ✅ |
| Yente (OpenSanctions) | 8086 | MIT | ⏳ Phase 3 |

**Cron на GMKtec:**
- `*/5` — memory-autosync + SOUL GUARD | ctio-watcher → SYSTEM-STATE.md
- `*/15` — watchdog-watcher.sh
- `0 */6` — backup-clickhouse.sh
- `0 2 * * 0` — adversarial-sim | `0 4 * * 0` — promptfoo-eval

---

## 11. P0 CASS 15 — STACK MAP

> Repo: `CarmiBanxe/banxe-emi-stack` | Deadline: 7 May 2026 | IL-009/IL-010

```
┌──────────────────────────────────────────────────────────────┐
│              BANXE EMI — P0 ANALYTICS STACK                  │
│              FCA CASS 15 | Deadline: 7 May 2026              │
├──────────────────┬───────────────────┬───────────────────────┤
│  LEDGER          │  RECONCILIATION   │  REPORTING            │
├──────────────────┼───────────────────┼───────────────────────┤
│ Midaz :8095      │ bankstatementparser│ dbt Core              │
│ (PRIMARY CBS)    │ (CAMT.053/MT940)  │ stg→safeguarding→     │
│ LedgerPort ABC   │ ReconciliationEng │ fin060_monthly        │
│ get_balance()    │ StatementFetcher  │ WeasyPrint            │
│ I-28: LedgerPort │ threshold £1.00   │ → FIN060 PDF          │
│ only, no HTTP    │ MATCHED/DISC/PEND │ → RegData upload      │
├──────────────────┼───────────────────┼───────────────────────┤
│  AUDIT TRAIL     │  FX / RATES       │  INFRASTRUCTURE       │
├──────────────────┼───────────────────┼───────────────────────┤
│ pgAudit          │ Frankfurter :8181 │ PostgreSQL 17 :5432   │
│ ClickHouse :9000 │ (self-hosted ECB) │ ClickHouse :9000      │
│ (5yr TTL, I-24)  │ 160+ currencies   │ Redis :6379           │
│ safeguarding_    │ ✅ DEPLOYED IL-010 │ n8n :5678             │
│ events table     │ GBP→EUR 1.1461    │                       │
└──────────────────┴───────────────────┴───────────────────────┘
                   adorsys PSD2 Gateway (Phase 2 — FA-07)
                   → CAMT.053 bank statement auto-pull
```

| FA | Компонент | Статус | IL |
|----|-----------|--------|----|
| FA-01 | ReconciliationEngine (Midaz vs bank) | ✅ code | IL-007 |
| FA-02 | bankstatementparser (CAMT.053) | ✅ wrapper | IL-009 |
| FA-03 | dbt Core (staging→safeguarding→fin060) | ✅ models | IL-009 |
| FA-04 | pgAudit | ✅ **DEPLOYED** pgaudit 17.1 | IL-010 |
| FA-05 | WeasyPrint FIN060 PDF | ✅ code | IL-009 |
| FA-06 | Frankfurter FX :8181 | ✅ **DEPLOYED** | IL-010 |
| FA-07 | mock-ASPSP FastAPI :8888 | ✅ **DEPLOYED** (sandbox) | IL-011 |

**Safeguarding accounts (ADR-013):**
- client_funds: `019d6332-da7f-752f-b9fd-fa1c6fc777ec`
- operational:  `019d6332-f274-709a-b3a7-983bc8745886`
- RECON_THRESHOLD_GBP = 1.00 | Cron: `0 7 * * 1-5`

---

## 12. ВЕРИФИКАЦИЯ (запускать перед каждым VERIFY)

```bash
curl -sf http://localhost:8095/health
curl -sf http://localhost:8181/latest?from=GBP
docker ps | grep midaz
python -m pytest tests/ -q --tb=short
python validators/validate_contexts.py
python validators/policy_drift_check.py --verify
bash scripts/il-check.sh
```

## 13. KEY COMMITS REFERENCE

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
# При BLOCKED статусе любой IL → ОБЯЗАТЕЛЬНО добавить запись в docs/BLOCKED-TASKS.md
# Формат: BT-NNN, задача, IL ref, blocker, тип, unblock trigger, дата, статус BLOCKED
# ═══════════════════════════════════════════════════════════════════════════════
