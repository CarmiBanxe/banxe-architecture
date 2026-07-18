# S-FAC-67 (R3) — Orchestration enforcement (SKILLS-ORCHESTRATION wiring)

<!-- Source: docs/runbooks/S-FAC-67-orchestration-enforcement-2026-07-18.md | Date: 2026-07-18 | Status: DRAFT (docs-only spec, PROPOSED, no code) | Implements: docs/roadmap/FACTORY-ROADMAP-2026-06-23.md §2 S-FAC-67 (R3) DoD | IL: pending-shard (allocator down, see §6) -->

> **Status: DRAFT — SPEC ONLY, no code.** Governance/docs-only. Nothing was implemented, no
> hook was written, no config changed. Written from the isolated worktree
> `agent/factory/govops/s-fac-60-evo1-remediation` (reused — sibling of the S-FAC-60/61
> runbooks already on this branch), **held locally, not pushed**, per I-71 while the evo1
> Redis IL-allocator is unreachable.

## 0. S-FAC-67 DoD (verbatim)

> `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §2: **S-FAC-67 | R3 | Orchestration
> enforcement** — *"SKILLS-ORCHESTRATION scenario→sequence rules wired so the factory runs
> them in order (CMS→RSB→ACG→… per matrix); quality-gate remains final layer; no skill
> bypasses gate."*

## 1. Canonical scenario→sequence table — three sources found, not fully reconciled

### 1a. The table matching the roadmap's own "CMS→RSB→ACG" shorthand exactly

`.claude/rules/agents.md` (`banxe-architecture`, `alwaysApply: true`) §"Scenario → Sequence reference":

| Scenario | Sequence |
|---|---|
| A. New feature | CMS → RSB → ACG → CAE → STG → gate |
| B. Product code | CMS → CAE → EHS → ACG → STG → gate |
| C. Safe refactor | CMS → ARP → CAE → STG → gate |
| D. Performance | CMS → PS → DO? → STG → gate |
| E. API/integration | CMS → RSB → ACG → EHS → STG → gate |
| F. Error model | CMS → EHS → CAE → STG → gate |
| G. Deps cleanup | CMS → DO → CAE → STG → gate |
| H. Test coverage | CMS → STG → gate |
| I. Governance | CMS → RSB → CAE → gate? |
| J. Standby | CMS → RSB → local → STG? |

*(Abbreviations, same file: CMS=Context Memory Sync, RSB=Rapid Spec Builder, ACG=API Contract
Guardian, CAE=Clean Architecture Enforcer, EHS=Error Handling Standardizer, PS=Performance
Scanner, DO=Dependency Optimizer, STG=Smart Test Generator, ARP=Auto Refactor Pro.)* Note the
`?` markers on rows D and I in the source itself — these are **the source document's own
uncertainty markers**, not mine; I have not resolved them.

### 1b. The fuller, MUST/SHOULD-graded original — `docs/SKILLS-ORCHESTRATION.md` §"Scenario Matrix"

Same 10 scenarios (A–J), same skills, but with per-step `MUST`/`SHOULD`/`MAY` granularity and a
named "Final Blocker" column (always `quality-gate.sh`, except scenario I = "Repo governance
review" and scenario J = "Plane isolation rules"). Not re-quoted here in full (already verbatim
in that file) — pointer, not duplicate. `docs/SKILLS-OPERATING-MODEL.md` §8 explicitly names
**this** file as canonical for order: *"Skill invocation order is defined in
**SKILLS-ORCHESTRATION.md**. The operating model governs _how_ skills run; the orchestration
model governs _when_ and _in what order_."* — and §8.3 of that same file reproduces the exact
same abbreviation table as §1a above, confirming 1a and 1b are the **same** specification at two
levels of detail (compact vs. full), not two competing ones.

### 1c. A third, later, broader table — NOT reconciled with 1a/1b by any source found

The **same file** as §1a (`.claude/rules/agents.md`) also contains, further down, an
"Agent-chain × GSD-phase matrix (FA-5)" (dated 2026-05-06, roughly a month after
SKILLS-ORCHESTRATION.md's 2026-04-08), with **different scenario letters and different content**:

| Chain | Sequence |
|---|---|
| A. Safe refactor (no compliance touch) | CMS → ARP → CAE → STG → gate |
| B. Compliance change | RSB → ACG → **Ruflo (mandatory)** → ARP → STG → mlro_agent → gate |
| C. Architecture decision | RSB → ACG → CAE → OpenClaw gateway-ctio → ADR draft → review by Ruflo |
| D. Deploy (factory side) | implement → STG → review → factory-fast/factory-coder → DEPLOY phase agents |
| E. Deploy (project side) | RSB → ACG → ARP → STG → **Ruflo** → MLRO approval (HITL) → OpenClaw gateway-moa → smoke test |
| F. Reasoning task (heavy) | route via `reasoning-235b` → analysis → Ruflo regulatory check → mlro_agent decision |

This introduces actors (**Ruflo**, **OpenClaw gateway-ctio/guiyon/moa**, **mlro_agent**,
**compliance_canon_agent**) that do not appear anywhere in `SKILLS-MATRIX.md`'s 9-skill roster
or in `SKILLS-ORCHESTRATION.md`'s Scenario Matrix. `SKILLS-OPERATING-MODEL.md` §8 names only
`SKILLS-ORCHESTRATION.md` as canonical for order — it does **not** mention this FA-5 chain table
at all, and nothing found in this repo states whether FA-5 **supersedes**, **extends**, or
**runs alongside** the original A–J scenarios. **This is a real, unreconciled overlap — not
invented here, and not resolved here.** See §5 [UNKNOWN].

## 2. Current-state: is ordering actually enforced? — **No, for skill sequence. Yes, for quality-gate itself.**

### 2a. The 6 hooks the specs say enforce this — searched for, not found as files

`docs/SKILLS-ORCHESTRATION.md` §"Enforcement Points" and `docs/SKILLS-OPERATING-MODEL.md` §5.2/§9
both name six hooks as the actual enforcement mechanism: `il_gate.py`, `policy_guard.py`,
`invariant_check.py`, `bounded_context_check.py`, `load_architecture.py`, `quality_gate_hook.py`.

**Searched (file-tree + content grep, both repos, `origin/main`):** none of these six filenames
exist anywhere in `banxe-architecture` or `banxe-emi-stack`. None of the six names appear inside
any `.json`/`.yaml`/`.toml` config in either repo (only two unrelated governance-mapping files —
`governance/aigf-risk-mapping.yaml`, `governance/trust-zones.yaml` — reference some of the names,
apparently descriptively, not as an implementation pointer). **Conclusion: these six hooks are
documented but not found implemented under these names in either repo.**

### 2b. What IS actually wired (verified) — real, but not the same thing

- `banxe-emi-stack/.claude/settings.json` wires real `PreToolUse`/`PostToolUse` hooks: a
  main-branch-edit blocker, a Bash-command guardian-shim filter, a ruff-format-on-save hook, a
  proto-sync-on-API-file-change hook, and `.claude/hooks/post-task.sh`. Four `.sh` files exist:
  `post-edit-scan.sh`, `post-task.sh`, `pre-commit-quality.sh`, `worktree-guard.sh`.
- A `git` pre-commit hook is empirically active in this session — every commit this session
  (across many prior tasks) triggered a LucidShark/semgrep scan before the commit completed.
- `scripts/quality-gate.sh` exists in **both** repos.
- **No script or hook anywhere greps, reads, or otherwise consults `SKILLS-ORCHESTRATION.md`
  programmatically** (content-searched both repos for the filename — zero hits in `.py`/`.sh`).

**Verdict: scenario **ordering** (CMS before RSB before ACG, etc.) is enforced 0% mechanically
today — it is a written convention that Claude Code (the LLM agent) is instructed to follow via
`.claude/rules/agents.md` / `CLAUDE.md`, with nothing independently checking it.** By contrast,
**`quality-gate.sh`'s constituent checks ARE mechanically enforced today** — see §3.

## 3. "quality-gate remains final layer; no skill bypasses gate" — current evidence

Checked live, read-only, via `gh api .../branches/main/protection`:

| Repo | Required status checks (main) | `enforce_admins` |
|---|---|---|
| `banxe-architecture` | `guardian-factory`, `guardian-project`, `guardian-ledger`, `ledger-append-only`, `main-merge-serialize` | **true** |
| `banxe-emi-stack` | `Smoke Gate (mock tier)`, `Pytest (coverage >= 80%)`, `Ruff lint + format`, `Semgrep (banxe-rules)`, `Semgrep security rules`, `Semgrep OSS`, `Gitleaks - Secrets Scan`, `Biome lint + format (Frontend)`, `Vitest (frontend)` | **false** |

**Reading this precisely, not overclaiming:**
- On `banxe-emi-stack`, the quality-gate constituent checks (pytest/ruff/semgrep/biome/vitest) are
  genuinely **non-bypassable via a normal PR merge** — GitHub will not allow the merge button to
  be used until they pass. This matches "quality-gate remains final layer" for anything reaching
  `main` via a PR, which is the only merge path this session has ever used (§5 operator-merge
  discipline, no `--admin`/`--force`).
- **`enforce_admins: false`** on `banxe-emi-stack` means a repository **admin** could, in
  principle, merge a PR while a required check is still failing (GitHub's "Merge without waiting
  for requirements" admin override). This is a **real, narrow residual bypass path** — not
  exercised in this session, not invented, just present in the current branch-protection
  configuration as read. `banxe-architecture` has `enforce_admins: true` (no such admin
  override there).
- **Local** pre-commit/git hooks (LucidShark scan, ruff, etc.) can always be skipped with
  `git commit --no-verify` at the git level — this is a general git fact, not a repo-specific
  finding. The **actual** non-bypassable backstop for anything landing on `main` is the
  **branch-protection required-status-check list above**, not the local hook.
- **None of this is specific to *skill* sequencing** — it protects code quality/security, not
  "did CMS run before RSB." No mechanism found anywhere enforces the latter (§2).

## 4. Proposed enforcement mechanism — DESIGN ONLY, no code, for operator/CTIO review

This is a spec sketch, not an implementation. Concrete file layouts, languages, and exact hook
wiring are left to a separate, explicitly-gated implementation PR (§6).

1. **Pick one canonical scenario→sequence source before building anything.** Per
   `SKILLS-OPERATING-MODEL.md` §8's own pointer, `SKILLS-ORCHESTRATION.md` Scenarios A–J is
   already the designated canonical source — recommend using it as-is and treating the FA-5
   chain (§1c) as a **separate**, explicitly-scoped extension to be reconciled (merged in,
   deprecated, or documented as a distinct later-stage flow) **before** wiring enforcement, so
   the enforcer isn't built against a source that's already known to be incomplete.
2. **A machine-readable manifest, generated from (or hand-kept in lockstep with) the prose
   table** — e.g. one YAML/JSON entry per scenario, `{scenario_id, steps: [{skill, mode:
   MUST|SHOULD|MAY, ...}], final_blocker}` — so a verifier can consult it without re-parsing
   markdown prose. **Format, location, and whether it's generated-from or hand-synced-with the
   `.md` source are all open design choices, not decided here.**
3. **A lightweight, per-session skill-invocation record** — each time a skill named in the
   manifest is invoked, append a small structured entry (skill, timestamp, scenario claimed).
   **Storage mechanism is an open choice** (a session-local log, a new hook similar to the
   existing `.claude/hooks/post-task.sh`, or something else) — not decided here.
4. **A sequence-verifier step, additive to — never instead of — `quality-gate.sh`.** Immediately
   before (or as an early step inside) `quality-gate.sh`/`pre-commit-quality.sh`, compare the
   session's skill-invocation record against the manifest's `MUST` steps for the declared
   scenario. Missing a `MUST` step → **block**, same failure mode as a failing ruff/semgrep
   check today (i.e., reuse the *existing*, already-proven-non-bypassable branch-protection
   mechanism from §3 — do not invent a second, weaker enforcement path). A missing `SHOULD` step
   requires a **documented reason** attached to the commit/PR (per `SKILLS-ORCHESTRATION.md`'s
   own "skip only with documented reason" rule for `SHOULD`) rather than a hard block.
5. **`quality-gate.sh` itself is never modified to be skippable by this new check** — the design
   principle mirrors the roadmap's own ordering: sequence-verification is a **new, additional**
   gate that runs alongside/before the existing one; it does not replace or weaken it. This
   directly satisfies "quality-gate remains final layer" by construction, not by promise.

## 5. "No skill bypasses gate" — verification approach for this design

Two distinct claims must both hold, and the evidence needed for each already exists as a pattern
in this repo (§3) — the design in §4 should reuse it, not reinvent it:

1. **No normal PR merge succeeds while quality-gate's constituent checks are failing.**
   Already true today (§3, `banxe-emi-stack` required-status-check list) — the sequence-verifier
   in §4 item 4 should be **added to that same required-check list**, not built as a parallel,
   independently-bypassable mechanism.
2. **No admin-override merge silently lands a change that skipped a `MUST` skill.** Currently
   `enforce_admins: false` on `banxe-emi-stack` (§3) means this is **not fully closed today**
   even for the *existing* quality-gate checks, independent of anything S-FAC-67 adds. Flagging
   this as a pre-existing gap this task surfaced, not one it introduces — **recommend the
   operator separately decide** whether to flip `enforce_admins: true` on `banxe-emi-stack`
   (matching `banxe-architecture`'s current setting) as part of, or ahead of, any S-FAC-67
   implementation PR.

## 6. Post-recovery TODO (not executed now — allocator is down)

- **Mint the IL-shard for this runbook** once `redis-cli -h 100.68.102.48 -p 6379 -a
  "$REDIS_PASS" ping` returns `PONG` again — same procedure as the sibling S-FAC-60/S-FAC-61
  runbooks on this branch: `build_ledger.py`, confirm `added=1/mutated=0/removed=0`,
  `--check == OK`, then push and open the PR (operator-merge, §5).
- **Raise the three-source scenario-table overlap (§1) to the operator/CTIO** before any
  implementation work starts — building an enforcer against an unreconciled spec would encode
  the ambiguity into code.
- **A separate, explicitly-gated implementation PR** for the actual manifest + verifier code
  (§4) — out of scope for this DRAFT spec; this document deliberately contains no code.
- **Recommend the `enforce_admins` decision (§5 item 2)** be raised to the operator as a
  standalone, small governance decision, independent of the rest of S-FAC-67.

## 7. [UNKNOWN] — not determinable from the repository alone

- **Which of the three sources (§1a/§1b vs §1c) is authoritative going forward**, or whether
  they are meant to coexist for different situations (e.g. §1a/§1b for day-to-day dev work, §1c
  for compliance/production-deploy chains specifically). Not stated anywhere found.
- **Whether Ruflo, OpenClaw gateway-*, mlro_agent, compliance_canon_agent (§1c) are live, running
  agents today or aspirational roles** — not verified in this task (out of scope; would require
  checking `banxe-emi-stack`'s agent registry, already partially covered in earlier tasks this
  session on RED-zone agent budgets, but not cross-checked against these specific names here).
- **Exact manifest format / skill-invocation-record storage mechanism** for the §4 design — left
  as an open implementation choice.
- **Whether flipping `enforce_admins: true` on `banxe-emi-stack`** has any operational
  consequence the operator would object to (e.g. a legitimate need for an admin override in an
  emergency) — not evaluated here, flagged as a decision, not a recommendation to silently apply.
- **Whether a `.claude/hooks/` equivalent exists in `banxe-architecture`** the way it does in
  `banxe-emi-stack` — only `.claude/settings.json` was found there; no `.claude/hooks/*.sh`
  directory, unconfirmed whether that's a real gap or simply not needed for a docs-only repo.

## Duplication Audit (ADR-102)

Reused, not duplicated: `.claude/rules/agents.md` (both tables quoted/tabulated, not
reimplemented), `docs/SKILLS-ORCHESTRATION.md` + `docs/SKILLS-OPERATING-MODEL.md` (pointed to for
full MUST/SHOULD detail, not restated), `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §2 (DoD,
quoted not restated), live `gh api` branch-protection reads (evidence, not a doc to duplicate).
No existing "orchestration enforcement" spec was found anywhere in `docs/**` — this is a new,
non-duplicate artifact satisfying the S-FAC-67 DoD as a **design spec**, not an implementation.

**Refs:** `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` (S-FAC-66/67), `docs/SKILLS-MATRIX.md`,
`docs/SKILLS-ORCHESTRATION.md`, `docs/SKILLS-OPERATING-MODEL.md`, `.claude/rules/agents.md`,
`banxe-emi-stack/.claude/settings.json` + `.claude/hooks/*.sh`, `scripts/quality-gate.sh` (both
repos), GitHub branch-protection API (`banxe-architecture`, `banxe-emi-stack` `main`), sibling
runbooks `docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md`,
`docs/runbooks/S-FAC-61-health-contract-2026-07-18.md`, ADR-102.
