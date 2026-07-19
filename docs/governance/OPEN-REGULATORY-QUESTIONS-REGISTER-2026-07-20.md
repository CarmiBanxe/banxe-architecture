# OPEN REGULATORY QUESTIONS REGISTER — Banxe/Banksy (Areas 1–8)

**Status: DRAFT / NOT FOR MERGE** · 2026-07-20 · Phase-0 deliverable плана `BANK-ROOMS MIGRATION PLAN v2`
Правила: записи не удаляются (append-only по духу I-24); переход RED→AMBER→GREEN — только с evidence-ссылкой; ни одна область не «resolved» без artefact'а (freeze rule Phase 0).
Traffic-light: GREEN = нет блокирующей правовой неоднозначности · AMBER = миграция с caveats + открытый counsel-item · RED = закрытие блокировано.
Источник областей 4–8: операторский ввод 2026-07-20 (**дословно**). Области 1–3: составлены фабрикой из plan v2 §3/§6 — подлежат операторскому подтверждению.

---

## 1. TAX (TaxComplianceAgent; ledger-room) — AMBER

- L2 vs L3 для propose-only tax-агента
  - Status: OPEN — внешнего правила, прямо решающего уровень автономии, не найдено; классификация = внутренний governance/ADR-вопрос.
  - Risk: молчаливое закрепление L2 без ратификации; налоговые позиции без counsel-проверки.
  - Action: draft-ADR «L2 propose-only, human-submit»; counsel-оценка ответственности Tax Manager vs SMF2 при автоматизированной подготовке позиций.
  - Owner: CFO/Tax Mgr · Compliance Owner: CFO-линия.

## 2. CARDS (card_agent; payments-room) — RED

- BIN sponsor / functional spec отсутствуют
  - Status: RED — структурно нерешено; функциональный scope агента не зафиксирован.
  - Risk: невозможно классифицировать по Annex III без точного описания решений агента; ownership решений (мы vs спонсор) не определён.
  - Action: «Card functional scope note» (предусловие любой классификации); counsel: SMF-владение при BIN-модели, минимальный HITL под scheme rules.
  - Owner: COO · Eng: CTO-линия.

## 3. CRYPTO / MiCA / TRAVEL RULE (crypto_agent; payments+aml-room) — RED

- CASP-периметр и модель одобрений
  - Status: RED — статус (мы CASP / агент CASP при Paybis-дистрибуции) не подтверждён; Travel Rule = transaction-level data-обязанность [CONFIRMED], per-transfer human approval = внутренний policy-выбор [INTERIM], не доказанный правовой минимум.
  - Risk: смешение data-pipeline-обязанностей и approval-политики; ratchet-риск само-ужесточения.
  - Action: тройное расщепление в room-доках (data controls / internal HITL / CASP-вопрос); counsel по MiCA-модели и юрисдикционным per-transfer случаям.
  - Owner: MLRO · gate: ADR-114.

---

## 4. NEW PRODUCTS (savings, insurance, merchant acquiring) — AMBER

- FCA permissions & Consumer Duty thresholds
  - Status: UNKNOWN — no concrete FCA permissions or Consumer Duty threshold mapping for savings / insurance / merchant acquiring in current materials.
  - Risk: Cannot confirm that product permissions are correctly scoped; external FCA/Consumer Duty legal review required before treating any product as “permissioned”.
  - Action: External counsel to map required permissions and Consumer Duty obligations per product; update room docs and ADRs accordingly.

- Sufficiency of single product gate H-017 (CEO)
  - Status: INSUFFICIENT — single CEO launch gate decides “launch / no launch” but does NOT replace evidence pack required by Consumer Duty.
  - Missing artefacts: fair value assessment; target market statement; vulnerable customer analysis; complaints route documentation.
  - Action: Define mandatory “Product Evidence Pack” template and link it to H-017; treat gate + evidence as combined requirement, not gate alone.

## 5. CONSENT / DPO (identity-room) — AMBER (RED-риск при подтверждении Art.37 без назначения)

- DPO obligation under GDPR Art.37
  - Status: LIKELY YES, NOT CONFIRMED — typical bank-scale systematic monitoring of customers fits Art.37(1)(b), but exact “scale” threshold for this bank is not measured or legally confirmed.
  - Risk: Treating DPO as optional would be misleading until obligation is clearly tested; vacancy may represent a regulatory gap, not just an org choice.
  - Action: External GDPR counsel to confirm DPO obligation for the bank’s actual data volumes and monitoring patterns; record decision and rationale in identity-room docs.

- “DPO vacant + Compliance/Ops/CEO” as governance scheme
  - Status: INTERIM ONLY — cannot be normalized as permanent solution while DPO obligation remains unresolved; at most acceptable as temporary until a DPO is appointed.
  - Risk: Long-term reliance on interim triage without named DPO may be non-compliant if Art.37 applies.
  - Action: Document interim scheme explicitly as temporary; set a board-level deadline for DPO appointment if obligation confirmed.

