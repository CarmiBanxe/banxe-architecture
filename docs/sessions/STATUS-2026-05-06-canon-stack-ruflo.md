# Session Status — 2026-05-06 — Canon Stack + Ruflo Orchestration

Generated: 2026-05-06 | Branch: docs/status-2026-05-06-canon-stack-ruflo

---

## Canon HEAD State

- **main HEAD:** `3894f24`
- **Key PRs merged in this session:**
  - PR #98 — `canon: factory/project stack — Legion, evo1, evo2 roles` (`68952b9`) → IL-CANON-STACK-2026-05-06
  - PR #99 — `canon: add Ruflo Review Agent to factory/project orchestration` (`24e106c`) → IL-CANON-RUFLO-2026-05-06 (docs)
  - PR #100 — `canon(il): IL-CANON-RUFLO-2026-05-06 — Ruflo Review Agent canonical placement in orchestration` (`3894f24`) → IL ledger entry
- **Canon files updated:**
  - `docs/canon/factory-project-stack-2026-05.md` — Legion/evo1/evo2 role map + Ruflo orchestration section
  - `INSTRUCTION-LEDGER.md` — entries IL-CANON-STACK-2026-05-06 and IL-CANON-RUFLO-2026-05-06 (BINDING, P1)

---

## Closed in This Session

| IL / Gap | Summary |
|---|---|
| IL-CANON-PROCESS-HYGIENE-2026-05-06 | Canon process hygiene rules: destructive verify-step (safety-rules.md) + parallel session isolation (new file, 6 rules) |
| G-OPS-04 / IL-OPS-G-OPS-04-2026-05-06 | banxe-frankfurter zombie on evo1 decommissioned (`docker stop` + `rm`, no restart policy) |
| G-OPS-05 / IL-OPS-G-OPS-05-OBSERVED-2026-05-06 | evo1 keycloak.service observed HEALTHY (active running, pid=705370, :8180 via Tailscale) — reclassified MONITOR |
| G-FACTORY-04 / IL-OPS-G-FACTORY-04-OBSERVED-2026-05-06 | Legion :8180 Java orphans not confirmed at observation time — 0 Java processes, docker-proxy only — reclassified MONITOR/VERIFY |
| IL-SEC-01-2026-05-06 | Frankfurter Postgres password exposed in PA-5a logs — PERMANENTLY BANNED from reuse; canon applied |
| IL-CANON-STACK-2026-05-06 | Factory/project stack canon: Legion=factory-fast/coder, evo1=infra/services, evo2=heavy-model/reasoning |
| IL-CANON-RUFLO-2026-05-06 | Ruflo Review Agent canonical placement: mandatory ARL pipeline placement, NOT a PATH binary, binding for all regulated request types |

---

## Still OPEN / Next Priorities

Derived from `GAP-REGISTER.md` at main HEAD `3894f24`. Sorted P1 → P3, then by domain.

### P1

| Gap | Description |
|---|---|
| G-KYC-04 | Webhook signature verification + idempotency-key coverage tests (SumSub) |

### P2

| Gap | Description |
|---|---|
| **G-INFRA-04** ⚠️ | evo1 swap pressure — **live confirmed**: load ~35, swap ~1.5 GiB active. Root cause not yet resolved. Next ops step: identify memory hog processes + swappiness tuning or service migration |
| **G-FACTORY-LITELLM-DUPLICATE** → close candidate | Two systemd units on :4000 (user `litellm-v2.service` + system `litellm-lan-gateway.service`). System-level unit effectively disabled operationally; **candidate for next docs step**: close in GAP-REGISTER + IL entry |

### P3 — MONITOR/VERIFY

| Gap | Description |
|---|---|
| **G-OPS-05** 🔁 | evo1 keycloak.service in restart-loop state — MONITOR. Periodic check required; decommission (docker compose down + disable systemd) is a separate operator-gated step |
| **G-FACTORY-04** 🔁 | Legion :8180 Java Keycloak orphan processes — MONITOR/VERIFY. At 2026-05-06 observation: 0 Java processes, port bound by docker-proxy only. Periodically re-check for unexpected Java PIDs outside canonical container |
| G-CLUSTER-03 | evo1 model dedup execution — ~134 GB cleanup, operator-gated |

### P? — New / Unscheduled

| Gap | Domain | Status |
|---|---|---|
| G-IAM-01..05, G-IAM-07 | IAM | WAITING_FOR_GATE-A (KC evo1 cutover path) |
| G-GUARD-03, G-GUARD-04 | Guardian | NOT_STARTED |
| G-CASS-02 | CASS audit | NEW 2026-05-05 |
| G-KYC-01, G-KYC-02, G-KYC-03 | KYC | NEW 2026-05-05 |
| G-OPS-01, G-OPS-02 | Ops / backup | NEW 2026-05-05 |
| G-API-01, G-API-02 | API rate-limit | NEW 2026-05-05 |
| G-INFRA-01 | Infra docs | NEW 2026-05-05 |
| G-CI-01, G-CI-02 | CI smoke gate | NEW 2026-05-05 |
| G-OBS-01, G-OBS-02 | Observability | NEW 2026-05-05 |
| Block J (safeguarding accounts) | CASS 15 | IN_PROGRESS — recon engine pending |
| D-recon | CASS 15 | NOT_STARTED |
| G-09 | Redis pre-tx gate | unscheduled |

---

## Operator Canon Reminders

### Working Layer

- **Claude Code** is the primary working layer (orchestrator, canon writer, IL author).
- **Shell on Legion** is used as "best decision" plane only: diagnostics, ops verification, confirming machine state (uptime / free / df / nvidia-smi / ps / ss / docker / systemctl on Legion + evo1 + evo2).
- Live shell metrics are the source of truth for infrastructure state — not memory or documentation snapshots.

### Stack Canon (IL-CANON-STACK-2026-05-06, BINDING)

| Node | Role | Canonical use |
|---|---|---|
| **Legion** | factory-fast / factory-coder | RTX 4070 local inference; Claude Code primary session |
| **evo1** | infra / services | Keycloak prod (:8180), Postgres, Redis, compose stacks |
| **evo2** | heavy-model / reasoning | qwen3:235b-Q3_K_S (142 GB); project-reason LiteLLM route |

### Ruflo Orchestration Canon (IL-CANON-RUFLO-2026-05-06, BINDING)

- **Ruflo is NOT a PATH binary.** It is invoked exclusively via the ARL pipeline.
- **Mandatory pipeline for regulated requests:**
  ```
  request → ARL → Ruflo (I-01..I-07 check) → target agent → response
  ```
- **Regulated types:** `payment`, `compliance`, `kyc`, `aml`, `emi`, `fca`.
- **Factory dev-agents:** must consult Ruflo before finalising any code/schema/config change on a regulated surface.
- **Project-side gateways** (gateway-moa, gateway-guiyon, gateway-ctio): must delegate to Ruflo and log result in canonical audit chain (G-01 ExplanationBundle, G-02 trail).
- **Perplexity supervisor-logic:** Ruflo is also mandatory in the supervisor decision path wherever regulated surfaces are touched.
- **Improvement path:** changes to Ruflo scope or pipeline placement require ADR + IL entry. No ad-hoc edits.
