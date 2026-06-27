# SRC-07 — Ограничения и Guardrails

**Статус:** INGESTED
**Загружен:** 2026-06-28
**Источник:** Часть аналитического корпуса, передана оператором

---

## Содержание

### Инвариант INV-AI-01

[ФАКТ] Инвариант INV-AI-01 запрещает передачу PII в облачные LLM-провайдеры. Локальный LiteLLM-прокси (:4000) является enforcing-точкой этого ограничения.

[ФАКТ] LiteLLM :4000 — LISTENING согласно VERIFIED-RUNTIME-SNAPSHOT.md (snapshot @ 6602842).

### HITL I-27

[ФАКТ] Финансовый инвариант I-27 (AI PROPOSES, human DECIDES) закреплён в CLAUDE.md и ADR-128. Применяется ко всем агентным потокам движка.

[ФАКТ] ADR-128 определяет матрицу уровней автономности L1–L4. Ни один агент не действует выше L2 без явного человеческого решения на HITL-воротах.

### AGPL / Jube

[ФАКТ] ADR-004 фиксирует ограничение AGPL-лицензии для Jube. Интеграция Jube в агентный движок требует соблюдения условий AGPL.

### 4 операционные проблемы (из корпуса)

[ФАКТ] В корпусе зафиксированы 4 класса проблем и предложенные решения:
1. Детерминизм — [НЕИЗВЕСТНО] конкретное решение без детального текста
2. Задержка (latency) — [НЕИЗВЕСТНО] конкретное решение без детального текста
3. Галлюцинации — [НЕИЗВЕСТНО] конкретное решение без детального текста
4. Bus-factor — [НЕИЗВЕСТНО] конкретное решение без детального текста

[ВЫВОД] Детальные решения по 4 проблемам потребуют загрузки соответствующей части корпуса (вероятно SRC-03..05 или SRC-08).

### banxe-rag

[ФАКТ] В корпусе упомянут banxe-rag как база знаний с 17 docs → 200+ (предположительно документов или chunks).

[НЕИЗВЕСТНО] Точный состав, формат хранения и текущий deployment-статус banxe-rag — не верифицированы без shell-аудита.

---

## Cross-references

- ADR-004 (Jube / AGPL)
- ADR-042 (UFW perimeter) — периметр защищает LiteLLM
- ADR-123 (Claude permissions hardening)
- ADR-128 (HITL matrix)
- VERIFIED-RUNTIME-SNAPSHOT.md — LiteLLM :4000 статус

---

## Pending

Детали решений по 4 проблемам — ожидают SRC-03/04/05/08.

---

## SRC-07 Enrichment — Точные Invariant-ID (добавлено 2026-06-28, append-only)

Уточнение расплывчатых меток из первичного текста SRC-07. Все ID по INVARIANTS.md + ADR-реестру @ origin/main.

---

### AI-Entry Constraints → I-32 + I-33 + ADR-016

**[ФАКТ]** "INV-AI-01" (из корпуса) = три конкретных контрола:

**I-32 — LiteLLM Universal Router**
Все AI-вызовы ОБЯЗАНЫ маршрутизироваться через LiteLLM v2 router.
Endpoint: `http://legion:4000/v1` → evo1.
Алиасы: `ai` / `ai-heavy` / `glm-air` / `reasoning` / `banxe-general` / `fast` / `coding`.
Прямые внешние LLM-запросы запрещены (ADR-016).

**I-33 — PII/AML Deny-Paths**
Следующие пути разрешены ТОЛЬКО локальным алиасам (не облачным провайдерам):
`compliance/cases/*`, `kyc/raw/*`, `secrets/*`, `.env*`, `*.pem`, `id_*`.
Enforcement: `policy.yaml` + pre-commit hook + runtime guard.

**ADR-016 — LiteLLM = единственный AI entrypoint**
Архитектурное решение: прямые обращения к OpenAI/Anthropic/Gemini API из кода запрещены.
Все модели (local + cloud) унифицированы под LiteLLM facade.

**Cross-refs:** INVARIANTS.md §I-32, §I-33; ADR-016; DEPLOYMENT-ARCHITECTURE.md (:4000 LISTENING)

---

### HITL → I-27 + HITL-MATRIX.yaml + ADR-128 + Dashboard :8091

