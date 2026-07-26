# NO-CREDIT-PRODUCTS-CANON — BANXE EMI не предоставляет кредитные продукты

> **STATUS: NORMATIVE, PROPOSED — operator decision (CEO); RATIFIED только после operator-акта.**
> ⚠ SANDBOX / TRAINING context (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false).
> STEP13, ENGREF01, 2026-07-27. Разрешает §CREDIT-GAP (`docs/audit/bdsl-fleet-classification-2026-07-10.md`)
> вариантом (б): исключение из области, не постройка high-risk credit-контура.
> Основание: `docs/master-document/01-master-full.md` («Кредитование, ипотека — ❌ Не нужно для EMI;
> нет встроенных loan/credit products»), EMD2 (e-money ≠ lending), EU AI Act Annex III §5.

## Fable5 banking-canon verdict (ШАГ 1 — advisory, зафиксирован)

- **Вердикт: КОРРЕКТНО — снятие Annex III §5 через явный no-credit-канон допустимо для UK EMI.
  Confidence = 0.93** (≥0.90 — авто-вердикт допустим; операторская ратификация обязательна).
- Обоснование: Annex III §5 охватывает AI-системы для **creditworthiness assessment / credit scoring
  физических лиц**. Если институция не предоставляет кредитных продуктов и ни одна AI-система флота не
  оценивает кредитоспособность — категория **не применяется** (out-of-scope, а не deferred). EMD2-периметр
  e-money institution подтверждает: кредитование — не бизнес BANXE.
- **C1 (обязательная):** заявление должно быть **операционным, не только документарным** — ни одна
  AI-система флота не выполняет creditworthiness assessment, включая **встроенные суб-функции**: scope-флаги
  обязательны на обоих подтверждённых носителях (`finance/apar_agent` credit-terms sub-function,
  `channel_c_sepa_orchestrator` credit-facility-drawdown routing) И на backlog-фичах аналитик
  (BNPL [v11-I11], credit-building guidance [v4-J] — **blocked-by-canon**; guidance допустим только как
  чистое advisory без скоринга клиента, отдельным решением).
- **C2 (обязательная):** EMD2 Art.6(1)(b) допускает для EMI узкий кредит, связанный с платёжными услугами
  (условия: не из safeguarded-средств и т.д.) — если BANXE когда-либо задействует даже такую форму
  (overdraft-подобное), настоящий канон ПЕРЕСМАТРИВАЕТСЯ ДО запуска (см. §4).

## Канон (NORMATIVE)

1. **BANXE как UK EMI НЕ предоставляет кредитные продукты:** loans, ипотека, credit-scoring,
   creditworthiness assessment, BNPL-lending. Основание: EMD2 (e-money ≠ credit), master-document v3.0.
2. **Следствие:** EU AI Act **Annex III §5 НЕ применяется** к BANXE — категория вне периметра →
   **CREDIT-GAP блокер СНЯТ** (исключением из области, не откладыванием).
3. **`finance/apar_agent`:** scope ограничен AP/AR (accounts payable/receivable) **БЕЗ credit-terms
   decisioning**; embedded credit sub-function — **declared out-of-scope / disabled** (флаг в
   passport+SOUL: «credit sub-function disabled, EMI no-credit canon»; код не меняется — только декларация).
   **`channel_c_sepa_orchestrator`:** credit-facility-drawdown routing — той же декларацией out-of-scope
   (носитель подтверждён §CREDIT-GAP; флаг при ближайшем правочном окне его паспорта).
4. **Условие будущего:** если BANXE решит выдавать кредиты (включая EMD2 Art.6(1)(b)-форму) — требуется
   отдельный operator-gated change-set + `credit_decision_agent` с полным Annex III §5 high-risk контуром
   (conformity, logging, oversight) ДО запуска. Настоящий канон при этом пересматривается.
5. Fable5-вердикт: **0.93**, C1/C2 — часть формулировки. Прецедентность: при конфликте с любым
   backlog-документом фич действует данный канон (fail-closed).

---
*STEP13 | ENGREF01 | NORMATIVE-PROPOSED (operator decision CEO) | Fable5 0.93 (C1/C2) | sandbox-labeled.*
