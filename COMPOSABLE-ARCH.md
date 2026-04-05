# Composable Compliance Architecture — Banxe

**Версия:** 1.0 | 2026-04-05  
**ADR:** decisions/ADR-011-reference-vs-dependency.md

---

## Принцип

BANXE compliance блок — **НЕ монолит** и **НЕ "ещё один open-source AML product"**.

Это гибрид:
- Собственные validators + training/feedback loop как **ЯДРО управления**
- OpenSanctions/Yente и AMLTRIX как **ВНЕШНИЕ open components** (MIT)
- Marble/Tazama/Jube как **АРХИТЕКТУРНЫЕ ОРИЕНТИРЫ** (reference, не dependency)

---

## 6 контуров (независимых, оркестрируемых)

### Контур 1 — Onboarding / KYC

```
Input: customer documents, biometrics
Output: CustomerProfile (risk_rating, kyc_status, is_pep)
```

- Текущее: `CustomerProfile` dataclass → manual KYC workflow
- Phase 3: PassportEye (MRZ) + DeepFace (liveness) + OpenKYC
- Владелец: `vibe-coding/src/compliance/`
- Статус: baseline active, Phase 3 planned

### Контур 2 — Screening (Sanctions + PEP)

```
Input: SanctionsSubject (name, jurisdiction, aliases)
Output: RiskSignal (SANCTIONS_CONFIRMED / SANCTIONS_PROBABLE / PEP_HIT)
```

- Текущее: Watchman `:8084` → Screener `:8085` → `sanctions_check.py`
- Phase 3: OpenSanctions/Yente `:8086` (primary), Watchman (fallback)
- Владелец: `vibe-coding/src/compliance/sanctions_check.py`
- Статус: Watchman active, Yente planned Phase 3

### Контур 3 — Transaction Monitoring

```
Input: TransactionInput (amount, jurisdiction, flags)
Output: list[RiskSignal] (velocity, structuring, jurisdiction block, ...)
```

- Текущее: `tx_monitor.py` (9 deterministic rules + Redis velocity 24h)
- ML layer: Jube `:5001` (AGPLv3, **reference architecture** — см. ADR-004)
- Владелец: `vibe-coding/src/compliance/tx_monitor.py`
- Статус: deterministic rules active, Jube ML = reference only

### Контур 4 — Case Management / Triage

```
Input: AMLResult (HOLD/SAR/REJECT)
Output: Marble case_id, MLRO notification
```

- Текущее: Marble `:5002/:5003` (ELv2, internal only — см. ADR-005)
- HITL: `scripts/hitl-bridge.sh` → Marble + Telegram
- Владелец: `vibe-coding/scripts/hitl-bridge.sh`
- Statус: active

### Контур 5 — Audit / Reporting

```
Input: all AMLResult + EvidenceBundle
Output: ClickHouse compliance_screenings, SAR draft
```

- Текущее: ClickHouse `banxe.compliance_screenings` (TTL 5Y, FCA MLR 2017)
- Dashboard: CEO dashboard via FastAPI `:8090`
- SAR: `sar_generator.py` → MLRO queue → Marble
- Владелец: `vibe-coding/src/compliance/audit_trail.py`
- Statус: active

### Контур 6 — Training / Feedback Loop (**конкурентное преимущество**)

```
Corpus JSONL → feedback_loop.py → patches → check-compliance → GMKtec deploy
```

- Текущее: `train-agent.sh` → `feedback_loop.py` → auto-deploy
- 160 сценариев, 5 agent roles, promptfoo eval cron (воскресенье 04:00)
- Drift monitoring каждые 6ч, adversarial sim еженедельно
- Замкнутый контур: drift → REFUTED corpus → patch → commit → deploy
- **Ни Jube, ни Marble, ни Tazama не имеют этого. Это BANXE-only.**
- Владелец: `developer-core/compliance/training/`
- Статус: fully active, GAP 1-5 complete

---

## Оркестрация

```
Request
  → Контур 1 (KYC) → CustomerProfile
  → Контур 2 (Screening) → RiskSignal[]
  → Контур 3 (TM) → RiskSignal[]
  → banxe_aml_orchestrator.py (Layer 3) → AMLResult + EvidenceBundle
      ↓
  HOLD/SAR → Контур 4 (Case Management) → Marble case_id
      ↓
  Всегда → Контур 5 (Audit) → ClickHouse
  
Offline:
  Контур 6 (Training) → patches → Контуры 1-3 улучшаются
```

---

## Каждый контур заменяем независимо

| Контур | Заменить на | Что меняется |
|--------|------------|-------------|
| Watchman → Yente | OpenSanctions `:8086` | Только `sanctions_check.py` |
| Marble → другой CM | Apache 2.0 case manager | Только `hitl-bridge.sh` + API calls |
| Jube → собственный ML | Apache 2.0 ONNX model | Только ML scoring layer |
| ClickHouse → другое | PostgreSQL / BigQuery | Только `audit_trail.py` |

Контур 6 (Training) = независим от всех. Он улучшает контуры 1-5 через feedback, не через dependency.

---

## Лицензионная карта

| Компонент | Лицензия | Риск при B2B |
|-----------|----------|-------------|
| Ядро (validators, orchestrator) | — (собственное) | Нет |
| OpenSanctions/Yente | MIT | Нет |
| Watchman | Apache 2.0 | Нет |
| ClickHouse | Apache 2.0 | Нет |
| Marble | ELv2 | Заменить при B2B |
| Jube | AGPLv3 | Заменить при B2B/external |
| Redis | BSD | Нет |
