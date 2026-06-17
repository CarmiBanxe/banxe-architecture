# MASTER-PLAN — EMI BANXE AI BANK
# Master-plan as of 2026-05-05 20:00 CEST
# Последовательный, по приоритетам, без дедлайнов.
# Canonical reference: banxe-architecture/MASTER-PLAN-2026-05-05.md
# Tag: checkpoint-2026-05-05-emi-canon

---

## Уже закрыто (checkpoint reference)

| Phase | Result | Artefact |
|-------|--------|---------|
| Phase 1 — Core EMI Platform | ✅ DONE | 13 functional blocks, 2987 tests, coverage 89% |
| Phase 2 — Operations & Compliance Intelligence | 🔄 PARTIAL | HITL / TM / Consumer Duty done; live integrations blocked on external API keys |
| Phase 3 — Advanced Compliance Reporting | ✅ DONE | FIN060, SAR auto-filing, Consumer Duty annual report |
| Phase 4 — 27 services scaffolded | ✅ DONE | banxe-emi-stack 27 services |
| Phase 4.5 — Compliance & IAM Cutover | ✅ DONE 2026-05-04 | ADR-017, STRATEGY-B live KC, AI Plane ADR-016, I-32..I-35 |
| Phase 4.6 — Guardian conversation-level enforcement | ✅ DONE 2026-05-05 | ADR-024/025/026, claude.bash CB1..CB4, ENFORCE mode, §3/§4/§15 |
| Phase 4.7 — V-violations canon formalisation | ✅ DONE 2026-05-05 | 13/13 V-violations → G-* gaps, ADR-027..034 plan, GAP-REGISTER.md |

---

## Track A — Guardian Enforcement Completion

> Closes remaining guardian gaps before any new code lands.

- [ ] G-GUARD-03: ClickHouse guardian audit retention ≥ 12 months (I-08 extension).
- [ ] G-GUARD-04: ENFORCE mode active on ALL repos (verify banxe-architecture shim config).
- [ ] G-CANON-AUTONOMY: Add V-14..V-17 to canon-judge test suite (MetaClaw test_canon_judge.py). Target: 17/17 PASS.
- [ ] G-CANON-15: Cover §15 Claude-Code-First in conversation-judge prompts (G-CANON-01 Week 3).

## Track B — IAM Live-Ops (operator-led)

> Low-risk, high-value; each step is reversible or short-downtime.

- [ ] **Phase F**: Production KC dev-file → Postgres backend switch. Staging 4/4 grants validated. RUNBOOK: `infra/keycloak-banxe-emi/RUNBOOK.md §G-IAM-09 Closure`. ~30-60s downtime. Trigger: operator says "go Phase F".
- [ ] **Phase G**: Production KC session-timeout hardening (V-02 / G-IAM-06). RUNBOOK: same file §Phase G. ~5 min, no downtime. Trigger: "go Phase G".
- [ ] G-IAM-09: Migrate keycloak-pg sidecar to shared managed Postgres (TBD schedule).

## Track C — KYC Reliability (ADR-028, ADR-034)

> Compliance-critical; silent KYC FSM drift = MLR 2017 Reg.28 exposure.

- [ ] ADR-028: KYC re-verification triggers strategy — write decision, implement triggers (G-KYC-01/02).
- [ ] ADR-034: SumSub webhook retry/DLQ — choose option (idempotency+200-OK / tenacity / DLQ inbound routing), implement, add SUMSUB_WEBHOOK_SECRET to .env.example (G-KYC-03/04).
- [ ] Tests: replay attack, out-of-order delivery, invalid signature, 5xx response path (G-KYC-04).

## Track D — Audit Trail Durability (ADR-027)

> FCA CASS 15 + I-24 hard requirement; write-once append-only.

- [ ] ADR-027: ClickHouse + pgAudit durability strategy — write decision.
- [ ] Implement: ClickHouse replication config, pgAudit WAL archival, 5yr TTL enforcement gate.
- [ ] Close G-CASS-01 (ClickHouse single-node risk) + G-CASS-02 (pgAudit WAL not archived).

## Track E — Observability / Alert Routing (ADR-033)

> KC generates events but eventsListeners=[]. Silent auth anomalies.

- [ ] ADR-033: KC alert routing channel — choose (a) n8n+Telegram / (b) KC SPI+Slack / (c) Prometheus+Alertmanager.
- [ ] Implement: set eventsListeners in realm-export, KC event retention ≥ 90 days.
- [ ] G-OBS-02: CI smoke test — synthetic LOGIN_ERROR → assert delivery < 60s.
- [ ] Close G-OBS-01/02.

## Track F — Security / Secrets Rotation (ADR-032)

> No rotation policy = I-34 exposure. Vault placeholder for long-term.

