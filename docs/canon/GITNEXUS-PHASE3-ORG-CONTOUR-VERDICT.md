# GITNEXUS PHASE 3 — ORG-CONTOUR VERDICT: **Вариант B, топология B3 (оба ребра)**

> **LICENSING / DISCLAIMER:** GitNexus = **PolyForm-Noncommercial-1.0.0**. Sandbox/TRAINING — без лицензии;
> **«PROD/commercial use requires a purchased GitNexus license.»**
> **DESIGNED-FOR-PROD** — спроектировано под будущий прод, не только песочница.
> ⚠ SANDBOX / TRAINING (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false). files-only, NO живой KuzuDB.
> Вердикт оператора зафиксирован; Fable5-запрос ORG-CONTOUR-COVERAGE-VERDICT (директива, PHASE 3) — закрыт этим решением.

## Вердикт

**B (отдельный орг-слой + cross-link), топология B3 = ОБА ребра:**
- **B1 `OWNED_BY`:** (CodeNode) → (Agent|Role) — accountability через passport-reference;
- **B2 `OWNS_PATH`:** (Department) → (PathGlob) — владение зонами `bank-rooms/F*-room/**`.

## Обоснование

(a) **Директива стр.25–26:** граф кода покрывает ТОЛЬКО код-связи (calls/imports/inheritance/flows);
орг-связи — отдельным решением ⇒ орг-слой обязан быть отдельным, соединённым мостами, а не встроенным.
(b) **Довод оператора:** песочница выйдет в прод — закладываем полную структуру сразу, чтобы не переделывать
(DESIGNED-FOR-PROD).
(c) **Комплаенс требует обоих рёбер:** department-impact (B2 — какие департаменты задевает изменение,
CASS/DORA-операционика) И agent/role-accountability (B1 — кто персонально отвечает, SM&CR/Decision Lineage).

## Почему не A и не B1/B2 поодиночке

| Вариант | Отклонён потому что |
|---|---|
| **A** (орг-узлы внутрь графа GitNexus/KuzuDB) | Нарушает директиву стр.25–26 (код-граф = только код-связи); смешение слоёв ломает заменяемость инструмента (PolyForm-NC: при смене инструмента орг-слой пришлось бы выдирать из чужого графа) |
| **B1 отдельно** | Даёт accountability (кто отвечает за файл), но НЕ даёт department-impact: комплаенс-вопрос «какие департаменты задеты» остаётся без ответа — для прод-банка недостаточно |
| **B2 отдельно** | Даёт зоны департаментов, но НЕ даёт персональной ответственности (SM&CR: решение прослеживается к SMF-человеку через агент/роль) — для прод-банка недостаточно |

## Граница слоёв (явная)

**Код-граф** (GitNexus/KuzuDB: calls/imports/inheritance/flows) и **орг-граф** (Department/Role/Agent из
`governance/CANONICAL-ORG-CHART-v2.md` + `docs/DEPARTMENT-MAP.md` + `agents/passports/*.yaml`) — **два слоя**;
соединение ТОЛЬКО cross-link-рёбрами B1/B2 (схема: `config/gitnexus/org-contour.schema.json`; код-узлы там —
external ref, живут в KuzuDB). Обогащение Phase 1 `detect_impact` — `GITNEXUS-PHASE3-CROSSLINK-INTEGRATION-NOTE.md`.

## Фактура (реальные источники, не выдумано)

10 департаментов (DEPARTMENT-MAP §1.1–1.10: Customer Onboarding · AML/Compliance · Payment Operations ·
Core Banking/Ledger · Safeguarding (FCA CASS 7) · Customer Management · Agreement/Contract · Notification ·
Security/Authentication · Reporting/FCA Regulatory) · 70 паспортов `agents/passports/**` (+ `docs/canon/passports/`)
с полями `department` / `bounded_context` (напр. CTX-07-AGREEMENT) / `human_double` / `governance.owner` ·
18 каталогов `bank-rooms/F{0..4}-*-room`. Маппинг B2: `config/gitnexus/org-path-ownership.map.yaml`
(однозначные — сопоставлены, неоднозначные — TODO-operator, NO-MOCK).

---
*PHASE 3 выдача | ENGREF01 | B/B3 | files-only, not committed | 2026-07-27.*
