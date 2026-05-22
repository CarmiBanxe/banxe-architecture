# Canon Transfer Package — EMI BANXE AI BANK

- Snapshot date: 2026-05-22
- main HEAD: e2d2f09
- Repo: CarmiBanxe/banxe-architecture

This file is the canonical snapshot used to seed a new Perplexity central
session. It replaces all previous transfer packages. It is reference-only:
everything binding lives in INSTRUCTION-LEDGER.md, ADRs, and the v2 docs in
docs/project/.

---

## 1. Binding Canon (reference, not re-explanation)

The 15 canon rules currently in force are recorded in INSTRUCTION-LEDGER.md.
Use the IL IDs below as the source of truth; do not paraphrase them in
operating use.

- IL-CANON-PERSISTENCE-SHELL-FIXATION-2026-05-12 (line 7758)
- IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12 (line 7775)
- IL-FACTORY-CLAUDE-CODE-PERMISSIONS-DOC-MANDATORY-2026-05-12 (line 7806)
- IL-CANON-TERMINALS-TOPOLOGY-AND-EXECUTION-RULE-2026-05-12 (line 7833)
- IL-CANON-FACTORY-ADDENDUM-SINGLE-OUTPUT-2026-05-12 (line 7851)
- IL-CANON-TERMINAL-B-AUTONOMOUS-FIXATION-2026-05-12 (line 7893)
- IL-CANON-EXPLICIT-TARGET-INSTRUCTION-2026-05-12 (line 7921)
- IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12 (line 7983)
- IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12 (line 8135)
- IL-CANON-IL-DEDUPE-FIX-D3-2D-2-2026-05-12 (line 8281)
- IL-CANON-SUB-B-PROMPT-VIA-FILE-2026-05-12 (line 8296)
- IL-CANON-ADR-030-ACCEPTED-FILE-STATUS-2026-05-12 (line 8314)
- IL-CANON-ALL-CLAUDE-CODE-PROMPTS-VIA-FILE-2026-05-12 (line 8377)
- IL-CANON-F01-REINFORCE-ALWAYS-ONE-ACTIONABLE-2026-05-12 (line 8444)
- IL-CANON-SOFTWARE-FACTORY-V1-INTEGRATION-ACKNOWLEDGE-2026-05-14 (line 8735)

Themes covered by these 15: Clause F-01 (one actionable artefact per
response), Factory Addendum single-output, two-layer documentation (factory
canon = Layer 1; Central IL = Layer 2), Claude Code primary with shell
fallback, terminals topology (one terminal = one project = one repo),
prompts via file, ADR file-status canon, Software Factory Canon v1.0
integration acknowledgement.

### Operator-facing house rules (stabilised in this session)

- Always specify TARGET and cwd in every artefact (e.g. TARGET = CLAUDE CODE
  TUI in ~/banxe-architecture; TARGET = LEGION bash in ~/banxe-architecture).
- One artefact per response (Clause F-01). No batched multi-artefact replies.
- Best-solution stance: propose and execute the best-known next step; do not
  wait for confirmation on micro-decisions inside a single approved task.
- Always answer the operator's question explicitly in prose before producing
  the artefact. The artefact comes after the answer, not instead of it.
- Never paste TUI menu instructions into bash. Clearly mark
  TARGET = CLAUDE CODE TUI vs TARGET = LEGION (bash) at the top of every
  prompt block.
- For docs-only PRs into main where required status checks guardian-factory
  and guardian-project physically cannot report (S14.3 PREP), documented
  admin-bypass is allowed and must be paired with an IL entry that records
  the merge, the reason for the bypass, and the systemic gap.

---

## 2. Roadmap state

### Backbone

S12–S25 is the binding delivery roadmap, approved
IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11 (line 7728). It is not
replaced by the v2 overlay.

### v2 overlay (R0–R8)

Binding anchor: IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22
(line 8775). Three source documents:

- docs/project/DELTA-ANALYSIS-LEGACY-REFACTOR-vs-CURRENT-ROADMAP.md
- docs/project/SPRINT-EXTENSION-LEGACY-REFACTOR-S12-S17.md
- docs/project/UNVERIFIED-CLAIMS-LEGACY-DISCOVERY.md

