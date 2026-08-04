# BANXE Factory v3 — Full-Cycle Canon Closure Roadmap

**Status:** DRAFT — awaits operator ratification
**Date:** 2026-08-04
**Related:** ADR-177 (factory full-cycle mandate — this session, pending), ADR-102, ADR-143-A, ADR-153
**Source:** session audit 2026-08-04, canon document «Компания-разработчик полного цикла для EMI BANXE AI Bank»

## Context

Канон полного цикла требует от фабрики не только выпускать код, но и закрывать
все контуры компании-разработчика: governance, надёжность, персоны-роли,
топологию команд, платформу и внешние петли обратной связи. Сессионный аудит
2026-08-04 зафиксировал 23 разрыва между каноном и текущей практикой: 7 —
«частично, усилить», 16 — «не делаю совсем». Основание для закрытия — ADR-177
(full-cycle mandate, pending ratification). Этот roadmap переводит реестр
разрывов в шесть укрупнённых двухнедельных спринтов (~3 месяца от ратификации);
оператор явно запросил big-batch, без дробления на атомарные шаги.

## Gap register

| ID | Area | Current state | Target state | Sprint |
|----|------|---------------|--------------|--------|
| G-01 | Immutable audit trails | частично (ledger live-verification pending) | live-verification runbook, регулярная проверка | S-01 |
| G-02 | AgentOps: kill switches / canary / rollback runbooks | частично | полный набор rollback/canary runbooks | S-02 |
| G-03 | Explainability thresholds (Fable-5 confidence-score) | частично | ADR-180 confidence-протокол, обязательное поле | S-01 |
| G-04 | Cost attribution per AI inference (LiteLLM virtual-keys) | частично | virtual-keys per persona/squad + spend-отчёт | S-05 |
| G-05 | Chaos Engineering | нет вообще | chaos-drill runbooks, регулярные учения | S-02 |
| G-06 | Performance Engineering | нет regular benchmark suite | bench-план + базовые замеры | S-02 |
| G-07 | Data governance / GDPR / retention | нет ADR | ADR-179 classification & retention | S-01 |
| G-08 | CAIO persona | не делаю совсем | charter + activation pattern | S-03 |
| G-09 | CCO persona (compliance-agent KYC/AML/PSD2/EMI) | не делаю совсем | charter + pre-merge hook design | S-03 |
| G-10 | CDO persona (data governance) | не делаю совсем | charter | S-03 |
| G-11 | CISO persona (threat modeling per feature) | не делаю совсем | ADR-vector в S-01, charter + шаблон в S-03 | S-01/S-03 |
| G-12 | Stream-aligned squads × 8 | не делаю совсем | 8 squad-файлов с canonical territory | S-04 |
| G-13 | Platform Team + IDP (Backstage-equivalent, catalog) | не делаю совсем | team charter + IDP plan + catalog | S-05 |
| G-14 | Enabling Teams (AI Enablement, Security Enablement) | не делаю совсем | Security — S-03, AI Enablement — S-05 | S-03/S-05 |
| G-15 | Complicated Subsystem Teams | не делаю совсем | Real-Time Data Pipeline + Model Training stubs | S-04 |
| G-16 | Spotify: Tribes/Chapters/Guilds | не делаю совсем | topology-доки (tribes/chapters/guilds) | S-04 |
| G-17 | AI Agent Architect / Prompt / Context / AgentOps / Evaluator | не делаю совсем | 5 role-charters | S-03 |
| G-18 | EMI Compliance Engineer + Financial Domain Expert + Legal/Regulatory | не делаю совсем | 3 role-charters | S-03 |
| G-19 | Design Factory + Design System + Figma tokens + Storybook | не делаю совсем | design-контур: charters + system plan | S-06 |
| G-20 | SRE Team: SLI/SLO/SLA, incident mgmt, post-mortem, multi-region | не делаю совсем | SLI/SLO charter + post-mortem практика | S-02 |
| G-21 | Data Engineering: ETL/ELT, CDC, Kafka, data lake | не делаю совсем | архитектурный план data-контура | S-06 |
| G-22 | Open Banking API Management | не делаю совсем | API-management план | S-06 |
| G-23 | Customer Feedback Loop Engineering | не делаю совсем | feedback-loop design | S-06 |

## Sprints

Six sprints, big-batch, каждый закрывает несколько gap'ов. Sprint length:
2 недели каждый. Итого ~3 месяца от ratification. Каждый спринт проходит
стандартные ворота: markdownlint, guardian docs-only, ledger shard, operator
merge (Rule 11).

