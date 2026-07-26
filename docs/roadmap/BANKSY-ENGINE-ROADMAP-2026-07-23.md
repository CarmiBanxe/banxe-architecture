# Banksy Engine — Roadmap — 2026-07-23

**BANK CORE / BANKSY ROADMAP / DOCS-ONLY / NO COMMIT**
Records the factory→Banksy wave-1 handoff (as reported by the factory) and the next sprint sequence. §0 is recorded per the factory handoff report; all items are untracked and reversible.

## §0 STATUS — factory→Banksy handoff wave 1 (COMPLETED, untracked, reversible)

Recorded as a completed fact (docs-only, no secrets, everything untracked/reversible). The factory delivered the first patchset to Banksy; filtered-accepted:

- **`.mcp.json`** — schema bug fixed: added `mcpServers` wrapper, registered Banxe MCP (`banxe_mcp.server`) in merged-repo/banxe-emi-stack format. **Status:** config present, but auto-import of `banxe_mcp.server` **not yet wired** (decision needed: editable install / PYTHONPATH / vendoring / separate service) → **`[pending wiring]`**.
- **`.claude/rules/`** — accepted domain-agnostic governance rules from merged-repo: global standards, git-workflow, tests, docs, incidents, MCP-tools, AI-agents, frontend, session-continuity. **ACCEPTED** (applicable to Banksy).
- **`.claude/rules/` deferred as reference-only (NOT active):** `financial-invariants.md`, CASS15, `compliance-boundaries` — bank regulatory canon, not to be forced onto Banksy's art layer.
- **`.claude/agents/`** — accepted universal: `code-guardian`, `researcher`, `ui-sync`. Deferred reference-only: `reporting-agent`, `reconciliation-agent` (bank-specific; activate only if Banksy enters that domain).
- **`.claude/skills/`** — A-state installed: `apple-design`, `scroll-world` (physically present, used as in the source environment).
- **`CLAUDE.md`** — Banksy identity fixed; separated A-state runtime skills (apple-design, scroll-world) vs written-standard (Hermes-authoring); flagged rules from Banxe canon needing adaptation.

**Risks / open (explicit):**
- Everything **untracked**, zero git commits, fully **reversible**.
- `banxe_mcp.server` not auto-imported yet → **`[pending wiring]`**.
- Imported rules/agents still contain Banxe names/paths (INSTRUCTION-LEDGER, banxe-architecture, IL-ID) → **`[pending adaptation]`** before full Banksy independence from EMI.
- Heavy repos (factory, banxe-*, MetaClaw, vibe-coding) marked **VERIFY-IN-REPO** — files not pulled in (audit-first honoured).

**§0 conclusion:** Banksy is **not an empty sandbox** — it has canon/agents/skills — but **without code-stack binding and without direct Banxe MCP launch**. Correct for wave 1: reversible and safe.

## §1 Sprint sequence

### S-B0 (NEXT) — close optional spot-checks
- `banxe-payment-core` (~6 agents), `developer-core` (~2), `vibe-coding` (~4), `MiroFish` (~1).
- Goal: confirm these are mirrors / non-new; any genuinely new agent → census → BANK-MASTER.
- Non-blocking, but closes "nothing left at all" before engine launch. (Ref: `../audit/BANKSY-COVERAGE-CLOSURE-2026-07-23.md`.)

### S-B1 (BIG STEP) — real build + launch of the Banksy Engine THROUGH THE FACTORY
- Factory builds production code: heart-32 + Legion-adopted (decision-framework / memory / tool-framework) + config pattern; **without** TOR / scrape / RL / direct-Legion-inference.
- Run through Reviewer + Canon-Guardian + Factory-Watchdog + install-audit + HITL-L4.
- Status **ONLINE only** on a green health-check (process + port live, 0 secrets, Legion external-only, all gates PASS).
- Relies on: `../architecture/BANKSY-ENGINE-BUILD-SPEC-FOR-FACTORY-2026-07-23.md` + `../architecture/BANKSY-LEGION-HARVEST-SPEC-2026-07-23.md`.

### S-B2 (after launch) — wiring + adaptation
- Wire `banxe_mcp.server` import (`[pending wiring]` — pick editable install / PYTHONPATH / vendoring / separate service).
- Adapt rules/agents to the Banksy context (strip Banxe paths / IL-ID) (`[pending adaptation]`).
- Activate deferred reference-only agents if Banksy enters their domain.

## §2 Gated / open
- `[counsel]`: Midaz/MCP→ledger; Banksy↔Legion data-flow.
- `[pending human ratification]`: AML-passport dedup; `executor.py`; expansion-agents.

## Notes
- §0 recorded per the factory handoff report (docs-only); nothing verified/modified by this roadmap beyond recording.
- Everything untracked and reversible; nothing committed.

---
**This does not replace legal advice.**

## S-B0 UPDATE — 2026-07-23 (CLOSED)

S-B0 spot-check result: **3 new bank agents found** (not mirrors) → BANK count **129 → 132** (Payments/FX-Exchange/Wallet ADR-049 §D3 masks; series now complete). Dev-tooling agents (policy/workflow/review) → FACTORY `[dev-tooling, not bank]`; vibe-coding = factory dev/training pipeline; MiroFish report_agent = out-of-bank app. **S-B0 CLOSED** after the additions. Next: S-B1 (build + launch through factory). Refs: `../audit/SB0-NEW-BANK-AGENTS-2026-07-23.md`.


---
> **SUPERSEDED (2026-07-23):** consolidated into the single **GENERAL-LINE** roadmap → `../roadmap/GENERAL-LINE-ROADMAP-2026-07-23.md` (see its §4 mapping / §5 register). This file is retained for history; the GENERAL-LINE is the source of truth. IL-ledger unaffected.
