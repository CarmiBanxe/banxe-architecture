# FABLE-5 CONSULTANT BRIEF — Code Placement by Cabinet/Department/Floor — 2026-07-25

**GOVERNANCE / FACTORY TASK / EXTERNAL-CONSULTANT BRIEF / DOCS-ONLY / NO COMMIT**

**Task type:** a factory task to invite external consultant **Fable-5** to rule on accumulated
code-placement questions. This document is the **brief** (questions + inputs + expected output) —
it does **not** itself assign placement. Placement decisions are Fable-5's deliverable, grounded in
the actual code; nothing here pre-empts them. Disputed → `[pending human ratification]`;
gated (write/ledger/Midaz/regdata) → `[counsel]`.

---

## §1 Context (for Fable-5)

- **BANK** = 4 floors, 17 rooms, plus the F0 **Banksy engine** (heart; ceo-conductor PROPOSES-only, I-27).
- **Floors:** F1 support / marketing / customer-ops / hr-legal · F2 identity / ledger / payments / safeguarding ·
  F3 risk / aml / treasury / finbi / regrep · F4 ai-platform / devops / security / audit-cell.
- **Canonical source of bank code = `banxe-emi-stack`** — verified: **112 domains, 84 routers, 86 agents**.
- **Verified coverage:** 100% across 34 repos.
- **Task:** distribute the code across cabinets / departments / floors. Several domains are contested or
  unmapped and need consultant rulings (below).

---

## §2 Questions for Fable-5

**Q1 `[source]` — mirror confirmation.**
Confirm that `merged-repo` (112 domains = emi-stack + OpenManus mirror) and `banxe` (336 routers,
umbrella monorepo containing emi-stack) are **mirrors/aggregates, NOT independent sources** — so code is
not placed twice. Verification asked: 100% domain overlap of merged-repo/banxe against emi-stack.

**Q2 `[fragments]` — small-repo ruling.**
Are `banxe-ai-infrastructure` (1 domain), `banxe-lexisnexis-distro` (6 domains), `crypto-ops-monitor`
(1 domain) **new domains or duplicates** of emi-stack? If new: which room/floor/owner? If crypto-ops
touches wallet/ledger → flag `[counsel]`.

**Q3 `[placement]` — map the ~30 UNMAPPED domains.**
For each, give **department · room · floor · human-owner/SMF · rationale**. Contested → `[pending]`.
Unmapped set:
`auth, hr, iam, dispute_resolution, document_management, webhooks, webhook_orchestrator,
transaction_monitor, case_management, experiment_copilot, reasoning_bank, producers, providers,
events, alerting, backup, secrets, config, shared, multi_tenancy, api_versioning, ato_prevention,
agreement, abs, churn, campaign, crm, lead_scoring, data_quality, deploy, resolution, sandbox,
repo_watch, voice_support, ci_governance, _legacy_common`.

**Q4 `[cross-cutting]` — infra-layer vs pervasive.**
Domains like `auth / iam / secrets / config / shared / events` — are these an **infrastructure layer (F4)**
or **cross-cutting** (present in every room)? Give a rule for placing cross-cutting code (single-owner
infra room vs shared library referenced by all), so it is not double-counted.

**Q5 `[gated]` — gated-concern confirmation.**
**687 files** touch gated concerns (`midaz / mcp / regdata / ledger-write`). Confirm these remain
`[counsel]` at placement — placement locates them, it does **not** authorize live write/execution.

---

## §3 Inputs available to Fable-5

- **Code registries (emi-stack):** `.ai/registries/{dependency-map,domain-map,api-map,agent-map}.md`,
  `.claude/memory/services-map.md`.
- **Audit:** `CODE-DEEP-PROCESS-GRAPH` (113 domains, cross-imports, ports).
- **Org canon:** `ORG-STRUCTURE`, `CONTACT-CHAIN-MATRIX-2026-07-25.md`,
  `AGENT-REGISTRY-BANK-MASTER-2026-07-22.md` (132 agents), per-floor registries F1–F4,
  `HITL-MATRIX.yaml`.
- **Runtime state (verified):** engine :8200 online; backend :8000 up (6 MCP tools, read LIVE / write `[counsel]`);
  Legion :8080 external-only.

---

## §4 Expected output from Fable-5

1. **CODE-PLACEMENT-MATRIX** — `domain → department → room → floor → owner/SMF → rationale`
   for **all 112 domains** (not only the ~30 unmapped), with contested rows marked `[pending human ratification]`.
2. **Mirror-ruling** — `merged-repo` + `banxe` confirmed **non-source** (mirror/umbrella), with overlap evidence.
3. **Fragment-ruling** — the 3 small repos (`banxe-ai-infrastructure`, `banxe-lexisnexis-distro`,
   `crypto-ops-monitor`): new-vs-duplicate + placement (crypto → `[counsel]` if wallet/ledger).
4. **Cross-cutting rule** — how infra/pervasive domains are placed without double-counting.
5. **Gated confirmation** — the 687 gated files remain `[counsel]` (placement ≠ write-authorization).

**Deliverable form:** a placement matrix doc in `docs/governance/`, referencing (not modifying) the
existing registries.

---

## §5 Constraints on the consultation

- **Docs-only.** No code moved/modified; placement is a mapping, not a migration.
- **No invented placement** — every row grounded in actual code (imports, ports, domain boundaries);
  where the code is ambiguous → `[pending human ratification]`, not a guess.
- **Gated** (midaz/mcp/regdata/ledger-write) → `[counsel]`; placement never authorizes live write.
- Existing registries are **referenced, not changed**.
- Runtime engines (:8200/:8000/:8080) not touched by this consultation.

---
**This does not replace legal advice.**
