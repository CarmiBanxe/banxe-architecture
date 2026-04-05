# INVARIANTS.md — Архитектурные инварианты Banxe

Эти правила всегда истинны. Нарушение любого — баг архитектуры, а не допустимое исключение.

---

## Compliance инварианты

**I-01 — Sanctions first**
Санкционная проверка выполняется ПЕРВОЙ, до любого другого AML шага. Результат санкций не может быть переопределён score-based логикой.

**I-02 — Blocked jurisdictions → REJECT**
Транзакция из/в Category A юрисдикцию (RU/BY/IR/KP/CU/MM/AF/VE-gov/Crimea/DNR/LNR) → REJECT немедленно, без исключений, без score.

**I-03 — Category B → HOLD/EDD, не auto-allow**
Транзакция из/в Category B юрисдикцию (SY/IQ/LB/YE/HT/ML/...) → минимум HOLD с Enhanced Due Diligence. Не APPROVE, не REJECT по умолчанию.

**I-04 — Transaction amount thresholds**
- ≥ £10,000 → EDD + HITL обязательны
- ≥ £50,000 crypto → High-value flag + MLRO approval
- Пороги не обходятся для "известных" или VIP клиентов

**I-05 — Decision thresholds неизменны без ADR + MLRO + CEO**
- SAR: composite ≥ 85 ИЛИ sanctions_hit
- REJECT: composite ≥ 70
- HOLD: composite ≥ 40
- Изменение threshold → обязательно ADR, нельзя через операторский интерфейс

**I-06 — Hard override всегда REJECT/SAR**
`HARD_BLOCK_JURISDICTION`, `SANCTIONS_CONFIRMED`, `CRYPTO_SANCTIONS` → REJECT независимо от composite score. Нет бизнес-причины, которая это отменяет.

**I-07 — Watchman minMatch = 0.80**
Нижняя граница Jaro-Winkler. Ниже → false positives. Выше 0.92 → пропускает алиасы. Изменение требует MLRO approval.

**I-08 — ClickHouse TTL = 5 лет**
FCA MLR 2017 record-keeping. Не уменьшать.

---

## Операционные инварианты

**I-09 — Auto-verify обязателен для compliance/kyc/aml/risk/crypto ответов**
Перед отправкой любого ответа по этим темам агент вызывает `http://127.0.0.1:8094/verify`. CONFIRMED → send. REFUTED → rephrase. Нет исключений для "быстрых" или "очевидных" случаев.

**I-10 — Нет фейковых интеграций**
Если LexisNexis, SumSub, Dow Jones, Chainalysis не подключены — не упоминать их как активные источники, не генерировать данные от их имени.

**I-11 — OFAC RSS не существует с 31.01.2025**
Только HTML scraper `ofac.treasury.gov/recent-actions`. Не пытаться подписываться на RSS.

---

## Архитектурные инварианты (слои)

**I-12 — Validators = source of truth, decisions = derived outputs**
`compliance_validator.py` (developer-core) — единственный авторитетный источник policy. AML engines (vibe-coding/src/compliance/) — derived. Никакой движок не переопределяет validator без явного изменения validator.

**I-13 — BANXE runtime делегирует, не дублирует**
`banxe_aml_orchestrator.py` вызывает developer-core validators через импорт. Логика threshold/forbidden_patterns не дублируется в нескольких местах.

**I-14 — Canonical key для компаний: (jurisdiction_code, registration_number)**
Никогда не использовать `company_number` в одиночку — коллизии между юрисдикциями.

**I-15 — Jube AGPLv3 — ТОЛЬКО internal, reference only**
Jube используется исключительно для внутреннего compliance. Любой external exposure (B2B, SaaS, партнёрский API) требует ПОЛНОЙ замены Jube-зависимости на Apache 2.0 альтернативу до запуска. Изучать архитектуру Jube как reference — допустимо. Создавать техническую зависимость (код, API-контракт) — запрещено.

---

## Инварианты привилегий

**I-16 — Обучение модели = только developer/CTIO**
Оператор-дублёр (Telegram, Marble UI) не имеет доступа к promptfoo eval, adversarial sim, training pipeline, изменению SOUL.md/SKILL.md/thresholds.

