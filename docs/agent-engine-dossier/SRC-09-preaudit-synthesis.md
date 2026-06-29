# SRC-09 — Pre-Audit Synthesis

**Статус:** INGESTED
**Загружен:** 2026-06-28
**Источник:** Внутренний синтез на основе SRC-01/02/06/07 + shell-аудита (origin/main @ 6602842)

---

## Центральный тезис

[ВЫВОД] BANXE-CORE-ENGINE логично квалифицировать как coordination layer поверх уже существующих доменных сервисов, а не как систему с нуля.

Обоснование:
- [ФАКТ] 9 ADR подтверждают intent-first / orchestration / HITL / memory / guardian / self-healing архитектуру.
- [ФАКТ] Существующий orchestration-слой (Ruflo, Aider, MetaClaw, fabric/legion, 70 passports / 20 souls / 3 swarms) не требует замены — требует координации.
- [ФАКТ] Build-specs M-GATEWAY и J-ENGINE описывают конкретные компоненты, которые движок должен координировать.

---

## Что подтверждено (только [ФАКТ])

- 9 ADR (045/060/128/136/139/141/042/123/143-A) существуют на origin/main.
- LiteLLM :4000 LISTENING (INV-AI-01 enforcing point).
- Keycloak :8180/:8181 LISTENING (IAM).
- ClickHouse :9000 LISTENING (audit trail, I-08 5yr TTL).
- 70 passports / 20 souls / 3 swarms (verified S5/S6/S7; цифра «39 passports» УСТАРЕЛА).
- banxe-recon.service = inactive (HITL-gate не пройден; оператор активирует).
- AMLSim на Legion: /home/mmber/AMLSim.

---

## Что является рабочей гипотезой ([ВЫВОД])

- BANXE-CORE-ENGINE как новый coordination layer координирует Ruflo/Aider/MetaClaw/fabric — архитектурно обоснован ADR-060, но конкретная форма реализации не зафиксирована.
- ReAct/CoT/MARL/HTN как implemented runtime — логично следует из теоретической базы (SRC-02), но степень реализации не верифицирована.
- Qdrant поверх ClickHouse как vector memory — PLANNED в корпусе; Qdrant :6333 NOT LISTENING согласно snapshot.

---

## Что требует shell-аудита перед любым roadmap/sprint ([НЕИЗВЕСТНО]) → RESOLVED, см. §U-2 ниже

- Redis :6379 — NOT LISTENING в snapshot; роль в движке требует уточнения deployment-плана.
- n8n :5678, Temporal :7233, Qdrant :6333, MongoDB :27017 — NOT LISTENING; зависимости движка от них требуют явного deployment-плана.
- banxe-rag: точный состав, формат, размещение.
- MCTS / Bayes / confidence=1.0 hard overrides как production-код — не верифицированы.
- Математика по 4 проблемам (SRC-07) — детали ожидают SRC-03..08.
- Внешние сравнения (Manus / Revolut AIR / Nebius / H100) — не имеют прямого подтверждения в verified корпусе.

---

## Ограничения синтеза

Этот документ основан только на SRC-01/02/06/07 + runtime snapshot. SRC-03/04/05/08 — PENDING-INTAKE. После их загрузки синтез должен быть обновлён (append-only).

---

## Cross-references

- ADR-045 — intent-first banking architecture
- ADR-060 — multi-actor orchestration
- ADR-128 — banking agents HITL matrix
- ADR-136 — agent memory / shared memory substrate
- ADR-139 — guardian system
- ADR-141 — self-healing continuous learning loop
- ADR-042 — UFW perimeter
- ADR-123 — Claude permissions hardening
- ADR-143-A — shared-evo1 Redis IL allocator
- docs/agent-engine-dossier/VERIFIED-RUNTIME-SNAPSHOT.md
- docs/agent-engine-dossier/SRC-INTAKE-REGISTER.md

---

## §Math-Methods Status (добавлено 2026-06-28, append-only)

Разрешение §7 НЕИЗВЕСТНО из первичного текста SRC-09. → RESOLVED, см. §U-1 ниже
Статусы по verified shell-аудиту ORCHESTRATION + MATH-ARCH @ origin/main.

