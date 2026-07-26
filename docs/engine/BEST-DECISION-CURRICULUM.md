# BEST-DECISION-CURRICULUM — обучающая программа «лучшее решение» для директора и ВСЕХ агентов

> **STATUS: PROPOSED — обязательна к обучению каждому агенту флота (не только директору); ничего не активировано.**
> ⚠ SANDBOX / TRAINING context (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false).
> STEP9 S-TRAIN+, ENGREF01, 2026-07-26. Источник: Концепция-Лучшего-Решения (полное извлечение, session analytics).
> Связки: `BANKSY-TRAINING-BDSL.md` (цикл дообучения директора), roadmap S-BDSL/S-TRAIN,
> `../canon/BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md` (fail-closed-over-best-decide — арбитр).

## A. Формальное ядро (обязательно каждому агенту)

```
d_opt = argmax_{d∈D} U_D(d) ;   U_D(d) = U_O(f(d))
```

Три предпосылки применимости: (1) исход зависит от d; (2) полезность измерима; (3) решения ранжируемы.
**Нет предпосылок → эскалация к HITL** — нельзя «решать» вне определения задачи решения.

## B. Каталог методов (агент ОБЯЗАН уметь классифицировать задачу → метод)

| Класс задачи | Метод |
|---|---|
| Вероятностная неопределённость | VNM Expected Utility |
| Многокритериальная | MAUT (U=Σ wj·uj) / AHP (веса через попарные сравнения + consistency check) / TOPSIS |
| Последовательная во времени | MDP / Bellman / Q(s,a) / RL |
| Непрерывное управление | Pontryagin Maximum Principle / LQR |
| Мульти-агентная (взаимовлияние) | Game Theory / Nash Equilibrium |
| Поток кандидатов | Secretary 37% (1/e) |
| Конфликтующие цели | Pareto / NSGA-II |
| Нечёткие данные | Fuzzy Logic |
| Обучение на опыте | RL (Q-learning / Policy Gradient / Deep RL) / RLHF |
| Интерпретируемость | Decision Trees / Random Forest |
| Поиск пути | A* (admissible heuristic) |

Классификация фиксируется в DecisionRecord (`stopping_rule`/метод — поля S-BDSL).

## C. Обучение (RL-семейство)

- Q-learning vs Policy Gradient vs Deep RL — выбор по размерности пространства состояний/действий.
- **AlphaGo-Zero self-play паттерн** (MCTS + Policy Net + Value Net) — для директора (симуляция решений
  до исполнения; только в sandbox/TRAINING).
- **RLHF 3 стадии** (preference → reward model → PPO) — строго human-gated (см. BANKSY-TRAINING-BDSL §3).
- **DeLLMa framework** — структура LLM-решений под неопределённостью (enumerate→forecast→utility→choose).

## D. Фундаментальные ограничения (обязательно знать — они ОБОСНОВЫВАЮТ HITL)

- **Arrow Impossibility:** идеальной агрегации предпочтений НЕ существует → окончательное решение при
  конфликте предпочтений = **HITL**, не алгоритм.
- **Bounded Rationality (Simon):** satisficing допустим ТОЛЬКО вне payment/compliance
  (там — full-search, NEVER-AUTONOMOUS лист).
- **NP-hardness:** эвристики/приближения легитимны, но **с обязательной пометкой в DecisionRecord**
  (решение приближённое, не оптимум).

## E. Bias & Fairness (обязательно каждому агенту)

- LLM **усиливают** когнитивные искажения (omission / prospect / anchoring) → contrastive bias-probes
  на каждом агенте и каждой версии политики (порог prospect_bias_rate >0.03 → REVIEW, см. S-TRAIN §7).
- Fairness-метрики: **demographic parity · equalized odds · predictive parity**.
  *(Дополнение при достройке обрыва: по теореме несовместимости (Kleinberg/Chouldechova) все три
  одновременно недостижимы при разных base rates → выбор рабочей метрики per-домен = операторское/
  Compliance-решение, HITL — согласуется с D/Arrow-логикой курса.)*

> **OPEN POINT (обрыв задания):** формулировка S-TRAIN+ оборвалась на «predictive» (секция E, fairness-метрики);
> возможные секции после E (напр. экзаменация/сертификация агентов, привязка к BDT) не получены.
> E достроена минимально-канонично (predictive parity + импоссибилити-нота с HITL-выводом);
> при доставке хвоста — дополнить отдельным коммитом.

## Применение к флоту

- **Обязательность:** curriculum входит в должностную инструкцию каждого агента (S4: поле обучения в
  паспорте); проверка знаний = часть BDT-гейта (S-BDSL/S-TRAIN: authoring 500-case включает задачи
  классификации метода).
- **Директор:** проходит curriculum первым (S-TRAIN Ph0) и владеет Decision Quality Registry по флоту.
- **Fable5-хук F5-TRAIN-2 (новый):** canon экзаменационного минимума агента по curriculum (порог допуска к tier AUTO).

---
*STEP9 S-TRAIN+ | ENGREF01 | PROPOSED | sandbox-labeled | curriculum = обязательная программа флота.*