- Separate high-risk classifier for consent/identity agents
  - Status: LEGAL: NO (not Annex III high-risk); INTERNAL POLICY: OPEN QUESTION.
  - Risk: Confusing legal high-risk AI Act perimeter with stricter internal classification; both must be clearly distinguished.
  - Action: Decide whether internal policy will treat consent/identity as “internal high-risk”; if yes, document this as voluntary stricter standard, not as AI Act requirement.

## 6. MIDAZ_AGENT (MCP → ledger; ledger-room) — AMBER

- Regulatory acceptability of MCP→ledger architecture
  - Status: OPEN, CONDITIONALLY ACCEPTABLE ONLY — no direct rule forbids or authorizes a specific MCP→ledger pattern; this is a data-integrity and auditability design question.
  - Condition: Architecture can be treated as acceptable only if 100% of writes are proven to traverse controlled LedgerAgent / LedgerPort gates, with no bypass paths.
  - Action: Architecture + audit teams to design and prove gate-enforced write path; external auditor to opine on adequacy of controls.

- High-risk AI classification of midaz_agent
  - Status: NOT high-risk under Annex III (financial reporting not listed), BUT oversight must be strict regardless.
  - Risk: Underestimating the governance requirements for ledger mutations because system is not labeled “high-risk AI”.
  - Action: Document midaz_agent as infrastructure/platform component with full traceability, logging, and human oversight requirements; separate formal AI Act classification from internal control strength.

## 7. WEBHOOK_AGENT (EXEC dispatch; DORA; ai-platform-room) — AMBER

- Infrastructure vs decision-making agent classification
  - Status: OPEN — regulator does not define a specific category for webhook dispatchers; boundary depends on actual autonomy (routing, retries, impact on regulated outcomes).
  - Risk: Misclassifying a highly-autonomous dispatcher as “mere infrastructure” may hide de facto decision-making in regulated flows (payments, AML, regrep).
  - Action: Describe webhook_agent autonomy explicitly (routing rules, retry strategies, failure modes); then classify per use case, with counsel input for high-impact flows.

- Logging / retention / fallback / retry under DORA
  - Status: NO NUMERIC MINIMUM; DESIGN+LEGAL QUESTION — DORA sets principles (central logs, retention, incident traceability, resilience), but no specific numeric “minimum standard” for webhook-layer.
  - Risk: Assuming generic logging is enough without designed retention periods, dead-letter queues, and bounded retry logic for regulated domains.
  - Action: Define architecture-level logging/retention/fallback/retry specification for webhook_agent; validate against DORA principles with external operational resilience expert.

## 8. AI-GOVERNANCE (cross-cutting) — AMBER

- Legal vs internal “high-risk” classification
  - Status: OPEN — Annex III + Recital 58 define a narrow legal high-risk perimeter (credit scoring, life/health insurance; AML/fraud explicitly excluded), while internal canon marks broader domains (AML/KYC/fraud etc.) as “high-risk”.
  - Risk: Claiming “AI Act compliance” as solved while internal labels blur legal and voluntary stricter definitions; may confuse external auditors / regulators.
  - Action: Produce a dedicated document that separates “legal high-risk (AI Act Annex III)” vs “internal high-risk (bank policy)” and maps agents accordingly.

- Deadlines and target dates for AI Act compliance
  - Status: NOT FIXED INTERNALLY — sources show staggered dates (2026 / 2027 / 2030 for various obligations); no single internal plan recorded for when each block will be met.
  - Risk: Migration and governance may proceed without a clear timeline, leading to compressed or missed compliance windows.
  - Action: Define an internal compliance roadmap with target dates per obligation class; link it into migration / roadmap docs and bank-rooms/ top-level page.

- Explainability, override, stop, change-control implementation
  - Status: DOCUMENTATION GAP — HITL codes and roles exist, but there is no technical description per agent of:
    * stop-function implementation,
    * automation bias mitigation,
    * format of interpretable output and override process.
  - Risk: Article 14 AI Act requirements cannot be considered fulfilled without concrete per-agent implementation details and evidence.
  - Action: For each high-risk or internally-high-risk agent, document:
    * how outputs are made explainable,
    * how human overseer can override/stop decisions,
    * how change-control is enforced.
  - Link these docs to room hitl-summary and ADRs before freezing migration.

---

## Сводка traffic-light

| # | Область | Свет | Owner | Комната |
|---|---|---|---|---|
| 1 | Tax | AMBER | CFO/Tax Mgr | ledger-room |
| 2 | Cards | RED | COO | payments-room |
| 3 | Crypto/MiCA | RED | MLRO | payments+aml |
| 4 | New products | AMBER | CEO/product [UNK-12] | customer-ops+payments |
| 5 | Consent/DPO | AMBER (RED-риск) | Legal/CEO | identity-room |
| 6 | midaz MCP→ledger | AMBER | CTO + Audit | ledger-room |
| 7 | webhook/DORA | AMBER | CTO | ai-platform-room |
| 8 | AI-governance | AMBER | CRO+CTO | cross-room |

*Producer: factory terminal. Области 4–8 — операторский текст без изменений; 1–3 — фабричная композиция, подтвердить.*