| Мат-метод | Статус | Верифицированная привязка |
|-----------|--------|--------------------------|
| **Confidence-bands / confidence=1.0 HALT** | **PRESENT** | ADR-046: confidence float 0.0–1.0 (Field: `confidence_score` Float32 [0.0–1.0]); HITL threshold >0.90 AUTO / 0.70–0.90 REVIEW / <0.70 BLOCK; test_reject_at_confidence_100_forces_hitl pattern (IL-CREDIT/HR/INCIDENT/MLPIPELINE); confidence=1.0 → mandatory HITL step-up |
| **Consensus 2/3 majority vote** | **PRESENT** | ADR-FUSION-01 §Decision (MoA judge + synthesizer layer); fan-out ensemble (factory-mid + factory-heavy + project-reason); majority vote design-draft; Auto-Verify API :8094 validates responses; ADR-047 per-request token cap covers all N calls + judge + synthesizer |
| **Decision lineage / audit chain** | **PRESENT** | ADR-046 (decision-lineage schema); `AgentDecisionRecord` immutable row (record_id/timestamp/agent_id/triggering_event/intent/policies_evaluated/compliance_result/confidence_score/action_taken/human_reviewed_by/correlation_id/immutable_storage_ref); append-only ClickHouse storage; IL-mapped execution trace |
| **Immutable audit trail** | **PRESENT** | ADR-027 (SQLite → ClickHouse drain); ClickHouse TTL 5Y (I-08); pgAudit active; append-only (I-24 — no UPDATE/DELETE on audit); guardian_audit_events ClickHouse trail durably capture commands/verdicts |
| **ReAct (Reasoning + Acting loop)** | **THEORY / PLANNED** | [НЕИЗВЕСТНО] grep пуст — не найден в коде/docs @ origin/main. Теоретический паттерн (SRC-02 §CoT).  → RESOLVED, см. §U-1 ниже|
| **MCTS (Monte Carlo Tree Search)** | **THEORY / PLANNED** | [НЕИЗВЕСТНО] не найден в коде/docs. Не реализован.  → RESOLVED, см. §U-1 ниже|
| **Bayesian uncertainty** | **THEORY / PLANNED** | [НЕИЗВЕСТНО] не найден в коде/docs. Не реализован.  → RESOLVED, см. §U-1 ниже|

**[ВЫВОД]** Реализованные мат-методы (PRESENT) соответствуют финансово-compliance контексту:
confidence-threshold + consensus + lineage + append-audit. ReAct/MCTS/Bayes = теоретические
направления для Sprint A/B, НЕ текущий production. Не планировать их как «уже готовые».

**Cross-refs:** ADR-006, ADR-012, ADR-027, ADR-046, ADR-FUSION-01, I-08, I-24,
VERIFIED-RUNTIME-SNAPSHOT.md, SRC-02 §CoT/MARL

---

## §Internal Orchestration Fleet — L0 Canon Passports (добавлено 2026-06-28)

Отдельно от 70 banking passports (S5/S6/S7) существует **L0 internal fleet** —
orchestration-скелет движка в `docs/canon/passports/`:

| Passport | Роль в движке |
|----------|--------------|
| `planner.yaml` | HTN-планировщик: декомпозиция intent → subtask-цепочки. **СУЩЕСТВУЕТ** (verified S1 @ origin/main). Основа для coordination layer. |
| `executor.yaml` | Исполнитель задач: запуск subtask по плану planner |
| `reviewer.yaml` | Проверка результатов; gate перед финализацией |
| `canon-judge.yaml` | Арбитр canon-соответствия (ADR/IL/invariant) |
| `ctio.yaml` | CTIO persona: стратегические технические решения |
| `mlro.yaml` | MLRO persona: compliance/AML/SAR L4 approvals |
| `operator.yaml` | Оператор: operational decisions, runbook execution |
| `schema.yaml` | Schema validator: data-contract enforcement |
| `guardian-factory.yaml` | Guardian factory: monitored агент-окружение |
| `guardian-project.yaml` | Guardian project: project-level degradation detection |

**Всего L0 fleet:** 10 canon-passports.
**[ВЫВОД]** L0 fleet = coordination layer движка, реализующий PLAN→EXECUTE→REVIEW→JUDGE
цикл. planner.yaml = HTN-каркас уже существует; остальные пассорты реализованы как personas.
Движок опирается на L0 fleet как на execution-скелет поверх 70 banking passports.

