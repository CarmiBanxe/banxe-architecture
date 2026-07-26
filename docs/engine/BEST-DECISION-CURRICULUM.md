# BEST-DECISION-CURRICULUM — обучающая траектория «лучшее решение» для директора и ВСЕХ агентов

> **Pointer-first per ADR-102: этот файл НЕ определяет методы — все определения живут в SSOT.**
> SSOT: `../sources/best-decision-concept-2026-07-06.md` (v1, §2–§16) ·
> `../sources/best-decision-concept-2026-07-06-v2.md` (verbatim, sha256-sealed) ·
> `../sources/best-decision-concept-2026-07-27-methods-extension.md` (E1–E5 + §M-MAP).
> Операционализация: ADR-162 (best-decision-principle) · ADR-164 (agent-method, D-2) ·
> `../canon/BEST-DECISION-BOUNDARY.md` (§7 v2) · SOUL `## Decision Method` (per-agent).
> **STATUS: PROPOSED — обязательна каждому агенту флота.** ⚠ SANDBOX/TRAINING (BANXE_ENV=sandbox).
> STEP9 S-TRAIN+ / STEP11 dedup, ENGREF01.

## Уникальное содержание этого файла: ТРАЕКТОРИЯ обучения (что агент обязан освоить и в каком порядке)

### Ступень 1 — Формальное ядро
Освоить: определение d_opt/U_D, три предпосылки применимости, правило «нет предпосылок → HITL».
→ SSOT v1 §1–§2; BOUNDARY §7 v2 (best-decision = метод исполнения решения оператора).

### Ступень 2 — Классификация задача→метод (указатель, БЕЗ определений)

| Класс задачи | Метод | Определение в SSOT |
|---|---|---|
| Вероятностная неопределённость | VNM Expected Utility | v1 §2 |
| Многокритериальная | MAUT / AHP / TOPSIS | v1 §4 |
| Последовательная во времени | MDP / Bellman / RL | v1 §3 |
| Непрерывное управление | Pontryagin / LQR | extension E1 |
| Мульти-агентная | Game Theory / Nash | v2 (games-раздел) |
| Поток кандидатов | Secretary 37% | v1 §8 |
| Конфликтующие цели | Pareto / NSGA-II | v1 §5 |
| Нечёткие данные | Fuzzy Logic | extension E2 (+v1 §4) |
| Обучение на опыте | RL / RLHF | v2 (RLHF-раздел) |
| Интерпретируемость | Trees / Random Forest | extension E4 |
| Поиск пути | A* | extension E3 |
| Стохастика/робастность | Monte-Carlo / robust | v2 (стохастич. программирование); v1 §10 |

Классификация фиксируется в DecisionRecord (схема — canon BEST-DECISION-SELF-LEARNING-LOOP).

### Ступень 3 — Обучение на опыте
Q-learning vs Policy Gradient vs Deep RL; AlphaGo-Zero self-play (директор, sandbox-only); RLHF 3 стадии
human-gated; DeLLMa. → v2 (RL/RLHF-разделы); операционный цикл — `BANKSY-TRAINING-BDSL.md`.

### Ступень 4 — Ограничения, обосновывающие HITL
Arrow Impossibility → v1 §13 (конфликт предпочтений решает человек); Bounded Rationality/satisficing →
v1 §7 (satisficing ЗАПРЕЩЁН в payment/compliance — NEVER-AUTONOMOUS, canon SELF-LEARNING-LOOP);
NP-hard → эвристика с обязательной пометкой в DecisionRecord.

### Ступень 5 — Bias & Fairness
Prospect/anchoring/omission → v1 §9 + contrastive probes (canon SELF-LEARNING-LOOP);
fairness-триада + теорема несовместимости → extension E5 (выбор метрики = HITL/Compliance).

## Экзаменация и допуск

- Прохождение траектории = поле **curriculum-статус** в паспорте агента (roadmap S4); допуск к tier AUTO —
  только с пройденным curriculum; проверка — частью BDT-гейта (canon SELF-LEARNING-LOOP; authoring 500-case
  включает задачи классификации Ступени 2).
- Директор проходит первым (S-TRAIN Ph0); Fable5-хук F5-TRAIN-2 — canon экзаменационного минимума.
- Согласованность: CEO-человек решает (`../canon/CEO-UNITARY-AUTHORITY-CANON.md`); агент применяет методы
  только как исполнитель (D-2/I-27/I-28 целы).

---
*STEP11 | ENGREF01 | pointer-first (ADR-102) | единственный источник определений = SSOT-тройка выше.*
