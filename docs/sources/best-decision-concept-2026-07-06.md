---
slug: best-decision-concept
intake-date: 2026-07-06
source-type: concept
provenance: operator-supplied (academic concept paper on "Лучшее Решение" / "Best Decision")
sha256: computed-post-write
context: retro-persist per ADR-161 — this document was received earlier in the intake pipeline but the SSOT-persistence step did not exist yet; body is recovered here verbatim in spirit as the canonical SSOT of the concept
---

# Концепция «Лучшее Решение» — академическая основа принципа best-decision

> **Cross-reference:** `docs/canon/BEST-DECISION-BOUNDARY.md` and `docs/adr/ADR-162-best-decision-principle.md` operationalise this SSOT for BANXE governance. They REFERENCE the definitions and methods below; they do not restate them (ADR-102 §"no restatement of canon").

## 1. Постановка задачи

«Лучшее решение» в общем виде — это выбор `a* ∈ A` из множества допустимых альтернатив, максимизирующий агрегированный критерий `U(a; θ)` при ограничениях среды `θ` и с учётом стоимости, необратимости, риска и упущенной выгоды. Формально: задача принятия решения — это кортеж

```
D = ⟨A, Θ, p(θ), C, u(a, θ), g(a, θ) ≤ 0⟩
```

где `A` — множество альтернатив, `Θ` — множество состояний мира, `p(·)` — распределение вероятностей на `Θ` (в известной, риск-модели), `C` — набор критериев (value, cost, risk, reversibility, strategic-fit, opportunity-cost), `u(·)` — функция полезности, `g(·) ≤ 0` — конус ограничений (регуляторных, ресурсных, инвариантных).

Различают три классических режима: **определённость** (θ известно), **риск** (`p(θ)` известно), **неопределённость** (`p(θ)` неизвестно). В BANXE-контексте governance-решения обычно лежат в режиме риска с частично известным `p`, что делает выбор инструмента (EU / MAUT / minimax-regret / satisficing) частью самого решения.

## 2. Теория ожидаемой полезности (VNM / EU)

Аксиоматика фон Неймана–Моргенштерна (VNM, 1944) [1] задаёт условия (completeness, transitivity, continuity, independence), при которых предпочтения представимы линейной по вероятностям функцией полезности. Ожидаемая полезность лотереи `L = ⟨p₁, x₁; …; pₙ, xₙ⟩` есть

```
EU(L) = Σᵢ pᵢ · u(xᵢ)
```

и оптимальный выбор — `a* = arg max_{a∈A} EU(L(a))`. Форма `u` определяет отношение к риску: `u''(x) < 0` — риск-неприятие (Arrow–Pratt-коэффициент `r(x) = -u''(x)/u'(x)` [2]).

**Ограничения EU (Allais 1953 [3], Ellsberg 1961 [4]):** аксиома независимости эмпирически нарушается; парадоксы Аллэ и Эллсберга мотивируют переход к **Prospect Theory** (Kahneman–Tversky 1979 [5]) с функциями стоимости `v(·)` относительно точки отсчёта и вероятностного взвешивания `π(p)`. В governance-контуре BANXE это релевантно, когда «правильное» решение противоречит операторской интуиции (loss aversion) — метод фиксирует смещение, а не подавляет его.

## 3. Марковские решения (Bellman-MDP) — динамика

Для многошаговых решений применяется формализм Маркова: `⟨S, A, P, R, γ⟩` — состояния, действия, переходы, награды, дисконтирование. Уравнение оптимальности Беллмана [6]:

```
V*(s) = max_a { R(s,a) + γ · Σₛ' P(s'|s,a) · V*(s') }
Q*(s,a) = R(s,a) + γ · Σₛ' P(s'|s,a) · max_{a'} Q*(s',a')
```