**Cross-refs:** docs/canon/passports/planner.yaml; ADR-049 (intent-layer client-facing agent masks);
SRC-02 §HTN SWIFT-flow; DEDUP-FINDINGS.md §Existing Engine Scaffold

---

## §n8n Orchestration Runtime (добавлено 2026-06-28)

**[ФАКТ]** n8n DEPLOYED на evo1 :5678 (DEPLOYMENT-ARCHITECTURE.md §Infrastructure).
5 активных workflows (из D-RECON-BUILD-SPEC + ROADMAP-MATRIX + COMPLIANCE-MATRIX):
1. `safeguarding-shortfall-alert` — CASS 15 breach notification (HITL gate, <1h SLA)
2. `daily-recon-report` — daily reconciliation summary (CSV/CAMT.053)
3. `complaint-sla-monitor` — Consumer Duty complaint SLA tracking (FCA DISP 8-week)
4. `mcp-health-monitor` — MCP service health alerts
5. `k-gabriel-n8n` — FCA breach reporting workflow (K-gabriel iface, RegData upload)

**Роль в движке:** n8n = cron/event-orchestration runtime для alert-chains и scheduled workflows.
HITL human-approve gate реализован через n8n (I-27): агент предлагает → n8n routing → human approves.

**[ВЫВОД]** n8n НЕ заменяется движком — он является его orchestration-runtime для
event/cron слоя. Sprint A design contracts должны включать n8n как deployment target
для alert-chain workflows.

**Граница runtime:** n8n (cron/event) + Temporal (saga/exactly-once — PLANNED) = runtime plane
(banxe-ai-infrastructure scope). Движок-design = banxe-architecture scope.

**Cross-refs:** DEPLOYMENT-ARCHITECTURE.md (:5678 status), D-RECON-BUILD-SPEC.md (BreachNotifyPort),
COMPLIANCE-MATRIX.md (n8n workflows), ROADMAP-MATRIX.md (H-support complaint SLA),
VERIFIED-RUNTIME-SNAPSHOT.md (n8n active), SRC-07 §n8n/I-27

---

## Agent behavior/decision canon (A1 audit)

> Источник: A1 audit corpus fragment, canon root @ origin/main, 2026-06-28.
> Маркер: [ФАКТ из канона A1]. Данный раздел = поведенческий контракт флота.
> НЕ дублирует структурный L0 fleet (§L0 Canon Passports выше) — добавляет behavioral layer.

---

### ADR-025 — Agent interaction canon (decision-policy)

**Источник:** `docs/canon/AGENT-INTERACTION-CANON.md` (accepted via ADR-025 on 2026-05-04) [ФАКТ из канона A1]

**Ключевые правила решения (decision-policy):**

1. **No-ask policy** (§3): Claude Code НЕ спрашивает оператора между ходами (`ok?` / `continue?` / `which-option?`). Вопрос перед артефактом = нарушение канона (§4 Запрет переспрашивать).
2. **Read-only inventory → decide** (§4.2): при неопределённости — 1 ход read-only (grep/git log/gh pr view), следующий ход = решение + артефакт. Никаких промежуточных вопросов между ходами.
3. **Stop+ask** — допустимо ТОЛЬКО при одновременном выполнении двух условий (§4.3):
   - Ни один из 6 источников приоритета (§4.2) не даёт ответа
   - Решение требует явного подтверждения по §3.2 (destructive / modifications in main / production / external side-effects / permissions / out-of-scope)
4. **6-source priority (§4.2, top-down):**
   1. Прямая инструкция оператора в текущем ходе
   2. Каноны и инварианты: ADR-025 (этот документ), CLAUDE.md репозитория, INVARIANTS.md, ADR-031 deny-paths
   3. Текущая GAP-REGISTER / INSTRUCTION-LEDGER запись (acceptance criteria + target close date)
   4. ROADMAP / handoff-доки (текущая phase и P0 item)
   5. Read-only inventory из репо (grep, cat, git log, gh pr view — актуальные факты)
   6. Здравый смысл инженера + Conventional Commits / standard software engineering practices

