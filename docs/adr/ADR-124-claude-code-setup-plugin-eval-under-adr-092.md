---
id: ADR-124
title: Evaluate claude-code-setup official plugin under ADR-092 advisory seam — read-only advisor, gated on ADR-123
status: ACCEPTED
date: 2026-06-25
accepted: 2026-06-25
supersedes: []
related:
  - "ADR-092-ecosystem-marketplace-advisory-seam.md (advisory-seam parent — read-only registry, no activation)"
  - "ADR-123 (PR #787 — Claude Code permissions hardening; HARD activation gate, currently OPEN)"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
  - "ADR-117 (factory/project perimeter — plugin acts on factory config, not project funds)"
il_anchor: IL-544
scope: BANXE-only
concept_only: true
---

# ADR-124 — Evaluate `claude-code-setup` official plugin under the ADR-092 advisory seam

**Status:** ACCEPTED — 2026-06-25 (governance / concept-only — **NO plugin installed, NO config mutated**)
**IL:** IL-544
**Extends:** ADR-092 (Ecosystem / marketplace advisory seam — read-only, no activation/entitlement).
The advisory-only, mock-first, no-activation boundaries of ADR-092 are **unchanged**: a plugin is
cataloged and conditionally cleared here, but **not enabled**.

## Context

Audit 2026-06-25 (HEAD `ec95496`) of the local Claude Code harness:

- **No Claude Code plugins are enabled** (`enabledPlugins = none`, both global and project). The plugin
  *infrastructure* is present under `~/.claude/plugins/` (`blocklist.json`, `known_marketplaces.json`,
  `installed_plugins.json`, `marketplaces/`). `installed_plugins.json` records `claude-code-setup@claude-plugins-official`
  cached at `scope=user` (`installedAt 2026-05-03`) but **not enabled** — cached ≠ active.
- Two candidate components surfaced for governance review:
  1. **`claude-code-setup@claude-plugins-official`** — verified **OFFICIAL Anthropic-managed** plugin
     (`claude.com/plugins/claude-code-setup`, `github.com/anthropics/claude-plugins-official`). It works
     **READ-ONLY**: it analyses the project and emits *recommendations* (hooks / skills / MCP / subagents);
     it does **not** modify files. The official README itself warns to **trust the plugin before installing**.
  2. **`n8n-atom`** (`khanh-atom/n8n-atom`) — a **third-party community VS Code extension**, **not Anthropic**,
     unrelated to the BANXE stack.

ADR-092 already established the canon for handling an external ecosystem: catalog it **read-only**, with **no
activation / entitlement / billing**, operator-gated for anything live. A Claude Code plugin that *advises on
harness configuration* is the harness-tooling analogue of that seam, so it is evaluated **under** ADR-092 rather
than as a new seam.

