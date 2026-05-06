# SNAPSHOT-2026-05-06 — Progress Checkpoint EMI BANXE AI BANK

**Дата:** 2026-05-06 10:00 CEST  
**Локация:** Antibes, FR  
**Тип:** Progress Snapshot (не handoff, не ADR)  
**Базовый чекпоинт:** `checkpoint-2026-05-06-adr027-accepted`  
**Новый тег (после merge):** `checkpoint-2026-05-06-progress-snapshot`

**Цель документа:** зафиксировать текущее состояние «что выполнено / что предстоит» как опорную точку для дальнейшего наращивания roadmap-блоков. Каждый последующий блок добавляется append-only, без перезаписи этого файла.

---

## 1. Что уже выполнено

### Ядро EMI (banxe-emi-stack)
- 27+ сервисов: ledger, payment, kyc, aml, recon, reporting, iam, auth, fraud, safeguarding, consumer_duty, hitl, events, webhooks, notifications, statements, agreement, customer, case_management, complaints, resolution, providers, config, arl, design_pipeline, banxe_mcp, customer_lifecycle.
- Тесты зелёные (~1931+ тестов), ruff clean, semgrep clean, покрытие ~89%.
- Protocol DI pattern (Port → Service → Adapter) выдержан во всех сервисах.
- ClickHouse audit (5yr TTL), pgAudit на всех Postgres БД.
- InMemory-стабы для всех портов — CI не требует внешних сервисов.

### Инфраструктура на evo1 (192.168.0.72) — live
| Компонент | URL/Port | Статус |
|---|---|---|
| Keycloak 26.2 | :8180 | live, realm banxe-emi |
| PostgreSQL 17 | :5432 | live, pgAudit active |
| ClickHouse | :9000/:8123 | live, 5yr TTL |
| Redis | :6379 | live |
| RabbitMQ | :5672/:15672 | live |
| Ballerine | :3000 | live (KYC) |
| Jube | :5001 | live (fraud scoring) |
| Marble | :5002 | live (TM/AML) |
| Frankfurter | :8080 | live (ECB FX, self-hosted) |
| n8n | :5678 | live (workflows) |
| Midaz | :8095 | live (CBS ledger) |
| PII Proxy | :8000 | live |
| Guardian (LucidShark) | ENFORCE mode | active, shim wired |
| LiteLLM | :4000 | live, local model aliases |

### Архитектурный канон (banxe-architecture)
- 28+ ADR (ADR-001..035, часть Proposed, ADR-027 Accepted).
- Инварианты I-01..I-36 задокументированы и machine-enforced (semgrep).
- GAP-REGISTER.md: G-CASS-01 закрыт, остальные gaps актуализированы.
- INSTRUCTION-LEDGER.md ведётся, IL нумерация консистентна.
- ArchiMate-диаграммы, COMPLIANCE-MATRIX, COMPOSABLE-ARCH.
- Governance: канон §0..§18 в CLAUDE.md.

### Регуляторная база
- FCA CASS 15 §15.10 — ежедневная reconciliation + FIN060 generation.
- SAR auto-filing pipeline (MLRO L4 gate).
- Consumer Duty PS22/9 — сервис + тесты.
- DORA Art.14(2) — audit durability via ADR-027 (Accepted).
- MLR 2017 / FCA MLR — AML/KYC сервисы live.

### AI / Security
- Keycloak realm `banxe-emi` — единый IdP для всех сервисов.
- LiteLLM с локальными alias-ами (Ollama + API gateway).
- Guardian в режиме ENFORCE — bash-shim активен для Claude Code.
- 34 MCP-инструмента в banxe_mcp/server.py.
- ARL (Agent Routing Layer): Haiku/Sonnet/Opus tier routing.
- HITL gates: SAR_filing (L4), AML_threshold_change (L4), PEP_onboarding (L4).

### ADR-027 (Audit-trail durability) — Accepted ✅
- `BufferedAuditPort` (SQLite ring-buffer) — PR #66, 8 тестов.
- DI wiring + `AUDIT_FAIL_CLOSED` — PR #67, 4 теста.
- Drain cron script + smoke — PR #68, 3 теста.
- G-CASS-01 закрыт, ADR-027 перешёл в Accepted (2026-05-06).

### ADR-028 (KYC re-verification triggers) — в работе 🔄
- Step 1: `ROLE_CHANGED`, `BENEFICIAL_OWNER_CHANGED`, `JURISDICTION_CHANGED` + `KycReTriggerEvent` + `build_kyc_retrigger_event()` — PR #69 (open).
- Step 2: wiring в `KYCLifecycleEngine.notify_attribute_change()`, auto-suspend для CRITICAL, 6 integration tests — PR #70 (open).
- Осталось: Step 3 (cron/CI smoke) + Step 4 (flip ADR→Accepted, G-KYC-01/02 close).

---

## 2. Что предстоит сделать

### ADR-028..035: закрытие по 4-шаговому шаблону (port → wire → cron/CI → flip Accepted)

