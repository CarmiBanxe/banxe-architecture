---
title: "Advisory Response — Consultant Ruling (Escalation #1084) — Perplexity Governance/Safety"
provenance: external consultant (Perplexity), staged evo1 zero-loss
intake_date: 2026-07-07
status: SSOT-RESTORED
classification: reference source (NOT canon)
body_bytes: 12238
body_sha256: 99e9595af3dffaf3dbfa7f3e5c0518ffc7518e19fbc842ec7a3c5ab485f63755
verify: "tail -c 12238 <this-file> | sha256sum"
related:
  - "Escalation #1084 (Consultant Escalation & Best-Decision Consultation Protocol)"
  - "docs/adr/ADR-162-best-decision-principle.md"
  - "docs/adr/ADR-163-sync-canon.md"
  - "docs/adr/ADR-164-best-decision-agent-method.md"
  - "docs/sources/consultant-escalation-protocol-2026-07-07.md"
---

# SSOT INTAKE HEADER (ADR-161) — read before the source body

**This file is a citable SOURCE, not canon.** It preserves, byte-for-byte, the Perplexity Governance & Safety
consultant's advisory ruling on the Best-Decision Q1–Q5 questions raised in Escalation #1084. The verbatim body
follows this header, unmodified.

- **Provenance:** external consultant (Perplexity Research / Governance & Safety), staged on evo1 as
  `/tmp/consultant-answer.md`; intake 2026-07-07; status **SSOT-RESTORED** (reference only).
- **Body integrity (zero-loss):** body-bytes=`12238`, body-sha256=`99e9595af3dffaf3dbfa7f3e5c0518ffc7518e19fbc842ec7a3c5ab485f63755`. Verify: run
  `tail -c 12238 docs/sources/consultant-response-best-decision-2026-07-07.md | sha256sum` — MUST match
  the body-sha256 above.
- **Advisory only.** Thresholds/weights/gates cited in the body are the CONSULTANT's proposal; per
  Config-over-Hardcoding (CLAUDE.md §10) any adoption lands in governance config via a **human-gated** PR
  (I-27 preserved). This file activates nothing.
- **ADR-102 (no restate):** derived synthesis (`docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md`) is
  pointer-first to this source and to the anchors listed above. It does not restate the body.
- **Anchors:** `.claude/rules/agents.md` (BUG-007 HITL), `schemas/agent_decision_record.schema.json`,
  `governance/novelty-pipeline-config.yaml`, `docs/canon/BEST-DECISION-BOUNDARY.md`, ADR-161.

