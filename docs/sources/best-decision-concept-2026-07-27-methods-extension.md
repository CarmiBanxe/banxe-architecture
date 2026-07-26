---
slug: best-decision-concept-methods-extension
intake-date: 2026-07-27
version: extension-1 (append-only per I-24 — extends, never edits, the sealed SSOT pair)
extends: best-decision-concept-2026-07-06.md (v1 §2–§16 catalog) + best-decision-concept-2026-07-06-v2.md (verbatim, sha256-sealed — MUST NOT be edited)
context: STEP11 ADR-102 dedup — the missing-methods delta lands HERE (new dated SSOT file), because both prior SSOT files are write-sealed (v2 sha256-body, v1 canonical-at-intake). This file completes the method catalog; §M-MAP below is the method-map delta that v2 §11 ("Синтез: Единая Карта Подходов") cannot receive in place.
---
# Best-Decision Concept — Methods Extension (2026-07-27)

> ⚠ SANDBOX / TRAINING context. SSOT-делта: только методы, ОТСУТСТВОВАВШИЕ в v1+v2 (проверено grep-аудитом).
> Уже покрыто и НЕ дублируется здесь: Arrow Impossibility — v1 §13 (полный, с Borda/Condorcet/consensus≥70%);
> Stochastic/Monte-Carlo — v2 (стохастическое программирование, робастная оптимизация, Монте-Карло);
> Fuzzy-TOPSIS-упоминание — v1 §4 (Chen 2000 [13]); Regret/Robust-MCDA — v1 §15.

## E1. Pontryagin Maximum Principle / LQR (непрерывное управление)

Оптимальное управление u*(t) максимизирует гамильтониан: `H(x,u,ψ,t) = ψᵀf(x,u,t) + L(x,u,t)`,
`u*(t) = argmax_u H(x*,u,ψ*,t)` при сопряжённой системе `ψ̇ = −∂H/∂x`. Частный случай — **LQR**:
для `ẋ=Ax+Bu`, `J=∫(xᵀQx+uᵀRu)dt` оптимум `u=−Kx`, `K=R⁻¹BᵀP`, P из уравнения Риккати.
Применение BANXE: непрерывные контуры (treasury-хеджирование, лимит-балансировка) — E-фазы поздние.

## E2. Fuzzy Logic (как самостоятельный метод, не только Fuzzy-TOPSIS)

Нечёткое множество: membership `μ_A(x) ∈ [0,1]`; правила «IF x is A THEN y is B»; дефаззификация
(centroid). Для решений с качественными/лингвистическими критериями без метрики (v1 §4 отмечает слабость
TOPSIS именно там). Применение: скоринг качественных сигналов до передачи в MAUT.

## E3. A* / heuristic search (поиск пути)

`f(n) = g(n) + h(n)`; при **допустимой** эвристике (h не переоценивает) A* оптимален. Применение:
маршрутизация процессов/платёжных путей по графу состояний (rails-выбор как поиск с допустимой оценкой стоимости).

## E4. Decision Trees / Random Forest (интерпретируемость)

Дерево: рекурсивное разбиение по критерию (Gini/entropy gain); лес: бэггинг + случайные подпространства,
голосование. Ценность для BANXE — **объяснимость** (EU AI Act Art.13/15): суррогатные деревья поверх
сложных моделей для клиентских объяснений; feature importance как вход SHAP-контура (ADR-169).

## E5. Fairness-метрики (триада)

- **Demographic parity:** `P(Ŷ=1|A=a) = P(Ŷ=1|A=b)`.
- **Equalized odds:** `P(Ŷ=1|Y=y,A=a) = P(Ŷ=1|Y=y,A=b)` для y∈{0,1}.
- **Predictive parity:** `P(Y=1|Ŷ=1,A=a) = P(Y=1|Ŷ=1,A=b)`.
Теорема несовместимости (Kleinberg 2016 / Chouldechova 2017): при разных base rates все три одновременно
недостижимы → выбор рабочей метрики per-домен = HITL/Compliance-решение (согласуется с Arrow-логикой v1 §13).

## §M-MAP. Дельта карты «задача→метод» (дополнение к v2 §11, которое v2 принять не может — печать)

| Класс задачи | Метод | Где определение |
|---|---|---|
| Непрерывное управление | Pontryagin / LQR | этот файл E1 |
| Качественные/нечёткие критерии | Fuzzy Logic | E2 (+v1 §4 Fuzzy-TOPSIS) |
| Поиск пути по графу | A* (admissible h) | E3 |
| Интерпретируемость/объяснимость | Decision Trees / Random Forest | E4 |
| Fairness-контроль | триада + impossibility → HITL | E5 |

---
*STEP11 | ENGREF01 | append-only SSOT extension (I-24) | sandbox-labeled | PROPOSED.*
