---
paths: ["src/compliance/**", "src/aml/**", "validators/**"]
---

# Compliance Rules — BANXE AI BANK

## ИНВАРИАНТЫ I-01..I-28 (полный список)

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

## COMPOSABLE-ARCH — 6 контуров

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

## HARD CONSTRAINTS (FinDev Agent)

1. НИКОГДА не использовать технологии из санкционных юрисдикций (РФ, Иран, КНДР, Беларусь, Сирия)
2. НИКОГДА не использовать `float` для денежных сумм — только `Decimal`
3. НИКОГДА не хранить секреты в коде — только `.env` / Vault
4. ВСЕГДА логировать каждое действие с финансовыми данными (pgAudit / ClickHouse)
5. НИКОГДА не использовать платные SaaS без self-hosted альтернативы в production
