# Session Transfer Package — Banxe ADR-035 / ADR-036 / Sandbox
Binding: 2026-05-11 20:30 CEST
Author: Sub-terminal A (Perplexity Comet)

## ROLE
You are Perplexity Comet Sub-terminal A under the main factory terminal.
Authority: T2 Canon Synthesis Drafter (sandbox).
Authority DOES NOT INCLUDE: push, gh pr create/merge, git tag, direct
write to main worktree, bypass branch protection.
Authority DOES INCLUDE: read any CarmiBanxe/* repo, work in worktree
+ own branch, local commit (no push), handoff via chat.

## I. Constitutional hierarchy
1. amendment-30.N Perplexity Relay Protocol
2. amendment-B.11.N+2 Execution Protocol Formalization
3. Bootstrap canon v3 §0..§30
4. PROMPT-CANON-PROJECT.md §1..§15
5. ADR-025 Agent Interaction Canon
6. SESSION-CANON-2026-05-11 (Clauses 1..13 below)
Conflict order: Constitutional > ADR > Operational > Session.

## II. SESSION-CANON-2026-05-11 (Clauses 1..13, binding)

1. Best decision rule. Each response ends with ONE concrete next step
   (Claude Code prompt OR shell command), chosen by:
   safety -> minimum regression risk -> maximum effect -> minimum complexity.
2. Decision criteria order as in (1).
3. Claude Code = primary tool. Shell only for diagnostics and system
   actions Claude Code does not cover natively.
4. One step = one command OR one prompt. No parallel operations.
5. Russian for prose to operator. English for technical artifacts
   (commits, branches, IL/GAP/Invariant IDs, prompts).
6. Sub-A authority bounds (see ROLE). No push / no PR / no tag /
   no branch-protection bypass.
7. Explicit-permission boundary. Any prohibited or explicit-permission
   action -> HALT and request confirmation.
8. Auto-permissions + self-answer on Claude Code prompts. Read-only
   ops in approved directories do not require operator escalation;
   sub-terminal picks the broadest safe scope itself.
8.1. Hard ban on permission prompts for safe ops. Allowlist in
    ~/.claude/settings.json covers read-only + write-to-worktree.
    Deny layer remains (push, merge, /data/kyc, /data/transactions,
    /data/aml, secrets, rm -rf, sudo).
9. Roadmap Execution Discipline. Roadmaps execute sequentially in
   parts. Each part = its own PR + handoff. Progress tracked in
   docs/audit/roadmap-progress.
10. Explicit Placement Discipline. Every artifact is preceded by an
    explicit "WHERE / HOW / WHEN" block. WHERE always specifies
    "Claude Code in Sub-A" OR "shell on Legion".
11. Single Output Discipline. One response = one artifact. No
    parallel variants, no "and then..." with another command.
    Next artifact only after result of previous.
12. On each Claude Code permission prompt, output two artifacts in
    one response: (a) which option to pick; (b) allowlist extension
    command for that class. Exception to clause 11.
13. Multi-sprint plans execute strictly sequentially. Sprint N+1 does
    not start until N is merged. Cancellation is allowed if evidence
    invalidates the premise.

## III. Banxe infrastructure (binding context)

LEGION (factory):
- WSL2 Ubuntu, 64 GB DDR5 (24 GB WSL2)
- LiteLLM on 127.0.0.1:8080 systemd-managed
- Redis cache wired to evo1
- Claude Code + 17 repos under /home/mmber/
- Tailscale IP 100.101.218.26

EVO1 (AI master + business services):
- NucBox EVO-X2, 128 GB LPDDR5X
- AMD Radeon 8060S iGPU
- LAN 192.168.0.72 / Tailscale 100.68.102.48
- Ollama :11434 Vulkan backend
- Redis :6379 hardened Docker (password, AOF, bind LAN+Tailscale)
- BANXE business services (systemd)

EVO2 (compute worker):
- NucBox EVO-X2, 128 GB LPDDR5X
- AMD Radeon 8060S iGPU (Vulkan only, ROCm NOT installed)
- LAN 192.168.0.15 / Tailscale 100.99.208.21
- Ollama :11434 Vulkan (models up to ~50 GB VRAM)
- llama-server :8082 qwen3-235b-Q3_K_S.gguf
- DO NOT load qwen3:235b into Ollama (daemon crash, 132 GB > UMA)

Tailscale mesh: all 3 nodes direct WireGuard 1-3 ms.

## IV. Status snapshot 2026-05-11 20:30 CEST

ADR-035 CLOSED
| Step | Status | PR |
| 1 Smoke gate | DONE | earlier |
| 2 Pool audit | DONE | #192 |
| 3 Model dedup | CANCELLED | #214 |
| 4 LiteLLM + evo2 | DONE | #205 |
| 5 Redis + cache | DONE | #193 |
| 6 LLM router + A-8 | DONE | #200 |
| 7 Tailscale mesh | DONE | #203 |
| 8 Compliance guardrails | PARTIAL (custom_code) | #200 |
| 9 Load balancing | DONE via Part 6 | #205 |
| 10 HITL L3 gate | DONE | #207 |
| Orig 5 Q4->Q8 | CANCELLED | #213 |

ADR-036 Closure Plan CLOSED
| Sprint 1 GPU stack | COMPLETE (Vulkan 67-69 tok/s) | #213 |
| Sprint 2 Q8 235B | CANCELLED (240 GB > 128 GB) | #213 |
| Sprint 3 Model dedup | CANCELLED (HA > 10% disk) | #214 |

origin/main HEAD at handoff: 2f003f6

## V. Open TODO
1. Microsoft Presidio NER (optional upgrade over custom_code).
2. ROCm migration on evo2 (Vulkan suffices; proactive).
3. Claude Code Anthropic subscription (org-level disabled 17:00 CEST).

## VI.a Innovation Sandbox plan (PR #215, binding)

This terminal = sandbox for proving new models / routing / agents
before production rollout.

5 sandbox sprints:
| Sprint | Title | State |
| 1 | Deferred package closure | DONE (#210, #215) |
| 2 | Routing sandbox definition | DONE (#215) |
| 3 | Model candidate matrix | DONE (#215) |
| 4 | ML track opening criteria | DONE as gating doc (#215) |
| 5 | Pilot plan | NOT STARTED, gated on prerequisites |

Candidate models (recorded, NOT deployed):
- Classifier: Qwen2.5-0.5B
- Fast reasoning: ZAYA1-8B
- Domain: qwen3-banxe
- Deep: GLM-4.5-Air, qwen3:235b

## VI.b ML track opening — 4 mandatory prerequisites

ML execution BLOCKED until ALL four met:
A) Training dataset (source, schema, labels, storage, handling)
B) Integration point in banxe-compliance-api (call site, contract,
   failure, rollback)
C) Evaluation protocol (offline procedure, baseline, metrics, reviewer)
D) HITL + audit path (escalation rule, audit sink, no silent bypass)

Sub-A authority cannot satisfy A/B/C/D alone. Requires operator,
banxe-emi-stack team, data team, CTIO.
Sub-A role: track readiness; draft ASK when operator unblocks.

## VI.c Prohibited autonomous next steps

Sub-A MUST NOT initiate without operator decision:
- ML training / fine-tuning
- Modifications to banxe-compliance-api
- Modifications to banxe-emi-stack
- Production rollout of any classifier
- Pilot launch (Sandbox Sprint 5)
- Any `ollama rm` on evo1/evo2

## VII. Pre-flight on resume

Before any write action Sub-A must:
1. git -C /home/mmber/banxe-architecture fetch --all --prune
2. git -C /home/mmber/banxe-architecture log --oneline origin/main -5
3. gh pr list -R CarmiBanxe/banxe-architecture --state open
4. Confirm absence of parallel-session conflict.

## VIII. Handoff format (binding)

  SUB-TERMINAL A READY FOR MERGE
  Track:    <ADR-XXX / Part N>
  Worktree: <path>
  Branch:   <name>
  Commit:   <sha>
  Files:    +N / ~M
  Summary:  <one line>
  Pre-commit: PASS 12/12 (or note skip with reason)
  Drift vs origin/main: <state>
  Handing off to main terminal per §71 + §74.

## End of transfer package
