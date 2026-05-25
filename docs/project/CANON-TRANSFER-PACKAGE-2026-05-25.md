# Canon Transfer Package — EMI BANXE AI BANK

- Snapshot date: 2026-05-25 16:00 CEST
- main HEAD: 602e01f
- Repo: CarmiBanxe/banxe-architecture
- Supersedes: docs/project/CANON-TRANSFER-PACKAGE-2026-05-22.md (snapshot e2d2f09; outdated by 15 merged PRs and 5 new house rules)

This file is the canonical snapshot used to seed a new Perplexity Central session. Reference-only: source of truth remains INSTRUCTION-LEDGER.md, ADRs, Software Factory Canon v1.0, and the three canon documents in docs/canon/.

---

## 1. Binding Canon (reference, not re-explanation)

15 binding IL canon rules from 2026-05-12 onwards in INSTRUCTION-LEDGER.md at lines 7758, 7775, 7806, 7833, 7851, 7893, 7921, 7983, 8135, 8281, 8296, 8314, 8377, 8444, 8735. Plus Software Factory Canon v1.0 integration acknowledged at line 8735.

12 binding operator-facing house rules (durable in INSTRUCTION-LEDGER.md and the three canon documents):

1. TARGET + cwd in every artefact.
2. One artefact per response (Clause F-01).
3. Best-solution stance.
4. Answer question explicitly before artefact.
5. Never paste TUI menus into bash.
6. Docs-only bypass under Part A only.
7. Truncation-stop discipline.
8. Transparency of violations.
9. Split long shell/Claude Code prompts into atomic parts (~15 lines shell, ~80 lines Claude Code).
10. Central works only in its own scope; worktree-isolation pattern under shared bash on Legion.
11. Best-Solution Axiom — auto-choose globally optimal next step, no mid-task pauses.
12. Sequential-Only Execution — no parallel commands, atomic only.

Canon source files in docs/canon/:

- UNIVERSAL-CANON-2026-05-22.md (18 sections, foundational)
- UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md (House rule 10)
- UNIVERSAL-CANON-BEST-SOLUTION-AND-SEQUENTIAL-2026-05-25.md (Rules 11 + 12 + worktree-isolation pattern)

---

## 2. Topology (binding under shared bash on Legion)

