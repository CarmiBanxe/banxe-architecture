# Operator canon — Reperential point amendment 2026-05-05

| Field | Value |
|---|---|
| Date | 2026-05-05 |
| Reperential commit | main @ 9f27f2c (after PR #57 merge) |
| Predecessor canons | IL-CANON-04 (best-decision rule), CLAUDE.md §1, §11 |
| Status | BINDING — applies to Perplexity supervisor + Claude Code + all future sprints in IL-AUDIT-* / IL-FACTORY-AUDIT-* / IL-PROJECT-AUDIT-* family |

## Operator canon — fixation 2026-05-05

Канонические принципы оператора, явно зафиксированные на момент закрытия аудита IL-AUDIT-01 и открытия sprint-ов реализации:

### Principle 1 — Hardware-first

> Сначала железо + модели должны работать корректно. evo1 не должен задыхаться. Только потом — установка факторных моделей на Legion и весь остальной layer оркестрации.

### Principle 2 — evo1 «as-is»

> evo1 (banxe-NucBox-EVO-X2, 100.68.102.48, 30 GiB RAM) используется в текущем виде. Конфигурация production-сервисов (Midaz, Marble, Ballerine, Jube, Keycloak, OpenClaw gateways, Watchman, ClickHouse, n8n, pii-proxy) не меняется без отдельного ADR. Разгрузка evo1 RAM достигается ТОЛЬКО через миграцию stateless-сервисов (Frankfurter, MiroFish первыми) на evo2.

### Principle 3 — evo2 «maximum model without harm»

> evo2 (banxe-nucbox-evo-x2-2, 100.99.208.21, 93 GiB RAM) хостит максимально мощную AI-модель, которую железо может реально обслуживать **без ущерба** (без OOM, без необратимого занятия диска моделью, которая не запускается). Текущий выбор: qwen3:235b-a22b Q3_K_S (142 GB, LIVE на :8082). 470 GB fp16-вариант признаётся избыточным, требует решения по PA-4.

### Principle 4 — Factory-side waits for cluster stability

> Любая работа спринта IL-FACTORY-AUDIT-01 (FA-1..FA-5: ollama+модель на Legion, LiteLLM routes, Keycloak split-brain, Ruflo, agents.md) **ждёт** завершения PA-2 + PA-4 + PA-5 + PA-1 в IL-PROJECT-AUDIT-01.

## Three-action corrective proposal

Корректирующий план реализации, согласованный с Principle 2 + 3:

| Order | PA-ID | Action | Why this order |
|---|---|---|---|
| 1 | PA-2 | Restore evo2 GPU userspace stack (rocm + mesa-vulkan-drivers) | unlocks 2-4× speedup на qwen3:235b — полное использование «без ущерба» прошлой инвестиции в evo2 |
| 2 | PA-4 | Decide qwen3:235b-fp16 fate (keep / quantize-and-archive Q4_K_M or Q5_K_M / delete) | устраняет «ущерб» в виде 470 GB неиспользуемого диска |
| 3 | PA-5 | Migrate stateless services evo1→evo2 (Frankfurter + MiroFish first) | evo1 перестаёт задыхаться **БЕЗ нарушения** Principle 2 («evo1 as-is» — stateful сервисы остаются) |
| 4 | PA-1 | Diagnose & fix midaz-ledger restart loop on evo1 (already on relieved evo1) | устраняем P0 на разгруженном узле, OOM-вероятность ниже |
| 5 | PA-3 | Document model placement matrix | follows naturally after PA-4 outcome |
| 6 | PA-6 | OpenClaw gateways → LiteLLM aliases | orchestration polish, finishing touch |

После окончания PA-1..PA-6 — стартует IL-FACTORY-AUDIT-01 (FA-1..FA-5) на стабильном кластере.

## Binding on Perplexity supervisor

Этот канон **обязателен** для применения Perplexity-supervisor во всех будущих ответах сессии:

1. Любой план / промпт / команду, затрагивающие evo1, evo2, Legion или их модели, Perplexity ОБЯЗАН проверять на соответствие Principle 1-4 ДО выдачи оператору.
2. При предложении любого нового sprint / артефакта Perplexity ОБЯЗАН явно указывать, какому принципу он соответствует или какой принцип нарушает (с обоснованием).
3. При обнаружении конфликта между текущими спринтами и Operator canon — Perplexity ОБЯЗАН остановить выдачу команд, доложить оператору и предложить корректировку до совпадения с каноном.
4. Perplexity ОБЯЗАН ссылаться на этот документ (`docs/canon/operator-canon-2026-05.md`) в каждом sprint kickoff'е семейства IL-FACTORY-AUDIT-* / IL-PROJECT-AUDIT-* / последующих.

Канон IL-CANON-04 (best-decision rule) сохраняется и применяется поверх — Perplexity выбирает best decision **в рамках** Operator canon, а не в его обход.

## Anchors

- IL-AUDIT-01 (PRs #50, #52, #54, #55) — original audit
- IL-FACTORY-AUDIT-01 (PR #57) — factory sprint kickoff (now blocked-on-cluster per Principle 4)
- IL-PROJECT-AUDIT-01 (pending kickoff) — to be re-issued under this canon
- A2 cluster baseline + A3 gap-analysis + A4 orchestration proposal
- IL-CANON-04 (best-decision rule)
- ADR-013 (Midaz primary CBS), ADR-018 (5-layer hybrid AI compute)
- Reperential point: main @ 9f27f2c

## Status history

| Date | Status | Note |
|---|---|---|
| 2026-05-05 | BINDING | Operator canon fixed and amended to reperential point. Perplexity supervisor canon updated. |
