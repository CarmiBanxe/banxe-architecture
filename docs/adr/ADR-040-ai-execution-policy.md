---
id: ADR-040
title: AI Execution Policy — Meta-Plane vs Inference-Plane
status: ACCEPTED
date: 2026-05-03
supersedes: []
related:
  - "../../decisions/ADR-013-midaz-cbs-primary.md (Midaz CBS Primary)"
  - "../../decisions/ADR-014-composable-financial-stack.md (Composable Financial Stack)"
  - "ADR-032-glm45-air-distributed.md (GLM-4.5-Air Distributed Inference)"
  - "ADR-033-ufw-perimeter.md (ufw Perimeter Posture)"
  - "ADR-034-aider-routes.md (Aider/Continue Routes)"
binding_artifact: banxe-infra/ai-routing/policy.yaml
---

# ADR-040: AI Execution Policy — Meta-Plane vs Inference-Plane

**Status:** Accepted
**Date:** 2026-05-03
**Source-of-determination:** YAML frontmatter `status: ACCEPTED` + body section `## Status` line `ACCEPTED — 2026-05-03 (CEO: Moriel Carmi)` (neither form matched by INDEX generator regex `^\*\*Status:\*\*`)

## Status
ACCEPTED — 2026-05-03 (CEO: Moriel Carmi)

## Context

Banxe operates two structurally distinct AI surfaces and they MUST NOT be conflated:

1. **Meta-plane** — the orchestrator that plans work, reads/edits files, opens PRs, and
   talks to the human operator. Today this is **Claude Code (Anthropic, cloud)** running
   on the developer station (`legion`). It sees code, ADRs, ledgers, governance state,
   and chooses which inference call to dispatch.
2. **Inference-plane** — local, on-prem model servers used for code completion, embedding,
   bulk generation, and agentic sub-tasks where data sensitivity, latency, or cost
   prohibits a cloud round-trip. Today this is the **GMKtec evo1 + evo2 cluster**
   reachable via the LiteLLM v2 router on `legion:4000`.

The two planes have different trust profiles, different ingress paths, and different
governance obligations under the Banxe Trust Zone model (CLAUDE.md §1.7-§1.8). Mixing
them — e.g. piping raw KYC documents through the cloud meta-plane, or letting an
inference-plane worker write to the repo without a human-reviewed PR — is a P0 violation.

This ADR codifies the boundary so every subsequent routing, quota, and compliance
decision has an unambiguous reference.

## Decision

### Plane definitions

| Plane | Where | Allowed inputs | Allowed outputs |
|-------|-------|----------------|-----------------|
| **Meta-plane** | Claude Code (cloud, legion only) | Repository files, ADRs, IL, public docs, Banxe-architecture metadata | File edits, git commits, PRs, shell commands per `approval-rules.md` |
| **Inference-plane** | LiteLLM v2 (`legion:4000`) → Ollama (`evo1:11434`, `evo2:11434`) + llama.cpp `glm-master` (`evo1:8081`) + RPC worker (`evo2:50052`) | Pre-redacted prompts, public documentation, code snippets without secrets | Generated text/code returned to the caller; never writes to disk directly |

### Routing rules

- The meta-plane **decides** which inference route to call; the inference-plane **never**
  initiates a meta-plane action.
- All inference-plane traffic from developer tooling (Aider, Continue, agents, scripts)
  routes through `legion:4000` (LiteLLM v2). Direct calls to `evo1:11434`, `evo2:11434`,
  `evo1:8081` are reserved for diagnostics and the LiteLLM router itself.
- The binding routing artifact is `banxe-infra/ai-routing/policy.yaml`. This ADR is
  authoritative for the policy intent; `policy.yaml` is authoritative for the runtime
  matrix (model names, weights, fallback order, quotas).

### Cloud deny-paths (meta-plane)

The following paths MUST NEVER be sent to a cloud LLM (Anthropic, OpenAI, anyone). These
are enforced by the harness allow/deny config and by repo-side hooks; the meta-plane
agent is also instructed via `CLAUDE.md` to refuse to read them into context.

```
compliance/cases/*
kyc/raw/*
secrets/*
.env*
**/*.pem
**/id_*
```

Rationale: these contain raw client identifiers, biometric inputs, sanctioned-list
matches, and credentials. CASS 15, GDPR Art. 9, and the FCA SYSC outsourcing rules all
treat outbound transmission of these payloads as a reportable event.

### Inference-plane data classification

Inference-plane endpoints are local and on-prem, but they are not unrestricted:

- **PII**: redact at the caller (PII Proxy / Presidio) before sending to any LLM,
  including local ones. The local plane is "trusted compute" not "trusted recipient".
- **Secrets, tokens, keys**: never in prompts, even local. Use environment-bound
  references, not literal values.
- **Mixed-tenant context**: a single inference call MUST NOT mix Banxe and GUIYON/SS1
  data (Invariants I-18, I-20).

## Consequences

Positive:
- Clean audit story: every cloud round-trip can be justified by "meta-plane orchestration",
  and every local inference call has a documented router entry.
- Deny-paths are repo-relative and grep-able; new contributors can verify them without
  reading agent code.
- Failover (ADR-032, ADR-034) is bounded to the inference-plane and never escalates
  silently to the cloud.

Negative:
- Developers who want a single chat interface across both planes must work through
  Claude Code; bare-metal terminals do not have the same guard rails.
- The deny-path list must be kept in sync between this ADR, the harness allow/deny config,
  and `banxe-infra/ai-routing/policy.yaml`. Drift is a P1 defect — see Verification.

## Verification

- `policy.yaml` `deny_paths` list MUST be a superset of the deny-paths in this ADR.
- Pre-commit hook (`.githooks/pre-commit`) MUST refuse staged content matching
  `kyc/raw/*` or `secrets/*` regardless of branch.
- Quarterly review against this ADR is owned by the CTIO; drift is logged in
  `INSTRUCTION-LEDGER.md`.

## Invariants reinforced

I-18 (no Banxe/GUIYON data crossing), I-20 (replaceable inference targets),
I-27 (HITL gate for outbound action), I-28 (no implementation without IL entry),
I-32 (no direct cloud LLM calls from EMI services) — `INVARIANTS.md`,
I-33 (PII/AML deny-paths route only via local aliases) — `INVARIANTS.md`.