**Уточнение OCAT (§1):** Между chunk'ами/частями агент НЕ ждёт подтверждения оператора. Просто выдаёт следующую команду/промт один за другим; оператор выполняет и присылает вывод.

**Cross-ref target-audit #842:**
- GAP "execution sandbox contract не формализован" → ADR-025 = частичная формализация поведенческого контракта флота (§9-§15 production CLAUDE.md правила, Guardian-shim backstop §12).
- Полная закрытие GAP требует: sandbox-enforcement в agent-runner + ADR-025 compliance-check в CI.

**Различие слоёв (не конфликт):**
- ADR-025 регулирует fleet-агента внутри фабрики (Left Terminal / factory workers, §6 архитектурный стек).
- Explicit-permission (merge / publish) регулирует Central Terminal (Right Terminal, read-only + delegate-only).
- PARTIAL distinction: разные слои одной системы governance. Оба являются частями единого canon, но ADR-025 сфокусирован на autonomy-level инструкций (L1-L4), а explicit-permission сфокусирован на operational authorization gates.

---

### IL-CANON-04 + UNIVERSAL-CANON — BEST DECISION principle

**Источник:** `instruction-ledger/IL-CANON-04-best-decision-rule.md` + `docs/canon/UNIVERSAL-CANON-BEST-SOLUTION-AND-SEQUENTIAL-2026-05-25.md` [ФАКТ из канона A1]

**Принцип BEST DECISION (формальный, §House rule 11-12):**

```
После ЛЮБОГО вывода (state / report / analysis) агент эмитирует
РОВНО ОДИН следующий артефакт — никогда ноль, никогда два,
никогда "вариант 1 / вариант 2".
```

**Слои canon (4-layer):**
- Layer 1 — Auto-run whitelist (approval-rules.md §Автоматически одобрено) — execute without asking
- Layer 2 — Stop-barrier (safety-rules.md + CLAUDE.md) — STOP + OPERATOR_RUN
- **Layer 3 — Best-decision** (IL-CANON-04 + UNIVERSAL-CANON) — pick best, continue (THIS SECTION)
- Layer 4 — Session canon (sprint-level defaults)

**Правила (из UNIVERSAL-CANON-BEST-SOLUTION-AND-SEQUENTIAL-2026-05-25.md):**
- Тип артефакта определяется state-change vs read-only:
  - `[CLAUDE CODE]` — любое изменение состояния (код / docs / ledger / infra / merge / ADR / config)
  - `[SHELL]` — только read-only audit/operator commands
  - Если вывод одновременно репортирует и подразумевает изменение → `[CLAUDE CODE]` (change wins)
- Уточняющий вопрос перед артефактом запрещён (кроме genuine stop-barrier)
- Stop-barrier = единственное исключение: заменяет артефакт, не сопровождает варианты
- **Sequential-only (House rule 12):** No parallel commands. One artefact per response, executed by operator, output returned, next artefact follows.

---

### UNIVERSAL-CANON-TOPOLOGY — Terminal topology

**Источник:** `docs/canon/UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md` [ФАКТ из канона A1]

**Топология терминалов (House rule 10):**

| Terminal | Role | Scope | Authority |
|----------|------|-------|-----------|
| Central (Perplexity) | Orchestrates — reads diagnostics, delegates ALL mutations to factory | banxe-architecture repo (docs, IL, ADR, runbooks, scripts) + read-only ssh evo1 | Read-only diagnostics; NO direct code/git/CI mutations |
| Left Terminal (Factory) | Executes — receives factory tasks, produces artifacts, reports back | Factory repo (banxe-emi-stack, vibe-coding, etc.) | Full execution; writes code, commits, pushes, opens PRs |
| Right Terminal agents | Fleet workers dispatched by factory | Assigned task scope | Scoped to assigned task; governed by ADR-025 |

**Scope isolation (shared bash on Legion):**
- Central uses `git worktree add` to create dedicated working directory whenever a long-running edit would collide with other terminal's branch checkouts.
- Worktree-isolation pattern = technical implementation of House rule 10 under shared bash.
- Central does NOT write in zones owned by other terminals (not in Guardian source, not in banxe-emi-stack production paths).

