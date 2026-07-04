---
il_ts: 2026-07-03T10:00:00Z
session_id: agent-factory-consolidation-sprintb-provenance-guardrail
source: CEO
status: DONE
---
### [OWNER: A] Sprint-B install-provenance guardrail — doc-only addendum to FRAMEWORK-ADOPTION-SPRINT-B (#992); nothing installed
- **Decision:** Per operator, appended **"## Install Provenance Guardrail"** to `docs/governance/FRAMEWORK-ADOPTION-SPRINT-B.md` (#992, canonical Sprint-B doc, verified on main) + this paired shard mirroring the guardrail. Doc-only, additive (append before Anchors; existing §1-5 preserved, <50% change). NO install/package-pull/registry-query; NO passport/ADR/config/secret/auth edited; NO provenance invented (all from operator engine-install-audit read + local repo docs). **PREPARE-ONLY**, Draft PR. Owner A.
- **Guardrail (mirror, concise):**
  - **openclaw** = npm steipete/vincentkoc (2026.3.24) — **trusted**.
  - **aider** = pipx **`aider-chat`** (0.86.2), NOT `aider` — **trusted** (real package name = aider-chat).
  - **metaclaw** = pipx venv — **trusted**.
  - **mirofish** = local repo `~/MiroFish` build-from-local (Dockerfile/docker-compose/backend/frontend/package.json; source CarmiBanxe/MiroFish) — **source-identified, LOCAL-ONLY** (do not substitute a registry package; `~/banxe-mirofish` = different docs/scenarios repo).
  - **hermes** = **no verified source** — BANXE ADR-126 Hermes is a canon ROLE, not a public package; public npm hermes = Segment's, pip hermes 0.9.1 = unknown → **do NOT install any public `hermes`**.
  - **nanoclaw** = pip 2026.3.20, publisher unverified → **[BLOCKING: operator]** verify openclaw-family before install.
  - **ironclaw** = npm 2026.2.22-1.3.1 publisher kumareth → **do NOT install** (wrong publisher / impersonation).
- **Policy recorded:** public package-name match ≠ sufficient provenance; no install without verified publisher/source + license-review (ADR-148 no-import-without-license-review; CLAUDE.md §9); wrong/unknown-publisher matches BLOCKED; local-source origin stays local-source.
- **CHECKLIST (new, Sprint-B install prompts MUST respect):** before ANY package pull for a Sprint-B engine, the install prompt MUST (1) confirm the source matches the verified publisher/local-origin in the guardrail; (2) reject wrong-publisher (ironclaw) and unknown-publisher (nanoclaw/public-hermes); (3) build mirofish from local `~/MiroFish` only; (4) treat hermes as canon-role (no public install); (5) satisfy ADR-148 license-review + CLAUDE.md §9 HITL. No pull proceeds until all pass.
- **Boundaries:** ONLY FRAMEWORK-ADOPTION-SPRINT-B.md (additive §6 guardrail) + this shard. NO install; NO registry query beyond local docs; NO passport/ADR/config/secret/auth edit; NO provenance invented; existing text preserved (append-only, <50%); no install instruction for blocked items (hermes/ironclaw/nanoclaw). 0 off-scope.
- **Anti-dup (ADR-102) pointer-first:** appends to #992's own doc (additive guardrail) — no parallel doc, restates none; cites ADR-148 (license-review), CLAUDE.md §9, #982 (host-audit baseline). Evidence = operator engine-install-audit read (2026-07-03) + local repo docs.
- **Scope/flow:** authored per #900 — doc + paired shard ATOMIC; NO hand-edit of generated ledger; NO hardcoded IL (build_ledger mints, ADR-119 Rule 8). ⚠️ redis degraded → local mint; if collision reset+re-mint (L-06), shard after reset (L-05).
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main via allocator (ADR-143, DEGRADED local); unique at author time; 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-07-03T10:00:00Z` > main max. Fresh worktree off origin/main (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — guardrail addendum + shard. **DRAFT PR; DO NOT MERGE — operator HITL. Must land before any operator install activity. Blocked installs (hermes/ironclaw) + [BLOCKING] nanoclaw remain operator-gated; mirofish local-build + aider(aider-chat) are the verified-safe sources.**
- **Refs:** `docs/governance/FRAMEWORK-ADOPTION-SPRINT-B.md` (#992); ADR-148 (no-import-without-license-review); CLAUDE.md §9; #982 (host-audit); ADR-102/119/143/144; #900. Operator engine-install-audit + directive 2026-07-03 (install-provenance guardrail; install nothing; doc-only; no auth bypass).
