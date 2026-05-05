# CHECKPOINT — EMI BANXE AI BANK — 2026-05-05 20:00 CEST

> **Reference point for resuming sessions.** Tag: `checkpoint-2026-05-05-emi-canon`.
> Cross-repo state captured at end of canon-formalisation phase, before implementation phase begins.

## 1. Project framing

- **Product**: AI-managed Electronic Money Institution under FCA UK regulation.
- **Scope**: GBP/EUR/USD safeguarding (CASS 15), SEPA/SWIFT/FPS payments, card payments, **crypto block** (Neuronext custody + TomPay fiat-crypto bridge + Travel Rule), full KYC/AML pipeline, regulatory reporting (FIN060, SAR POCA 2002 s.330, Consumer Duty PS22/9).
- **Operating model**: 32 roles, 10 departments, 30 features, AI-agents under HITL supervision.
- **Compliance regime**: FCA, MLR 2017, PSR 2017, GDPR Art.5/32, EU AI Act Art.14, FCA SS1/23 (XAI), FINOS AIGF v2.0, KPMG AIGF, DORA Art.14(2).

## 2. Repository topology

| Repo | HEAD on this checkpoint | Role |
|------|------------------------|------|
| CarmiBanxe/banxe-architecture | this commit | Architecture canon — ADRs, INVARIANTS, GAP-REGISTER, INSTRUCTION-LEDGER, ArchiMate, governance, schemas. |
| CarmiBanxe/banxe-emi-stack | merged through PR #59 + #58 + #57 + #51 | Banking stack — 27+ services, infra/keycloak-banxe-emi/. |
| CarmiBanxe/MetaClaw | guardian/ deployed via cron pull | AI/Agent platform — Guardian factory + project + claude.bash family. |

## 3. Production state (live on Legion + evo1)

- **Production Keycloak realm `banxe-emi`** UP on Legion `100.101.218.26:8180` via Tailscale, dev-file backend, 4 client_credentials (banxe-compliance-api, banxe-dashboard, deep-search, drive_watcher).
- **Staging KC with Postgres backend** UP on Legion `:8181` (4/4 grants OK) — ready for Phase F live switch.
- **Guardian factory** :8195 + **project** :8196 on evo1, claude.bash CB1..CB4 active in ENFORCE mode.
- **Cron pull-deploy** MetaClaw → evo1:/data/banxe/guardian/ every 15 min + systemd restart.
- **n8n + Telegram bot** wired, safeguarding-shortfall-alert workflow loaded.
- **Other services on evo1**: ClickHouse, RabbitMQ, Midaz, Ballerine, Jube, Marble, Frankfurter, OpenClaw, PII Proxy.

## 4. Canon — what is binding now

### ADRs (canonical decisions/)
- ADR-001..015: privilege model, telegram, training, Jube AGPLv3, Marble Elastic, evidence bundle, scenario registry, jurisdiction, OpenSanctions, AMLTrix, ref-vs-dep, port :8093, Midaz CBS primary, composable stack, payment processing.
- ADR-016: AI plane / PII routing.
- ADR-017: Keycloak IAM cutover (P3.4).
- ADR-018: hybrid 5-layer AI compute.
- ADR-019: AI Guardian two-family.
- ADR-020: memory governance.
- ADR-022: Guardian bootstrap baseline exception.
- ADR-024: Guardian bash shim (Strategy-S1 PreToolUse).
- ADR-025: Agent Interaction Canon (4-layer; §3 whitelist taxonomy, §4 Best-Decision Principle, §15 Claude-Code-First).
- ADR-026: Guardian agent.bash family (third).

### Thematic ADRs (docs/adr/)
- ADR-031..034: Phase 3 cluster (AI execution policy, GLM-4.5-Air distributed, ufw perimeter, Aider routes).
- ADR-CST-01, ADR-FOS-01, ADR-HMR-01, ADR-LCY-01.

### INVARIANTS active
- I-01..I-31 historical.
- I-32: no direct cloud LLM from EMI services.
- I-33: PII deny-paths route only via local LiteLLM aliases.
- I-34: no direct credentials in EMI configs.
- I-35: Keycloak realm `banxe-emi` as single IAM issuer.
- I-36: Claude Code bash routes through Guardian shim.

### IL-CANON ledger
- IL-CANON-01: ADR-025 + G-CANON-01 design.
- IL-CANON-02: V-01 closure (G-GUARD-01).
- IL-CANON-03: G-DEPLOY-01 closure (cron pull-deploy).
- IL-CANON-04: best-decision rule (layer 3 of 4-layer canon).
- IL-CANON-05: §3/§4 expansion + §15 CCF + V-14..V-17.
- IL-052: phase4 org-cleanup branch recovery post-mortem.

