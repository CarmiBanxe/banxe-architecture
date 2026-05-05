# Sprint — Factory (Developer) Audit Implementation 2026-05

| Field | Value |
|---|---|
| Sprint ID | IL-FACTORY-AUDIT-01 |
| Branch | sprint/factory-developer-audit-2026-05 |
| Started | 2026-05-05 |
| Status | BLOCKED-ON-CLUSTER per docs/canon/operator-canon-2026-05.md (Principle 4) — waits for IL-PROJECT-AUDIT-01 PA-2/PA-4/PA-5/PA-1 completion |
| Owner | CEO (operator) + Perplexity supervisor + Claude Code |
| Predecessor | IL-AUDIT-01 (PRs #50, #52, #54, #55) |
| Successor | (TBD по результатам) |

## Goal

Реализовать на 100% все факторные (factory-side) action items, выявленные аудитом IL-AUDIT-01. Это рабочая ветка-зонтик, в неё подшиваются мини-PR по каждому FA-N. Закрытие спринта = все 5 FA в DONE + все 3 факторных gap (G-FACTORY-01..03) в DONE.

## Reperential snapshot (фиксация существующего положения дел на 2026-05-05)

### Factory plane (Legion — mark-legion, WSL2 Ubuntu 24.04)

| Resource | Reality | Source |
|---|---|---|
| RAM | 23 GiB (WSL2 cap) | A1 |
| Storage | /dev/sdd 1 TB ext4 + /mnt/d 3.7 TB + /mnt/c 952 GB = ~5.6 TB composite | A1 |
| GPU | NVIDIA RTX 4070 Laptop, CUDA via WSL2 | A1 |
| Local AI runtime | NO ollama; llama.cpp built locally | A1 |
| Local model cache | only ggml-vocab-* tokenizers (no weights) | A1 |
| AI agent CLIs | claude 2.1.128, aider 0.86.2, openclaw 2026.3.24, metaclaw, litellm, continue, cursor 2.6.20, codex-cli 0.106.0 | A1 |
| Ruflo | NOT detected | A1 / G-FACTORY-03 |
| Listening ports | :4000 (LiteLLM), :8180 (Keycloak), :8181 (Frankfurter local), :8765, :8096/:8098, :8080 | A1 |
| Guardian-shim | enforce/closed, scope=claude.bash | A1 |
| Local repos | banxe-architecture (11M), banxe-emi-stack (1.8G), MetaClaw (204M), factory (452K), .banxe (48K) | A1 |

### Open factory gaps (from PR #55)

- **G-FACTORY-01 (P2)** — Legion has no local model serving
- **G-FACTORY-02 (P1)** — Keycloak realm split-brain risk Legion vs evo1
- **G-FACTORY-03 (P3)** — Ruflo not detected on Legion

## Implementation roadmap

| ID | Action | Source gap | Phase (GSD) | Status | Mini-PR |
|---|---|---|---|---|---|
| FA-1 | Install ollama + qwen3:4b (2.5 GB) on Legion as factory-fast | G-FACTORY-01 | DEPLOY | PENDING | TBD |
| FA-2 | Define LiteLLM routes factory-fast/mid/heavy/coder + project-reason on :4000 | G-CLUSTER-01 (cross-plane ref) | DESIGN+DEPLOY | PENDING | TBD |
| FA-3 | Resolve Ruflo identity (search alternative names; install or reclassify) | G-FACTORY-03 | SPEC+CLOSE | PENDING | TBD |
| FA-4 | Decommission Legion-side Keycloak OR convert to read-only mirror; document in .claude/rules/infrastructure.md | G-FACTORY-02 | DESIGN+DEPLOY | PENDING | TBD |
| FA-5 | Document agent chain matrix in .claude/rules/agents.md (tie OpenClaw gateways to GSD phases per A4) | A4 | DESIGN | PENDING | TBD |

## Acceptance criteria for sprint closure

- [ ] FA-1 done: `ollama list` on Legion shows qwen3:4b; LiteLLM route `factory-fast` returns 200 on `/v1/chat/completions`.
- [ ] FA-2 done: LiteLLM config on Legion has 5 named routes (factory-fast/mid/heavy/coder + project-reason); each route smoke-tested with `curl`.
- [ ] FA-3 done: Ruflo либо installed либо marked as renamed/integrated (with replacement name documented).
- [ ] FA-4 done: only one canonical Keycloak realm `banxe-emi` exists; Legion-side either decommissioned or read-only mirror; `.claude/rules/infrastructure.md` updated.
- [ ] FA-5 done: `.claude/rules/agents.md` has explicit agent-chain × GSD-phase matrix.
- [ ] All 3 factory gaps closed in `GAP-REGISTER.md` (G-FACTORY-01..03 → DONE).
- [ ] IL-FACTORY-AUDIT-01 closed in `INSTRUCTION-LEDGER.md` with closure block.

## Out of scope

- Project-side actions (PA-1..PA-6) — отдельный спринт `sprint/project-cluster-audit-implementation`.
- HW changes (RAM upgrade, SSD swap, BIOS edits).
- Decommission live evo1/evo2 services.

## Anchors

- IL-AUDIT-01 sprint (PRs #50, #52, #54, #55)
- A1 Legion baseline + A3 gap-analysis + A4 orchestration proposal
- IL-CANON-04 (best-decision rule)
- ADR-018, ADR-019, ADR-026
- MetaClaw org-cleanup/phase4-hw-matrix-roc-rpc @ 016dc26
- docs/canon/operator-canon-2026-05.md (binding canon)

## Status history

| Date | Status | Note |
|---|---|---|
| 2026-05-05 | OPEN | Sprint kickoff — реперная точка зафиксирована, ветка sprint/factory-developer-audit-2026-05 создана от main 1115808 |
| 2026-05-05 | BLOCKED-ON-CLUSTER | Per Operator canon Principle 4 (factory-side waits for cluster stability). Sprint kickoff остаётся merged in main как заявка; реализация FA-1..FA-5 ждёт завершения PA-2/PA-4/PA-5/PA-1 в sibling sprint IL-PROJECT-AUDIT-01. |
