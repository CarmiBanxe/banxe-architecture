# HANDOFF-LIVE — Session Restart Snapshot
# Status: LIVE (auto-maintainable — update after every TRACK BOARD change)
# Purpose: Any terminal reads this file first. No operator recap needed.
# Last updated: 2026-07-11

---

## WHO / MACHINES

| Role | Identity | Location |
|------|----------|---------|
| Operator | Mark (Moriel Carmi) | — |
| Central terminal | Claude Code (Sonnet 4.6) | Legion (local machine, WSL2) |
| Factory / Terminal A | Claude Code (factory agent) | Legion (local machine) |
| Heavy inference | evo1 / evo2 | Remote GPU servers |

---

## INFRASTRUCTURE

### LiteLLM Gateway
| Param | Value |
|-------|-------|
| Endpoint | `http://127.0.0.1:4000/v1` (IPv4 only — `::1:4000` refused) |
| Master key name | `sk-banxe-llm-gateway-2026` |
| Aliases total | 20 confirmed (`litellm-config.v2.yaml`) |
| Key aliases | `banxe-general`, `coding`, `qwen3-30b`, `fast`, `reasoning`, `reasoning-235b`, `project-mid`, `factory-coder`, `ai-heavy` |
| `banxe-general` | BANNED from Private Engine (Banking Engine only, ADR-103) |

### Legion Hardware
| Component | Spec |
|-----------|------|
| CPU | Intel i7-14700HX, 20 threads |
| RAM | ~54Gi usable (~64GB physical) |
| GPU | NVIDIA RTX 4070 Laptop, 8188 MiB VRAM, CUDA 560.94 |
| Disk | 769G free |
| OS | Linux 6.6.87.2-microsoft-standard-WSL2 |

### Legion Local Model State (audited 2026-07-11)
- **Active:** Ollama `:11434` with `qwen2.5-coder:7b` only.
- **Inactive:** `llama-server :8080` — NOT running.
- **Heavy/uncensored model (Qwen3.6-35B IQ2_M):** NOT running locally. Source blueprint for it is SUPERSEDED.
- **Ollama 30B-class model:** NOT yet pulled (OI-LOCAL-1 unresolved — operator must run `ollama list`).

---

## ACTIVE CANONS

| Canon | File | Binding since |
|-------|------|--------------|
| Memory-First, Audit-Confirms | `CANON-MEMORY-FIRST-AUDIT-CONFIRMS.md` | 2026-07-11 |
| Parallel Orchestration | `CANON-PARALLEL-ORCHESTRATION.md` | 2026-07-11 |
| Prompt-Rewrite on New Output | `CANON-PROMPT-REWRITE-ON-OUTPUT.md` | 2026-07-11 |
| Ledger Event After Block | `CANON-LEDGER-EVENT-AFTER-BLOCK.md` | 2026-07-11 |

All files in `docs/governance/`. All are additive — they do not override I-27, I-71, ADR-060, §72.

---

## TRACK BOARD (pointer → SESSION-STATE.md for live data)

Full TRACK BOARD lives in `docs/governance/SESSION-STATE.md` § TRACK BOARD.
Summary as of last update:

| Track | Status | Blocked-by |
|-------|--------|-----------|
| T1 — Private Engine config | PR #1126 OPEN | OI-LOCAL-1 (Ollama tag + G-6) |
| T2 — Sprint plan | DRAFT commit 5c41cb1 | OI-LOCAL-1 (same gate) |
| T3 — Watchdog brigade | RUNNING | — |
| T-MEM — Memory infra | IN PROGRESS | — |

**Critical blocker:** OI-LOCAL-1 — operator must run `ollama list` and confirm Ollama model tag
before T1 config.toml edit and T2 Sprint L-1 revision can proceed.
Draft proposals: `docs/ops/legion-private-engine/OI-LOCAL-1-FINDINGS.md`.

---

## HARD BOUNDARIES (immutable)

| Boundary | Rule |
|----------|------|
| I-27 HITL | Agents PROPOSE, human DECIDES. Never autonomous write to banking. |
| I-71 Single-writer | Operator-only: git push, PR merge, tag, install, `systemctl enable/start`. |
| ADR-060 branch regex | `^agent/(central|right|factory|specproj)/[A-Za-z0-9]+/[a-z0-9._-]+$` |
| §72 Dup-check | Before any artifact creation, verify no existing file covers the same scope. |
| DLP (ADR-103) | No banking credentials, Postgres password, customer PII, IBAN, or banking source code in Private Engine config or prompts. `banxe-general` alias BANNED on Legion. |
| Uncensored model | Factory will NOT help deploy or configure uncensored/abliterated models in compliance-adjacent contexts. Blueprint for llama-server + Qwen3.6 uncensored is SUPERSEDED. |
| I-24 Ledger | Append-only. Never rewrite or delete ledger events. |

---

## HOW TO RESUME A SESSION

**Step 1:** Read this file (HANDOFF-LIVE.md). You are here.

**Step 2:** Read `docs/governance/SESSION-STATE.md`.
- § HARDWARE — Legion runtime facts
- § LITELLM GATEWAY — inference endpoints
- § OPEN ITEMS — what is blocking which track
- § TRACK BOARD — current track states (added 2026-07-11)

**Step 3:** Read last 10 ledger events per active track:
```
ledger/entries/T1/<today>.log
ledger/entries/T2/<today>.log
ledger/entries/T-MEM/<today>.log
```
(Ledger namespace created per CANON-LEDGER-EVENT-AFTER-BLOCK.md — populate as events occur.)

**Step 4:** Read `docs/ops/legion-private-engine/OI-LOCAL-1-FINDINGS.md` for current OI-LOCAL-1 status and draft config proposals.

**Step 5:** Resume from last closed block. Do NOT ask the operator to recap. Do NOT re-run audits that SESSION-STATE.md already records as completed.

---

## TWO-ENGINE ARCHITECTURE (summary)

| Engine | Name | Host | Purpose |
|--------|------|------|---------|
| Private Legion Engine | OpenManus | Legion (local) | AUTONOMOUS dev/research — browser, bash, search, code |
| Banking Engine | Banksy | evo1 (primary) + evo2 (failover) | FCA-compliant banking orchestration (LangGraph) |

**Separation is hard (ADR-103):** No routes from Legion to banking DBs or internal APIs.
Private Engine memory (Qdrant local) ≠ Banking Engine memory (Qdrant evo1). No sync without human audit trail.

---

## WORKTREES IN USE

| Worktree | Branch | Purpose |
|----------|--------|---------|
| `/home/mmber/wt/private-engine-openmanus` | `agent/factory/private-engine/openmanus-config` | T1: OpenManus config + T-MEM governance files |
| `/home/mmber/wt/bdsl-act-prep` | `agent/factory/t5/bdsl-activation-prep` | T2: Sprint plan + Grossbuch addendum |
| Main worktree | `agent/factory/watchdog/sprint3-decision-core` | T3: Watchdog brigade (independent) |

---

## REFERENCES

- Session memory: `docs/governance/SESSION-STATE.md`
- OI findings: `docs/ops/legion-private-engine/OI-LOCAL-1-FINDINGS.md`
- Config (current, needs revision): `docs/ops/legion-private-engine/config.toml` (commit f9e5d7b)
- Sprint plan (needs L-1 revision): `docs/architecture/SPRINT-PLAN-TWO-ENGINES.md` (commit 5c41cb1, bdsl-act-prep)
- Canons directory: `docs/governance/CANON-*.md`
- Architecture repo: `https://github.com/CarmiBanxe/banxe-architecture`