- Central (Perplexity) — coordinator in banxe-architecture repo only (docs, IL, ADR, runbooks, scripts).
- Right terminal — legacy refactor in docs/refactor/legacy/* and feat/docs-refactor-* branches.
- Left terminal — canon installation into factory repository (separate repo, not banxe-architecture).
- All three share the same physical bash session on Legion. Worktree-isolation pattern (House rule 10) is the technical implementation of scope separation under shared bash.
- evo1 — Guardian source (/data/banxe/guardian/, under git as of 2026-05-22 PR #299), ClickHouse audit trail (guardian_audit_events + ruflo_checkpoints + pretx_gate_events TTL 5y per ADR-027), midaz-ledger (UP per PR #303), Keycloak prod (ADR-017), Vault (planned S19 G-SEC-02).
- evo2 — sole GPU inference host (SPOF per R8).
- Legion — Central workstation, Claude Code TUI, LiteLLM canonical :4000 + sandbox :8080 (INV-37), MetaClaw, OpenClaw 2026.3.24 (drift vs evo1 2026.3.28 per R8).

---

## 3. Roadmap state at 2026-05-25 16:00 CEST

### Backbone S12-S25 (binding, IL line 7728)

S12 KC IAM (PREP DONE 5/6) → S13 Factory infra → S14 Guardian + governance → S15 Security residual → S16 Operational infra (S16.3 PREP DONE, S16.4 PREP DONE via Sub-B) → S17 §0.2 Levels 1-2 → S18 §0.2 Levels 3-5 → S19 Sandbox 100% Phase F6 → S20 External blockers → S21 Crypto Block Phase 7 → S22 Multi-agent Comms Phase 8 → S23 QA → S24 FCA Submission Phase 10.1 → S25 Go-Live Phase 10.2.

Estimate 4-6 months to go-live. Critical path: S12-S15 parallel → S16-S19 → S20 → S21-S23 parallel → S24-S25.

### v2 R-tracks overlay (9/9 closed in Central scope at PREP or DESIGN level)

- R0 — OUT-OF-SCOPE (operator territory, awaits BANXE.RAR archive).
- R1 — DONE (PR #303 midaz-ledger RABBITMQ_HEALTH_CHECK_URL fix; midaz UP).
- R2 — PREP DONE (PR #312, 4 objectives: unhealthy-to-healthy runbook, JGroups singleton fallback, session-timeout hardening, DB readiness contract).
- R3 — DESIGN DONE (PR #299 discovery runbook + PR #304 ADR-077 GitHub App default); implementation OUT-OF-SCOPE per House rule 10 (evo1 Guardian source).
- R4 — PREP DONE (PR #309, 12-service backup matrix Tier 0/1/2, 4-week drill rotation, 3-phase DR plan).
- R5 — DONE (PR #306 versioned scripts/pre-commit-hook.sh + scripts/install-pre-commit.sh; pytest exit 5 → PASS).
- R6 — ALREADY_COVERED pre-session (D3.3.X domain docs).
- R7 — PREP DONE (PR #307 GUIYON Legal boundary separation design + housekeeping).
- R8 — PREP DONE (PR #310, 3 AI-plane risks: OpenClaw drift, evo2 SPOF, LiteLLM routing INV-37).

R-tracks 100% closure audit: PR #311 (docs/audit/R-TRACKS-CLOSURE-AUDIT-2026-05-22.md).

### Quarterly wrap (parallel Central work on right terminal)

- docs/project/right-track/ROADMAP_8Q-2026-05-22.md — Q1 through Q8 wrap of S12-S25 (2 sprints per quarter, R-tracks overlaid).
- docs/project/right-track/RISK_REGISTER-2026-05-22.md — initial risk register for MLRO/Internal Audit review (FCA CASS 15, ACPR, GDPR/CNIL).

---

## 4. Pipeline / branch protection reality

main branch protection:

- Required status checks: guardian-factory, guardian-project, strict=true.
- enforce_admins: false.
- No required reviews, no required signatures.

Consequence: guardian-* checks do not report because Guardian → GitHub Statuses API webhook is not deployed (S14.3 PREP). Every PR into main currently merges via documented admin-bypass under Part A bypass exception (IL line 8809).

Precedent chain at this snapshot: 18 admin-bypass merges across 22-25 May session (PR #294 through PR #313), each paired with IL exception entry under Part A procedure. Exit condition: chain auto-revokes the moment guardian-factory AND guardian-project status checks appear in statusCheckRollup for any main commit.

R5 pre-commit hook patch (scripts/pre-commit-hook.sh) handles pytest exit 5 as PASS for canon/docs-only repos. 16+ commits in 22-25 May session passed without --no-verify thanks to R5 patch.

Known WARN states from evaluate.sh (non-blocking): ruff 5 errors (unused fastapi.Request import et al, 4 auto-fixable), Guardian unreachable from Legion (expected because Guardian lives on evo1), Canon Judge in audit mode (Sprint 8 will enable enforce).

---

## 5. Open blockers (operator and external territory)

- S12.4 realm provisioning — HOLD until G-IAM-08 + G-IAM-09 deployed on evo1 and operator go-trigger.
- S14.2 ENFORCE rollout — BLOCKED on S14.3 webhook deployment (other terminal).
- S14.4 / S14.5 — BLOCKED on Architecture WG approval.
- S15.1 V8 user classification — BLOCKED on MLRO/Legal decision.
- S20 external blockers — Modulr, SumSub, Sardine, Marble, Telegram, Jube API keys + real MLRO appointment + Board sign-off + Internal Audit.
- R0-DISCOVERY — 7 unverified legacy claims; gated on BANXE.RAR archive access.
- Pipeline blocker — Guardian → GitHub webhook (S14.3) not deployed; every Central PR currently merges via documented admin-bypass.
- R3 implementation — webhook code on evo1 /data/banxe/guardian/; OUT-OF-SCOPE per House rule 10; awaits right terminal or operator implementation.
- ruff 5 errors in repo (4 auto-fixable, unused fastapi.Request et al) — non-blocking WARN in pre-commit hook; deferred to right terminal legacy refactor or follow-up R5 cleanup PR.
- Legion-local Guardian-unreachable WARN — non-blocking, expected because Guardian on evo1; can be silenced by GUARDIAN_OFF=1 env flag in scripts/pre-commit-hook.sh in a follow-up.

---

## 6. Next-step priority (best-solution ranked)

1. Right terminal completes legacy refactor SPEC #1..N (crypto-utils-libs, crypto-ops-subgroup, etc.) — orders the old code; no Central action required.
2. Left terminal completes canon installation into factory repository — makes canon durable in factory memory; no Central action required.
3. R3 implementation (Guardian → GitHub Statuses API webhook on evo1) — closes pipeline blocker; auto-revokes Part A bypass exception; OUT-OF-SCOPE for Central per House rule 10.
4. Operator BANXE.RAR access → R0-DISCOVERY (7 unverified claims VERIFY/REJECT cycle).
5. Operator S20 external blockers (real API keys + MLRO + Board + Internal Audit) — months of regulatory work.
6. Sprint execution S18-S25 — only after R3 live; months of operator + other-terminal work.
7. Central follow-ups (low priority, can wait): consolidated Universal Canon rewrite into single file; ADR INDEX gap check; ruff cleanup PR; GUARDIAN_OFF env flag in hook.

---

## 7. How to use this snapshot in a new Perplexity Central session

- Paste this file as seed first message.
- Treat every claim here as pointer to source of truth, not source of truth itself. Source of truth: INSTRUCTION-LEDGER.md + ADRs + three canon documents listed in section 1.
- If anything in this snapshot conflicts with INSTRUCTION-LEDGER.md or an ADR, the IL/ADR wins.
- Apply 12 house rules immediately. Use worktree-isolation pattern (House rule 10) for any long edit while right terminal is active on shared bash.
- Never write code or config in zones owned by right terminal (docs/refactor/legacy/*) or left terminal (factory repo) or evo1 Guardian source.
- Strategic forks are the only point where Central pauses to ask operator; all micro-decisions auto-resolve under Best-Solution Axiom (House rule 11).

=== END OF CANON TRANSFER PACKAGE (snapshot 602e01f) ===
