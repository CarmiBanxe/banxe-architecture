---
il_ts: 2026-07-01T14:00:00Z
session_id: agent-factory-governance-uiux-runtime-contract
source: CEO
status: DONE
---
### [OWNER: A] UI/UX cross-repo runtime contract — Phase P1 (contract_version 1.0.0)
- **Decision:** Authored `docs/governance/UIUX-RUNTIME-CONTRACT.md` (contract_version 1.0.0) — the machine-checkable cross-repo contract between banxe-architecture (governance, requires+consumes evidence) and banxe-ui (executes+emits envelope). References `schemas/uiux-audit-findings.schema.json` contract_version (P0, #918). Authored as governance doc (ADR-promotion to ADR-156 available if operator prefers). **PREPARE-ONLY**, Draft PR. Owner A.
- **Verified baseline (source of fact):** all banxe-ui statements verified vs **banxe-ui origin/main b9645a2 (2026-06-27)**, identical from two clones (/home/mmber/banxe-ui, /home/mmber/banxe/banxe-ui), NOT a feature branch. Written to verified reality, not assumption.
- **Existing (contract surfaces, not rebuilds):** axe-core/WCAG (4 refs + tests/a11y 2 sets + quality-gate CI) = the one HARD runtime gate, maps onto existing passing CI; Storybook 13 stories; vitest 2 configs (80% lines/70% branches). Contract requires banxe-ui to emit the P0 envelope from these already-running checks.
- **Genuine gaps (scoped, project-side, operator-gated, NOT built here):** Playwright e2e (0/no config); visual-regression (0); viewport-matrix; state-coverage; the envelope emission itself. Five remain advisory-until-built; axe-core/WCAG stays the only hard runtime gate.
- **Envelope handoff:** banxe-ui emits {contract_version,commit_sha,generated_at,results[]} per P0 schema; factory consumes read-only, checks present/valid/fresh (commit_sha matches frontend); absence/staleness ⇒ НЕИЗВЕСТНО never pass (P0 honesty boundary). Transport mechanism = [НЕИЗВЕСТНО]/P2 (default proposal: committed signed manifest read read-only; not final, operator/project choice).
- **Anti-dup (ADR-102) pointer-first:** references UIUX-AUDIT-BLOCK-SPEC §2 Layer C (#916), P0 schema+gate-policy (#918), UI-UX-DESIGN-SYSTEM-CANON (§5 WCAG, §5A taste), taste A/B/C, 7 governance docs, gates ADR-102/117/135/149 — no restatement. No new agent.
- **Boundaries:** ONLY contract doc + this shard. uiux-pipeline.sh NOT touched (P2); banxe-ui NOT touched (ADR-117 perimeter); no runners; no runtime asserted passed; feature-branch NOT passed off as main.
- **Scope/flow:** authored per #900 — doc + paired shard ATOMIC; NO hand-edit of generated ledger; NO hardcoded IL/ADR (build_ledger mints). 0 off-scope.
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main (max 767) → IL-768 via allocator (ADR-143/143-A); unique, 0 dups; 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-07-01T14:00:00Z` > main max `2026-07-01T13:00:00Z`. Fresh worktree off origin/main `9359ca2` (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — contract + shard. **DRAFT PR; DO NOT MERGE — operator HITL. Next: P2 (uiux-pipeline.sh ingest + first banxe-ui runners under operator gate).**
- **Refs:** `docs/governance/UIUX-RUNTIME-CONTRACT.md`; UIUX-AUDIT-BLOCK-SPEC.md (#916); schemas/uiux-audit-findings.schema.json + UIUX-GATE-POLICY.md (#918); UI-UX-DESIGN-SYSTEM-CANON.md; ADR-102/117/135/149; banxe-ui origin/main b9645a2; #900. Operator directive 2026-07-01 (P1).