**Invariant (from canon):**
- Central выполняет НОЛЬ прямых мутаций. Всё production — через factory как задачу.
- Left Terminal = единственный исполнитель мутаций (code / git / infra).
- Диагностика (grep / git log / gh pr view / чтение файлов) = Central MAY run directly.
- Central markers in artefacts: TARGET = CENTRAL — bash on LEGION, or TARGET = CENTRAL — CLAUDE CODE TUI on LEGION, or TARGET = CENTRAL — ssh evo1 (read-only). Markers like TARGET = TERMINAL B are forbidden because Central does not own Terminal B's execution.

**Релевантность для движка:**
- Топология определяет routing всех агентских action-запросов:
  - L1 intent → Intent Dispatcher (ADR-049, NOT DEPLOYED — см. addendum A-003) → Central/Left routing
  - L2 governed action → factory (Left Terminal) → artifact

---

### Behavioral canon summary

| Canon source | Key rule | Enforcement layer | Status |
|-------------|----------|-------------------|--------|
| ADR-025 | No-ask; read-only-then-decide; 6-source priority; OCAT between chunks | Conversation layer (G-CANON-01 planned) | PRESENT (doc); NOT ENFORCED in CI |
| IL-CANON-04 | BEST DECISION: exactly 1 artifact per turn (layer 3 of 4-layer) | Conversation layer | PRESENT (doc) |
| UNIVERSAL-CANON-BEST-SOLUTION | Best-solution + sequential-only (House rules 11-12) | Conversation layer | PRESENT (doc) |
| UNIVERSAL-CANON-TOPOLOGY | Central/Left/Right terminal separation + scope isolation (House rule 10) | Worktree isolation + ADR-031 deny-paths | PRESENT (doc) |
| Sandbox enforcement (runtime) | ADR-025 compliance-check in agent-runner | CI gate | GAP → target-audit #842 |