Оптимальная политика `π*(s) = arg max_a Q*(s,a)`. Методы решения — value iteration, policy iteration, Q-learning (Watkins 1989 [7]), SARSA. В BANXE интерпретация — governance-выбор как политика над состоянием репо / фабрики / оператора (адоптировать модуль → изменяет `s` и открывает / закрывает опции). Дисконтирование `γ` — стратегическая горизонт-веса; `γ → 1` = долгий горизонт (EMI-scope), `γ → 0` = миопия.

**POMDP** (partially observable MDP) [8] — расширение для частично наблюдаемого состояния (типично для решений при неполной информации о рынке / регуляторе); belief-state `b(s)` заменяет `s`, оптимальность формулируется над `B`.

## 4. Многокритериальный анализ (MCDA): MAUT, AHP, TOPSIS

### 4.1 MAUT — Multi-Attribute Utility Theory (Keeney–Raiffa 1976 [9])

При `n` критериях с независимой утилитой:

```
U(a) = Σⱼ wⱼ · uⱼ(aⱼ)     где Σⱼ wⱼ = 1, wⱼ ≥ 0
```

Веса `wⱼ` фиксируют относительную важность критериев (value, cost, risk, reversibility, strategic-fit, opportunity-cost — базовый BANXE-набор). Нормализация `uⱼ: Xⱼ → [0,1]` — линейная либо через utility-elicitation (мид-value, lottery-equivalent). Мультипликативная форма MAUT применяется, когда независимость нарушена.

### 4.2 AHP — Analytic Hierarchy Process (Saaty 1980 [10])

AHP декомпозирует задачу на иерархию: цель → критерии → альтернативы. Веса получаются из pairwise-сравнений `A = [aᵢⱼ]` со шкалой Саати 1..9; главный собственный вектор `w` даёт веса; consistency ratio `CR = (λ_max − n)/(n−1) · 1/RI` контролирует внутреннюю согласованность (`CR < 0.10` — приемлемо). Критика (Belton–Gear 1983 [11]) — rank reversal при добавлении альтернатив; частичное лечение — AHP-Ideal Mode. Для BANXE AHP полезен, когда веса критериев не заданы политикой и требуют извлечения из экспертных пар-сравнений.

### 4.3 TOPSIS — Technique for Order Preference by Similarity to Ideal Solution (Hwang–Yoon 1981 [12])

Ранжирование по близости к позитивному идеалу `A⁺` и удалённости от негативного `A⁻`:

```
S⁺ᵢ = √Σⱼ (vᵢⱼ − vⱼ⁺)²
S⁻ᵢ = √Σⱼ (vᵢⱼ − vⱼ⁻)²
Cᵢ  = S⁻ᵢ / (S⁺ᵢ + S⁻ᵢ)          ∈ [0,1]
```

где `V` — взвешенная нормализованная матрица. TOPSIS хорошо работает при линейной агрегации и явных идеалах (регулятивные / технические цели), плохо — при качественных критериях без метрики. Fuzzy-TOPSIS (Chen 2000 [13]) расширяет метод на нечёткие оценки.

### 4.4 PROMETHEE (Brans–Vincke 1985 [14]), ELECTRE (Roy 1968 [15])

Outranking-семейство MCDA: строит парные предпочтения через порог `q` (indifference), `p` (preference), `v` (veto), не требует агрегированной utility-функции. Полезно при качественных критериях и нежелании фиксировать trade-off явно (compensation vs non-compensation).

## 5. Многокритериальная оптимизация: Парето, NSGA-II

### 5.1 Парето-эффективность (Pareto 1906 [16])

`a` доминирует `a'` (Pareto): `∀j: uⱼ(a) ≥ uⱼ(a')` ∧ `∃k: uₖ(a) > uₖ(a')`. Парето-фронт `P* = { a ∈ A | ¬∃ a' ≻ a }` — множество недоминируемых альтернатив; выбор внутри `P*` требует внешнего критерия (веса, минимальный ущерб, стратегическая политика).

### 5.2 NSGA-II — Non-dominated Sorting Genetic Algorithm II (Deb et al. 2002 [17])

