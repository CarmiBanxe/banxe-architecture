# GITNEXUS PHASE 0 — VERIFY: результат (GATE FAIL-CLOSED)

> ⚠ SANDBOX / TRAINING context. STEP15 (артефакт GitNexus, фаза 0/3), ENGREF01, 2026-07-27.
> Директива: `docs/canon/GITNEXUS-CODE-CONTOUR-DIRECTIVE.md` (STEP14). Метод: read-only —
> npm-метаданные БЕЗ исполнения пакета + git-перепись расширений fleet-носителей.

## ВЕРДИКТ PHASE 0: **GATE FAIL-CLOSED — PHASE 1 НЕ СТАРТУЕТ**

**Блокер — лицензионный, обнаружен ДО языкового:**

```
npm view gitnexus:  name=gitnexus  version=1.6.9
license = PolyForm-Noncommercial-1.0.0        ← НЕКОММЕРЧЕСКАЯ
repository = github.com/abhigyanpatwari/GitNexus
```

- BANXE — коммерческий банк (UK EMI). Прогон `npx gitnexus analyze` на код банка, регистрация MCP и
  CI-gate = **коммерческое использование**, запрещённое PolyForm-Noncommercial-1.0.0.
- Собственный license-gate канона: **production core = MIT/Apache-2.0/BSD only** (ADR-171 §3;
  прецедент: AutoGen исключён за CC-BY-NC — идентичный класс ограничения).
- Это ПРАВОВОЕ ограничение третьей стороны — внутренним канон-override не снимается.
- Директива STEP14 сама предписывает «fail-closed» — применён к самому инструменту.

## Языковая матрица (собрана несмотря на блокер — пригодна для любого преемника инструмента)

Заявленное покрытие GitNexus расходится по источникам (13 vs 50+ vs подтверждённые TS/JS/Python) —
из npm-метаданных подтвердить полный список без исполнения пакета нельзя; вопрос снят блокером.

**Фактический состав fleet-носителей (git-перепись, 2026-07-27):**

| Носитель | Языки (файлов) | Покрытие при «TS/JS/Python» |
|---|---|---|
| banxe-architecture: F0-engine-manus-room/runtime | **py 52**, md 2, toml 1 | ✅ python |
| banxe-architecture: F2-safeguarding-room/runtime (safeguarding-engine) | **py 39** | ✅ python |
| banxe-architecture: F2-ledger-room/runtime (recon-perimeter) | **py 18**, md 1 | ✅ python |
| banxe-architecture: tools/sandbox/intent_slice | **py 15**, jsonl 4, json 2 | ✅ python |
| banxe-emi-stack: services/ + api/ (вкл. apar, sepa-orchestrator, webhooks, banking/safeguarding engines) | **py 1004**, yaml/yml 4, j2 3, sh 1, toml 1, Makefile 1 | ✅ python (yaml/sh/sql — конфиги/скрипты, графом AST не критичны) |

**Вывод по языкам:** fleet кодово **Python-доминантен (~99%)** — при подтверждённом Python-покрытии
языковой gate ПРОШЁЛ БЫ; SQL (ClickHouse DDL в sql/) и Bash/YAML — вспомогательные, не-индексация
не критична (fixировать как известный пробел любого AST-инструмента).

## Развилка для оператора (PHASE 1 заблокирована до решения)

| Опция | Содержание | Последствие |
|---|---|---|
| **O1** | Приобрести коммерческую лицензию у автора GitNexus (PolyForm-NC допускает отдельный коммерческий грант) | PHASE 1 стартует по текущему плану |
| **O2** | Заменить инструмент на permissive-аналог (tree-sitter-based code-graph класса; кандидаты — через license-gate: MIT/Apache, Python-покрытие обязательно) | PHASE 1 повторяется с преемником; матрица выше переиспользуется |
| **O3** | Отложить код-контур (директива остаётся ACTIVE как поведенческая норма «enrich→impact→act» без инструментальной автоматизации) | S-GITNEXUS паркуется |

PHASE 2 (memory lock) — частично уже исполнена STEP14 (CLAUDE.md-секция в #1153); финализация — после
решения по O1/O2/O3. PHASE 3 (Fable5 ORG-CONTOUR-VERDICT) — независима от лицензии инструмента ТОЛЬКО
при O2-выборе с иным графом; при O1 — тоже применима; запускается после PHASE 1 по канону артефакта.

---
*STEP15 | ENGREF01 | PHASE 0 выдача | GATE FAIL-CLOSED (license) | HITL: операторская развилка O1/O2/O3.*
