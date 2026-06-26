# Factory Scripts / Tools BACKLOG

> **Status: PROPOSED / NOT ACTIONED.** Captured candidate tools/integrations for the factory.
> **NONE installed / enabled / adopted.** Each item requires its own **ADR/IL + Duplication Audit
> (ADR-102) + security review** before adoption. **Sandbox-first**; production stays on LiteLLM
> **:4000 (I-37)**; **`AGENT_ROUTING_ENABLED` unchanged (false)**; **Ruflo mandatory** for any
> compliance-adjacent use. This document only **CAPTURES** candidates — it adopts nothing.

**Trust legend:** ✅ higher/official · ⚠️ medium (rewrite/audit) · 🔴 strict-audit / regulatory-sensitive · ⛔ REJECT.

---

## CLUSTER A — Memory / Context

### BL-SCRIPT-01 — Memoir
- **Source:** github.com/zhangfengcdt/memoir
- **What it gives:** persistent agent memory → knowledge base.
- **Why for factory:** durable cross-session memory for agents/spec-build.
- **Canon flags:** Duplication Audit vs existing **CMS / context_memory_sync** (likely overlap — keep/extend, not new); **no secrets/PII** (I-08); **Ruflo** for any compliance output; external claims **[НЕИЗВЕСТНО]**.
- **Trust:** ⚠️ medium. **Status:** RESOLVED → **ADR-137** (Outcome B: factory-only alternative-backend PILOT under the ADR-136 boundary envelope; agentmemory remains primary; no second production substrate; no authority/secrets). See `docs/adr/ADR-137-memoir-versioned-memory-pilot.md`.

---

## CLUSTER B — UI / UX

### BL-SCRIPT-02 — Lazyweb
- **Source:** lazyweb.com (MCP server, ~257k design references)
- **What it gives:** large design-reference corpus via MCP.
- **Why for factory:** frontend/design acceleration for `banxe-emi-stack`.
- **Canon flags:** **external MCP trust + PII** exposure; **copyright** of generated styles; **frontend-scope** (belongs to banxe-emi-stack, NOT the architecture repo); **sandbox-only**.
- **Trust:** ⚠️ medium. **Status:** PROPOSED.

### BL-SCRIPT-05 — Google DESIGN.md (Stitch)
- **Source:** Google, Apache-2.0, alpha (Stitch)
- **What it gives:** machine-readable design tokens + WCAG + Tailwind / W3C-DTCG export.
- **Why for factory:** standardized, accessible design tokens; local file + CLI (no external service).
- **Canon flags:** **low trust-risk** (local file + CLI, OSS); **alpha → pin version**; **frontend-scope**; **WCAG gate augments, does not replace** guardian checks.
- **Trust:** ✅ higher. **Status:** PROPOSED.

---

## CLUSTER C — Core / Infra / Security

### BL-SCRIPT-03 — Anthropic financial agent templates
- **Source:** claude.com/solutions/financial-services (KYC / recon / fund-accounting / credit-memo)
- **What it gives:** ready financial-services agent templates.
- **Why for factory:** accelerate KYC/recon/reporting agent patterns.
- **Canon flags:** 🔴 **Duplication Audit vs existing passports** (`aml_orchestrator`, `payment_router_agent`, `reconciliation`, `reporting`) — high overlap; **Ruflo + MLRO mandatory**; **FCA lineage** (I-24/I-25/I-28, ADR-046); **no client PII via external connectors**; **I-37 :4000**.
- **Trust:** ✅ source / 🔴 regulatory-sensitive. **Status:** PROPOSED (route via governance like ADR-RUFLO-01).

### BL-SCRIPT-04 — Claude Code settings.json policy
- **Source:** medium.com/@vibecoding_tg (allow/deny + hooks to cut approval popups)
- **What it gives:** fewer approval prompts via allow/deny lists + hooks.
- **Why for factory:** smoother session flow; can encode a **cwd-guard** for the MetaClaw cwd-reset.
- **Canon flags:** 🔴 **DO NOT auto-allow gated ops** (merge / push-to-ledger / deploy / AGENT_ROUTING / finance / `--force` / `rm -rf`); **mandatory deny-list**; **rewrite under HITL canon — NOT copy-paste**.
- **Trust:** ⚠️ rewrite-required. **Status:** PROPOSED as "session-policy formalization".