**Blocker (hard, fail-closed):** ADR-123 (PR #787 — Claude Code permissions hardening) is still **OPEN**; the
global `~/.claude/settings.json` has **not** been applied by the operator. Until permissions are hardened, no
external advisor — even a read-only, official one — may be wired into the harness.

## Decision

### D1 — `n8n-atom` → **REJECTED**, source added to the blocklist policy

`n8n-atom` (`khanh-atom/n8n-atom`) is **rejected**. It is a non-Anthropic, third-party community VS Code
extension with no relation to the BANXE EMI stack; admitting it would cross the ADR-117 perimeter and bypass
plugin/skill governance for zero benefit. Its source is recorded in the in-repo **blocklist policy**
(`docs/governance/plugin-blocklist-policy.json`) so the rejection is config-as-data, not tribal knowledge. This
policy file is the **source of truth for the rejection decision**; the operator-side runtime mirror is
`~/.claude/plugins/blocklist.json` (operator-applied — **not** mutated by this ADR).

### D2 — `claude-code-setup` → **CONDITIONALLY APPROVED** as a read-only advisor

`claude-code-setup@claude-plugins-official` is **conditionally approved** as a **read-only advisor only**, with:

- **Scope = `user`** (per-operator harness tooling; never project/repo scope, never a runtime BANXE service).
- **Read-only:** the plugin may *analyse and recommend*; it MUST NOT modify repo files, settings, or service
  state. It is an advisor, not an actuator.
- **No auto-apply:** **every recommendation the plugin emits is treated as input only** and MUST pass the normal
  **ADR/PR governance flow** (IL entry → ADR/PR → review → gate) before any change lands. A plugin recommendation
  is never self-executing and never bypasses `quality-gate.sh`, invariants I-01..I-28, or the merge canon.
- **Perimeter:** the plugin advises on **factory/harness configuration** (ADR-117 factory plane), never touches
  client funds or production EMI state (CLAUDE.md §11). It is **not** added to any external `/v1` BaaS facade
  (mirrors ADR-092 D3).

### D3 — Activation is gated on ADR-123 (no install in this ADR)

This ADR **does not install or enable** the plugin. Installation/enablement (toggling `enabledPlugins` at
`scope=user`) is permitted **ONLY after** the activation verify-conditions in §"Activation verify-condition"
all hold. Until then the conditional approval is **dormant** — fail-closed.

### D4 — Stays inside the ADR-092 seam (additive, reversible)

No new external surface, no entitlement/billing, no "click → enable" automation. The evaluation is additive and
fully reversible: removing this ADR + the policy entry returns the harness to the pre-evaluation state.

## Activation verify-condition (ALL must hold before any install/enable)

Activation of `claude-code-setup` is permitted **only when every** condition below is verified true:

1. **ADR-123 CLOSED** — PR #787 (Claude Code permissions hardening) merged to `main`; the ADR-123 file present
   in `docs/adr/`.
2. **`skipDangerous` ABSENT** — the global `~/.claude/settings.json` contains **no** `skipDangerous` (or
   equivalent permission-bypass) flag. A present bypass = fail-closed, do NOT activate.
3. **push-deny on `main` PRESENT** — the permission set denies direct push to `main` (deny rule present and
   effective), i.e. the operator has applied the hardened global config from ADR-123.

If any condition is false → **do NOT install/enable** (fail-closed); report and stop. No timeout-based
auto-activation. Activation, when conditions hold, is itself an operator-gated step recorded in a fresh IL.

## Consequences

- **Positive:** an official, read-only setup advisor is pre-cleared under a known seam, so when permissions are
  hardened the operator can adopt it without re-litigating governance; the front-office/community noise
  (`n8n-atom`) is fenced off in config-as-data.
- **Negative / cost:** the plugin remains dormant until ADR-123 closes; its recommendations carry per-item
  ADR/PR overhead (intentional — no auto-apply).
- **Risk:** scope creep toward auto-applying plugin recommendations — fenced by D2 (no auto-apply, full ADR/PR
  flow) and D3 (gated, fail-closed). Trust risk on an external plugin — fenced by official-only + read-only +
  scope=user + the activation verify-condition.

## OPERATOR DECISION REQUIRED (gated — NOT in this ADR)

- Closing ADR-123 (merge PR #787) and applying the hardened global `~/.claude/settings.json`.
- After §verify-condition holds: the explicit decision to **enable** `claude-code-setup` at `scope=user`
  (recorded in a fresh IL).
- Adoption of **any** recommendation the plugin produces (each via its own IL → ADR/PR).

## Duplication Audit (ADR-102)

- **Repo-wide search:** no prior ADR/policy evaluates `claude-code-setup`, `n8n-atom`, or a Claude Code plugin
  admission decision (`grep -ri "claude-code-setup\|n8n-atom\|enabledPlugins"` over `docs/` → only this ADR).
  ADR-092 is the parent seam (referenced, not duplicated). ADR-122 maps Anthropic finance *templates* (a
  distinct concern — agent reference patterns, not harness plugins).
- **Source-of-truth:** rejection decision → `docs/governance/plugin-blocklist-policy.json` (new, in-repo).
  Operator runtime mirror → `~/.claude/plugins/blocklist.json` (operator-owned, not mutated here).
- **Decision per match:** keep ADR-092 (parent); **create** ADR-124 + policy file (no overlap to merge/delete).
- **Hidden consumers:** none — no code imports a plugin; no service references `claude-code-setup`/`n8n-atom`.
- **Verdict:** non-duplicative; additive only.

## References

- `docs/governance/plugin-blocklist-policy.json` (NEW — config-as-data blocklist policy)
- ADR-092 (advisory seam parent); ADR-123 / PR #787 (permissions-hardening gate, OPEN); ADR-102 (no-dup);
  ADR-117 (factory/project perimeter); CLAUDE.md §11 (production/client-funds gate)
- External (verified): `claude.com/plugins/claude-code-setup`, `github.com/anthropics/claude-plugins-official`
  (official Anthropic-managed, read-only advisor); `khanh-atom/n8n-atom` (third-party community VS Code
  extension — rejected)
- Harness audit 2026-06-25 (HEAD `ec95496`): `enabledPlugins=none`; `~/.claude/plugins/{blocklist,known_marketplaces,installed_plugins}.json`