### Open gaps awaiting ADR + code
- G-CASS-01/02 — audit-trail durability → ADR-027
- G-KYC-01/02 — KYC re-verification triggers → ADR-028
- G-KYC-03/04 — SumSub webhook retry/DLQ → ADR-034
- G-OPS-01/02 — Postgres backup rotation → ADR-029
- G-API-01/02 — auth rate limits → ADR-030
- G-CI-01/02 — end-to-end smoke gate → ADR-035 (ADR-031 already taken by Phase 3 cluster)
- G-SEC-01/02 — secrets rotation + Vault placeholder → ADR-032
- G-OBS-01/02 — KC alert routing → ADR-033
- G-GUARD-03 — ClickHouse retention 12 months
- G-GUARD-04 — ENFORCE everywhere (all repos)
- G-INFRA-01 — evo2 in SERVICE-MAP / .claude/rules/infrastructure.md

### Operator live-ops gates pending
- **Phase F** — production KC dev-file → Postgres switch (~30-60s downtime)
- **Phase G** — production KC session-timeout hardening (~5 min no downtime)
- **G-IAM-09** — migration to shared managed Postgres (TBD schedule)

## 5. Implementation phases — what comes next

| Phase | Status | Scope |
|-------|--------|-------|
| 1 Core EMI Platform | ✅ DONE | 13 functional blocks, 2987 tests, coverage 89% |
| 2 Operations & Compliance Intelligence | 🔄 PARTIAL | HITL / Notification / Velocity / Consumer Duty / Jube / Ballerine / Marble done; live integrations blocked on API keys (Modulr / Companies House / OpenCorporates / Sardine) |
| 3 Advanced Compliance Reporting | ✅ DONE | FIN060, SAR auto-filing, Consumer Duty annual report |
| 4 Code Implementation (banxe-emi-stack 27 services) | ✅ DONE | All 27 services scaffolded |
| 4.5 Compliance & IAM Cutover | ✅ DONE 2026-05-04 | Keycloak realm `banxe-emi` live, AI Plane, I-32..I-35 |
| 4.6 Guardian conversation-level enforcement | ✅ DONE 2026-05-05 | 4-layer canon, claude.bash CB1..CB4, ENFORCE mode |
| 4.7 V-violations canon formalisation | ✅ DONE 2026-05-05 | 13/13 reframed as G-* gaps + ADR-027..034 plan |
| 5 Advanced Features | ⏳ PLANNED | Multi-agent comms, real-time dashboard, Telegram bot ops, FCA Section 4, MI reports |
| 6 Crypto Block | ⏳ PLANNED | Neuronext API, wallet mgmt, fiat↔crypto bridge, Travel Rule, crypto AML, cross-entity recon |
| 7 Testing & QA | ⏳ PLANNED | E2E onboarding, payment regression, compliance scenarios, AI agent benchmarks, load testing |
| 8 Production Readiness | ⏳ PLANNED | Infra hardening, DR procedures, monitoring/alerting, docs audit, go-live checklist |

## 6. Open prompts (banxe-architecture/prompts/)

- `19-customer-support-block.md` — Customer Support AI
- `20-marketing-block.md` — Marketing & CRO AI
- `21-crypto-onboarding-flow.md` — Crypto wallet onboarding
- `22-crypto-compliance-flow.md` — Crypto AML / Travel Rule
- `23-agent-communication-bus.md` — Inter-agent messaging

## 7. External / organisational blockers (not code)

- Modulr Payments live API key (CEO must register at modulrfinance.com/developer)
- Companies House API key
- OpenCorporates API key
- Sardine.ai API key
- Telegram bot credentials for n8n shortfall alert
- Marble API key + INBOX_ID
- Jube password

## 8. How to resume from this checkpoint

```bash
git -C ~/banxe-architecture fetch origin
git -C ~/banxe-architecture checkout checkpoint-2026-05-05-emi-canon
# read this file
cat ~/banxe-architecture/docs/sessions/HANDOFF-2026-05-05-emi-canon-checkpoint.md
# then return to main and pick a track
git -C ~/banxe-architecture checkout main
```

Recommended next tracks (any one, pick by priority):
- ADR-027 audit-trail durability (closes G-CASS-01).
- Phase F live switch (operator-led, low-risk).
- Phase 6 Crypto block kickoff (new architecture work).
- Phase 7 testing matrix design.
- Resolve external API-key blockers (organisational).