Operator-facing index: docs/project/R-TRACKS-V2-ONE-PAGER.md (merged via
PR #296, commit b681556).

IL pairing for the merge: IL-OPS-V2-ONE-PAGER-MERGED-MAIN-2026-05-22 (merged
via PR #297, commit e2d2f09). The pairing entry also records the systemic
Guardian webhook gap that forced admin-bypass.

Per-track summary (full detail in R-TRACKS-V2-ONE-PAGER.md):

- R0 DISCOVERY — gated on BANXE.RAR access; 7 unverified claims.
- R1 Redis dependency chain — PARTIAL (midaz crash-loop root cause).
- R2 IAM stabilisation — PARTIAL (KC unhealthy → healthy, JGroups note).
- R3 Observability foundation — NEW, highest priority.
- R4 Backup and DR — PARTIAL (formal matrix + restore drill + DR mirror).
- R5 Repo governance — PARTIAL (branch protection, CODEOWNERS,
  evaluate.sh scope).
- R6 Documentation — ALREADY_COVERED (8/8 D3.3.X domains).
- R7 Legal boundary cleanup — NEW (GUIYON separation).
- R8 AI / LLM platform — PARTIAL (OpenClaw version, evo2 SPOF, LiteLLM
  routing).

### Per-sprint short status (changes since 2026-05-11 flagged)

- S12 KC IAM hardening: 5/6 PREP. S12.1 DONE (KC backend Postgres).
  S12.4 realm provisioning HOLD. No change since 2026-05-11 beyond v2
  pairing.
- S13 Factory infra cleanup: 2/8 DONE. S13.7 .gitignore DONE; S13.8
  G-FACTORY-05 reclassified.
- S14 Guardian + governance: 2/5. S14.1 CH 5y TTL verified DONE. S14.3
  Guardian → GitHub webhook PREP — OPEN; this is the active pipeline
  blocker.
- S15 Security residual: 4/5 PREP. S15.1 V8 user classification blocked on
  MLRO/Legal.
- S17 Secrets rotation: PREP DONE.
- Sprint 0 (Factory bootstrap): NEW since 2026-05-11. D4 ruflo_checkpoints
  DDL DONE on evo1; CH password reset DONE (default-password.xml renamed).
  D2 (wire evaluate.sh) and D5 (workflow-service crash-loop) OPEN. Anchor:
  IL-OPS-SPRINT-0-CH-PASSWORD-RESET-RUFLO-DDL-2026-05-22 (line 8759).
- Sub-B Guardian threads: G-IAM-08 PR #135 PREP DONE; G-IAM-09 KC backup
  PREP DONE; further Sub-B work tracked in their own IL entries.
- v2 overlay artefacts NEW since 2026-05-11: three docs/project/ files
  landed via PR #295; one-pager landed via PR #296; IL pairing via PR #297.

---

## 3. Infrastructure state (verified 21–22 May 2026)

### evo1

- ClickHouse 26.4.2.10: password reset (default-password.xml → .bak),
  clickhouse-client works without password, 196 tables, ports 8123 / 9000
  / 9009 on 127.0.0.1.
- ruflo_checkpoints created (default.ruflo_checkpoints, 14 columns,
  MergeTree, TTL 5y per ADR-027, PARTITION BY toYYYYMM, EXISTS = 1).
- Guardian factory active on :8195; Guardian project active on :8196.
- Keycloak production active.
- Audit gap (last event 2026-05-11 13:25:48): root cause is the missing
  Guardian → GitHub webhook (S14.3 OPEN), not CH auth.

### Legion

- KC banxe-emi container active.
- LiteLLM active on :4000 (canonical) and :8080 (sandbox) per INV-37.
- Ollama active on :11434.
- evaluate.sh wired as pre-commit hook.
- Anthropic Claude Code API key INVALID for API-key billing; interactive
  Max-subscription login is working. Settings backed up under
  ~/.claude/settings.json.api-backup-*.

### Negative facts (known broken or absent)

- workflow-service in crash-loop (Sprint 0 D5 OPEN).
- midaz-ledger and midaz-mongodb in Exited state (R1 scope).
- Guardian → GitHub webhook not deployed (S14.3 PREP). Causes the audit
  gap and the merge-blocker on main.

---

## 4. Pipeline / branch protection reality

main branch protection:

- Required status checks: guardian-factory, guardian-project.
- strict = true.
- enforce_admins = false.
- No required reviews.
- No required signatures.

Consequence: until S14.3 (Guardian → GitHub webhook) and R3 (Observability
foundation) land, every PR into main blocks on the two guardian-* checks
because they cannot report at all. The only ways through are webhook
deployment or documented admin-bypass paired with an IL entry.

Precedents this session:

- PR #294 (Sprint 0 CH fix) — merged with --no-verify, IL pairing
  IL-OPS-SPRINT-0-CH-PASSWORD-RESET-RUFLO-DDL-2026-05-22.
- PR #296 (R-tracks one-pager) — merged with --admin, IL pairing
  IL-OPS-V2-ONE-PAGER-MERGED-MAIN-2026-05-22.
- PR #297 (IL pairing itself) — merged with --admin.

---

## 5. Open blockers (operator and external territory)

- S12.4 realm provisioning — HOLD.
- S14.2 enforce — blocked on S14.3 webhook deployment.
- S14.4 / S14.5 — blocked on Architecture WG decision.
- S15.1 V8 user classification — blocked on MLRO / Legal.
- S20 external blockers — Modulr, SumSub, Sardine, Marble, Telegram, Jube,
  MLRO appointment, Board, Internal Audit.
- R0-DISCOVERY — 7 unverified legacy claims; gated on BANXE.RAR access.
- Pipeline blocker — Guardian → GitHub webhook (S14.3) not deployed.

---

## 6. Recommended next-step priority (best-solution, ranked)

1. R3 Observability foundation + S14.3 Guardian → GitHub webhook —
   directly removes the systemic merge-blocker on main. Highest leverage.
2. R5 repo governance — clean up pre-existing pytest / ruff failures so
   evaluate.sh stops blocking docs-only commits.
3. S16.3 Redis pre-tx gate PREP — blocked on R1 Redis chain fix, but the
   PREP work itself can advance.
4. R0-DISCOVERY — start as soon as BANXE.RAR is available; 7 claims need
   VERIFIED / REJECTED status.
5. R1 Redis dependency chain — fixes midaz crash-loop at the root and
   unblocks S16.3.
6. R7 Legal boundary cleanup — GUIYON separation; non-blocking for
   production but must precede go-live.
7. Housekeeping — 2 stale worktrees (part8-adr035-deferred, v-xmrig);
   rotate the Anthropic API key created earlier this session if it remains
   valid; verify that settings.json.api-backup-* files are not committed.

---

## 7. How to use this snapshot

- Start a new Perplexity central session by pasting this file as the seed.
- Treat every claim here as a pointer to the source of truth, not as the
  source of truth itself. The source of truth is INSTRUCTION-LEDGER.md plus
  the four v2 docs in docs/project/.
- If anything in this snapshot conflicts with INSTRUCTION-LEDGER.md or an
  ADR, the IL / ADR wins.

=== END OF CANON TRANSFER PACKAGE (snapshot e2d2f09) ===