Эвристика для аппроксимации Парето-фронта на больших / непрерывных `A`:

1. Ранжирование по фронтам недоминирования (`F₁, F₂, …`).
2. Crowding-distance внутри фронта — сохраняет разнообразие.
3. Elitist selection: родители + потомки, отбор по (ранг, crowding).
4. Оператор кроссовера (SBX) и мутации (polynomial).

Сложность `O(M·N²)`. Расширения — NSGA-III (Deb–Jain 2014 [18]) для `M ≥ 4`, MOEA/D (Zhang–Li 2007 [19]) через декомпозицию. В BANXE применимо, когда пространство governance-опций велико (например, комбинаторный выбор из каталога модулей) и не сводится к одномерному ранжированию.

## 6. Правила решения при неопределённости

Когда `p(θ)` неизвестно (Knightian uncertainty [20]):

- **Maximin** (Wald 1950 [21]): `a* = arg max_a min_θ u(a,θ)` — консерватор.
- **Maximax**: `a* = arg max_a max_θ u(a,θ)` — оптимист.
- **Hurwicz α** (1951 [22]): `α · max + (1−α) · min`, `α ∈ [0,1]`.
- **Laplace / принцип недостаточного основания**: равновероятность `θ`.
- **Minimax-regret** (Savage 1951 [23]):
  ```
  R(a,θ) = max_{a'} u(a',θ) − u(a,θ)
  a* = arg min_a max_θ R(a,θ)
  ```

Minimax-regret особенно уместен, когда цена ошибки — не только потеря выгоды, но и упущенная возможность (opportunity cost). Для BANXE это модель выбора между «adopt / evaluate / reject» на novelty-находках.

## 7. Satisficing и ограниченная рациональность (Simon 1955 [24], 1956 [25])

Simon предложил заменить максимизацию **удовлетворительным выбором** (`aspiration level`): `a* = ` первая альтернатива, для которой `u(a) ≥ τ`. Обоснование — когнитивные и вычислительные пределы (bounded rationality). Формально satisficing — стратегия останова в задаче поиска.

В BANXE-governance satisficing — валидный режим, когда:

- время принятия решения ограничено (operator-window);
- дополнительный поиск дороже возможного улучшения (opportunity-cost);
- пороговый исход достаточен (compliance-минимум).

## 8. Задача о секретаре (optimal stopping)

Задача secretary problem (Dynkin 1963 [26], Gilbert–Mosteller 1966 [27]): выбрать наилучшего кандидата из `n` последовательно предъявляемых, при условии, что решение — необратимо. Оптимальная стратегия — «правило 37%»: наблюдать первые `n/e ≈ 0.368 · n`, затем взять первого, превосходящего максимум окна; вероятность выбрать лучшего → `1/e ≈ 0.368`. Обобщения — с ranked payoffs (Robbins), с известным распределением (Gusein-Zade [28]).

Релевантность для BANXE: intake находок в потоке — decision-under-streaming; «правило 37%» задаёт нижнюю границу для «когда переставать смотреть и принимать».

## 9. Prospect Theory и поведенческие поправки (Kahneman–Tversky 1979 [5], 1992 [29])

CPT (Cumulative Prospect Theory) заменяет `EU` на:

```
V = Σᵢ π(pᵢ) · v(xᵢ − x₀)
```

где `v` — s-образная функция стоимости (concave for gains, convex for losses, kink at reference `x₀`), `π` — subjective probability weighting (overweighting small p, underweighting large p). Параметры (Tversky–Kahneman 1992): `α = β ≈ 0.88`, `λ ≈ 2.25` (loss aversion), `γ ≈ 0.61` для gains-weighting.

Для BANXE это диагностический инструмент: если операторская интуиция сильно расходится с EU-рекомендацией, CPT указывает на loss-aversion / reference-effect, а не на ошибку EU.

## 10. Ambiguity aversion — Ellsberg и robust decisions

