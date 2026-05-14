# Factory Routing Map

Per Software Factory Canon v1.0 Section 5 + A4-orchestration-proposal.

## Canonical LiteLLM :4000 (litellm-v2.service)

| Alias | Model | Backend | Use case |
|-------|-------|---------|----------|
| factory-fast | qwen2.5-coder:14b-banxe-factory | Legion :11434 | Autocomplete, lint, single-line edits |
| factory-mid | qwen3:30b-a3b | evo1+evo2 :11434 LB | Multi-file refactor, spec writing |
| factory-heavy | llama3.3:70b | evo1+evo2 :11434 LB | Heavy reasoning |
| factory-coder | qwen3-coder-next:q4_K_M | evo1 :11434 | Code-tuned heavy work |
| project-reason | qwen3-235b-Q3_K_S | evo2 :8082 | Architecture / cross-repo reasoning |
| project-mid | qwen3:30b-a3b | evo1+evo2 :11434 LB | Project-side general |
| reasoning-235b | qwen3-235b-Q3_K_S | evo2 :8082 | Legacy alias for project-reason |
| ai | qwen3.5:35b | evo1+evo2 :11434 LB | Guardian backbone |
| ai-heavy | qwen3.5:35b | evo1+evo2 :11434 LB | Guardian heavy |
| fast | glm-4.7-flash | evo1+evo2 :11434 LB | Low-latency tasks |

## Sandbox LiteLLM :8080 (litellm.service)

Per PR #277 Option B — sandbox-only, NOT for production agents.

| Alias | Model | Backend | Use case |
|-------|-------|---------|----------|
| default | qwen3:30b-a3b | evo1+evo2 :11434 LB | Sandbox default |
| classifier-qwen2.5-0.5b | qwen2.5:0.5b | evo2 :11434 | Shadow tap pilot |
| project-reason | qwen3-235b-Q3_K_S | evo2 :8082 | Sandbox duplicate |
| fallback-claude | claude-sonnet-4-6 | Anthropic API | Guardrail-gated |

## Agent-to-Route mapping (per .claude/rules/agents.md)

| Agent | Route | Hardware |
|-------|-------|----------|
| ARP (light refactor) | factory-fast | Legion RTX 4070 |
| ARP (heavy refactor) | factory-coder | evo1 Strix Halo |
| RSB, ACG, CAE, EHS, STG, DO, PS | factory-mid or factory-heavy | evo1/evo2 |
| OpenClaw GUIYON | factory-coder (code) + factory-fast (routine) | evo1 + Legion |
| Aider --fast | factory-fast | Legion |
| Aider --full | factory-mid | evo1/evo2 |
| Aider --banxe | qwen3-banxe | evo1 |

## Invariant I-37

Production agent traffic MUST use :4000 only.
:8080 reserved for Innovation Sandbox (PR #277).

Refs: Canon v1.0 Section 5, A4-orchestration-proposal,
PR #273, #277, ADR-043, .claude/rules/agents.md.