| ADR | Тема | Статус | Осталось шагов |
|---|---|---|---|
| ADR-028 | KYC re-verification triggers (G-KYC-01/02) | Step 2 in flight | 2 (Step 3 cron + Step 4 flip) |
| ADR-029 | Postgres backup strategy | Proposed | 4 шага |
| ADR-030 | Auth rate-limit policy | Proposed | 4 шага |
| ADR-032 | Secret rotation policy | Proposed | 4 шага |
| ADR-033 | Alert routing strategy | Proposed | 4 шага |
| ADR-034 | Webhook reliability KYC | Proposed | 4 шага |
| ADR-035 | CI smoke-gate policy | Proposed | 4 шага |

### Phase 5 — Advanced Features
- Multi-agent protocol (OpenClaw-MOA координация).
- Real-time dashboard (Metabase/Superset self-hosted).
- Telegram-бот (IL-TG-01, ADR-002 scope).
- FCA Section 4 reporting (расширение FIN060).
- MI reports (Management Information, CFO/MLRO).

### Phase 6 — Crypto Block
- Neuronext / fiat↔crypto bridge.
- Travel Rule (FATF Rec. 16, VASP-to-VASP).
- Crypto AML (chain analysis, on-chain monitoring).
- Cross-entity reconciliation (crypto+fiat).

### Открытые промпты
- prompts/19..23 (в banxe-architecture/prompts/ или эквиваленте).
- ARCHITECTURE-18-COMPLIANCE-KB.md (Compliance KB финальный промпт).

### Phase 7 — Testing & QA
- E2E onboarding flow (Ballerine → KYC → Activate → Payment).
- Регрессия по платёжным сценариям (CAMT.053, MT940).
- Compliance сценарии (SAR, EDD, PEP, jurisdiction block).
- AI-бенчмарки (ARL routing latency, HITL timeout SLA).
- Нагрузочное тестирование (recon engine, FIN060 batch).

### Phase 8 — Production Readiness
- Security hardening (pentest scope, OWASP top-10 audit).
- DR план (evo1 failover, backup restore drill).
- Monitoring/alerting (Prometheus + Grafana, PagerDuty webhook).
- Doc audit (stale ADR, missing runbooks, API changelog gaps).
- Go-live checklist (FCA pre-launch sign-off).

### Operator gates (ручные шаги)
| Gate | Описание | Блокирует |
|---|---|---|
| Phase F | KC dev-file → Postgres live (миграция KC storage) | IAM prod hardening |
| Phase G | Session timeout hardening (KC token TTL) | Security audit |
| G-IAM-09 | Миграция KC-pg на shared managed Postgres | Phase F + infra |

### Внешние ключи и интеграции (ожидают)
| Сервис | Что нужно | Где используется |
|---|---|---|
| Modulr | API key + sandbox onboarding | Payment adapter |
| Companies House | API key | KYC/KYB corporate |
| OpenCorporates | API key | KYC/KYB corporate |
| Sardine.ai | API key | Fraud scoring (supplement Jube) |
| Telegram Bot | Bot token | ADR-002, уведомления |
| Marble | API key + INBOX_ID | TM/AML alerts |
| Jube | Production password | Fraud scoring live |

---

## 3. Якоря для продолжения работы

| Якорь | Значение |
|---|---|
| Активные PR в banxe-emi-stack | #69 (ADR-028 Step 1), #70 (ADR-028 Step 2) |
| Последний Accepted ADR | ADR-027 (audit-trail durability) |
| Активный ADR в реализации | ADR-028 Step 2 in flight (PR #70) |
| Базовый тег для resume | `checkpoint-2026-05-06-adr027-accepted` |
| Новый тег (после merge этого PR) | `checkpoint-2026-05-06-progress-snapshot` |
| Следующий ADR шаг | ADR-028 Step 3 — cron/CI smoke (branch: `feat/adr-028-step3-drain-cron`) |
| После ADR-028 закрытия | ADR-029 Postgres backup strategy |

---

## 4. Протокол наращивания roadmap

Каждый последующий блок, который оператор добавляет:

1. Оформляется отдельным коммитом и отдельным PR в banxe-architecture.
2. Обновляет этот документ в разделе **«Дополнения»** (append-only, новые записи внизу).
3. Обновляет соответствующий раздел в ROADMAP.md (если применимо).
4. **Никаких перезаписей** предыдущих блоков — только append.
5. После merge — оператор ставит тег по канону §18:
   ```bash
   git -C ~/banxe-architecture tag -a <tag-name> -m "<message>" && \
   git -C ~/banxe-architecture push origin <tag-name>
   ```

---

## 5. Дополнения

*(append-only — новые записи ниже этой строки)*

## Подтверждение фиксации в ROADMAP

- Дата фиксации: 2026-05-06 (CEST).
- Тег: `checkpoint-2026-05-06-progress-snapshot` → коммит `24ad91a` (PR #97).
- Запись в `ROADMAP.md` → раздел `## Checkpoint registry`.
- Статус: ACTIVE (является текущей опорной точкой для последующих блоков roadmap).