**[ФАКТ]** I-27: AI PROPOSES, human DECIDES — базовый invariant (INVARIANTS.md).
**[ФАКТ]** HITL-MATRIX.yaml: матрица агент → уровень автономии (L1–L4).
**[ФАКТ]** HITL Dashboard: DEPLOYED :8091 (ADR-012; verify by DEPLOYMENT-ARCHITECTURE.md).
**[ФАКТ]** ADR-128: L1–L4 autonomy levels.
  - L1 = Auto (полностью автоматизировано)
  - L2 = Alert → Human (AI действует, алертит)
  - L3 = Auto + HITL gate (блокировка на критичных решениях)
  - L4 = Human Only (только человек; пример: KYC restricted → customer = L4 MLRO)

**Cross-refs:** INVARIANTS.md §I-27; HITL-MATRIX.yaml; ADR-128; ADR-012 (:8091); docs/policies/hitl-l3-agent-gate-2026-05-11.md

---

### AGPL Jube → ADR-004 (точная граница)

**[ФАКТ]** ADR-004: Jube :5001 AGPLv3, internal-only deployment.
Граница: B2B SaaS → обязательный rewrite на Apache-2.0 стек (Flink/ONNX) до запуска в B2B.
`tx_monitor.py` независим (9 deterministic rules + Redis velocity :6379) — Apache-2.0 совместим.

**AML synthetic data — VERIFIED-LOCAL:**
- AMLSim: `/home/mmber/AMLSim` (git repo, VERIFIED-LOCAL) — synthetic AML transaction generator.
- AMLGentex: `/home/mmber/AMLGentex` (git repo, VERIFIED-LOCAL) — AML data generation toolkit.
- AMLTRIX: Apache-2.0 taxonomy, referenced (not deployed locally).

**[ВЫВОД]** Собственный TM-движок (Apache-2.0 path) имеет верифицированную локальную data-инфраструктуру (AMLSim + AMLGentex) для backtesting без Jube AGPL dependency.

**Cross-refs:** ADR-004; COMPLIANCE-MATRIX §Jube; SRC-06 §AMLSim VERIFIED-LOCAL; DEDUP-FINDINGS.md §OSS Status Correction

---

### Guardrails Stack → Verify / Guardian / Semgrep / Redis

**[ФАКТ] Verify API :8094** — `verify_api.py`, DEPLOYED evo1 (ADR-012, I-09).
Routes: 8093 → 8094, OpenClaw 18789 → 8094. Validates compliance/AML responses.
BANXE-STATUS: PRESENT.

**[ФАКТ] Guardian two-family** — ADR-019.
evo1 services + MetaClaw guardian/ (PRESENT, ~/MetaClaw/guardian/).
Audit: ClickHouse TTL 5Y (I-08).
Degradation detection: ADR-139.
BANXE-STATUS: PRESENT.

**[ФАКТ] Semgrep × 3 (required, never bypass)**
Gate 3 of quality-gate.sh. Three scan passes required; bypass = policy violation.
Custom rules: `.semgrep/banxe-rules.yml` (10 custom rules incl. banxe-float-money, banxe-audit-delete, banxe-clickhouse-ttl-reduce).
BANXE-STATUS: PRESENT (enforced in CI).

**[ФАКТ] Redis velocity tracker :6379** — tx_monitor.py rate-limiting + velocity checks.
BANXE-STATUS: PRESENT (evo1; :6379 LISTENING per VERIFIED-RUNTIME-SNAPSHOT.md).

---

### Bus Factor → GAP-084 / ADR-140 RD-06

**[ВЫВОД]** Bus factor risk = GAP-084 (🟡 PENDING): 8 repos no-org, 6/8 missing CODEOWNERS,
Guardian coverage 7/18 repos (ADR-139). Remediation: RD-06 / ADR-140.

**Досье не дублирует детали** — полная картина в docs/GAP-REGISTER.md §GAP-084 и ADR-140.
SRC-07 фиксирует только как guardrail-gap: агентный движок не снимает risk до закрытия GAP-084.

**Cross-refs:** docs/GAP-REGISTER.md §GAP-084; ADR-139 (Guardian); ADR-140 (RD-06)

---

### banxe-rag corpus

**[НЕИЗВЕСТНО в banxe-architecture]** "17 docs → 200+" упоминается в корпусе.
Источник: banxe-rag repo / emi-stack (НЕ в banxe-architecture; путь не верифицирован здесь).
Досье не может подтвердить статус deployment без cross-repo access.

**Cross-refs:** banxe-rag repo (out-of-scope для этого repo)