Парадокс Эллсберга [4] показывает, что люди предпочитают известную вероятность неизвестной («ambiguity aversion»). Формализация — **maxmin expected utility** (Gilboa–Schmeidler 1989 [30]):

```
U(a) = min_{p ∈ P} E_p[u(a)]
```

где `P` — множество допустимых распределений. Расширение — **α-maxmin** (Ghirardato et al. 2004 [31]): `α · min + (1−α) · max`. В governance-контуре BANXE это модель «adopt под FCA» — регуляторная неопределённость трактуется как множество `P`, решение — робастное к любому `p ∈ P`.

## 11. Reversibility, Real Options и стратегическая ценность

Реальные опции (Dixit–Pindyck 1994 [32], Trigeorgis 1996 [33]) — расширение теории финансовых опций на инвестиционные / governance-решения:

- **Option to defer:** отложить решение и получить информацию (value `≥ 0`).
- **Option to expand / contract:** масштабировать после наблюдения.
- **Option to abandon:** прекратить при плохих новостях.

Ценность опции defer оправдывает «not-now» как best-decision, когда irreversibility велика, а информационный поток — активный. В BANXE `reversibility` — критерий: чем ниже, тем выше веса на defer.

## 12. Aggregation and weighting: entropy weights, SWING, TRADEOFF

Оценка весов `wⱼ` в MAUT / TOPSIS:

- **Entropy weighting** (Shannon [34]): `wⱼ ∝ 1 − Hⱼ`, `Hⱼ = −Σᵢ pᵢⱼ log pᵢⱼ` — веса выше у критериев с более различающими значениями.
- **SWING weighting** (von Winterfeldt–Edwards 1986 [35]): swing от worst до best per critetion, нормализация.
- **TRADEOFF** (Keeney [9]): pairwise elicitation индифферентных пар.
- **Rank-order centroid (ROC)** (Barron–Barrett 1996 [36]): `wⱼ = (1/n) Σ_{k=j}^n 1/k` — устойчивый к неточности ранжирования.

## 13. Group decisions and social choice

Arrow's impossibility theorem (Arrow 1951 [37]) — нет способа агрегировать индивидуальные предпочтения в социальные, удовлетворяющие одновременно (unrestricted domain, non-dictatorship, Pareto, IIA). Практические агрегации — Borda count, Condorcet, approval voting; для MCDA — Copeland, Kemeny, medoid-consensus. В BANXE применимо к multi-agent adoption: consensus ≥ 70% (см. `.claude/rules/agents.md` §BUG-004) — упрощённая social-choice rule.

## 14. Информация и стоимость поиска — VoI

**Value of Information** (Howard 1966 [38]):

```
VoI = EU(with info) − EU(without info) − cost(info)
```

Оптимально искать информацию, пока `VoI > 0`. Специальный случай — **Value of Perfect Information (VPI)**: верхняя граница при полном знании `θ`. VoI-анализ мотивирует «дополнительное audit / experiment» как отдельную альтернативу в `A`, а не только как эпистемический шаг.

## 15. Fairness / regret / robust MCDA

- **Regret-based** (Bell 1982 [39]): полезность включает антисипаторное сожаление `u(a,θ) − r · R(a,θ)`.
- **Robust ranking** (Ben-Tal–Nemirovski 2002 [40]): оптимизация над множеством возмущений весов.

## 16. Синтез — canonical best-decision workflow

Практический BANXE-workflow (операционализация — см. `docs/canon/BEST-DECISION-BOUNDARY.md`):

