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
