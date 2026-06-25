---
id: ADR-126
title: Hermes Tier-1 role in the Software Factory — CI/CD Watchdog + Telegram DevOps + infra/alerting companion (read-only, HITL-safe)
status: ACCEPTED
date: 2026-06-25
accepted: 2026-06-25
supersedes: []
relates:
  - "ADR-117 §Hermes (refines the 'future factory work item' into a concrete, bounded Tier-1 role)"
  - "ADR-092 (ecosystem/marketplace advisory seam — read-only, no activation/entitlement)"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
  - "ADR-103 (server-only; an operator must host/configure any Hermes server, factory does not)"
  - ".claude/rules/agents.md (HITL thresholds BUG-007; ARL/Ruflo pipeline BUG-005)"
il_anchor: IL-546
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
scope: BANXE-factory-only
concept_only: true
research_ref: "Hermes-Agent-Razbor-i-primenenie-v-EMI-BANXE-AI-Bank-i-Software-Factory.md (attached research artifact — referenced, NOT duplicated)"
---

# ADR-126 — Hermes Tier-1 role in the Software Factory (CI/CD Watchdog, read-only, HITL-safe)

## Context

ADR-117 §Hermes recorded Hermes as an **ARCHITECTURAL AGENT PATTERN** (SOUL.md identity layer,
3-tier memory, self-improving skills, 24/7 specialized agents) and a **FUTURE factory work item,
NOT an installed feature** — "no Hermes agent exists in the repo." That framing stands; this ADR
**refines the shape** of that future role so any future adoption is pre-bounded by canon.

A dedicated research artifact (**`Hermes-Agent-Razbor-i-primenenie-v-EMI-BANXE-AI-Bank-i-Software-Factory.md`**,
attached — referenced here, **not duplicated**) evaluated Hermes against the BANXE Software Factory.
Its load-bearing conclusions, taken as the evidence base for this ADR:

- **Hermes is NOT a replacement** for the Claude Code factory orchestration nor for the OpenClaw /
  MoA coding-orchestration layer. (Research terms "IronClaw / MicroFish" map to the repo-canon
  **OpenClaw** security-orchestration / **MiroFish** research agent — Hermes replaces neither.)
- **Best-fit role = Tier-1**: CI/CD Watchdog + Telegram DevOps assistant + infrastructure /
  monitoring / alerting layer — **read-only / alerting-first**, **HITL-safe**.
- **Proven strengths**: persistent 24/7 agent server; SSH / browser / cron gateways; long-term
  memory; self-improving skills.
- **Proven constraints**: no native multi-model routing; **weaker security maturity than OpenClaw**;
  no security-critical write role.

This ADR converts those findings into a governance boundary. It introduces **no runtime code** — the
repo audit (below) confirms no Hermes config stub exists, so there is nothing to wire; adoption
remains a future, separately-gated work item.

## Decision

**Define Hermes as a Tier-1 monitoring/alerting companion of the Software Factory, in-scope only for
read-only / alerting / DevOps-assist work, and explicitly out-of-scope for any write, merge, deploy,
or compliance-decision authority.** Tier-1 sits **below** the Tier-0 orchestration layer (Claude Code
/ OpenClaw-MoA) and never substitutes for it.

### IN SCOPE (Tier-1, read-only / alerting-first, HITL-safe)

1. **CI/CD Watchdog** — observe pipeline/runner state, surface failing checks, flaky tests, stuck
   queues, coverage/gate regressions as **alerts**. No mutation of CI config, no re-runs that change
   state without human approval.
2. **Telegram DevOps assistant** — operator-facing notifications, status digests, and read-only
   queries ("what's red?", "last deploy status"). Outbound assist only; it does not execute
   privileged actions on the operator's behalf.
3. **Infrastructure / alerting / research companion** — host/service health, MTTD-style alerting,
   cron-driven heartbeat checks, and research-fetch assistance (browser/SSH gateways) feeding
   **human** decisions. Leverages Hermes' proven strengths (24/7 server, long-term memory,
   self-improving skills) strictly within these read-only bounds.

### OUT OF SCOPE (hard boundary — never, without a new ADR + operator HITL)

- **Merge authority** — no commit/merge/push/PR-approval rights on any repo. Merge stays with the
  factory's gated flow (ADR-119/strict protection, Claude Code orchestration).
- **Deploy authority** — no promotion to staging/production; no service start/stop that changes
  production state (CLAUDE.md §11).
- **Payment-core write access** — no write path to ledger, safeguarding, midaz, or any
  customer-funds surface (I-28: CBS only via LedgerPort; Hermes has none).