### Sprint S-01 — Governance & Ratification Backbone

**Duration:** 2 weeks | **Closes:** G-01, G-03, G-07, G-11 (partial)

Deliverables:
- ADR-177 merged (prerequisite).
- ADR-178 AI DLC phases (discovery/build/operate) draft + PR.
- ADR-179 Data classification & retention (GDPR-aligned) draft + PR.
- ADR-180 Fable-5 confidence-score protocol (high/medium/low + evidence anchor) draft + PR.
- Ledger live-verification runbook: `docs/runbooks/ledger-live-verify.md`.
- Fable-5 advisory template updated: mandatory confidence field.

Ratification gates: markdownlint, guardian docs-only, ADR index.
Owner persona: Fable-5 (Architecture Enabling).

### Sprint S-02 — AgentOps & Reliability Runbooks

**Duration:** 2 weeks | **Closes:** G-02, G-05, G-06, G-20

Deliverables:
- `docs/runbooks/rollback-litellm.md`
- `docs/runbooks/rollback-allocator-redis.md`
- `docs/runbooks/rollback-ledger-regen.md`
- `docs/runbooks/rollback-gateway-config.md`
- `docs/runbooks/canary-deploy-model.md`
- `docs/runbooks/chaos-drills/allocator-noauth.md`
- `docs/runbooks/chaos-drills/ledger-shard-corrupt.md`
- `docs/runbooks/chaos-drills/gateway-timeout-storm.md`
- `docs/sre/sli-slo-charter.md` (initial SLI/SLO/SLA: allocator PING, gateway :4000 latency, ledger mint p99)
- `docs/sre/incident-postmortem-template.md`
- `docs/sre/post-mortem/2026-08-03-evo1-triple-offline.md` (retro post-mortem: три оффлайна за 15h; штатный reboot + DHCP + tailscale relay flap; действия закрытия — отдельно)
- `docs/runbooks/perf-benchmark-suite.md` (bench-план: ollama tok/s, gateway p99, allocator INCR/s, ledger append/s)

Ratification gates: markdownlint, guardian docs-only.
Owner persona: AgentOps Engineer + SRE (new personas — G-17, G-20).

### Sprint S-03 — Persona Charter (C-Suite + Specialized Roles)

**Duration:** 2 weeks | **Closes:** G-08, G-09, G-10, G-11, G-14 (Security half), G-17, G-18

Deliverables:
- `docs/personas/CAIO-charter.md` (model risk mgmt, LLM lifecycle, cost optimization; scope, invocation, boundaries)
- `docs/personas/CCO-charter.md` (compliance-agent: per-merge KYC/AML/PSD2/EMI check; hook to guardian pre-merge)
- `docs/personas/CDO-charter.md` (data governance, retention, lineage)
- `docs/personas/CISO-charter.md` (threat modeling template per feature)
- `docs/personas/AI-Agent-Architect.md`
- `docs/personas/Prompt-Engineer.md`
- `docs/personas/Context-Engineer.md`
- `docs/personas/AgentOps-Engineer.md`
- `docs/personas/AI-Evaluator.md`
- `docs/personas/EMI-Compliance-Engineer.md`
- `docs/personas/Financial-Domain-Expert.md`
- `docs/personas/Legal-Regulatory-Engineer.md`
- `docs/personas/README.md` — index + activation-pattern (how each persona is invoked: явная пометка в промте, как chapter/squad activation)

Каждый charter: ≤ 80 строк, единый шаблон (role / scope / invocation /
canonical territory / boundaries / handoff to Fable-5).

Ratification gates: markdownlint, guardian docs-only.
Owner persona: Fable-5 (bootstrap round).

### Sprint S-04 — Squads, Chapters, Guilds Topology

**Duration:** 2 weeks | **Closes:** G-12, G-15, G-16

Deliverables:
- `docs/topology/squads/README.md` — 8 stream-aligned squads (Payments, KYC, Crypto, Trading, Customer-AI-Agent, CRM, Compliance, Cards). Каждый squad — отдельный файл `docs/topology/squads/<name>.md` с полями: canonical territory (bank-room cell + OWNS_PATH), linked passport-id (TODO stubs OK), activation pattern, boundaries.
- `docs/topology/complicated-subsystem/README.md` — Core Ledger Settlement (existing), Real-Time Data Pipeline (new stub), AI Model Training/Fine-tuning (new stub).
- `docs/topology/chapters/README.md` — Backend, Frontend, QA, AI/ML, Security. Каждый chapter — ownership `.claude/rules` (только упоминание, без переноса файлов), Chapter Lead persona (assignable Fable-5 sub-persona).
- `docs/topology/guilds/README.md` — Architecture, AI Ethics & Compliance, Performance Engineering, Design Systems.
- `docs/topology/tribes.md` — 4 tribes (Client Experience, Financial Ops, Crypto/Trading, Infrastructure).
- Appendix — mapping table Squad ↔ Cell ↔ OWNS_PATH ↔ Passport (перенести таблицу из ADR-177 Appendix A, заполнить TODO из bank-rooms если доступно, иначе оставить TODO с anchor).

