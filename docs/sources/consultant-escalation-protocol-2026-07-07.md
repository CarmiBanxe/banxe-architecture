---
title: "SOURCE — Consultant Escalation & Best-Decision Consultation Protocol"
provenance: authored in-session by the factory expert-consultant role (NOT an operator-supplied external paper)
intake_date: 2026-07-07
status: PROPOSED
classification: reference source (NOT canon)
---

# SSOT INTAKE HEADER (ADR-161) — read before the body

**Reference source, not canon.** This protocol was authored **in-session by the factory's expert-consultant
role** — recorded honestly, it is *not* an external operator-supplied paper (unlike the engine/concept/self-learning
sources). It was written directly into this file rather than pasted, so there is no paste-corruption vector and the
content is lossless by construction.

- All thresholds/weights below are marked **"proposal, not adopted"** — per Config-over-Hardcoding (CLAUDE.md §10)
  any adoption lands in governance config via a **human-gated** PR. Nothing here sets a live threshold/weight/gate,
  and nothing is activated (I-27).
- **Pointer-first anchors:** `docs/sources/best-decision-concept-2026-07-06-v2.md`,
  `docs/sources/best-decision-self-learning-loop-2026-07-07.md` (PR #1083), `docs/canon/BEST-DECISION-BOUNDARY.md`,
  `docs/adr/ADR-162-best-decision-principle.md`, ADR-164 / `docs/design/BEST-DECISION-AGENT.md` (PR #1080),
  `.claude/rules/agents.md` (BUG-007), ADR-161.
- **Related but distinct (no ADR-102 duplication):** #1080 = per-agent advisory *method*; #1070
  `BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md` = engine / 24-7 / Factory-Central-Right *principles*; **this** =
  the *escalation-and-consultation protocol* (when/how a decision is escalated to the expert consultant and how the
  consultant applies the Best-Decision method).

---

Consultant Escalation & Best-Decision Consultation Protocol — Техническая Спецификация

Версия: 1.0 | Статус: Draft-for-Review (reference source, NOT canon) | Контекст: EU AI Act high-risk, I-27 fail-closed, метод «Лучшее Решение»
Первоисточники (pointer-first, не пересказывать): docs/sources/best-decision-concept-2026-07-06-v2.md, docs/sources/best-decision-self-learning-loop-2026-07-07.md, docs/sources/emi-banxe-engine-2026-07-06.md, docs/canon/BEST-DECISION-BOUNDARY.md, docs/adr/ADR-162-best-decision-principle.md, ADR-164/docs/design/BEST-DECISION-AGENT.md (PR #1080), .claude/rules/agents.md (BUG-007), ADR-161 (Intake SSOT).

0. Область и инварианты

Протокол определяет, когда решение эскалируется к эксперт-консультанту, как консультант применяет метод Лучшего Решения, и где проходит граница «предлагает система — утверждает человек». Он не вводит новый решающий контур: вердикт консультанта — всегда advisory, применение — human-gated (I-27). Три инварианта: append-only lineage (I-24); human-gated activation; explainability-by-construction.

1. Разбор по методу Лучшего Решения

Проблема: какой механизм эскалации-и-консультации минимизирует ожидаемый regret на трудных решениях, не нарушая I-27 и не создавая автономного решающего органа?

Пространство решений D:
- d1 — без консультанта: каждый агент решает сам в рамках своего HITL-gate.
- d2 — центральный решающий консультант: консультант выносит связывающие решения. Отсеян (pruned, причина: запрещён ADR-164 — создаёт автономный central decider, конфликт с I-27).
- d3 — консультант-advisor, эскалация по триггеру: агент/оркестратор эскалирует только «трудные» решения; консультант выдаёт разбор + рекомендованный satisficing-вариант; человек ратифицирует.
- d4 — консультант на все решения: разбор каждого решения. Отсеян (стоимость/латентность неприемлемы, нарушает satisficing-принцип Simon).

Оценка по критериям (веса — proposal, not adopted):
- Польза/качество решений (0.30): d1=0.55, d3=0.88, d4=0.90
- Стоимость/латентность (0.20): d1=0.95, d3=0.80, d4=0.25
- Риск / regret на трудных кейсах (0.25): d1=0.50, d3=0.90, d4=0.92
- Обратимость (advisory, не связывает) (0.10): d1=0.90, d3=0.95, d4=0.95
- Соответствие ограничениям I-27/§10 (0.15): d1=0.80, d3=1.00, d4=0.85
- U (MAUT, additive): d1=0.66, d3=0.884, d4=0.72

Satisficing-выбор: d3 — лучший достижимый, а не абстрактный оптимум. d4 даёт микроскопический прирост пользы ценой краха стоимости/латентности; d3 проходит все жёсткие ограничения (единственный с 1.00 по I-27) и доминирует по MAUT.

Где неопределённость → Value-of-Information (собрать, а не гадать): эскалация оправдана тогда и только тогда, когда ожидаемое снижение regret от консультации превышает её стоимость:
  Consult  ⟺  E[ΔR_reduction | consult]  >  Cost_consult
Это ставит эскалацию на VoI-основу, а не на «на всякий случай».

2. Конкретные измеримые рекомендации (proposal, not adopted)

2.1 Escalation predicate. Эскалируем к консультанту при высоком E:
  E = α·(1−c) + β·(1−ΔU) + γ·Irrev + δ·Downside + ε·CanonConflict
где c — confidence (BUG-007); ΔU = U(1) − U(2) — зазор между двумя лучшими вариантами (малый ΔU = close-call); Irrev, Downside ∈ [0,1]; CanonConflict ∈ {0,1}. Эскалация при E ≥ θ_esc.
- Пороги (proposal, not adopted): θ_esc = 0.60; веса α=0.30, β=0.25, γ=0.20, δ=0.15, ε=0.10; жёсткий override: CanonConflict=1 ⇒ эскалация всегда, независимо от E.

2.2 Схема ConsultRequest (поля = слоты шаблона, машиночитаемо):
{ "request_id":"uuid", "source_terminal":"CENTRAL|RIGHT|FACTORY",
  "problem":"...", "escalation_reason":"out_of_scope|high_uncertainty|irreversible|criteria_conflict|canon_contradiction",
  "known_facts":[ "verified fact + ref (ADR/invariant)" ],
  "decision_space":[{ "id":"d1","label":"..." }], "hard_constraints":[ "I-27","§10","ADR-102","Rule6" ],
  "escalation_score_E":0.72, "trace_id":"uuid", "input_hash":"sha256" }

2.3 Схема ConsultVerdict (advisory):
{ "verdict_id":"uuid", "request_id":"uuid",
  "pruned":[{ "id":"d2","reason":"..." }], "criteria":[{ "name":"...","weight":0.30,"score_per_option":{} }],
  "U_per_option":{}, "recommended":"d3", "recommendation_type":"satisficing",
  "confidence":0.84, "value_of_information":[{ "collect":"...","expected_regret_reduction":0.12,"cost":0.03 }],
  "fail_closed_default":"BLOCK_and_escalate_human",
  "human_ratification_required":true, "citations_verified":true, "schema_hash":"sha256","prev_hash":"sha256" }

2.4 Метрики качества консультации (proposal, not adopted; окно W=90d):
- Regret-reduction консультируемых кейсов: R̄_consult < R̄_baseline (иначе консультация вредит).
- Calibration консультанта: Brier BS ≤ 0.15, ECE ≤ 0.08 (метод — pointer к self-learning-loop §3.2).
- Ratification-agreement: доля вердиктов, ратифицированных человеком без override, ≥ 0.85 (слишком высоко ⇒ консультант — резиновый штамп; слишком низко ⇒ бесполезен).
- Escalation-precision: доля эскалаций, где E действительно предсказал сложность, ≥ 0.80.

3. Явная граница: система vs человек

- Вычислить E, сформировать ConsultRequest — делает сам агент/оркестратор.
- Разбор по методу, U, VoI, рекомендованный вариант — делает сам консультант (advisory).
- Применить рекомендацию на compliance/payment — НИКОГДА сам; human-gated (I-27, fail-closed).
- Изменить веса/пороги (θ_esc, α…ε, BUG-007) — НЕ сам; governance config через human-gated PR (§10).
- Активация агента / promotion — НЕ сам; I-27 HITL-L4, оператор.
- Дедупликация/рефактор канона по совету консультанта — НЕ сам; ADR-102 Duplication Audit + человек.

Консультант предлагает satisficing-вариант и VoI; решение и применение — человека. Вердикт не связывает и не самоприменяется.

4. Риски выбранного пути и контроль (fail-closed)

- Over-reliance (консультант де-факто решает): ratification-agreement мониторится; вердикт advisory; периодический human-audit sample.
- Галлюцинация «фактов» консультантом: citations_verified обязательно; неверифицируемый факт ⇒ fail_closed_default = BLOCK_and_escalate_human, а не догадка.
- Латентность на срочном контуре: SLA по tier (proposal: compliance 4ч / KYC-AML 24ч); при таймауте — не авто-решение, а эскалация человеку (fail-closed).
- Single point of failure: консультант недоступен ⇒ решение падает в human HITL-gate, никогда в авто-approve.
- Дрейф порогов: θ_esc/веса — только через human-gated config PR; изменение = ImprovementProposal, не авто.
- Конфликт с каноном: CanonConflict=1 ⇒ жёсткая эскалация + Duplication Audit (ADR-102).

Fail-closed правило: при сбое, таймауте, неоднозначности или неверифицируемом факте — блок + человек, никогда не автономный approve.

5. Поэтапный rollout (фабрика → банк; учителя → флот)

- Фаза 0 — инфраструктура: ConsultRequest/ConsultVerdict schema, append-only lineage (I-24), метрики. Никого не подключаем.
- Фаза 1 — фабрика, учителя/оркестраторы: сначала те, кто пишет/проверяет решения (auditors: spec_first_auditor, gap_tracker; orchestrators: ceo/cfo/coo_orchestration). Эскалация на синтетике; пороги calibration-phase занижены.
- Фаза 2 — фабрика, остальной флот: authoring-gate включён.
- Фаза 3 — банк, информационный контур: агенты-рекомендатели; все вердикты в REVIEW-tier.
- Фаза 4 — банк, compliance/payment: строжайший режим; только после ≥3 мес PASS, EU AI Act conformity assessment, adversarial probes. Здесь AUTO≥0.95 (proposal), satisficing запрещён, ратификация обязательна всегда.

6. Подтверждение соответствия ограничениям (по пунктам)

1. Нет автономного изменения решающих правил на compliance/payment — ✅ §3, §4: вердикт advisory, применение human-gated (I-27).
2. «Предлагает система — утверждает человек» — ✅ §3 таблица границы; human_ratification_required:true.
3. EU AI Act аудируемость, append-only (I-24) — ✅ schema_hash+prev_hash hash-chain, ConsultRequest/Verdict = документация решения.
4. Config-over-Hardcoding (§10) — ✅ все пороги/веса помечены «proposal, not adopted», живут в config через human-gated PR.
5. Не дублировать канон (pointer-first, ADR-102) — ✅ шапка pointer-first; CanonConflict триггерит Duplication Audit.
6. SYNC-CANON + Rule 6 — ✅ эскалация координируется через Central; консультант не трогает TRADING-001/agent/specproj/*, execution boundaries в силе.

Глоссарий

E — escalation score · ΔU — зазор двух лучших вариантов (малый ΔU = close-call) · VoI — value of information (собрать данные вместо догадки) · BS/ECE — Brier Score / Expected Calibration Error (калибровка confidence) · θ_esc — порог эскалации (proposal, not adopted) · Irrev/Downside — необратимость и величина даунсайда ∈ [0,1] · CanonConflict — флаг противоречия канону {0,1} · MAUT — Multi-Attribute Utility Theory (U = Σ w_j·u_j) · HITL — human-in-the-loop · I-27 — fail-closed activation/decision gate (human-gated) · BUG-007 — confidence-tiers.