- [ ] ADR-032: Interim secrets rotation policy — document cycle, owners, n8n reminders.
- [ ] Audit all operator-supplied secrets: `~/.banxe/keycloak.env`, GitHub Actions secrets, systemd EnvironmentFile.
- [ ] G-SEC-02: Vault/Infisical long-term adoption — ADR stub, schedule TBD.
- [ ] Close G-SEC-01.

## Track G — Ops / CI Hardening (ADR-029, ADR-030, ADR-035)

> Infrastructure hygiene; required before production traffic.

- [ ] ADR-029: Postgres backup rotation strategy (G-OPS-01/02).
- [ ] ADR-030: Auth surface rate limits — FastAPI middleware / KC brute-force policy (G-API-01/02).
- [ ] ADR-035: End-to-end smoke gate — CI fixture covering payment + KC auth + safeguarding recon (G-CI-01/02).
- [ ] G-INFRA-01: evo2 added to SERVICE-MAP + `.claude/rules/infrastructure.md`.

## Track H — New Architecture Work

> Greenfield; begin only after Track A-D stable.

- [ ] Phase 5: Advanced Features — multi-agent comms protocol, real-time dashboard (ClickHouse + Superset/Metabase), Telegram bot ops interface, FCA Section 4 automated reporting, MI report generator.
- [ ] Phase 6: Crypto Block — Neuronext custody API, wallet management, TomPay fiat↔crypto bridge, Travel Rule (FATF 16), crypto AML (Chainalysis/Elliptic), cross-entity reconciliation.
- [ ] Phase 7: Testing & QA matrix — E2E onboarding, payment regression, compliance scenario playbooks, AI agent benchmarks, load testing.
- [ ] Phase 8: Production Readiness — infra hardening (DR, failover), monitoring/alerting full coverage, docs audit, go-live checklist sign-off.

## Track I — External / Organisational Blockers

> Unblocks Phase 2 live integrations. CEO/operator action required.

- [ ] Modulr Payments live API key (register at modulrfinance.com/developer).
- [ ] Companies House API key.
- [ ] OpenCorporates API key.
- [ ] Sardine.ai API key.
- [ ] Telegram bot credentials for n8n shortfall alert (TELEGRAM_BOT_TOKEN + TELEGRAM_MLRO_CHAT_ID).
- [ ] Marble API key + INBOX_ID.
- [ ] Jube admin password.

---

## Track K — Three-Node Fabric Operationalization (PROPOSED, ADR-104)

> Status: **PROPOSED — planning only. Activates nothing.** Operationalizes the canonical merged
> **ADR-104** (three-node execution fabric: evo1 control / evo2 reasoning / Legion execution) +
> its six fabric invariants F1..F6 (= the `I-FAB-1..6` labels in the PROPOSED ADR-FABRIC-01, #492 —
> see convergence note). `AGENT_ROUTING_ENABLED` stays `false`; every build/enable step is **GATED**
> on Terminal-A infra + CEO/WG ratification.

### Reality audit (designed vs running — read-only, 2026-06-17)

| Inv | Designed (ADR-104) | Running on infra? | Blocker | Gated-on / sprint |
|---|---|---|---|---|
| **F1** unified task lifecycle + `correlation_id` | yes (reuses ADR-046) | ❌ no — `correlation_id` schema exists (ADR-046) but no unified 3-node task lifecycle | no fabric lifecycle/orchestrator service | K-2 |
| **F2** shared queue + heartbeat/health | yes | ⚠️ partial — evo2 `:8082 /health` 200, `node_exporter :9100`, RabbitMQ `:3004` on evo1; **no** unified cross-node task/event queue + fabric heartbeat protocol | no fabric queue + heartbeat daemon | K-3 (↔ Track J / ADR-WDG-01) |
| **F3** evo1 policy gate + Legion exec gate | yes | ❌ no — Ruflo not deployed (`G-FACTORY-RUFLO-NOT-DEPLOYED` P0 OPEN); `AGENT_ROUTING_ENABLED=false` | Phase F1 Ruflo deploy + ADR-RUFLO-01 ratify | K-4 |
| **F4** controlled context-sync (no drift) | yes | ❌ no — no sync layer; context flows ad-hoc | no sync-layer build | K-5 (↔ Memoir/CMS, BL-SCRIPT-01) |
| **F5** fail-closed failover | yes | ❌ no — nodes independently healthy, no cross-node failover logic | no failover controller | K-6 |
| **F6** fabric-by-default + `AGENT_ROUTING` flip | yes | ❌ no — `AGENT_ROUTING_ENABLED=false`; tasks single-node by default | K-1..K-6 + Terminal-A infra | K-7 (last) |

> **Substrate is up, coordination layer is not.** Nodes evo1 (`192.168.0.72`) + evo2
> (`192.168.0.15`, REGISTERED) + Legion, the qwen3-235b reasoning brain (`evo2:8082`, ✅ healthy),
> the Legion LiteLLM `:4000` gateway, the USB4 evo1↔evo2 link, and `:9100` metrics are **running**.
> The fabric **coordination layer** (unified lifecycle, queue, heartbeat protocol, policy/exec gates,
> sync layer, failover) is **designed-only**.

