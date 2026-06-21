# Feature-Installation Audit — Execution Roadmap v2 (2026-06-21)

## Purpose

This roadmap converts all unresolved findings from the feature-installation audit into an execution backlog. It also incorporates newly confirmed read-only evidence about model-to-role routing in the LiteLLM LAN gateway, live model availability on evo1/evo2, and the still-PROPOSED state of ADR-117.

This is a planning and governance artifact only. No feature code is changed by this document.

## Newly incorporated evidence

- LiteLLM LAN gateway v2 config contains explicit model-name routing entries for:
  - banxe-general
  - qwen3-30b
  - qwen3-banxe
  - fast
  - glm-4-flash
  - coding
  - gpt-oss-20b
- Config shows partial load-balancing across evo1 and evo2 for some routes, while others remain evo1-only.
- Live Ollama model inventories on evo1/evo2 include multiple models beyond the role-routed set.
- ADR-117 remains PROPOSED, so governance for persistent role-to-model mapping is not yet closed.

## Scope of unresolved work

### Still not fully verified or not fully installed

- GAP-064 adverse-media EDD — L1 ONLY
- GAP-066 braslina onboarding — L2 CODE
- GAP-068 crypto-AML graph — L1 ONLY
- GAP-069 voice AI support — L1 ONLY
- GAP-070 quant pricing/risk advisory — L1 ONLY
- GAP-072 Travel Rule — L1 GOVERNANCE
- GAP-074 acquiring/issuing — L2 CODE / L3 BLOCKED

### Cross-cutting audit backlog

- AU-1 crypto / blockchain deep verification
- AU-2 acquiring / payments / travel-rule deep verification
- AU-3 compliance / EDD / supply-chain deep verification
- AU-4 platform / merchant onboarding deep verification
- AU-5 advisory / voice deep verification
- AU-7 installation-% roll-up and cross-repo gap-delta matrix

### Additional unresolved governance/routing backlog

- ADR-117 role-to-model routing closure
- model-role mapping verification against live evo1/evo2 inventories
- drift check between routing config, cluster reality, and AGENT-ORG-STRUCTURE / governance docs

## Sprint plan

### Sprint A — Crypto and blockchain verification
Covers:
- GAP-065 crypto-ops-monitor
- GAP-068 crypto-AML graph
- AU-1

Deliverables:
- Read-only L1/L2/L3 verification for both features
- STUB/scaffold detection report
- live-RPC vs safe-stub classification
- gap-delta for GAP-068 implementation absence

Definition of done:
- AU-1 verdict written as repository-backed audit output
- install % confirmed for GAP-065 and GAP-068

### Sprint B — Payments, Travel Rule, and key-gated live blockers
Covers:
- GAP-071 payment distribution
- GAP-072 Travel Rule
- GAP-074 acquiring/issuing
- AU-2

Deliverables:
- blocked-on-keys inventory
- exact live blockers list for Modulr BT-001 / Paymentology
- L1/L2/L3 verdict refresh for GAP-071/072/074
- evidence of whether runtime path is live, gated, or stubbed

Definition of done:
- AU-2 verdict published
- GAP-074 blockers reduced to explicit key / environment dependencies only

### Sprint C — Compliance and supply-chain
Covers:
- GAP-064 adverse-media EDD
- GAP-067 OSS supply-chain / license governance
- AU-3

Deliverables:
- proof of code presence or absence in emi-stack/tooling
- adverse-media wiring verdict
- SBOM / SCA / license-tier verification summary

Definition of done:
- AU-3 verdict published
- GAP-064 classified definitively as L1-only or L2-present

### Sprint D — Merchant onboarding platform
Covers:
- GAP-066 braslina onboarding
- AU-4

Deliverables:
- braslina repository presence verification
- L2 evidence summary
- live-wiring gap-delta
- KYB completeness checklist status

Definition of done:
- AU-4 verdict published
- GAP-066 install % confirmed

### Sprint E — Advisory and voice tracks
Covers:
- GAP-069 voice AI support
- GAP-070 quant pricing/risk advisory
- AU-5

Deliverables:
- code-presence grep results
- advisory-seam verification
- implementation absence/presence evidence
- gap-delta for both tracks

Definition of done:
- AU-5 verdict published
- install % confirmed for GAP-069 and GAP-070

### Sprint F — Model routing and governance closure
Covers:
- ADR-117
- LiteLLM LAN gateway v2 routing config
- live evo1/evo2 Ollama inventories
- AGENT-ORG-STRUCTURE alignment

Deliverables:
- read-only model-to-role mapping table
- config-vs-runtime drift report
- identification of evo1-only vs load-balanced routes
- governance gap-delta for ADR-117 closure
- recommendation whether routing is L1 only, L2 configured, or L3 operational

Definition of done:
- repository-backed audit output published
- ADR-117 closure blockers made explicit
- every active role has a verified mapped model status

### Sprint G — Roll-up and final matrix
Covers:
- AU-7
- all unresolved features above
- Sprint F routing/governance output

Deliverables:
- aggregate installation-% table
- cross-repo gap-delta matrix
- final “not done / not found” closure report
- final routing-governance status appendix

Definition of done:
- AU-7 published
- every unresolved item has a final tracked verdict

## Execution rules

- Every sprint is read-only unless a separate delivery ADR/PR explicitly authorizes code changes.
- Source of truth for L2/L3 is code reality, not governance prose.
- Routing/governance claims must be backed by both config evidence and live inventory evidence.
- Each sprint must publish repository-backed evidence before any delivery claim is upgraded.
- One sprint at a time through the factory pipeline.

## Ordering rationale

The order follows blocker proximity and evidence freshness:
1. crypto verification,
2. payment live blockers,
3. compliance/tooling,
4. onboarding platform,
5. advisory/voice,
6. model-routing governance closure,
7. final roll-up.

## Expected outcome

After Sprint G, no audit item remains in an untracked state. Every unresolved feature or routing concern is either:
- confirmed installed,
- confirmed absent,
- confirmed blocked,
- confirmed configured but not governed,
- or moved into a separate implementation backlog with explicit gap-delta.
