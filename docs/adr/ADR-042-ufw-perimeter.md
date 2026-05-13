---
id: ADR-042
title: ufw Perimeter Posture per Host
status: ACCEPTED
date: 2026-05-03
supersedes: []
related:
  - "ADR-031-ai-execution-policy.md (AI Execution Policy)"
  - "ADR-032-glm45-air-distributed.md (GLM-4.5-Air Distributed Inference)"
  - "ADR-034-aider-routes.md (Aider/Continue Routes)"
binding_artifact: banxe-infra/ai-routing/policy.yaml
---

# ADR-042: ufw Perimeter Posture per Host

**Status:** Accepted
**Date:** 2026-05-03
**Source-of-determination:** YAML frontmatter `status: ACCEPTED` + body section `## Status` line `ACCEPTED — 2026-05-03 (CEO: Moriel Carmi)` (neither form matched by INDEX generator regex `^\*\*Status:\*\*`)

## Status
ACCEPTED — 2026-05-03 (CEO: Moriel Carmi)

## Context

The Banxe inference cluster (evo1, evo2) and the developer station (legion) sit on the
same LAN, but they have very different exposure profiles. Without an explicit per-host
ufw policy, services drift toward "Anywhere"-bound rules every time a debugging session
opens a port for convenience and forgets to close it. As of 2026-05-03 04:32 the cluster
is in a clean state and this ADR captures that posture so future drift is detectable.

The classification used below:

- **LAN** — local /24, the wired subnet behind the firewall.
- **Tailscale** — `100.64.0.0/10`, the Tailnet that links operator devices.
- **WSL** — `172.16.0.0/12` ranges originating from the legion WSL2 environment when
  it tunnels back to evo1 for distributed inference debugging.
- **Anywhere** — the public internet. Default DENY for inbound on every host.

## Decision

### Default policy (all hosts)

- `ufw default deny incoming`
- `ufw default allow outgoing`
- Loopback (`lo`) is always permitted; this is implicit in ufw and not a per-rule entry.

### evo1 — primary inference + llama.cpp `glm-master`

| Port | Service | Allowed sources |
|------|---------|-----------------|
| 22, 2222 | SSH | LAN, Tailscale |
| 80, 443 | Reverse proxy / health UI | LAN, Tailscale |
| 3389 | RDP (operator console) | LAN, Tailscale |
| 8081 | llama.cpp `glm-master` HTTP | LAN, WSL, Tailscale |
| 11434 | Ollama | LAN, Tailscale |

Public 80/443 from `Anywhere` is **forbidden** on evo1. Any rule matching
`80/tcp ALLOW Anywhere` or `443/tcp ALLOW Anywhere` is a P1 incident.

### evo2 — secondary inference + RPC worker

evo2 mirrors evo1 **minus port 8081** (no llama.cpp HTTP server here; the RPC worker on
50052 is reached only from evo1 over the USB4 link).

| Port | Service | Allowed sources |
|------|---------|-----------------|
| 22, 2222 | SSH | LAN, Tailscale |
| 80, 443 | Reverse proxy / health UI | LAN, Tailscale |
| 3389 | RDP | LAN, Tailscale |
| 11434 | Ollama | LAN, Tailscale |
| 50052 | llama.cpp RPC worker | evo1 only (LAN-restricted), USB4 path preferred |

### legion — developer station

legion exposes one inbound port to the LAN:

| Port | Service | Allowed sources |
|------|---------|-----------------|
| 4000 | LiteLLM v2 router | LAN |

Everything else on legion is `deny incoming`. SSH/RDP into legion is not in scope; the
developer drives it interactively.

### Forbidden states

- Any inbound rule with source `Anywhere` for ports other than `22/2222` over Tailscale
  exit nodes.
- Any port open on legion other than 4000.
- Port 8081 open on evo2.
- Port 50052 reachable from anything other than evo1.

A drift in any of these triggers a P1 IL entry and a `ai_perimeter_drift` incident.

## Consequences

Positive:
- Tailscale + LAN posture means an exposed home network does not expose the cluster.
- Single-port surface on legion limits blast radius if the developer station is
  compromised.
- The matrix above is grep-able and can be machine-checked from a single ufw export.

Negative:
- Tailscale dependency means a Tailnet outage degrades remote access for the operator;
  document fall-back via LAN-attached console.
- Future services that need a new inbound port must add an entry here AND in the host
  ufw config; drift between this ADR and `ufw status numbered` is the failure mode.

## Verification

- Snapshot of `ufw status numbered` from each host taken at 2026-05-03 04:32 is the
  reference state. Re-snapshot weekly via the cluster monitor and diff against this ADR.
- A scheduled job MUST flag any inbound rule with source `Anywhere` on any host except
  the documented exceptions above.
- Changes to this posture require a new ADR or a documented amendment with CEO sign-off.