**I-17 — SOUL.md изменяется только через protect-soul.sh**
Прямое редактирование workspace SOUL.md → не даёт защиту (`chattr +i`). Только `bash scripts/protect-soul.sh update`.

**I-18 — GUIYON исключён из Banxe**
Никаких shared services, cross-routing, shared ports с проектом GUIYON.

**I-19 — Marble ELv2 — только internal compliance workflow**
Marble используется только для внутреннего MLRO workflow. Предоставление Marble как managed service третьим лицам — прямое нарушение Elastic License V2.

**I-20 — Compliance контуры независимы и заменяемы**
Каждый из 6 контуров (onboarding, screening, monitoring, triage, audit, training) может быть заменён независимо от остальных. Монолитная зависимость между контурами — баг архитектуры. Общий контракт: models.py (RiskSignal, AMLResult, EvidenceBundle).

---

## Инварианты агентной архитектуры (добавлены 2026-04-05, аудит v2)

**I-21 — feedback_loop.py НИКОГДА не изменяет SOUL.md/AGENTS.md автоматически**
`feedback_loop.py --apply` может предлагать патчи для Class B (SOUL.md, AGENTS.md),
но не применять их. Применение — только вручную через `protect-soul.sh update` после
MLRO + CTO approval. Нарушение: если `feedback_loop.py` делает commit/push
изменений в SOUL.md без явного человеческого действия.
Обоснование: `governance/change-classes.yaml` CLASS_B_SOUL_AGENTS. GAP-REGISTER G-05.

**I-22 — Агент Level 2 не пишет в policy layer**
Агенты, обрабатывающие внешние данные (транзакции, KYC-документы, ответы
от контрагентов), не имеют write-доступа к `developer-core/compliance/`.
Policy layer (compliance_validator.py) изменяется только через developer terminal.
Нарушение открывает вектор prompt injection → policy modification.
Обоснование: Orchestration Tree (NCC Group), GAP-REGISTER G-04.

**I-23 — Emergency stop state проверяется ДО любого автоматического решения**
Все screening endpoints обязаны проверять `emergency_stop.get_stop_state()`
перед выполнением. HTTP 503 при активном стопе — не опция, а обязательное поведение.
Нарушение: любой endpoint, выдающий compliance-решение без проверки stop state.
Обоснование: EU AI Act Art. 14(4)(e). GAP-REGISTER G-03.

**I-24 — Decision Event Log = append-only, без UPDATE/DELETE**
Записи аудит-трейла compliance-решений нельзя изменять или удалять.
При реализации G-01 (PostgreSQL decision_events): `REVOKE UPDATE, DELETE ON decision_events`.
До реализации G-01: ClickHouse append-only является допустимым промежуточным состоянием.
Нарушение: любой UPDATE/DELETE в audit-таблицах — немедленный alert MLRO.
Обоснование: DORA Art. 14(2), FCA MLR 2017 record-keeping. GAP-REGISTER G-01.

**I-26 — Compliance incident → FCA notification в течение 72 часов**
Если prompt-injected данные привели к изменению compliance_validator.py или SOUL.md
без надлежащего governance gate (Class B approval) — это FCA-reportable compliance failure
(UK DORA requirements). Уведомление регулятора обязательно в течение 72 часов.
Практически: любое автоматически применённое изменение в policy layer без L0 approval
классифицируется как incident и запускает incident response процедуру.
Первый шаг incident response: активировать emergency stop (I-23), затем MLRO review.
Обоснование: Mastercard предупреждение об agentic AI commandeering; UK DORA Art. 19.

**I-25 — ExplanationBundle обязателен для решений > £10,000**
`BanxeAMLResult` для транзакций >= £10,000 должен содержать заполненный
`ExplanationBundle` с `top_factors`, `narrative` и `method`.
До реализации G-02: поле может быть null с `method: "pending"`.
Нарушение: REJECT/SAR > £10k без readable explanation — FCA SS1/23 нарушение.
Обоснование: UK GDPR, FCA PS7/24, EU AI Act transparency. GAP-REGISTER G-02.