---

## CLUSTER D — Meta / Tooling-setup

### BL-SCRIPT-06 — claude-code-setup
- **Source:** official Anthropic plugin (advisory)
- **What it gives:** analyzes repo, recommends hooks / skills / MCP / subagents.
- **Why for factory:** advisory audit to prioritize the rest of this backlog.
- **Canon flags:** ✅ **official**; **advisory only** (no auto-activate); `/plugin install` = code install → **needs operator OK**; run in **correct cwd** (architecture repo).
- **Trust:** ✅ highest. **Recommendation:** consider **FIRST**, as an advisory audit to prioritize the others. **Status:** PROPOSED.

---

## CLUSTER E — Orchestration / Workflow-as-code

### BL-SCRIPT-07 — Atom / n8n-atom
- **Source:** github.com/khanh-atom/n8n-atom (n8n workflows as LLM-readable files)
- **What it gives:** version-controlled, LLM-readable workflow definitions.
- **Why for factory:** workflow-as-code if n8n is in scope.
- **Canon flags:** 🔴 **obscure personal repo → security/code audit before install**; **n8n workflows often hold secrets → exfiltration risk + gitleaks scan**; **"AI edits code directly" conflicts with HITL**; **verify n8n is even in the BANXE stack** (canon names Fluxnova / Temporal / BPMN, NOT n8n).
- **Trust:** 🔴 strict-audit. **Status:** PROPOSED (verify applicability first).

---

## CLUSTER F — Computer-use / Autonomous agents

### BL-SCRIPT-08 — QClaw
- **Source:** qclawsg.qq.com (Tencent) — desktop computer-use agent; claims OpenClaw base, messenger integration, long-term memory, "online purchases".
- **What it gives:** autonomous desktop/computer-use automation.
- **Why for factory:** (claimed) broad automation — **not justified given the risks below**.
- **Canon flags:** 🔴🔴 **full-PC access near banking keys/ledger**; **autonomous purchases = forbidden financial transactions** (CLAUDE.md DO-NOT); **unverified CN source for FCA EMI → data-residency / GDPR risk** (sanctioned-jurisdiction & residency canon); **Telegram/Discord = exfiltration / injection channel**; **duplicates existing OpenClaw / openclo-moa**; claims **[НЕИЗВЕСТНО]**.
- **Trust:** ⛔ **REJECT / DO-NOT-ADOPT** (recorded with reason for audit trail). **Status:** REJECTED.

---

## Trust-gradient summary

| ID | Tool | Cluster | Trust | Status |
|---|---|---|---|---|
| BL-SCRIPT-06 | claude-code-setup | D meta | ✅ highest (official, advisory) | PROPOSED (consider first) |
| BL-SCRIPT-05 | Google DESIGN.md | B ui/ux | ✅ higher (OSS, local) | PROPOSED |
| BL-SCRIPT-03 | Anthropic fin templates | C core | ✅ source / 🔴 regulatory | PROPOSED (governance route) |
| BL-SCRIPT-01 | Memoir | A memory | ⚠️ medium | PROPOSED |
| BL-SCRIPT-02 | Lazyweb | B ui/ux | ⚠️ medium | PROPOSED |
| BL-SCRIPT-04 | Claude settings.json | C core | ⚠️ rewrite-required | PROPOSED |
| BL-SCRIPT-07 | n8n-atom | E orchestration | 🔴 strict-audit | PROPOSED (verify applicability) |
| BL-SCRIPT-08 | QClaw | F computer-use | ⛔ REJECT | REJECTED |

**Note:** Each PROPOSED item needs its **own ADR + Duplication Audit (ADR-102) + security review**
before any adoption. This document **CAPTURES only** — it installs, enables, and adopts **nothing**.
Production stays on LiteLLM **:4000 (I-37)**; **`AGENT_ROUTING_ENABLED=false`**; **Ruflo mandatory**
for compliance-adjacent use; **sandbox-first** for everything.

### Anchors
ADR-102 (duplication audit), ADR-RUFLO-01 (governance route for compliance-adjacent), I-37 (:4000),
I-08 (no secrets/PII), I-24/I-25/I-28 (FCA lineage), ADR-046 (correlation/lineage), BUG-007 (HITL),
CLAUDE.md DO-NOT list (no finance auto-actions, no sanctioned-jurisdiction tech).
