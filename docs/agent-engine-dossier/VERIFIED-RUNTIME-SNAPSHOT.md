# Verified Runtime Snapshot — BANXE-CORE-ENGINE Intake

**Snapshot basis:** origin/main @ 6602842
**Date:** 2026-06-28
**Host:** mark-legion (local)
**Method:** S5/S6/S7 shell audit (не воспроизводить без повторного аудита)

---

## Listening Services (VERIFIED)

| Port | Service | Status | Note |
|------|---------|--------|------|
| :8180 | Keycloak (HTTP) | LISTENING | IAM — ADR-IAM |
| :8181 | Keycloak (HTTPS/management) | LISTENING | IAM management |
| :4000 | LiteLLM proxy | LISTENING | INV-AI-01 PII guard |
| :9000 | ClickHouse (native) | LISTENING (local only) | Audit trail, I-08 5yr TTL |

---

## Not Listening at Snapshot Time

| Port | Service | Note |
|------|---------|------|
| :6379 | Redis (local) | NOT LISTENING — ADR-143-A uses shared-evo1 Redis |
| :5678 | n8n | NOT LISTENING — workflow automation, not yet deployed |
| :7233 | Temporal | NOT LISTENING — workflow orchestrator, not yet deployed |
| :6333 | Qdrant | NOT LISTENING — vector memory PLANNED (SRC-02), not deployed |
| :27017 | MongoDB (local) | NOT LISTENING locally |
| :8094 | Verify service | NOT LISTENING |

---

## Special Cases

| Component | Status | Detail |
|-----------|--------|--------|
| MongoDB / Midaz | HEALTHY | Midaz uses :5703 per ADR-013 (NOT :27017) |
| banxe-recon.service | INACTIVE | HITL gate (CTIO + CFO) not yet cleared; timer: not-found |
| AMLSim | PRESENT | /home/mmber/AMLSim on Legion |

---

## Swarm Status (S5/S6/S7 verified)

| Metric | Value | Note |
|--------|-------|------|
| Passports | 70 | VERIFIED — цифра «39» из ранних источников УСТАРЕЛА |
| Souls | 20 | VERIFIED |
| Swarms | 3 | VERIFIED |

---

## Usage Rules

- Все runtime-числа в docs/agent-engine-dossier/ ДОЛЖНЫ ссылаться на этот snapshot.
- Не экстраполировать snapshot за пределы даты 2026-06-28.
- При следующем shell-аудите создать новый snapshot (append-only, не перезаписывать этот).
- [НЕИЗВЕСТНО] для любого компонента, не упомянутого в таблицах выше.

---

## Stale Data Warning

Цифра «39 passports», упоминаемая в ранних частях аналитического корпуса, УСТАРЕЛА.
Verified значение: **70 passports** (S5/S6/S7).

---

## Snapshot v2 — 2026-06-28 (append-only; basis: live shell P0 RUNTIME CLAIMS @ origin/main)

---

### Models & Routing

**Ollama :11434 — 10 active models:**

| Model | Notes |
|-------|-------|
| `qwen3-235b-a22b-banxe` | BANXE custom variant |
| `qwen3-235b-a22b` | Base 235B |
| `llama3.3-70b` | General reasoning |
| `qwen3.5-35b` | Mid-tier |
| `qwen3-4b` | Fast/lightweight |
| `qwen3-30b-a3b` | Compact 30B |
| `qwen3.5-latest` | Latest snapshot |
| `qwen3-coder-next` | Code specialization |
| `glm-4.7-flash` | Flash variant |
| `gpt-oss-20b` | OSS GPT-class |

**qwen3-235b master :8082** (ADR-018): Q3KS 235.1B, 101.4 GB, evo2 healthy.

**LiteLLM router :4000 — 5 canonical aliases (I-32):**

| Alias | Target |
|-------|--------|
| `factory-fast` | Lightweight model (fast responses) |
| `factory-mid` | Mid-tier model |
| `factory-heavy` | Heavy reasoning |
| `factory-coder` | Code-specialised |
| `project-reason` | qwen3-235b @ evo2:8082 (ADR-018) |

