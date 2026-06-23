# BANXE Factory Roadmap — 2026-06-23

> **Status:** PROPOSED (awaits operator merge). **Basis:** BANXE FACTORY AUDIT v2 @ mark-legion
> 2026-06-23 (live audit, not memory) + PR #707/IL-460 (defusedxml XXE close on `main`).
> **Scope:** factory build-out from current audited state to **100 % skill adoption**.
> **Discipline:** audit-first · best-solution · minimal-diff · append-only ledger · passport-bound skills.
> This document is a *plan*. Artifacts owned by later sprints are **specified here, not implemented**.
> **Scope boundary (ADR-102):** this is the **factory** build-out roadmap (factory infra, training
> runner, traffic-light, skill adoption). For **project/EMI status** see the companion
> `docs/ROADMAP-STATUS-2026-06-23.md` (PR #716, canonical for *status*) — referenced, not duplicated.

## 0. Audit-derived problem statement (v2, verbatim findings → roadmap drivers)

| # | Audited fact (v2) | Roadmap driver |
|---|---|---|
| A1 | `main` advanced (origin `95d3c08`); #708 closed-clean; defusedxml fix landed via **PR #707 / IL-460**; `use-defused-xml` count = 0; pre-commit PASS | Baseline is green — build forward, not backward |
| A2 | **Training runner MISSING** — no `scripts/train.sh`, empty `make train` | **R2** (S-FAC-63/64) |
| A3 | SKILLS-MATRIX / SKILLS-ORCHESTRATION / SKILLS-OPERATING-MODEL exist; branch `factory/ai-onboarding` exists | **R3** (S-FAC-66/67) |
| A4 | Hardware: legion 20 vCPU / 54 GiB / RTX 4070 idle ~6 %; evo1 & evo2 = **no-GPU** | Train/infer co-locate on legion GPU; evo* = CPU/services |
| A5 | Models: ollama `qwen2.5-coder:14b-banxe-factory` + `7b`; ArchiMate claims `qwen3-30b` → **mismatch** | **R2** (S-FAC-64 model registry reconciliation) |
| A6 | Env: evo1 `midaz-ledger`/`mongodb`/`workflow-service` **RESTARTING (RED)**; legion `keycloak` **unhealthy (YELLOW)**; `redis-cli` absent on legion | **R0** (S-FAC-60/61) |
| A7 | **No audit cron** → traffic-light agent must be built **from zero** | **R1** (S-FAC-62/65) |

No data beyond audit v2 is assumed. Items marked *(asserted)* in source docs remain assertions.

## 1. Roadmap blocks R0–R5

- **R0 — Environment stabilization.** Bring RED/YELLOW services to a known-good contract:
  evo1 `midaz-ledger`/`mongodb`/`workflow-service`, legion `keycloak`; install `redis-cli` on
  legion. Exit: every audited service GREEN or explicitly quarantined with a reason.
- **R1 — Observability & traffic-light.** Stand up the audit cadence that does not yet exist:
  telemetry schema, Redis fabric stream, and the traffic-light agent (08:00/20:00 CEST). Exit:
  two scheduled verdicts/day persisting to ledger + stream.
- **R2 — Training runner & model truth.** Deliver the missing `scripts/train.sh` + `make`
  targets (S-FAC-63) and a single model-routing source of truth resolving the qwen mismatch
  (S-FAC-64). Exit: `make train-dry` green on legion GPU; model registry == reality.
- **R3 — Skills adoption.** Bind every skill in SKILLS-MATRIX to a passport **and** a ledger
  entry; wire SKILLS-ORCHESTRATION sequences into the factory. Exit: 0 unbound skills.
- **R4 — DORA/KPI binding.** Wire the KPI-DORA-FRAMEWORK §4.2 collection pipeline to factory
  events (deploy, lead-time, CFR, MTTR) + ADR-117 KPIs. Exit: metrics flow to the dashboard model.
- **R5 — 100 % adoption gate & close-out.** Verify the adoption gate, run the clean final audit,
  close the roadmap. Exit: gate satisfied (§3).

## 2. Sprint table S-FAC-60 … S-FAC-69

| Sprint | Block | Title | Definition of Done (DoD) |
|---|---|---|---|
| **S-FAC-60** | R0 | evo1 RED-service triage | Root-cause for `midaz-ledger`/`mongodb`/`workflow-service` RESTARTING documented; remediation runbook; services GREEN ≥30 min or quarantined w/ reason in ledger. |
| **S-FAC-61** | R0 | Health contract + legion `redis-cli` | `redis-cli` installed on legion; keycloak YELLOW→GREEN root-cause + fix; uniform healthcheck contract (endpoint, interval, RED/YELLOW/GREEN thresholds) documented per service. |
| **S-FAC-62** | R1 | Audit telemetry schema + fabric stream | JSON-Schema for an audit event (service, status, reason, ts, source); Redis fabric stream channel defined; append-only ledger binding for each audit run; schema validated by `guardian-schemas`. |
| **S-FAC-63** | R2 | **Training runner** (`scripts/train.sh` + Makefile) | Artifact spec §4.1 implemented: `train`/`train-dry`/`train-verify` targets; `train-dry` exits 0 on legion GPU without mutating models; reads SKILLS-MATRIX→passports; Ruff ≥0.12.0 clean (**S314, never S320**). |
| **S-FAC-64** | R2 | Model registry reconciliation | Single source of truth for model routing (config-as-data); qwen2.5-coder 14b/7b vs ArchiMate `qwen3-30b` mismatch (A5) resolved or documented as deliberate; ArchiMate updated to match reality. |
| **S-FAC-65** | R1 | **Traffic-light agent** | Artifact spec §4.2 implemented on `internal_audit_agent` (+`resilience_agent`): cron 08:00/20:00 CEST + Redis trigger; emits 🔴🟡🟢 + reason; writes ledger shard + publishes to stream; DORA-bound. |
| **S-FAC-66** | R3 | Skill ↔ passport ↔ ledger binding | Every skill in SKILLS-MATRIX mapped to exactly one passport (`agents/passports/*.yaml`) and one ledger entry; unbound-skill count = 0; SKILLS-OPERATING-MODEL updated. |
| **S-FAC-67** | R3 | Orchestration enforcement | SKILLS-ORCHESTRATION scenario→sequence rules wired so the factory runs them in order (CMS→RSB→ACG→… per matrix); quality-gate remains final layer; no skill bypasses gate. |
| **S-FAC-68** | R4 | DORA/KPI collection wiring | KPI-DORA-FRAMEWORK §4.2 pipeline emits the 4 DORA metrics + 5 ADR-117 KPIs from factory events into the dashboard model (§5); on-prem residency (A?, §4.3 asserted) honored. |
| **S-FAC-69** | R5 | 100 %-adoption gate + final audit | Adoption gate (§3) verified GREEN; clean final audit (0 RED, 0 unbound skill, 0 open DoD); roadmap CLOSE entry in ledger; sign-off artifact. |

**Sequencing:** R0 (60–61) → R1/R2 in parallel on green env (62,63,64,65) → R3 (66,67) →
R4 (68) → R5 (69). S-FAC-63 and S-FAC-65 carry only **specs** until their sprint opens.

## 3. 100 %-adoption gate (definition of "done for the whole roadmap")

The factory is **100 % adopted** when **all** hold simultaneously:

1. **Traffic-light GREEN 2×/day for 3 consecutive days** — six consecutive scheduled verdicts
   (08:00 & 20:00 CEST × 3 days), each persisted to ledger + stream, all GREEN.
2. **Clean final audit** — final audit run reports 0 RED services, 0 unbound skills, 0 open DoD.
3. **Every skill passport+ledger bound** — each SKILLS-MATRIX skill has a passport and a ledger entry (S-FAC-66).

Gate is binary; a single amber/red verdict in the 3-day window resets the counter.

## 4. Artifact specifications (DEFINED here, IMPLEMENTED in their sprint)

### 4.1 S-FAC-63 — `scripts/train.sh` + Makefile targets

- **`scripts/train.sh`** (POSIX `sh`/`bash`): single entrypoint, config-as-data (no hardcoded
  model names — reads the S-FAC-64 model registry). Subcommands map to Makefile targets.
- **Makefile targets:**
  - `make train` — full training run on legion RTX 4070 (the only GPU host, A4); refuses on
    no-GPU hosts (evo1/evo2).
  - `make train-dry` — validate config + dataset + passport mapping, **no model mutation**; exit 0
    is the S-FAC-63 DoD probe.
  - `make train-verify` — post-train assertions (model tag present in ollama, eval threshold).
- **Input contract:** reads `docs/SKILLS-MATRIX.md` → resolves each skill to its owning passport
  (`agents/passports/*.yaml`); the matrix is the source of truth for what gets trained/bound.
- **Quality:** Python helpers (if any) use **Ruff ≥ 0.12.0**; XML/parse code uses the **S314**
  rule family — **`S320` is forbidden** (defusedxml is already the standard on `main`, PR #707).

### 4.2 S-FAC-65 — Traffic-light audit agent

- **Owner agents:** `agents/passports/internal_audit_agent.yaml` (primary) +
  `agents/passports/resilience_agent.yaml` (co-owner for RED escalation).
- **Triggers:** cron **08:00 & 20:00 CEST**; plus **Redis fabric/legion session trigger** (event
  on session start so an ad-hoc audit can run on demand).
- **Verdict:** one of **🔴 / 🟡 / 🟢** with a machine-readable `reason` (per the S-FAC-62 schema).
  Threshold rule: any audited service RED ⇒ 🔴; any YELLOW ⇒ 🟡; all GREEN ⇒ 🟢.
- **Outputs:** (a) append-only **ledger shard** per run; (b) **publish** verdict to the Redis
  fabric stream (S-FAC-62 channel) for downstream/dashboard consumption.
- **DORA binding:** verdict + reason feed KPI-DORA-FRAMEWORK §4.2 (deployment-frequency proxy via
  GREEN cadence; CFR/MTTR via RED→GREEN transitions); supplies the 3-day GREEN evidence for §3 gate.
- **Constraints:** read-only audit (no service mutation); HITL on RED escalation per resilience
  passport; no `--admin`/bypass; config-as-data thresholds (no hardcoded limits).

## 5. Duplication Audit (ADR-102)

Repo-wide search for roadmap artifacts dated 2026-06-23 / overlapping the factory build-out:

| Match | Scope | Decision |
|---|---|---|
| `docs/ROADMAP-STATUS-2026-06-23.md` (PR #716) | **Project/EMI** status + forward plan; governance/org line, EMI product blocks, BANXE.RAR→EMI migration; *canonical for status* | **KEEP both** — disjoint scope. This doc adds nothing that ROADMAP-STATUS covers; cross-referenced above. |
| `docs/ROADMAP-MATRIX.md` | Product **block→sub-block** registry (taxonomy) | **KEEP** — no overlap; this doc defines no product blocks. |
| `docs/roadmap/audit-2026-05-*`, `sprint-factory-developer-audit-2026-05.md` | Prior (May) factory/project audits | **KEEP** — superseded by audit v2 for *current* state; historical. |

Source-of-truth: factory sprints **S-FAC-60..69** and the training-runner / traffic-light specs
exist in **no** other artifact → this doc is their source-of-truth. No merge/delete; no hidden
consumer. Outcome: **additive, non-duplicative.**

## 6. Provenance & references

- **Basis:** BANXE FACTORY AUDIT v2 @ mark-legion 2026-06-23; #708 closed-clean.
- **Proof anchors:** PR **#707** (`d37a955`, defusedxml S320 close) / **IL-460** on `main`.
- **Refs:** `docs/governance/KPI-DORA-FRAMEWORK.md`; `governance/CANONICAL-ORG-CHART-v2.md`;
  `governance/STAFF-MATRIX-v2.md`; `docs/SKILLS-MATRIX.md`; `docs/SKILLS-ORCHESTRATION.md`;
  `docs/SKILLS-OPERATING-MODEL.md`; `agents/passports/internal_audit_agent.yaml`;
  `agents/passports/resilience_agent.yaml`; ADR-119 (frozen IL numbering); ADR-060 (branch namespace).