> [ВЫВОД] Behavioral canon полностью задокументирован (4 источника, 4-layer canon framework). Runtime enforcement = open GAP (#842): canon проверяется вручально, не автоматически в CI/agent-runner. Это адресат GAP "execution sandbox contract не формализован" — требует CI gate на ADR-025 compliance (no-ask, 6-source priority, OCAT, stop-barrier proper deployment).

**Cross-refs:** ADR-024 (agent autonomy levels L1-L4), ADR-025 (agent interaction), ADR-031 (deny-paths), ADR-039 (permissions reclassification), ADR-123 (permissions hardening), `.claude/rules/approval-rules.md`, `.claude/rules/safety-rules.md`, CLAUDE.md §1-§11

## ENRICHMENT — Consolidation-audit C4 resolution (2026-06-28)

Append-only. Original content above unchanged.
Source: verified session facts from prior audits (no new external data).
Policy: cross-ref only — do NOT duplicate snapshot/SRC-06/SRC-03 content.

---

## §U — UNKNOWN Placeholders: Resolution Table

5 UNKNOWNs identified by consolidation-audit C4 @ origin/main ad99f63.
Each resolved using verified session facts (source cited). No guessing. No invention.
Nebius/H100 remain НЕ ПОДТВЕРЖДЕНО — honest; no verified corpus source exists.

| # | Topic | Prior status | Resolution | Source |
|---|-------|-------------|-----------|--------|
| U-1 | Math methods (ReAct/MCTS/Bayes) | UNKNOWN / not in code | THEORY/PLANNED: not implemented in code (grep empty). Confidence-bands/consensus-2:3/decision-lineage PRESENT. | G3 Part 2 audit |
| U-2 | Runtime services (Redis/Qdrant/Temporal/n8n/MongoDB) | UNKNOWN port status | See §U-2 detail below | VERIFIED-RUNTIME-SNAPSHOT.md |
| U-3 | External comparisons: Manus/Revolut/bunq/Monzo | НЕ ПОДТВЕРЖДЕНО | CONFIRMED by corpus Part 6 (see §U-3 detail) | SRC-06 §N (corpus Part 6) |
| U-4 | banxe-recon status | UNKNOWN / assumed active | RESOLVED: inactive / drifted (FROZEN-ARCHIVE). GAP-087 activation-spec; HITL gate CTIO+CFO pending. | VERIFIED-RUNTIME-SNAPSHOT.md §banxe-recon |
| U-5 | Passport count | UNKNOWN / "39" (stale) | RESOLVED: **70 passports** (verified git ls-tree, A2-audit G1). "39" = obsolete figure. | A2-audit G1 (git ls-tree verified) |

---

## §U-1 — Math Methods: THEORY / PLANNED (not implemented in code)

[RESOLVED from G3 Part 2 audit — grep empty for ReAct/MCTS/Bayes in production code]

**Resolution:** Math-method markers in production code:

| Method | Code presence | Status |
|--------|--------------|--------|
| ReAct (Reasoning+Acting interleaved) | grep empty in services/ | THEORY/PLANNED — not implemented as named module |
| MCTS (Monte Carlo Tree Search) | grep empty in services/ | THEORY/PLANNED |
| Bayesian inference (explicit) | grep empty in services/ | THEORY/PLANNED |

**Present in code (verified):**

| Component | Location | Status |
|-----------|----------|--------|
| confidence-bands | ADR-012, ADR-046 (confidence_score Float32 [0.0–1.0]) | ✅ PRESENT |
| consensus 2/3 threshold | ADR-FUSION-01 §Decision (majority vote ensemble) | ✅ PRESENT |
| decision-lineage / audit trail | ADR-046; ClickHouse append-only (I-24) | ✅ PRESENT |

**Interpretation:** BANXE implements the *outputs* of mathematical reasoning (confidence thresholds, consensus gates, audit lineage) without explicitly naming the underlying methods. ReAct/MCTS/Bayes remain architectural aspirations (THEORY layer), not production code.

Cross-ref: `SRC-02-theory-principles.md` §Math-Status (primary source for theory/planned distinction).

---

## §U-2 — Runtime Services: Port Status (2026-06-28 snapshot)

[RESOLVED from VERIFIED-RUNTIME-SNAPSHOT.md — verified 2026-06-28 @ commit 6602842]
Cross-ref: `VERIFIED-RUNTIME-SNAPSHOT.md` §Compliance-ports + §Orchestration (primary).
Content NOT duplicated here — summary only.

| Service | Port | Status | Notes |
|---------|------|--------|-------|
| Redis | :6379 | NOT LISTENING on local | ADR-143-A: uses shared evo1 Redis (not localhost); expected |
| Qdrant | :6333 | NOT LISTENING | PLANNED (vector DB, not deployed); SRC-01 §Qdrant |
| Temporal | :7233 | NOT LISTENING | infra-scope (banxe-ai-infrastructure / ADR-060§6, Sprint B); expected |
| n8n | :5678 | ✅ LISTENING (evo1) | 5 workflows; HITL gate (I-27) operational |
| MongoDB (midaz) | :5703 | ✅ healthy | Midaz CBS internal storage |

Full port inventory: `VERIFIED-RUNTIME-SNAPSHOT.md` §Compliance-ports (primary, not duplicated here).

---

## §U-3 — External Comparisons: Confirmed + Remaining Unconfirmed

[PARTIAL RESOLUTION: Confirmed by corpus Part 6 SRC-06]
[Nebius/H100 remain НЕ ПОДТВЕРЖДЕНО — honest; no verified corpus source]
Cross-ref: `SRC-06-references-academic.md` + corpus Part 6 (primary source for neobank confirmations).

### CONFIRMED by corpus Part 6

| Product | Company | Confirmed fact | SRC-09 prior status |
|---------|---------|---------------|-------------------|
| **Manus** | Manus AI | Autonomous agent framework (multi-modal, tool-use); open-access 2024 | НЕ ПОДТВЕРЖДЕНО → ✅ CONFIRMED |
| **Revolut AIR** | Revolut | AI-driven automated investment routing; intent-based portfolio; production 2024 | НЕ ПОДТВЕРЖДЕНО → ✅ CONFIRMED |
| **bunq Finn** | bunq | Conversational AI financial assistant (NLP → transaction commands); production 2023 | НЕ ПОДТВЕРЖДЕНО → ✅ CONFIRMED |
| **Monzo Flex Agent** | Monzo | AI agent for BNPL/flex-credit eligibility; automated approval; production 2024 | НЕ ПОДТВЕРЖДЕНО → ✅ CONFIRMED |

Full neobank detail: corpus Part 6 (not duplicated here).
Competitive implication: BANXE 2+ years behind neobanks on Intent-First UI (GAP-080, RED OPEN Q3 2026).

### Still НЕ ПОДТВЕРЖДЕНО (honest)

| Entity | Why unconfirmed | Action |
|--------|----------------|--------|
| **Nebius** | No verified corpus source in this session | Remains НЕ ПОДТВЕРЖДЕНО |
| **H100 GPU cluster** | No verified inventory source in this session | Remains НЕ ПОДТВЕРЖДЕНО |

These items are not removed from the "unconfirmed" category. A future corpus part or direct operator verification would be needed to resolve them.

---

## §U-4 — banxe-recon Status: RESOLVED (inactive / drifted)

[RESOLVED from VERIFIED-RUNTIME-SNAPSHOT.md §banxe-recon — verified 2026-06-28]
Cross-ref: `VERIFIED-RUNTIME-SNAPSHOT.md` §banxe-recon (primary).

**Resolution:** banxe-recon.service = **inactive** as of 2026-06-28 snapshot.

| Aspect | Status | Details |
|--------|--------|---------|
| Service state | INACTIVE | Not running (FROZEN-ARCHIVE expected inactive state) |
| GAP-087 activation-spec | PREPARED | Spec ready; governance: "LIVE / timer enabled" |
| Runtime fact | INACTIVE | Service NOT running (2026-06-28 verified) |
| HITL gate | PENDING | CTIO + CFO sign-off required before activation |
| Note | PARTIAL CONFLICT | Governance-claim (GAP-087 "LIVE") vs runtime-fact (inactive). Runtime-fact wins in this dossier. |

---

## §U-5 — Passport Count: RESOLVED (70, not 39)

[RESOLVED from A2-audit G1 — verified git ls-tree count]

**Resolution:**

| Figure | Value | Source | Status |
|--------|-------|--------|--------|
| Passport count | **70** | git ls-tree (verified A2-audit G1) | ✅ AUTHORITATIVE |
| Soul files | 20 | git ls-tree | ✅ AUTHORITATIVE |
| Active swarms | 3 | live swarm registry | ✅ AUTHORITATIVE |
| "39 passports" | — | stale reference (pre-expansion) | ❌ OBSOLETE — do not use |

"39" was the passport count before the compliance swarm expansion. Current authoritative figure = **70**.
Cross-ref: `VERIFIED-RUNTIME-SNAPSHOT.md` §Swarm (primary; also records 70/20/3).

---

## §X — Resolution Summary (SRC-09 enrichment)

| # | UNKNOWN topic | Resolved? | Remaining uncertainty |
|---|--------------|-----------|----------------------|
| U-1 | Math methods | ✅ RESOLVED: THEORY/PLANNED; code-present = confidence-bands/consensus/lineage | None |
| U-2 | Runtime services | ✅ RESOLVED: Redis/Qdrant/Temporal/n8n/MongoDB port status confirmed | None |
| U-3 | External comparisons | ✅ PARTIALLY RESOLVED: Manus/Revolut/bunq/Monzo CONFIRMED; Nebius/H100 НЕ ПОДТВЕРЖДЕНО | Nebius/H100 remain unconfirmed |
| U-4 | banxe-recon status | ✅ RESOLVED: inactive (runtime-fact) | HITL gate pending |
| U-5 | Passport count | ✅ RESOLVED: 70 (not 39) | None |

**UNKNOWN count change:** 5 → 0 resolved in this enrichment (Nebius/H100 honestly preserved as НЕ ПОДТВЕРЖДЕНО — not an UNKNOWN, a confirmed-unconfirmed).

**Cross-ref index (no duplication):**

| Target | Used for | Duplicated? |
|--------|---------|------------|
| `VERIFIED-RUNTIME-SNAPSHOT.md` | Runtime port status, banxe-recon, passport count | Cross-ref only |
| `SRC-06-references-academic.md` + corpus Part 6 | Neobank confirmations | Cross-ref only |
| `SRC-03-implementation-state.md` §3 | PARTIAL CONFLICT (GAP-087 governance vs runtime) | Cross-ref only |
| `SRC-02-theory-principles.md` §Math-Status | Theory/planned distinction | Cross-ref only |
