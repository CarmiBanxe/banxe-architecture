---
il_ts: 2026-07-01T22:00:00Z
session_id: agent-factory-governance-banxe-ui-emitter-build-prompt
source: CEO
status: DONE
---
### [OWNER: A] banxe-ui evidence-emitter BUILD-PROMPT — transferable task for project-side construction
- **Decision:** Per operator "пиши команды — оператор исполняет", authored `docs/governance/BANXE-UI-EMITTER-BUILD-PROMPT.md` — the canonical ready-to-hand build-prompt for constructing the banxe-ui evidence-envelope emitter, derived from the emission spec (#928). This is a **TASK for the project side, executed by the operator inside the banxe-ui repo beyond the ADR-117 perimeter** — NOT banxe-ui code. **PREPARE-ONLY**, Draft PR. Owner A.
- **What to build (per prompt):** an emitter banxe-ui runs in its existing quality-gate CI that writes ONE envelope conforming to `schemas/uiux-audit-findings.schema.json` (P0, contract_version 1.0.0) to `evidence/uiux-findings.json` — the selected default transport (#928 §1), matching the factory ingest default (#921, UX_EVIDENCE_ENVELOPE fallback). Factory consumes read-only, zero config.
- **Format:** `{contract_version:"1.0.0", commit_sha, generated_at, results[]}`; each result per P0 schema (requirement/status/severity + optional artefact_ref/confidence/file_paths/impacted_flows/remediation); additionalProperties:false; severity read from UIUX-GATE-POLICY §3, not invented.
- **Proof-of-loop (first slice):** emit ONE real `axe_core_wcag_aa` result (severity blocking) with status pass/fail from the EXISTING banxe-ui quality-gate CI (axe-core+jest-axe, verified on b9645a2) — lights the hard WCAG gate end-to-end, moving ingest #921 from unknown → real pass/fail.
- **Remaining requirements:** Playwright / visual-regression / viewport / states emitted as `status: unknown` until their runners exist (separate project-side slices) — NOT asserted passed.
- **Freshness (P0 honesty boundary):** commit_sha = frontend commit; stale ⇒ factory treats as unknown, never pass.
- **Acceptance (project terminal):** envelope schema-valid; commit_sha fresh; ingest #921 moves axe_core_wcag_aa unknown → real pass/fail; other requirements remain unknown correctly. Factory verifies read-only.
- **[НЕИЗВЕСТНО]:** exact envelope placement inside the banxe-ui tree; the CI step/job that generates+commits it; if/when to strengthen to a signed manifest — all project-side decisions, not invented.
- **Boundaries:** NO banxe-ui code; banxe-ui repo NOT touched; P0 schema NOT touched; uiux-pipeline.sh ingest NOT touched; policy/spec NOT touched. Only this build-prompt + shard. 0 off-scope. Baseline of fact: banxe-ui origin/main b9645a2 (2026-06-27, two clones).
- **Anti-dup (ADR-102) pointer-first:** references emission-spec #928, runtime-contract #920, P0 schema+policy #918, ingest #921, ADR-117 — restates none; no parallel spec/schema, no code.
- **Scope/flow:** authored per #900 — doc + paired shard ATOMIC; NO hand-edit of generated ledger; NO hardcoded IL (build_ledger mints, ADR-119 Rule 8). Re-mint discipline if mid-session collision: reset onto origin/main + regenerate; recreate shard AFTER reset (lesson #933).
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main (max 790; #938/IL-790 landed mid-session → re-mint, 790 retained) via allocator (ADR-143/143-A); unique, 0 dups; 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-07-01T22:00:00Z` > main max. Fresh worktree off origin/main (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — build-prompt + shard. **DRAFT PR; DO NOT MERGE — operator HITL. Next: operator hands this build-prompt to the project side to construct the emitter inside banxe-ui under the ADR-117 gate; then the 4 runner slices.**
- **Refs:** `docs/governance/BANXE-UI-EMITTER-BUILD-PROMPT.md`; UIUX-EVIDENCE-EMISSION-SPEC.md (#928); UIUX-RUNTIME-CONTRACT.md (#920); schema + UIUX-GATE-POLICY.md (#918); uiux-pipeline.sh ingest (#921); ADR-102/117; #900. Operator directive 2026-07-01 (fix transferable banxe-ui emitter build-prompt).