- **AML / SAR decisions** — no role in KYC/AML/sanctions/SAR; it is **not** in the ARL → Ruflo →
  agent pipeline for `payment`/`compliance`/`kyc` (BUG-005). The compliance swarm (RED zone) is
  AI-FORBIDDEN to Hermes.
- **Replacing Claude Code factory orchestration** — Hermes is additive Tier-1, not Tier-0; it does
  not orchestrate code generation, ADRs, or the spec-build pipeline, and does not replace
  OpenClaw/MoA or the MiroFish research agent.

## HITL / read-only / security boundaries

- **Read-only by default; alerting-first.** Any action beyond *observe + notify* is gated by a
  human decision. Hermes proposes; a human disposes.
- **HITL thresholds apply (BUG-007, EU AI Act Art. 14).** Hermes is **not** an L2+ decision agent;
  it produces no AUTO decisions over customer funds or compliance. Where it surfaces a signal that
  could trigger an L2 action, that action is taken by the responsible agent/human, never by Hermes.
- **Security posture (research: weaker maturity than OpenClaw).** Hermes is assigned **no
  security-critical write role**. It runs in the factory infra-monitoring plane only (ADR-117
  perimeter — factory node), never the PROJECT RED zone, never touching domain/banking models or
  passports. Least-privilege: read/observe scopes only; secrets stay operator-side (ADR-103).
- **Server-only / operator-owned (ADR-103).** Any Hermes server is hosted and configured by the
  operator on a secured node; the factory neither installs nor secret-provisions it. No local-machine
  Hermes; no Hermes-held repo write credentials.
- **Fail-closed.** If Hermes scope is ambiguous for a given action, the action is denied and
  escalated to a human — it does not self-expand.

## Duplication Audit (ADR-102)

1. **Repo-wide search** (`grep -ril hermes`, all in-scope paths) — three matches, all pre-existing:
   `docs/adr/ADR-117-…md` (§Hermes), `ledger/entries/…/IL-2026-06-20T20-05-00Z--85fdaa.md` (ADR-116
   coupling shard, historical mention), and the generated `INSTRUCTION-LEDGER.md`. **No** Hermes role
   doc, **no** roadmap entry, **no** passport (`agents/passports/`), **no** soul/swarm, and **no**
   config/runtime stub exist.
2. **Source-of-truth + consumers.** Source-of-truth for "Hermes as future pattern" = **ADR-117
   §Hermes**; its only consumer is the ADR-116 historical shard (immutable ledger record) and the
   generated ledger. This ADR-126 becomes the source-of-truth for the **role detail / boundaries**,
   subordinate to and consistent with ADR-117.
3. **No hidden dependencies.** No code imports, no service references, no CI hooks key off "hermes" —
   confirmed by the repo-wide search returning only docs/ledger.
4. **Decision per match:** ADR-117 §Hermes → **KEEP + extend** (one-line pointer to ADR-126, no
   content rewrite — ADR-117 stays ACCEPTED/immutable in substance). ADR-116 shard → **KEEP**
   (historical, append-only). Generated ledger → regenerated, not hand-edited. **No delete, no merge,
   no parallel duplicate** — ADR-126 is a child refinement, not a competing doc.
5. **No doubt / fail-closed:** no ambiguity surfaced; nothing to escalate. No runtime code added (no
   stub to update), keeping scope minimal per the task constraint.

## Consequences

- Hermes' future adoption is **pre-bounded**: a Tier-1 read-only/alerting role with explicit
  merge/deploy/payment/AML exclusions and HITL/security guards — so any later "install Hermes" work
  starts inside canon, not outside it.
- ADR-117 §Hermes keeps its high-level framing and gains a pointer to this role detail; no parallel
  Hermes doc is created (ADR-102 satisfied).
- **No runtime change.** Activating any Hermes capability remains a future, separately-gated work
  item (passport under I-27, operator HITL, server-only host) — out of scope for this PR.

## Anchors

- ADR-117 §Hermes (refined here); `docs/governance/CANON-RECONCILIATION-ADR117.md` (ADR-117 canon).
- ADR-092 (advisory seam), ADR-102 (Duplication Audit), ADR-103 (server-only), ADR-119 (IL numbering).
- `.claude/rules/agents.md` — HITL thresholds (BUG-007), ARL/Ruflo pipeline (BUG-005), perimeter zones.
- Research artifact `Hermes-Agent-Razbor-i-primenenie-v-EMI-BANXE-AI-Bank-i-Software-Factory.md`
  (attached; referenced, not duplicated) — evidence base for the Tier-1 role and the exclusions.
