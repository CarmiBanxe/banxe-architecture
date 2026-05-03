---
id: ADR-034
title: Aider/Continue Routes — ai / ai-heavy / reasoning
status: ACCEPTED
date: 2026-05-03
supersedes: []
related:
  - ADR-031 (AI Execution Policy)
  - ADR-032 (GLM-4.5-Air Distributed Inference)
  - ADR-033 (ufw Perimeter Posture)
binding_artifact: banxe-infra/ai-routing/policy.yaml
---

# ADR-034: Aider/Continue Routes — `ai` / `ai-heavy` / `reasoning`

## Status
ACCEPTED — 2026-05-03 (CEO: Moriel Carmi)

## Context

Aider, Continue, and any other developer-side coding assistants need a small set of
named routes rather than direct model IDs. Direct IDs (`qwen3.5:35b`, `llama3.3:70b`,
`qwen3:235b-a22b`, …) leak into config files, IDE settings, and shell history, and they
make it impossible to swap a backend without hunting them down.

ADR-031 fixes the plane boundary; ADR-032 establishes a `large` reasoning backend; this
ADR fixes the **caller-facing route names** that everything in the developer plane
should use.

## Decision

Three route aliases are exposed by LiteLLM v2 on `legion:4000`:

| Alias | Class | Backend | Hosts | Notes |
|-------|-------|---------|-------|-------|
| `ai` | light / interactive | `qwen3.5:35b` | evo1 + evo2, load-balanced | Default Aider/Continue route. Sub-second latency target. |
| `ai-heavy` | heavy code-gen | `llama3.3:70b` | evo1 + evo2, load-balanced | Larger refactors and multi-file changes. Cold-load latency tolerated. |
| `reasoning` | distributed reasoning | `qwen3:235b-a22b` | evo2 only — **pending P3.2 finalize** | Long-form planning, ADR drafting, dense compliance reasoning. Cold-load latency tolerated. |

Notes on each:

- **`ai`** — primary day-to-day route. Both evo1 and evo2 hold the model warm; LiteLLM
  load-balances by health and queue depth. This is the route Aider should call by
  default in `~/.aider.conf.yml`.
- **`ai-heavy`** — used when the operator explicitly needs higher capacity. Both nodes
  hold the 70B; the first call after idle pays a cold-load penalty (warm-up of weights
  into VRAM/RAM). This is **acceptable** — the alternative (keeping every large model
  perpetually warm) would saturate node memory.
- **`reasoning`** — currently bound to `qwen3:235b-a22b` on evo2 only as the
  finalisation pass of P3.2 (instruction-tuned reasoning capacity). Once P3.2 closes,
  this alias may be re-pointed to `glm-4.5-air-distributed` (ADR-032) or kept on the
  235B route depending on benchmark results. Either way, the **alias name** is stable.

### Cold-load latency policy

The 70B and 235B routes pay a multi-second to multi-tens-of-seconds cold load on first
call after idle. This is **acceptable** for the developer plane:

- Aider/Continue are interactive; the operator can wait.
- LiteLLM v2 is configured with retry + fallback so a cold-load timeout falls through
  to the next configured backend rather than surfacing as an error to the IDE.
- Keeping every model warm would defeat the purpose of having tiered routes.

### Failover (per route)

- `ai` → evo1 ↔ evo2 LB → on dual failure, error to caller (no degradation to cloud).
- `ai-heavy` → evo1 ↔ evo2 LB → on dual failure, error to caller (no degradation).
- `reasoning` → evo2 only (P3.2-pending) → on failure, error to caller; once
  retargeted, the failover follows ADR-032.

The strict no-cloud-degradation rule is reinforced by ADR-031: developer-plane code
generation MUST stay on-prem; the meta-plane (Claude Code) is the only sanctioned
cloud surface.

## Consequences

Positive:
- Three caller-facing names cover the realistic needs of the developer plane.
- Backend swaps are a single edit in `policy.yaml`; no IDE config rewrites needed.
- Cold-load latency is documented as a policy choice, not a defect; reduces support
  noise.

Negative:
- A heavily multi-tasking operator may experience repeated cold loads on `ai-heavy` if
  the model is evicted between calls; consider warm-keep heuristics in `policy.yaml`
  if this becomes painful.
- The `reasoning` route's eventual binding is unresolved; downstream consumers must
  not encode assumptions about the underlying model ID.

## Verification

- `~/.aider.conf.yml` MUST resolve to one of `ai`, `ai-heavy`, `reasoning`. Direct
  model IDs in IDE config are a P2 lint failure.
- `policy.yaml` MUST define all three aliases with explicit backend lists and retry +
  fallback configuration.
- A regression in cold-load latency above ~60s on `ai-heavy` is an investigation IL.