### Gated sprints

- **K-1 — Ratify ADR-104 + F1..F6** (CEO/WG). **[GATED]** Precondition for all build sprints.
- **K-2 — Unified task lifecycle + `correlation_id`** (F1, reuse ADR-046; no new trace schema). **[build, sandbox-first]**
- **K-3 — Shared queue + heartbeat/health** (F2). **CONVERGES with Watchdog Track J / ADR-WDG-01** (the watchdog heartbeat is the fabric heartbeat — single implementation, not two). **[build, sandbox-first]**
- **K-4 — evo1 policy gate + Legion execution gate** (F3). **Depends on Phase F1 (Ruflo deploy) + ADR-RUFLO-01.** **[GATED]**
- **K-5 — Controlled context-sync layer** (F4). **CONVERGES with Memoir/CMS (BL-SCRIPT-01)** — context-sync reuses the memory candidate, subject to its own ADR + dup-audit. **[build, sandbox-first]**
- **K-6 — Fail-closed failover** (F5): evo2 down ⇒ evo1 lightweight reasoning + Legion blocks risky actions. **[build]**
- **K-7 — Fabric-by-default + flip `AGENT_ROUTING_ENABLED`** (F6) — **LAST.** **[GATED on K-1..K-6 + Terminal-A infra + the four AGENT_ROUTING enable-conditions]**

### Dependencies & convergence

- **Phase F1** (Ruflo deployment, `G-FACTORY-RUFLO-NOT-DEPLOYED` P0) — hard dependency for K-4.
- **Track J** (watchdog, ADR-WDG-01) — the heartbeat/health implementation is shared with K-3.
- **Memoir/CMS** (BL-SCRIPT-01, backlog #493) — candidate substrate for K-5 context-sync.
- **Terminal-A infra** — all node-side stand-up (queue daemon, sync layer, gate wiring) is Terminal A's domain (CLAUDE.md NO-WAIT rule).
- **Convergence note (ADR-102):** the merged **ADR-104** and the still-open **#492 (ADR-FABRIC-01)** are
  near-duplicates (same six invariants; ADR-104 contract `docs/runbooks/three-node-execution-fabric-contract.md`
  vs #492 `docs/contracts/runtime-contract-evo1-evo2-legion.md`). **ADR-104 is canonical (merged).**
  Recommendation (operator decision, NOT actioned here): close #492 as **superseded by ADR-104**.

Track K **activates nothing** — planning artifact only.

---

## CANON SESSION RULES (1..7)

Обязательные правила каждой сессии. Источник: ADR-025 Agent Interaction Canon §14 + §3/§4/§15.

1. **§15 Claude-Code-First**: все действия исполняются в Claude Code. Shell только при выполнении одного из 5 исключений (out-of-tree probe / permission ceiling / bootstrap-recovery / independent verification / phase-deadline pressure).
2. **§1 OCAT**: один ход = одна задача (промт ИЛИ команда). Никаких параллельных action в одном сообщении.
3. **§4 Best-Decision Principle**: агент принимает лучшее решение сам из 6 источников (сессионный канон / production CLAUDE.md / ADR + INVARIANTS / read-only факты / GAP-REGISTER / отраслевой best-practice). Не перекладывает на оператора.
4. **§2 Адресат**: каждый ход явно помечается «Для Claude Code (repo, path):» или «Для Legion (mark-legion shell):». Один адресат за ход.
5. **§3 Whitelist**: безопасные read-only операции (`git status`, `grep`, `ls`, `cat`, чтение файлов, `gh pr view`, `docker ps`, `curl` GET) — выполнять без подтверждения оператора.
6. **§6 Scope guard**: работаем только в production repos `CarmiBanxe/*`. Перед началом verify: `git remote -v` должен показывать `CarmiBanxe/*` GitHub URL. Sandbox `/data/banxe-emi-stack` — frozen.
7. **§8 Secret-leak zero**: не печатать секреты, токены, хэши, длины секретов или любые метаданные, которые дают энтропию.

---

## Cross-references

- GAP-REGISTER.md — полный список всех G-* gaps с планом.
- INSTRUCTION-LEDGER.md — IL-CANON-01..05, IL-052 и далее.
- ROADMAP.md — Phase 4.5/4.6/4.7 COMPLETED; Phase 5..8 PLANNED.
- docs/sessions/HANDOFF-2026-05-05-emi-canon-checkpoint.md — детальный checkpoint (production state, ADRs, invariants, repo topology).
- decisions/ADR-025-agent-interaction-canon.md — binding canon document.
- docs/canon/AGENT-INTERACTION-CANON.md — living doc canon.