**Classifier:** qwen2.5-0.5b @ evo2 (routing classification, lightweight).

**[ФАКТ] Cross-refs:** ADR-018 (hybrid compute evo1/evo2 USB4); ADR-016 (LiteLLM single entrypoint); I-32 (all AI calls via :4000).

---

### Compliance Services & Ports

| Port | Service | Status | ADR / Note |
|------|---------|--------|-----------|
| :8094 | Verify API / auto-verify | PRESENT (evo1) | ADR-012, I-09; compliance/AML response validation; routes 8093→8094 |
| :8084 | Watchman (Moov) | PRESENT | Sanctions screening |
| :8085 | Screener | PRESENT | AML screener |
| :8086 | Yente | Phase 3 / PLANNED | OpenSanctions; Phase 3 deployment |
| :5001 | Jube | Reference-only | ADR-004 (AGPLv3 internal-only; B2B → Apache-2.0 rewrite required) |
| :5002 / :5003 / :15433 | Marble | ELv2 internal | ADR-005; fraud scoring |
| :5137 / :5200 / :5201 | Ballerine | PRESENT | KYC orchestration (self-hosted) |
| :3001 | MiroFish | PRESENT | — |
| tx_monitor | 9 deterministic rules + Redis 24h velocity | PRESENT | :6379; Apache-2.0 compatible path |

**[ФАКТ] tx_monitor** — 9 deterministic rules + Redis velocity tracker (24h window).
Independent of Jube AGPL; forms Apache-2.0 compliant TM-baseline.

---

### Orchestration Runtime

| Component | Endpoint | Status | Notes |
|-----------|----------|--------|-------|
| Guardian factory | :8195 | PRESENT (evo1) | ADR-077; App id 15368 |
| Guardian project | :8196 | PRESENT (evo1) | ADR-077; App id 15368 |
| guardian-shim | — | PRESENT | I-36: fail-closed / fail-open modes |
| Keycloak | :8180 | LIVE | v26.2.5; realm banxe; 7 roles; KeycloakAdapter active |
| n8n | :5678 | DEPLOYED (evo1) | 5 workflows: safeguarding-shortfall-alert, daily-recon-report, complaint-sla-monitor, mcp-health-monitor, k-gabriel-n8n; HITL gate (I-27) |
| Redis IL allocator | evo1 shared | PRESENT | ADR-143-A: key `banxe:il:counter` INCR; fallback local max+1 |

**Guardian shim I-36:** fail-closed = block on degradation; fail-open = pass with alert.
Degradation detection: ADR-139. Guardian factory/project = L0 fleet infrastructure.

---

### banxe-recon Service — Current Status

**[ФАКТ] Current status:** `inactive` (verified 2026-06-28).
Note: banxe-recon.service/timer was `installed/active` per FROZEN-ARCHIVE (historical S7 snapshot).
Status has drifted — current evo1 state = inactive/not-found.

**Implication:** CASS 15 daily reconciliation cron is NOT currently running via systemd.
Operator must re-enable after HITL gate (CTIO + CFO sign-off) per GAP-087 activation spec.

**Cross-refs:** FROZEN-ARCHIVE (historical), GAP-087 (LIVE activation spec), HITL gate requirement.

---

### Secrets Policy

**[ПРИНЦИП]** Этот snapshot НЕ фиксирует значения секретов (ANTHROPIC_API_KEY и пр.).
Секреты хранятся в `/etc/banxe/secrets.env` и `~/.env.*` — не в документации (I-02, security-policy.md).

---

## Runtime addendum (A-003 audit)

> Источник: A-003 corpus fragment, live shell @ origin/main ad99f63, 2026-06-28.
> Маркер: [ФАКТ из корпуса A-003]. Только новинки — существующие порты (8094/8195/8196/4000/9000/5678) НЕ дублируются.

---

### OpenClaw instances (новинка A-003)

Обнаружено 4 инстанса OpenClaw, **не присутствовавших в snapshot v2**:

| Instance | Port | Role | Gateway |
|----------|------|------|---------|
| ctio | :18791 | CTIO-role agent | OLLAMA direct (see gap below) |
| guiyon | :18794 | guiyon-role agent | OLLAMA direct (see gap below) |
| moa | :18789 | MOA — Multi-agent orchestration | OLLAMA direct (see gap below) |
| mycarmibot | :18793 | mycarmibot-role agent | OLLAMA direct (see gap below) |

> [ФАКТ] Все 4 инстанса обращаются к OLLAMA local напрямую, минуя LiteLLM gateway (:4000).

**Known gap — G-CANON-PROJECT-AGENTS-BYPASS-GATEWAY:**
- Canon-требование: все агентские вызовы → LiteLLM gateway :4000 (ADR-018, ARL routing tier).
- Фактический статус: OpenClaw ctio/guiyon/moa/mycarmibot = BYPASS (прямой OLLAMA).
- Последствия: нет audit-trail токенов через LiteLLM; нет quota-enforcement; нет model-alias routing.
- Владелец: CTIO. Статус: OPEN P1 gap.
- Fix-path: переконфигурировать OpenClaw base_url → `http://localhost:4000` (LiteLLM proxy), добавить API-key env var.

---

### ADR-049 dispatcher-spec (новинка A-003)

**ADR-049:** Intent-Layer — client-facing masks (L1→L2 dispatcher specification).