---
Advisory Response — Consultant Ruling (Escalation #1084)
Source: Perplexity Research / Governance & Safety Consultant
To: Moriel Carmi (Operator) + Central
Re: Governance/Safety best-decision в EMI BANXE — 5 вопросов
Status: Advisory. Ратификация за оператором и Central. I-27 и variant-2 сохранены.

Q1 — Guardrails: Advisory vs Autonomy на payment/compliance контуре
Ruling: Да, необходим отдельный deterministic policy-gate ДО scoring.

Одного execution-class недостаточно. Причина — CJEU прецедент по SCHUFA (2023): человеческое вмешательство должно быть содержательным (meaningful), а не формальным rubber-stamp. Если scoring-алгоритм фактически предрешает исход, а human review лишь подписывает — это всё равно считается автоматическим решением по GDPR Art. 22.

Рекомендуемая двухступенчатая архитектура для payment/compliance:

text
Step 0 [DETERMINISTIC ADMISSIBILITY GATE] — ДО scoring
  ├── Rule-based: regulatory hard constraints (EMD2, AML thresholds)
  ├── Output: ADMISSIBLE | BLOCKED (no appeal to scoring)
  ├── Implemented as: static rule-engine (versioned, human-authored)
  └── NOT модифицируется агентом никогда

Step 1 [SCORING / enumerate→score→satisfice] — только для ADMISSIBLE
  ├── MAUT-scoring по критериям с весами
  ├── Output: execution-class {advisory|gated|blocked}
  └── Result = PROPOSAL, never direct execution

Step 2 [HUMAN GATE] — для gated и все payment actions
  └── Meaningful review (не rubber-stamp)
Ключевой принцип из EU AI Act Art. 6(3): агент классифицируется вне high-risk только если он «not meant to replace or influence the previously completed human assessment without proper human review». Если Step 1 существует без Step 0, агент влияет на исход до human review — это high-risk с полными обязательствами.

Минимальный набор guardrails:

Deterministic Admissibility Gate (DAG) — статический, человек-authored, append-only changelog.

execution-class обязателен — но как выход Step 1, не как замена Step 0.

advisory класс означает: агент предоставляет ранжированный список вариантов с обоснованием; решение о действии принимает человек.

Никакого direct-write в payment ledger без explicit human confirm — даже при confidence ≥ 0.99.

Audit trail Step 0 + Step 1 отдельно, чтобы можно было доказать регулятору последовательность.

Q2 — Калибровка весов S = 0.30·B − 0.15·C − 0.30·R + 0.15·V + 0.10·F
Ruling: Для high-risk доменов веса некорректны. Необходима лексикографическая архитектура.

Предложенные веса реализуют аддитивную MAUT: математически корректно для trade-off задач, но неприемлемо для compliance/payment по следующей причине. При аддитивной модели высокий B (benefit) может компенсировать высокий R (risk) — это называется «substitutability». В регулируемом контексте подобная компенсация запрещена: нарушение compliance не может быть оправдано доходностью.

Академическое решение — Lexicographic Safety First (LSF), где:

𝑊
𝑖
=
(
𝑉
𝑖
,
𝐸
𝑖
)
W 
i
​
 =(V 
i
​
 ,E 
i
​
 )
𝑉
𝑖
=
1
−
max
⁡
(
𝛼
,
𝐹
𝑖
(
𝑑
)
)
V 
i
​
 =1−max(α,F 
i
​
 (d)) — «satisficed safety» (если риск ниже порога 
𝛼
α, считается «достаточно безопасным»)

𝐸
𝑖
E 
i
​
  — ожидаемая полезность (benefit, cost, value и т.д.)

Техника с 
𝐹
𝑖
>
𝛼
F 
i
​
 >α никогда не выбирается, сколь бы высоким ни было 
𝐸
𝑖
E 
i
​
 

Для BANXE высокорисковых контуров конкретное предложение (proposal, not adopted):

text
LEVEL 0 [LEXICOGRAPHIC HARD]:
  Regulatory Admissibility ∈ {0,1}  — 0 = BLOCKED unconditionally

LEVEL 1 [LEXICOGRAPHIC SOFT]:
  Risk score R < threshold α        — satisficed; ties resolved by Level 2
  (if R ≥ α: choose min-R option regardless of other criteria)

LEVEL 2 [ADDITIVE MAUT over admitted options]:
  S = w_B·B − w_C·C + w_V·V + w_F·F
  (risk R excluded — уже обработан на Level 1)
Подтверждение из LexiSafe (2025): лексикографическая приоритизация с safety-first доказуемо converges to policies, удовлетворяющих safety constraints, без жертвы reward-оптимизацией внутри допустимого множества. IJCAI 2022 показывает аналогичный результат для multi-objective RL.

Calibration-совет: FCA и PRA SS1/23 требуют independent model validation для моделей, влияющих на material decisions. Веса Level 2 должны пройти такую валидацию до активации.

Q3 — Scope: что считать каноническим «BANXE concept» для SSOT
Ruling: Это решение владельца scope (оператор + Central). Консультант даёт критерий, не решает за вас.

Два критерия для разграничения канонических документов:

Критерий A — функциональный origin: Документ является каноническим если он:

Создан в контексте BANXE-процессов (не внешние legal-документы, не библиотеки).

Содержит архитектурные решения или бизнес-правила, влияющие на поведение агентов.

Ратифицирован через ADR-процесс или эквивалентный governance-механизм.

Французские ASSIGNATION-документы по этому критерию — не канонические. Они внешние legal-документы, не архитектурные.

Критерий B — traceability: Канонический документ должен иметь lineage в SSOT: создан когда, кем, какой ADR на него ссылается. Если document не traceable через ADR-chain → не canonical по умолчанию.

Рекомендуемый процесс консолидации:

Оператор + Central формируют критерий (A+B выше — один из вариантов).

Один-разовый audit: пройтись по всем «concept v*» с применением критерия.

Результат: список canonical | archived | external-reference — фиксируется в SSOT ADR.

Этот процесс — human decision, не автоматизируется. Именно поэтому консультант не может его закрыть.

Q4 — Adoption-audit 88 находок: пороговые критерии
Ruling: Предлагаю двухэтапную decision-matrix вместо ручного разбора.

Для автоматической тriage без ручного разбора каждой находки — scoring-матрица на 4 предложенных метриках:

Метрика	Вес	Смысл
HGC (Human Governance Cost)	0.30	Сколько HITL-времени требует внедрение
FCR (Failure Consequence Risk)	0.35	Какой ущерб, если не принять
AC (Adoption Complexity)	0.20	Техническая сложность
CGR (Compliance Gain Rate)	0.15	Насколько улучшает compliance-покрытие
Scoring-формула (proposal, human-gate для активации):

𝑆
f
i
n
d
i
n
g
=
0.35
⋅
𝐹
𝐶
𝑅
+
0.15
⋅
𝐶
𝐺
𝑅
−
0.30
⋅
𝐻
𝐺
𝐶
−
0.20
⋅
𝐴
𝐶
S 
finding
​
 =0.35⋅FCR+0.15⋅CGR−0.30⋅HGC−0.20⋅AC
где все метрики нормированы в.

Decision-gate:

text
S ≥ 0.60               → ADOPT (queue for implementation sprint)
0.30 ≤ S < 0.60        → DEFER (re-evaluate in 90d window)
S < 0.30               → REJECT-AS-NOT-WORTH (archived with reason)
FCR ≥ 0.80 (любой S)   → ESCALATE-IMMEDIATE (lexicographic override —
                          высокий риск отказа перекрывает score)
Ключевое правило: FCR ≥ 0.80 — лексикографический override (аналогично Q2 Level 0). Находка с критическим compliance-риском не может быть отвергнута через scoring.

Для калибровки 88 находок: предлагаю прогнать scoring на 10-15 repres. sample с human-validation результатов → скорректировать веса → применить ко всем 88. Это RLHF-аналогичный подход на micro-scale: человек валидирует, система применяет.

Q5 — Churn-treadmill: оптимальное решение для ledger-PR
Ruling: Merge-queue serialize (авто) — оптимален. Commit-index redesign — правильный, но не сейчас.

Анализ трёх вариантов по cost × reversibility:

Вариант	Стоимость	Обратимость	Корневой долг	Рекомендация
Окно затишья (ручное)	Низкая	Высокая	Нет	Временный workaround
Merge-queue serialize (авто)	Средняя	Высокая	Нет	Оптимально сейчас
Commit-index redesign	Высокая	Низкая	Да — устраняет	Правильно, но позже
Обоснование merge-queue:

GitHub merge queue тестирует каждый PR против точного состояния main, каким оно будет в момент мержа — включая PRs впереди в очереди. Это устраняет race condition в ledger-PR без ручного управления. GitHub официально позиционирует merge queue для «teams where multiple users regularly commit to a single branch» — точное описание ситуации.

Техническая деталь: при concurrent-velocity «aggressive caching» (actions/cache) делает re-runs для неизменившегося кода практически бесплатными по времени. CI интегрируется через concurrency: group: ci-${{ github.ref }}, cancel-in-progress: false для sequential execution.

Commit-index redesign — корректный архитектурный долг, устраняющий проблему в корне. Но он необратим в краткосрочной перспективе и требует отдельного ADR с полным impact-анализом. Рекомендую ADR-draft сейчас, реализацию — в следующем релизном окне с нулевой concurrent-activity.

Окно затишья — только как emergency-fallback при сбое merge-queue.