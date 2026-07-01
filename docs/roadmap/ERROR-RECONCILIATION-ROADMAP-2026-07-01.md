# ERROR-RECONCILIATION-ROADMAP — 2026-07-01

> **Docs-only** self-audit + fix-plan + sprint schedule.
> No runtime, infra, LiteLLM, or config change is authored by this document.
> All infra actions listed here are **operator-owned** (see §5 GUARDRAILS).
>
> **Venue:** authored on evo1 in `~/banxe-architecture` per ADR-103 server-only
> policy. **Attribution:** Software Factory (evo1) preparing for operator merge
> per Best Single Artifact canon.

---

## §1 ERROR REGISTER

Honest self-audit of this session. Every row is a **verified fact** — no
softening. Statuses distinguish what was corrected in-session
(analytical misses `A*`), what remains OPEN and needs the roadmap
(discrepancies `B*`), and what is infra-owned and out of factory scope
(infra `C*`).

| ID   | Error / observation                                             | Verified fact                                                                                                        | Fix                                                                    | Status         | Owner            |
| ---- | --------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- | -------------- | ---------------- |
| **A — Analytical misses (corrected in-session; captured in memory)**                                                                                                                                                                                                                                                                                                                             |
| A1   | Wrong-repo audits (`banxe-architecture` docs vs. `evo1/trading-backend`) | Reviews landed against the wrong working copy; conclusions did not apply to the intended repo                        | Audit the right repo / origin; verify `git remote -v` before conclusions | CORRECTED      | Factory          |
| A2   | `nvidia-smi` on AMD Strix-Halo iGPU                             | Strix-Halo is AMD; `nvidia-smi` never applies                                                                        | Use `rocm-smi` / `amd-smi` on AMD iGPU                                 | CORRECTED      | Factory          |
| A3   | Reported "no heavy route"                                       | Routing canon (`factory-heavy` / `project-reason`) already existed (canon PR #871)                                   | Run ADR-102 duplication check before concluding "missing"              | CORRECTED      | Factory          |
| A4   | Reported phantom IL-2028 / IL-784 via `grep \| sort`             | Grep-based numbering hallucinates; canonical number = `build_ledger.py` max over current main                        | Use `python3 ledger/build_ledger.py` (JSON max), never text grep       | CORRECTED      | Factory          |
| A5   | Stale local checkout (behind origin)                            | Local HEAD was behind `origin/main`; conclusions read stale state                                                    | `git fetch origin` + read `origin/main`, not local HEAD                | CORRECTED      | Factory          |
| A6   | "PR #929 merged" false attribution to IL-775                    | IL-775 belonged to a parallel `sprintplan07` shard; #929 mapped to a different shard KEY                             | Verify by **shard KEY** (`session_id__hex`), never the IL number alone | CORRECTED      | Factory          |
| A7   | Plan-1 / Plan-2 conflation (Claude-dispatch ≠ local ollama)     | Anthropic Claude API dispatch is not the same substrate as local ollama; §5 amendment landed via merged PR #929      | Keep plane classification explicit in §5 canon                         | CORRECTED      | Factory          |
| A8   | IL-777 label-drift (squash subject vs. ledger)                  | The squash-commit subject did not track the re-minted IL on rebase                                                   | Re-mint the **PR TITLE** on rebase, not just the shard                 | CORRECTED      | Factory          |
| A9   | Reported "235b idle" against wrong stack                        | Measured ollama `:11434` (idle); model is **LIVE** on evo2 llama-server `:8082`; §5 correction merged in #938        | Verify the actual stack + port before drawing an availability claim   | CORRECTED      | Factory          |
| A10  | Reported "Redis down / restart=no"                              | Targeted the wrong container (`:16379` jube container). Allocator Redis (`banxe-redis`, host-net) is already durable | Verify container identity (name, network, port) before status claims  | CORRECTED      | Factory          |
| A11  | `ssh evo2` self-fail + wrong `:4000` host                       | Session was **on** evo2; LiteLLM `:4000` runs on **evo1**                                                            | Local-exec on evo2; tailscale to evo1 for `:4000`                     | CORRECTED      | Factory          |
| A12  | Recommended raw `:8082` bypass                                  | Raw `:8082` = canon violation (I-32 / I-33 no-bypass; ADR-016 single entrypoint)                                     | Governed `:4000` only; **never** raw `:8082`                          | CORRECTED      | Factory          |
| **B — Real open discrepancies (drive the roadmap)**                                                                                                                                                                                                                                                                                                                                              |
| B1   | §5.2 / §5.5 canon factually wrong                               | §5 correction PR **#938** is currently OPEN; IL is provisional and needs a re-rebase (IL-785 collided on `main`)      | Rebase-freeze IL per ADR-119; re-mint PR title + shard; merge          | IN-PROGRESS    | Factory prepares / operator merges |
| B2   | evo2 has no agentic CLI                                         | `node = NONE`, `claude` CLI ABSENT; `python3 + pip` present                                                          | Decide the evo2 agent lane, then provision                            | OPEN           | Operator (decision + install) |
| B3   | No canon record of the evo2 agent-lane decision                 | The choice between Claude-quality (Plan-1) and Aider-local (Plan-2) is not written into governance                   | Author an ADR + IL that records the decision (docs-only)              | OPEN           | Factory (draft) / operator (accept) |
| B4   | Ledger-thrash root cause = concurrent regeneration              | Concurrent regeneration of `INSTRUCTION-LEDGER.md` / `IL-SEQUENCE.json` between parallel PRs (**not** Redis).         | Serialization strategy = software base-drift guard (`main-serialize.yml`, `MERGE-SERIALIZATION-FALLBACK.md`) is the current mechanism (proven, landed); durable OPTIONS = (A) transfer repo to a GitHub org → native queue becomes available → activate it (+ `merge_group` trigger on `main-serialize.yml` or drop it from required checks); (B) keep the software serializer + arm-auto-merge-then-rebase tactic (current, proven — landed #941 / #938); (C) reduce concurrent ledger-PR load. Native Merge Queue is org-only and UNAVAILABLE on this user-owned repo. correction 2026-07-01b: native Merge Queue is org-only (repo is user-owned); see MERGE-SERIALIZATION-FALLBACK.md. | OPEN — strategy choice | Operator (strategy: org-transfer vs software-serializer) |
| **A13** | Merge-Queue advice inaccuracy (this session)                 | Prior recommendation to "activate native GitHub Merge Queue" (as the durable thrash-fix) was inaccurate: `CarmiBanxe` is user-owned → native queue is org-only, unavailable (verified: `gh api graphql {repository{mergeQueue}}` = null). The correct mechanism/anchor is the software serializer (`.github/workflows/main-serialize.yml` base-drift guard, documented in `docs/governance/MERGE-SERIALIZATION-FALLBACK.md`). ADR-060 §1 ("native Merge Queue is the mechanism") assumed an org, so it does NOT apply to this repo. ADR-143 Redis allocator handles unique numbering — NOT base-drift serialization. | Correct §1 B4 / §2 B4 / §3 R3 / §4 Sprint-E3 to describe the software serializer + org-transfer option (A) vs accept-serializer option (B), instead of "activate native Merge Queue"                          | corrected-here | Factory          |
| **C — Infra (operator-owned; explicitly not factory mutations)**                                                                                                                                                                                                                                                                                                                                 |
| C1   | Redis allocator (`banxe-redis`, host-net, AUTH)                 | Durable: `restart=unless-stopped`; no action                                                                         | None                                                                   | OK / NO ACTION | Operator (owns) |
| C2   | 235b live on evo2 `:8082` (llama-server)                        | Serving traffic through governed `:4000` (per ADR-016); no action                                                    | None                                                                   | OK / NO ACTION | Operator (owns) |
| C3   | evo2 runtime / agent provisioning                               | Awaiting the B2 / B3 decision before install                                                                         | Blocked on B3 outcome (see §4 Sprint-E2 → E4)                          | BLOCKED        | Operator (install per B3) |

Confirmation footprint: **A1–A13 present, B1–B4 present, C1–C3 present.**
correction 2026-07-01b: native Merge Queue is org-only (repo is user-owned); see MERGE-SERIALIZATION-FALLBACK.md.

---

## §2 FIX PLAN (per open item)

### B1 — §5 canon correction PR #938

- **What:** re-rebase PR #938 against current `origin/main`, regenerate the
  ledger from root, allow `build_ledger.py` to assign `max+1` (never hardcode
  the number), re-mint the PR title + shard body to match, land the merge.
- **Owner:** factory prepares the rebase artefact; operator merges via the
  software serializer `main-serialize.yml` (B4 option B — current, proven)
  or, if B4 option A is chosen (org-transfer), via the native Merge Queue
  once activated.
- **How:** ADR-119 canonical sequence (fetch → switch → regenerate → verify
  `--check` = 0 → push → PR title/body sync → merge). No skip flags.

### B2 — evo2 has no agentic CLI

- **What:** provision an agent runtime on evo2 per the outcome of B3
  (Claude-quality lane, Aider-local lane, or both). All provisioning targets
  the **governed** `:4000` on evo1 over tailscale — never raw `:8082`.
- **Owner:** operator (install / systemd unit / secrets). Factory prepares
  the install command inventory per Sprint-E4.
- **How:** see §4 Sprint-E4 (post-decision provisioning) — routed via
  `factory-*` / `project-reason` aliases per `agents.md` LiteLLM route map.

### B3 — Author the evo2 agent-lane decision (canon record)

- **What:** an ADR + IL that captures the decision — Claude-quality
  (Anthropic API, Plan-1) vs. Aider-local (Plan-2) vs. both — with the
  hardware / plane rationale (Plan-1 ≠ Plan-2, per A7). RED-zone /
  regulated code stays on Claude per BUG-005 (Ruflo mandatory) and
  `agents.md` Ruflo review canon.
- **Owner:** factory drafts, operator accepts.
- **How:** docs-only ADR draft under `docs/adr/`, IL shard under
  `ledger/entries/`, no runtime change.

### B4 — Serialization strategy (org-transfer vs software-serializer)

> correction 2026-07-01b: native Merge Queue is org-only (repo is user-owned); see MERGE-SERIALIZATION-FALLBACK.md.

- **What:** decide the durable serialization mechanism for `main`. The
  earlier advice to "activate native GitHub Merge Queue (ADR-060 §1)" was
  **inaccurate**: `CarmiBanxe` is a user account, not an org, and the
  **native Merge Queue is an org-only feature** (verified read-only —
  `gh api graphql {repository{mergeQueue}}` returns null; REST returns
  422; the Settings UI does not persist it). The repo already serializes
  merges via a **software substitute** — `.github/workflows/main-serialize.yml`
  (base-drift guard: fails any PR with `behind > 0` vs `origin/main`,
  forcing rebase-before-merge). That guard is doing exactly what it was
  designed to do; the "thrash" observed under concurrent ledger writes
  is the guard **working as designed**, not a bug. ADR-143 Redis
  allocator handles **unique numbering** (C1) and does NOT serialize
  merge order.
- **Owner:** operator (strategy choice; repo settings; no factory
  runtime change).
- **How — three options (docs-only inventory):**
  - **(A) Org-transfer.** Transfer `CarmiBanxe/banxe-architecture` to a
    GitHub organization → native Merge Queue becomes available →
    activate it under Settings → Branches → `main` → "Require merge
    queue"; then either **add a `merge_group` trigger** to
    `main-serialize.yml` (so the base-drift guard runs inside the
    queue), or **drop `main-serialize.yml` from required checks** (the
    queue itself serializes). ADR-060 §1 then applies as originally
    written.
  - **(B) Accept the software serializer (current, proven).** Keep
    `main-serialize.yml` + the arm-auto-merge-then-rebase tactic (as
    landed on #941 / #938). This is the mechanism operating **today**
    and is documented in `docs/governance/MERGE-SERIALIZATION-FALLBACK.md`.
    No repo transfer; no additional infra.
  - **(C) Reduce concurrent ledger-PR load.** Serialize the *authoring*
    side (one ledger-touching PR in flight at a time) so the software
    guard has nothing to trip on. Complements (B); does not replace it.
- **Anchor:** `docs/governance/MERGE-SERIALIZATION-FALLBACK.md`
  (Variant B — software base-drift guard; canonical for user-owned repo).

---

## §3 ROADMAP — phases

| Phase | Name              | Objective                                                                                                | Depends on   |
| ----- | ----------------- | -------------------------------------------------------------------------------------------------------- | ------------ |
| **R1** | Canon-accuracy    | Land §5 correction PR **#938** (B1) + this ERROR-RECONCILIATION register into main                       | —            |
| **R2** | evo2 lane decision | Author + accept the agent-lane ADR (B3); RED-zone stays on Claude (BUG-005 / `agents.md`)              | R1           |
| **R3** | Serialization strategy | Choose strategy per B4 — **(A)** org-transfer → activate native Merge Queue (ADR-060 §1); **(B)** accept the software serializer `main-serialize.yml` (current, proven — `MERGE-SERIALIZATION-FALLBACK.md`); **(C)** reduce concurrent ledger-PR load. Native queue is org-only; correction 2026-07-01b. | R1           |
| **R4** | evo2 provisioning | Install per R2: Node + Claude Code (Claude-quality lane) OR Aider (local lane) — all via governed `:4000` | R2 (+ ideally R3) |

R1 / R3 can run in parallel from the operator side (R1 is factory-authored,
R3 is repo-settings). R2 blocks R4 because provisioning is decision-driven.

---

## §4 SPRINTS

### Sprint-E1 — Canon-accuracy (docs-only)

- **Scope:** merge §5 correction PR #938 (B1) + this ERROR-RECONCILIATION
  roadmap. Docs-only. No runtime.
- **Factory:** prepare the re-rebase of #938, regenerate ledger from root,
  push updated shard + regenerated `INSTRUCTION-LEDGER.md` +
  `IL-SEQUENCE.json`; keep both PRs in Best-Single-Artifact discipline.
- **Operator:** review + merge in serial order (or via queue once R3 is
  active).
- **Exit:** PR #938 merged; this register merged; §5.2 / §5.5 canon
  factually accurate on `main`.

### Sprint-E2 — evo2 agent-lane decision (docs-only)

- **Scope:** operator chooses one of:
  - **Claude-quality only** (Anthropic API — Plan-1),
  - **Aider-local only** (local ollama over governed `:4000` — Plan-2),
  - **Both** (Claude-quality primary + Aider-local for non-RED tasks).
- **Invariant:** RED-zone / regulated code paths (payment, compliance,
  KYC, safeguarding) **STAY on Claude** per BUG-005 (Ruflo mandatory) and
  the agent-chain × GSD-phase matrix in `.claude/rules/agents.md`.
- **Factory:** draft the ADR + IL capturing the decision (B3), including
  per-lane install commands (all commands target governed `:4000`).
- **Operator:** accept the ADR; approve the install-command inventory.
- **Exit:** ADR-`<next>` + IL landed on `main`; provisioning unblocked.

### Sprint-E3 — Serialization strategy (repo-settings; operator)

> correction 2026-07-01b: native Merge Queue is org-only (repo is user-owned); see MERGE-SERIALIZATION-FALLBACK.md.

- **Scope:** pick the durable serialization strategy per B4. Three
  paths, one choice:
  - **(A) Org-transfer** → transfer `CarmiBanxe/banxe-architecture` to
    a GitHub org → Settings → Branches → `main` → "Require merge
    queue"; either add `merge_group` trigger to `main-serialize.yml`
    or drop it from required checks.
  - **(B) Accept the software serializer** (current, proven — landed
    #941 / #938): `main-serialize.yml` base-drift guard +
    arm-auto-merge-then-rebase tactic; no repo transfer.
  - **(C) Reduce concurrent ledger-PR load** so the guard has nothing
    to trip on (complements B).
- **Factory:** none (repo Setting or authoring-side discipline; no
  code / docs change is required beyond this register and
  `MERGE-SERIALIZATION-FALLBACK.md`).
- **Operator:** choose the strategy and, if (A), execute the transfer
  + enable native Merge Queue. If (B), no repo-settings change beyond
  keeping `main-serialize.yml` on required checks.
- **Exit:** strategy chosen and documented; if (A), native Merge
  Queue active on `main`; if (B), the software serializer remains the
  canonical mechanism.

### Sprint-E4 — evo2 provisioning (per Sprint-E2 outcome)

- **Scope:** install on evo2, per the E2 decision:
  - **Claude-quality lane:** Node + Claude Code CLI; all inference via
    Anthropic API (Plan-1) OR routed through evo1's governed `:4000`
    where applicable.
  - **Aider-local lane:** Aider CLI, routed via **governed** `:4000` on
    evo1 (tailscale) — NEVER raw `:8082` (I-32 / I-33 no-bypass).
- **Factory:** prepare the exact install command sequences per lane
  (published as an operator runbook under `docs/runbooks/`).
- **Operator:** install; verify agent-lane liveness via read-only shell
  audit (`[SHELL]` per Best Single Artifact).
- **Exit:** evo2 has an agentic CLI aligned to the E2 decision; RED-zone
  requests continue to route through Ruflo per BUG-005.

---

## §5 GUARDRAILS

**Prevention gate — A1–A12 audit-discipline checklist.** Before any
factory conclusion / recommendation:

1. Verify **which repo** (A1): `git remote -v` + branch confirms the
   intended target.
2. Verify the **GPU vendor** (A2): AMD → `rocm-smi` / `amd-smi`; NVIDIA →
   `nvidia-smi`. Match tool to silicon.
3. Run the **ADR-102 duplication check** (A3) before concluding "missing".
4. Use **`python3 ledger/build_ledger.py`** for IL numbers (A4). Never
   `grep | sort` a text ledger.
5. **Fetch + read `origin/main`** (A5) before analysis; local HEAD is
   informational only.
6. Verify by **shard KEY** (`session_id__hex`), not by IL number alone
   (A6).
7. Keep **plane classification explicit** (A7): Anthropic API dispatch ≠
   local ollama. Different substrates, different governance.
8. **Re-mint the PR title on rebase** (A8), not just the shard.
9. Verify the **actual stack + port** (A9) before availability claims.
10. Verify **container identity** (name, network, port) (A10) before
    status claims.
11. **Local-exec** on the current host (A11); use tailscale for the
    other host; do not `ssh` yourself.
12. **Governed `:4000` only** (A12). Raw `:8082` is a canon violation
    (I-32 / I-33 no-bypass; ADR-016 single entrypoint).

**Structural guardrails.**

- All fixes proposed here are **docs-only** or **governed** (routed via
  the LiteLLM `:4000` proxy). No factory-side runtime / infra / secret
  mutation.
- **RED-zone → Claude.** Payment / compliance / KYC / safeguarding paths
  route through Ruflo per BUG-005 and `.claude/rules/agents.md`.
- **Infra = operator.** Redis allocator (C1), 235b llama-server (C2),
  and evo2 runtime provisioning (C3) are operator-owned; the factory
  prepares inventory only.
- **Direct `:8082` bypass forbidden.** Cite I-32 / I-33 and the
  COMPUTE-ROUTING-TAXONOMY no-bypass rule on every routing
  recommendation.
- **Secrets:** referenced by **vault / config location only**; no key
  values, no plaintext, no filesystem paths that leak credentials.
- **Ledger discipline:** IL number frozen at merge time per ADR-119
  (never hardcode); shards append-only per ADR-059-A; no foreign shard
  / branch mutation (parallel-session-isolation Rules 6 / 7).

---

## Anchors (see, do not restate)

- **COMPUTE-ROUTING-TAXONOMY** §5 + §1 — I-32 / I-33 no-bypass rule
  (`docs/agent-engine-dossier/COMPUTE-ROUTING-TAXONOMY.md`).
- **ADR-060 §1** — GitHub native Merge Queue (applies **only** if B4
  option A is chosen; org-only feature — unavailable on this user-owned
  repo per correction 2026-07-01b).
- **`docs/governance/MERGE-SERIALIZATION-FALLBACK.md`** — software
  base-drift guard (`.github/workflows/main-serialize.yml`); canonical
  mechanism for a user-owned repo (Sprint-E3 option B).
- **ADR-119** — IL freeze at merge / re-mint on rebase (Sprint-E1 pattern).
- **ADR-103** — server-only refactoring venue (evo1 is the authoring host).
- **ADR-153** — terminal topology canon (Orchestrating Terminal role;
  Right-Terminal alias).
- **BUG-005** — Ruflo mandatory middleware for payment / compliance / KYC.
- **`.claude/rules/agents.md`** — LiteLLM route map (`factory-fast`,
  `factory-mid`, `factory-heavy`, `factory-coder`, `project-reason`).
- **Session memory:** `terminal-b-audit-discipline` and `compute-planes`
  (A1–A12 gate + Plan-1 / Plan-2 plane distinction).

---

*End of ERROR-RECONCILIATION-ROADMAP-2026-07-01.*