- Отношение к ADR-045: ADR-045 = концептуальный уровень (what intents are). ADR-049 = формальная спецификация (HOW intents surface as governed L2 agent actions).
- Суть: L1 intent (raw client request) → Intent Dispatcher → L2 governed action (через compliance guardrails + audit-trail).
- Статус деплоя: **NOT DEPLOYED** (см. target-audit #842, GAP «Intent Dispatcher not deployed»).
- Gap-source: target-audit #842 идентифицировал отсутствие живого Intent Dispatcher как P1 architectural gap.

> [ФАКТ] ADR-049 = orchestration-spine spec для intent routing. Отсутствие деплоя = разрыв между архитектурным решением (ADR-049) и рантаймом.

**Импликации для дossier:**
- VERIFIED-RUNTIME-SNAPSHOT v2 §Orchestration (Guardian :8195/:8196) = инфраструктура L2 execution.
- ADR-049 Intent Dispatcher = L1→L2 routing layer поверх Guardian — пока PLANNED/NOT_DEPLOYED.
- Путь к закрытию: deploy intent-dispatcher service (порт TBD) → wire в LiteLLM ARL pipeline.

---

### G-GUARDIAN-WEBHOOK-MISSING (новинка A-003)

**Infra gap — G-GUARDIAN-WEBHOOK-MISSING:**

| Field | Value |
|-------|-------|
| GitHub App ID | 15368 |
| Expected webhook target | evo1:8195 / evo1:8196 (Guardian) |
| Observed status | Webhook NOT delivering checkruns |
| Severity | P1 (blocks Guardian CI integration) |
| Impact | Guardian cannot receive GitHub checkrun events; automated PR gates inoperative |

> [ФАКТ] GitHub App id 15368 webhook к evo1:8195/8196 не доставляет checkruns. Guardian listening (PRESENT в snapshot v2 §Orchestration) но не получает события.

**Fix-path:**
1. Проверить GitHub App webhook delivery log (App → Settings → Advanced).
2. Убедиться, что evo1:8195/8196 доступен с GitHub webhook IP-диапазонов (firewall/NAT).
3. Переdelivery или реконфигурация webhook URL.
- Владелец: CTIO. Статус: OPEN P1 gap.

---

### Сводка новых gaps (A-003)

| Gap ID | Описание | Severity | Владелец |
|--------|----------|----------|---------|
| G-CANON-PROJECT-AGENTS-BYPASS-GATEWAY | OpenClaw (4 instances) bypasses LiteLLM :4000 | P1 | CTIO |
| G-ADR-049-NOT-DEPLOYED | Intent Dispatcher (ADR-049) not deployed; L1→L2 routing absent | P1 | Arch |
| G-GUARDIAN-WEBHOOK-MISSING | GitHub App 15368 webhook → evo1:8195/8196 not delivering checkruns | P1 | CTIO |

> Существующие gaps (banxe-recon INACTIVE, Qdrant NOT LISTENING, :6379/:5678/:8094 NOT LISTENING) зафиксированы в snapshot v2 — не дублируются.

---

## Runtime addendum (A2 audit — 2026-06-28)

> Источник: A2 audit corpus fragment, тройная прогонка F/R/G @ origin/main, 2026-06-28.
> Маркер: [ФАКТ из корпуса A2]. Только новинки — все A-003 ports/gaps не дублируются.

---

### Hyperswitch payment processor + Jube infrastructure ports

Обнаружено в A2 audit — не присутствовали в snapshot v2 или addendum A-003:

| Service | Port(s) | Role | ADR/Source | Status |
|---------|---------|------|-----------|--------|
| Hyperswitch | :8096 (API), :8098 (web dashboard) | Payment processor router | ADR-015, ADR-140 | PRESENT |
| Jube-Postgres | :15432 | Jube dedicated PostgreSQL | DEPLOYMENT-ARCHITECTURE | PRESENT |
| Jube-Redis | :16379 | Jube dedicated Redis | DEPLOYMENT-ARCHITECTURE | PRESENT |

> [ФАКТ] Hyperswitch (:8096/:8098) = основной payment router (ADR-015: Hyperswitch as payment orchestration layer; ADR-140: Amendment 1 confirming deployment). Jube (:5001) уже зафиксирован в snapshot v2 §Compliance — здесь только Jube infra (dedicated PG + Redis), не дублируется.

---

### OpenClaw MoA — состав 10-агентной оркестрации (A2 audit)

Дополнение к OpenClaw instances (addendum A-003): moa-инстанс (:18789) = **MOA (Multi-agent Orchestration Architecture)** с 10 агентами.

**Источник:** `.claude/agents/openclo.md`, GMKtec node @ :18789 [ФАКТ из корпуса A2]

```
OpenClaw MoA (:18789) = 10 агентов
├── Размещён на: GMKtec (evo fabric)
├── Паттерн: MoA — несколько LLM-агентов синтезируют ответы коллективно
└── Связь с LiteLLM: BYPASS (G-CANON-PROJECT-AGENTS-BYPASS-GATEWAY, зафиксировано A-003)
```

> [ФАКТ] Состав 10 агентов задокументирован в `.claude/agents/openclo.md`. MoA-архитектура = mixture-of-agents (агрегация нескольких LLM-ответов). Контекст: moa-инстанс не проксирует через LiteLLM :4000 — тот же gateway-bypass gap (A-003).

---

### Model-card alias-резолюция (A2 уточнение)

Уточнение §Models из snapshot v2 — точная резолюция LiteLLM aliases (из `model-cards/`):

| LiteLLM Alias | Resolves to | Model | Location | Notes |
|--------------|-------------|-------|----------|-------|
| `project-reason` | qwen3-235b-a22b **Q3_K_S** (235.1B MoE) | Qwen3-235B | evo2 :8082 | Primary reasoning alias |
| `factory-mid` | qwen3-30b-a3b **MoE** (30B) | Qwen3-30B | evo1/evo2 :11434 (LB) | Load-balanced across evo nodes |
| `reasoning` | → **legacy alias** → `project-reason` | (same as project-reason) | — | Use project-reason directly; reasoning is deprecated alias |

> [ФАКТ] Snapshot v2 §Models listed aliases without resolution targets. A2 audit adds: (a) Q3_K_S quant for project-reason (qwen3-235b), (b) MoE 30B для factory-mid с load-balancing :11434 evo1+evo2, (c) `reasoning` = deprecated alias → project-reason (see model-cards/). Passport-count = 70 (verified A2, unchanged).

---

### Обновлённые gap-notes (A2)

Существующий G-CANON-PROJECT-AGENTS-BYPASS-GATEWAY (A-003) подтверждён для MoA-инстанса:
- OpenClaw moa (:18789) с 10 агентами = тот же bypass-gap, что и остальные 3 инстанса.
- Hyperswitch (:8096/:8098) маршрутизация через LiteLLM: НЕ ПОДТВЕРЖДЕНО в A2 (Hyperswitch — payment router, не LLM-агент; gateway-bypass inapplicable).