Ratification gates: markdownlint, guardian docs-only.
Owner persona: Fable-5 + AI Agent Architect (S-03 deliverable).

### Sprint S-05 — Platform Team, IDP, Cost Attribution

**Duration:** 2 weeks | **Closes:** G-04, G-13, G-14 (AI Enablement half)

Deliverables:
- `docs/platform/team-charter.md` — Platform Team scope (self-service, IDP, service catalog, CI/CD, secrets mgmt)
- `docs/platform/idp-plan.md` — lightweight IDP proposal (Backstage-equivalent или собственный service catalog в Markdown/JSON — сравнение, рекомендация, staged rollout)

> ⚠️ RECONSTRUCTED FROM HERE (операторский input оборвался на этой строке;
> дальнейшие deliverables S-05 и весь S-06 достроены фабрикой из gap register —
> проверить при ратификации).

- `docs/platform/service-catalog.md` — initial catalog фактических сервисов фабрики: LiteLLM gateway (:4000), allocator Redis (evo1/evo2 per ADR-143-B), ledger builder, ollama-парк, watchdog, Control-Room; owner + runbook + SLO-ссылка на запись.
- `docs/platform/cost-attribution.md` — G-04: схема LiteLLM virtual-keys per persona/squad (ключ = учётная единица), spend-логи в Postgres, ежемесячный cost-отчёт по инференсу; связь с CAIO charter (cost optimization).
- `docs/enabling/ai-enablement-charter.md` — G-14 (AI half): команда-включатель, которая раскатывает AI-практики по squad'ам (prompt/context patterns, eval harness, model selection guidance).

Ratification gates: markdownlint, guardian docs-only.
Owner persona: Platform Team (bootstrap: Fable-5) + CAIO (S-03 deliverable).

### Sprint S-06 — Design Factory, Data Engineering & External Loops (RECONSTRUCTED)

**Duration:** 2 weeks | **Closes:** G-19, G-21, G-22, G-23

> ⚠️ Спринт целиком достроен фабрикой (в операторском input отсутствовал) —
> состав выведен из непокрытых строк gap register. Проверить при ратификации.

Deliverables:
- `docs/design/design-factory-charter.md` — G-19: роли UX Researcher / UI Designer / Motion / Accessibility как персоны; scope и activation по шаблону S-03.
- `docs/design/design-system-plan.md` — G-19: Design System + Figma tokens + Storybook: staged plan (tokens → components → Storybook как living catalog), связь с frontend chapter.
- `docs/data/data-engineering-plan.md` — G-21: архитектурный план ETL/ELT, CDC, Kafka, data lake; связка с существующим ClickHouse-контуром и CDO charter (S-03); границы с midaz (foreign core — untouchable).
- `docs/data/real-time-pipeline-stub.md` — детализация Complicated-Subsystem stub из S-04 до планового уровня.
- `docs/api/open-banking-api-management.md` — G-22: план API-management контура (каталог Open Banking API, версионирование, PSD2-consent surface, связь с mock-aspsp);
- `docs/feedback/customer-feedback-loop.md` — G-23: инженерия петли обратной связи (каналы сбора → классификация → маршрутизация в squad backlog → замыкание в HITL/eval), связь с Customer-AI-Agent squad и AI-Evaluator persona.

Ratification gates: markdownlint, guardian docs-only.
Owner persona: Design Factory lead + CDO + Platform Team (все — S-03/S-05 deliverables).

## Sequencing & ratification

- Порядок жёсткий: S-01 (governance backbone) — prerequisite для всех
  последующих; S-03 порождает персоны, на которые ссылаются S-04–S-06.
- Каждый спринт закрывается отдельным PR-пакетом с ledger shard'ами и
  операторским merge (Rule 11); ADR-ы ратифицируются Proposed → Accepted
  отдельными flip-PR по установленному прецеденту.
- Roadmap не меняет код, скрипты, конфиги, guardian hooks, `.claude/rules`,
  LiteLLM config, ledger scripts, redis.conf и существующие ADR — docs-plane only.
