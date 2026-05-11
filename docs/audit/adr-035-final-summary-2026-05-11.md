# ADR-035 AI Pool Roadmap - Final Summary 2026-05-11

## Status table
| Step | Title | Status | PR |
|---|---|---|---|
| 1 | Smoke gate | DONE | earlier |
| 2 | Pool audit | DONE | #192 |
| 3 | Model deduplication | PARTIAL - inventory only; rm needs CTIO/MLRO | #205 |
| 4 | LiteLLM + evo2 backend | DONE | #205 |
| 5 | Redis + LiteLLM cache | DONE | #193 |
| 6 | LLM router + A-8 MetaClaw | DONE | #200 |
| 7 | Tailscale mesh verify | DONE | #203 |
| 8 | Compliance guardrails | PARTIAL - custom_code active; Presidio optional | #200 |
| 9 | Load balancing | DONE via Part 6 | #205 |
| 10 | HITL L3 gate | DONE | #207 |
| Orig 5 | qwen3:235b Q4->Q8 | DEFERRED - IA/MW/HITL-ASK-001 | this PR |

## Completion
- 7 of 10 steps DONE
- 2 PARTIAL with active functional substitutes
- 1 DEFERRED (Original Part 5) gated by GPU stack on evo2

## Open prerequisites
- G-INFRA-EVO2-GPU-STACK: required for Original Part 5
- CTIO sign-off: required for any ollama rm on evo1/evo2 (Step 3 cleanup)

## Architectural state 2026-05-11
- Canonical LiteLLM on Legion 127.0.0.1:8080 systemd
- Backends: evo1 Ollama priority 1; evo2 Ollama load-balance; Anthropic guardrail-gated fallback
- Redis on evo1 hardened
- LiteLLM cache hit 0.65 ms verified
- Tailscale mesh: Legion + evo1 + evo2 direct WireGuard 1-3 ms
- Guardrail block-regulated-paths: custom_code precall 8 keywords
- HITL L3 policy active

## Note
Sub-A Claude Code disabled at org level 2026-05-11 17:00 CEST.
This finalization commit produced via shell per SESSION-CANON Clause 5.
Pre-commit auditor skipped (depends on Sub-A); CI verification active.

Earlier mis-commit went to MetaClaw repository by mistake (wrong CWD);
that branch was deleted from MetaClaw remote before this commit was made.