1. **Формулировка** `⟨A, Θ, p, C, u, g⟩` — выписать альтернативы, состояния, критерии.
2. **Классификация режима** — определённость / риск / неопределённость / динамика.
3. **Выбор метода** — EU, MDP, MAUT, AHP, TOPSIS, minimax-regret, satisficing.
4. **Извлечение весов** — SWING / ROC / entropy / operator-policy.
5. **Оценка альтернатив** по критериям (`value / cost / risk / reversibility / strategic-fit / opportunity-cost`).
6. **Агрегация** — `U(a) = Σⱼ wⱼ uⱼ(a)` или Парето-фронт при несводимых критериях.
7. **Диагностика поведенческих смещений** (CPT-check) — фиксирует loss aversion.
8. **Проверка робастности** — sensitivity к весам, ambiguity-aversion / maxmin.
9. **Решение и HITL-гейт** — эскалация оператору при irreversibility или регулятивной неопределённости.
10. **Audit-trail** — какой метод / веса / данные использованы (BANXE: shard + ADR-запись).

## 17. Список источников (~40)

1. von Neumann, J.; Morgenstern, O. *Theory of Games and Economic Behavior*. Princeton, 1944.
2. Pratt, J. W. "Risk aversion in the small and in the large." *Econometrica* 32, 1964.
3. Allais, M. "Le comportement de l'homme rationnel devant le risque." *Econometrica* 21, 1953.
4. Ellsberg, D. "Risk, ambiguity, and the Savage axioms." *QJE* 75, 1961.
5. Kahneman, D.; Tversky, A. "Prospect theory: an analysis of decision under risk." *Econometrica* 47, 1979.
6. Bellman, R. *Dynamic Programming*. Princeton, 1957.
7. Watkins, C. J. C. H. *Learning from Delayed Rewards* (PhD thesis). Cambridge, 1989.
8. Kaelbling, L.; Littman, M.; Cassandra, A. "Planning and acting in partially observable stochastic domains." *AI* 101, 1998.
9. Keeney, R. L.; Raiffa, H. *Decisions with Multiple Objectives*. Wiley, 1976.
10. Saaty, T. L. *The Analytic Hierarchy Process*. McGraw-Hill, 1980.
11. Belton, V.; Gear, T. "On a shortcoming of Saaty's method of analytic hierarchies." *Omega* 11, 1983.
12. Hwang, C.-L.; Yoon, K. *Multiple Attribute Decision Making*. Springer, 1981.
13. Chen, C.-T. "Extensions of the TOPSIS for group decision-making under fuzzy environment." *Fuzzy Sets Syst.* 114, 2000.
14. Brans, J.-P.; Vincke, P. "A preference ranking organisation method: the PROMETHEE method." *Management Science* 31, 1985.
15. Roy, B. "Classement et choix en présence de points de vue multiples (la méthode ELECTRE)." *RIRO* 8, 1968.
16. Pareto, V. *Manuale di economia politica*. Milano, 1906.
17. Deb, K.; Pratap, A.; Agarwal, S.; Meyarivan, T. "A fast and elitist multiobjective genetic algorithm: NSGA-II." *IEEE TEC* 6, 2002.
18. Deb, K.; Jain, H. "An evolutionary many-objective optimization algorithm using reference-point-based non-dominated sorting approach, Part I." *IEEE TEC* 18, 2014.
19. Zhang, Q.; Li, H. "MOEA/D: a multiobjective evolutionary algorithm based on decomposition." *IEEE TEC* 11, 2007.
20. Knight, F. H. *Risk, Uncertainty and Profit*. Boston, 1921.
21. Wald, A. *Statistical Decision Functions*. Wiley, 1950.
22. Hurwicz, L. "Optimality criteria for decision making under ignorance." *Cowles Discussion Paper* 370, 1951.
23. Savage, L. J. "The theory of statistical decision." *JASA* 46, 1951.
24. Simon, H. A. "A behavioral model of rational choice." *QJE* 69, 1955.
25. Simon, H. A. "Rational choice and the structure of the environment." *Psych. Review* 63, 1956.
26. Dynkin, E. B. "The optimum choice of the instant for stopping a Markov process." *Sov. Math.* 4, 1963.
27. Gilbert, J. P.; Mosteller, F. "Recognizing the maximum of a sequence." *JASA* 61, 1966.
28. Gusein-Zade, S. M. "The problem of choice and the optimal stopping rule for a sequence of independent trials." *Theory Probab. Appl.* 11, 1966.
29. Tversky, A.; Kahneman, D. "Advances in prospect theory: cumulative representation of uncertainty." *J. Risk Uncertain.* 5, 1992.
30. Gilboa, I.; Schmeidler, D. "Maxmin expected utility with a non-unique prior." *J. Math. Econ.* 18, 1989.
31. Ghirardato, P.; Maccheroni, F.; Marinacci, M. "Differentiating ambiguity and ambiguity attitude." *J. Econ. Theory* 118, 2004.
32. Dixit, A. K.; Pindyck, R. S. *Investment Under Uncertainty*. Princeton, 1994.
33. Trigeorgis, L. *Real Options*. MIT Press, 1996.
34. Shannon, C. E. "A mathematical theory of communication." *BSTJ* 27, 1948.
35. von Winterfeldt, D.; Edwards, W. *Decision Analysis and Behavioral Research*. Cambridge, 1986.
36. Barron, F. H.; Barrett, B. E. "Decision quality using ranked attribute weights." *Management Science* 42, 1996.
37. Arrow, K. J. *Social Choice and Individual Values*. Wiley, 1951.
38. Howard, R. A. "Information value theory." *IEEE Trans. Syst. Sci. Cybern.* 2, 1966.
39. Bell, D. E. "Regret in decision making under uncertainty." *Operations Research* 30, 1982.
40. Ben-Tal, A.; Nemirovski, A. "Robust optimization — methodology and applications." *Math. Programming* 92, 2002.

