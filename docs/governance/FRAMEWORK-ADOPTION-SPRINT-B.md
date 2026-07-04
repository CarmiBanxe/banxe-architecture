# Framework Adoption — Sprint B: ADR-148 advance-recommendation + per-engine build-prompts

> **Status:** governance advance-record + build-prompts (Sprint B of the master-plan #978). **Additive,
> pointer-first (ADR-102).** It **recommends** advancing the existing adopt track (ADR-148) and hands
> **install/orchestration tasks** to operator/infra as **build-prompts**. **It installs no binary, edits no
> ADR file (advance = a governance reference, not an ADR edit), does not duplicate ADR-148, touches no
> passport / config / perimeter / legal / ss1, and bypasses no auth.** Every adopt/install/host-placement is
> **`[AWAITS-OPERATOR]`** — the factory prepares tasks; **operator/infra installs**, beyond the ADR-117
> perimeter.

## 1. Baseline (from the #982 host-audit — verified, not re-probed)
- **Already installed (do NOT re-install):** `openclaw` (Legion + evo1, running on evo1), `metaclaw` (Legion),
  `aider` (Legion), `ruflo` (evo1). Sprint B **excludes** these.
- **MISSING — Sprint B targets:** **`hermes`, `mirofish`, `ironclaw`, `nanoclaw`** + external frameworks
  (crewai/autogpt/langgraph/autogen/…) — absent on every host per #982 §7.3.
- **Orchestration alongside install** (operator requirement): each installed engine is wired into the existing
  orchestration in the same step (§5), not left standalone.

## 2. ADR-148 advance-recommendation (decision = operator, via ADR-135)
`ADR-148` (Hands-On-AI adoption pack v1) is currently **`PROPOSED`** (read-only selection, no-install). Sprint B
**recommends advancing it** through the **ADR-135 held-out adoption gate** — but **the advance-vs-defer decision
is the operator's**, taken via ADR-135; **no decision is fabricated here.**
- **Recommendation (advisory):** advance the **factory-side, no-new-secret/infra/egress** deltas first (ADR-148's
  Phase-1), defer the gated Phase-2 items — consistent with ADR-148's own delta-not-greenfield framing.
- **`[AWAITS-OPERATOR]`** — the ADR-148 advance/defer call + its ADR-135 gate run are operator actions; this doc
  **references** ADR-148, does not edit or duplicate it.

## 3. Per-engine build-prompts (MISSING engines)
> Each is a **task specification for operator/infra**, not code and not an install. Role is taken from existing
> canon where defined; where a role/detail is not verifiable it is marked **`[BLOCKING: operator]`** — **not
> invented.** Host targets are drawn from `config/fleet/server-inventory.yaml` (Legion / evo1 / evo2); final
> placement is **`[AWAITS-OPERATOR]`**.

### 3.1 `hermes`
- **Role (verified, ADR-126/127):** Tier-1 **CI/CD Watchdog + Telegram DevOps + infra/alerting companion**,
  **read-only / alerting-first, HITL-safe, factory-scoped**; ADR-126 parks it as the concrete shape of the
  "future 24/7 agents" item.
- **Dual-use assessment (as #949):** persistent 24/7 agent server + SSH/browser/cron gateways = **dual-use**;
  adopt only within the ADR-126 read-only/no-write envelope. **No write/merge/deploy/payment authority**
  (ADR-127/130).
- **Install-task (operator/infra):** host candidate = **Legion** (factory host, per inventory — Hermes is
  factory-scoped) OR a dedicated persistent server; **final host `[AWAITS-OPERATOR]`**. Install per the
  upstream project's documented method; **factory does not pull the binary.**
- **Orchestration:** register as a **read-only Tier-1 watchdog** feeding the factory journal + Prometheus/Telegram
  (ADR-126, #964 placement); monitored by agent-liveness (#988).
- **Adopt-vs-defer:** **`[AWAITS-OPERATOR]`** (ADR-135 gate; dual-use).

### 3.2 `mirofish`
- **Role (verified, `.claude/rules/agents.md`):** **Research Agent** (MiroFish, ports :3001/:5004) — API
  research, changelog, feature-parity.
- **Dual-use assessment:** research/read-oriented; lower dual-use risk than a code-writing/gateway engine, but
  network-egress for research ⇒ egress via the **litellm gateway seam only** (ADR-148 §egress); no direct
  uncontrolled egress.
- **Install-task (operator/infra):** host candidate = **evo1** (orchestration/control node per inventory, where
  the MoA gateways already run) OR **Legion**; **final host `[AWAITS-OPERATOR]`.** Install per upstream method.
- **Orchestration:** expose as a research route behind the evo1 MoA gateway / litellm :4000; a2a contract
  (ADR-150) for inter-agent calls; liveness via #988.
- **Adopt-vs-defer:** **`[AWAITS-OPERATOR]`**.

### 3.3 `ironclaw`
- **Role:** **OpenClaw-family variant named in the Hermes/memory ADRs** (ADR-126/135/136/137). Its **exact role
  is not verifiable from repo canon** ⇒ **`[BLOCKING: operator]` — specify role before adopt** (not invented).
- **Dual-use assessment:** OpenClaw-family ⇒ presumed **dual-use** (gateway/agent capability); treat as such
  until the operator specifies. No authority expansion (ADR-130).
- **Install-task (operator/infra):** host candidate = **evo1** (OpenClaw-family already runs there) — **but
  gated on the `[BLOCKING: operator]` role clarification**; final host `[AWAITS-OPERATOR]`.
- **Orchestration:** if adopted, wire into the evo1 MoA gateway family (ctio/guiyon/moa pattern); liveness #988.
- **Adopt-vs-defer:** **`[AWAITS-OPERATOR]`** — **defer by default** until role is specified.

### 3.4 `nanoclaw`
- **Role:** **OpenClaw-family variant named in ADR-127 (Hermes delegation) + the Hermes-stack ledger.** Exact
  role **not verifiable** ⇒ **`[BLOCKING: operator]` — specify before adopt** (not invented).
- **Dual-use assessment:** OpenClaw-family ⇒ presumed dual-use; same envelope as ironclaw.
- **Install-task (operator/infra):** host candidate = **evo1**; **gated on role clarification**; final host
  `[AWAITS-OPERATOR]`.
- **Orchestration:** as ironclaw (MoA-family), if adopted; liveness #988.
- **Adopt-vs-defer:** **`[AWAITS-OPERATOR]` — defer by default** until role is specified.

### 3.5 External frameworks (crewai / autogpt / langgraph / autogen / …)
- **Role:** general agent-orchestration frameworks; **appear only in the `docs/agent-engine-dossier/` research
  set** (SRC-01/04 landscape/selection), **not selected**. ADR-148 already frames orchestration as
  delta-not-greenfield (existing `services/swarm/orchestrator.py` + LangGraph/AutoGen referenced).
- **Recommendation:** **defer** — no external framework is adopted without ADR-148 advancing + an ADR-135
  gate; **`[AWAITS-OPERATOR]`**. Third-party import requires the ADR-148 **license review + no-import-without-
  review** rule.

## 4. Boundary — build-prompts + advance-recommendation, NOT install
- **The factory does NOT install dual-use code, pull third-party binaries, or bypass auth.** Installation of any
  missing engine is **operator/infra, by their hand, per these tasks, beyond the ADR-117 perimeter.**
- **No ADR file is edited** — the ADR-148 advance is a **governance reference/recommendation**, taken by the
  operator via ADR-135; ADR-148/126/127 are **cited, not duplicated or modified.**
- **No host is invented** — targets are inventory hosts (Legion/evo1/evo2) as *candidates*; final placement is
  `[AWAITS-OPERATOR]`. Unknown roles (ironclaw/nanoclaw) are `[BLOCKING: operator]`, not guessed.

## 5. Unified orchestration (install-time, operator requirement)
All engines — **already-installed** (openclaw/metaclaw/aider/ruflo) **and newly-adopted** — are orchestrated
**uniformly** via the **existing canon**, not a new mechanism:
- **evo1 MoA gateway** (ctio/guiyon/moa, confirmed running #982) + **litellm :4000** egress seam;
- **a2a inter-agent contract (ADR-150)** for inter-agent messaging;
- **shared-space / arbiter orchestration (ADR-154)** for coordination;
- **agent-liveness (#988)** for 7/24 monitoring of every engine/agent uniformly.
This §5 is a **task for infra** (wire new engines into the above), **not code here.** **`[AWAITS-OPERATOR]`** for
the actual wiring.

## Install Provenance Guardrail
> Addendum (2026-07-03, additive). Records **verified install sources** so no engine is pulled by *name-match
> alone*. Evidence basis: the operator-provided engine-install-audit read + existing local repo docs. **Doc-only;
> installs nothing, edits no passport/ADR/config, bypasses no auth, invents no provenance.** This closes a gap
> not yet captured in the §3 build-prompts: **which source is trusted, and which is a wrong/unknown publisher.**

| Engine | Approved source | Status | Required action | Notes |
|---|---|---|---|---|
| **openclaw** | npm, publisher **steipete/vincentkoc** (installed 2026.3.24) | **trusted** | none — installed | the trusted openclaw-family publisher |
| **aider** | pipx package **`aider-chat`** (0.86.2) | **trusted** | install as `aider-chat` | **real package name is `aider-chat`, NOT `aider`** |
| **metaclaw** | pipx venv | **trusted** | none — installed | — |
| **mirofish** | **local repo `~/MiroFish`** — build-from-local (Dockerfile, docker-compose.yml, backend/frontend, package.json) | **source-identified — local-only** | build from local `~/MiroFish` (source = CarmiBanxe/MiroFish); do **not** substitute a registry package | `~/banxe-mirofish` is a **different docs/scenarios repo** |
| **hermes** | **none verified** — BANXE ADR-126 Hermes is a **canon role, not a public package**; public npm `hermes` = Segment's, pip `hermes 0.9.1` = unknown | **blocked (no verified source)** | **do NOT install any public package named `hermes`** | BANXE-role ≠ any public `hermes` package |
| **nanoclaw** | pip `2026.3.20`, **publisher unverified** | **`[BLOCKING: operator]`** | operator must verify it belongs to the openclaw family **before** any install | do not install until verified |
| **ironclaw** | public npm `2026.2.22-1.3.1`, publisher **kumareth** | **do NOT install** | reject — wrong publisher | **impersonation / wrong-publisher risk** |

**Policy.** A **public package-name match is not sufficient provenance.** No install proceeds without a
**verified publisher/source** and **license-review compliance** (ADR-148 no-import-without-license-review;
CLAUDE.md §9 external-adoption + HITL). **Wrong-publisher** (ironclaw/kumareth) and **unknown-publisher**
(nanoclaw pip; public hermes) matches are **blocked**. Where the verified origin is a **local source**
(mirofish → `~/MiroFish`), the install **must remain local-source** — it may not be swapped for a same-named
registry package. This guardrail is a **precondition** on every §3 build-prompt before any package pull.

## Anchors
`docs/adr/ADR-148-handson-ai-adoption-pack-v1.md` (adopt track — **referenced for advance, not edited/duplicated**;
PROPOSED, ADR-135 gate) · `docs/adr/ADR-126-hermes-tier1-cicd-watchdog-role.md` + `docs/adr/ADR-127-hermes-factory-delegation-contract.md`
(Hermes role, read-only; ironclaw/nanoclaw named) · `docs/adr/ADR-135-agent-skill-evolution-gate.md` (adoption
gate — the advance mechanism) · `docs/adr/ADR-117-*` (perimeter — install operator-side) · `docs/adr/ADR-154-*`
(arbiter/shared-space orchestration) · `docs/adr/ADR-150-*` (a2a inter-agent contract) ·
`docs/governance/AGENT-FLEET-MASTER-PLAN.md` §7 (#982 host-audit — installed vs missing baseline) ·
`docs/governance/AGENT-LIVENESS-SPEC.md` (#988 — 7/24 monitoring of adopted engines) · `config/fleet/server-inventory.yaml`
(#959/#964 — the host targets, not invented) · #949 (Hyperbrowser eval — dual-use precedent) ·
`.claude/rules/agents.md` (MiroFish research-agent role) · `docs/agent-engine-dossier/` (external frameworks =
research, not selected) · CLAUDE.md §9 (external adoption + HITL) · ADR-102 (Duplication Audit — restates none).
Operator directive 2026-07-02 (Sprint B: advance ADR-148 + build-prompts for missing engines; install nothing;
no ADR edit; no auth bypass; hosts from inventory).
