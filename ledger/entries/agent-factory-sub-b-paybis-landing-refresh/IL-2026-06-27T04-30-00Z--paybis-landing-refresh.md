---
il_ts: 2026-06-27T04:30:00Z
session_id: agent-factory-sub-b-paybis-landing-refresh
source: CEO
status: DONE
---
### LANDING-HANDOFF-MAIN.md refresh — current verified landing commands (docs-plane)

- **Objective:** Refresh the "👉 OPERATOR EXECUTES" section of LANDING-HANDOFF-MAIN.md with current verified state + exact ARCH/EMI landing commands for operator/MAIN. sub-B does NOT execute. Docs-plane.
- **Live audit (evidence, not memory):** ARCH branch agent/factory/paybis/neuronext-retirement-adr @ 62fd737 = 21 commits ahead (IL-545…565), ledger-build OK; ARCH origin/main IL max=560 → provisional 545…565 collide → re-id mandatory. EMI NOT pushed: wave-a-adapter @ c21bf2e, wave-a-guard @ cfe185d. nosemgrep targets verified on c21bf2e: PAYBIS-WAVE-A.md lines 6/8/28/102/153 + paybis_crypto_adapter.py line 3 contain 'neuronext' (other paybis files clean — verified). Required CI gates: guardian-factory/guardian-project/guardian-ledger/ledger-append-only; required_signatures=false (unsigned OK). This shard on the same branch; provisional IL = max+1 frozen-at-merge (Rule 8).
- **Doc update:** replaced OPERATOR EXECUTES block with current commands — ARCH landing (push → rebase linear-history → re-id build_ledger.py + --check FROM ROOT → ADR-126-vs-in-flight verify → required checks GREEN → PR/merge) + EMI landing (PRE-MERGE nosemgrep fix on exact verified lines → push guard FIRST → push adapter → quality-gate GREEN → PR/merge each) + notes (sub-B no push; signatures not required; after-landing flag-gated default OFF, live still gated SRC-06/creds/Onboarding-Fee/CASP T&C 2026-07-01/TR-MLRO).
- **Honest currency fixes:** prior section cited stale IL-545…560 / origin IL max=551 / 2-line nosemgrep list — corrected to 21 commits IL-545…565, origin max=560, full 5+1 nosemgrep line targets.
- **Perimeter / canon:** docs-plane only; sub-B does NOT push/PR/merge/execute; every SHA/IL/line cites live audit; isolated worktree off arch origin/main; sub-B hands to MAIN per §71/§74.
- **Deliverable:** LANDING-HANDOFF-MAIN.md OPERATOR EXECUTES refresh, this IL shard.
- **Refs:** ARCH 62fd737 (IL-545…565), EMI c21bf2e/cfe185d; nosemgrep grep on c21bf2e; required_signatures=false + required checks (gh-api); §71/§73/§74; ADR-126/119/114; PAYBIS-SANDBOX-STATE/GOVERNANCE-FACTS.