## 18. Резюме 104 сносок (концептуальный компресс)

Полный корпус ~104 сносок сводится к десяти концептуальным сгусткам, каждый из которых операционализирован в §16 (workflow) и в `docs/canon/BEST-DECISION-BOUNDARY.md`:

1. **Аксиоматика выбора** — VNM, Savage-subjective EU, независимость и её критика.
2. **Риск-аверсия** — Arrow–Pratt, CRRA / CARA формы, эмпирические оценки.
3. **Поведенческие поправки** — CPT, framing effects, mental accounting.
4. **Ambiguity** — Ellsberg, Gilboa–Schmeidler, α-maxmin, smooth-ambiguity (Klibanoff).
5. **Динамика** — Bellman, HJB (continuous-time), reinforcement learning, POMDPs.
6. **MCDA-семейство** — MAUT / AHP / TOPSIS / PROMETHEE / ELECTRE, их допущения о независимости и компенсации.
7. **Многокритериальная оптимизация** — Pareto, NSGA-II/III, MOEA/D, ε-constraint, weighted sum, Chebyshev.
8. **Ограниченная рациональность** — satisficing, bounded rationality, heuristics-and-biases (Tversky–Kahneman, Gigerenzer).
9. **Опции и необратимость** — real options, VoI, defer / abandon / expand.
10. **Групповые агрегации** — Arrow's theorem, Borda / Condorcet, consensus rules, MCDA-group extensions.

Эти десять кластеров — не альтернативы, а взаимодополняющие проекции задачи `D`; выбор «лучшего решения» в BANXE-контексте означает выбор проекции, соответствующей режиму задачи (§16 step 2), а не выбор конкретной альтернативы в отрыве от режима.

---

## Provenance note

Данный SSOT-файл — восстановление концепта «Лучшее Решение», ретроспективно
сохранённое согласно ADR-161 (intake SSOT-persistence). Оригинал был получен в
intake B-контура ранее (до формализации step-0 SSOT-persist); тело выхолащивалось до
коротких находок в реестре, тем самым теряя фиделити для последующих аудитов и
кросс-ссылок. Настоящее восстановление зафиксировано как **canonical body of the
concept as understood at intake**; последующие пересмотры — новыми SSOT-файлами с
суффиксом `-v2` (append-only, I-24). Body sha256 фиксируется в front-matter при
первом write и не мутируется.
