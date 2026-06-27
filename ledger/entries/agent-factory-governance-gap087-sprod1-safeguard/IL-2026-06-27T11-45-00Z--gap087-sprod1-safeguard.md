---
il_ts: 2026-06-27T11:45:00Z
session_id: agent-factory-governance-gap087-sprod1-safeguard
source: CEO
status: DONE
---
### docs(governance): GAP-087 S-PROD-1 Safeguarding P0-OVERDUE + ADR-140 Amendment 1 [IL-606]

- **Instrukciya:** S-PROD-1 Safeguarding Engine (J-engine/J-audit/E-safeguard, FCA CASS 15) was NOT captured in ADR-140 (GAP-079..086). ROADMAP-STATUS-2026-06-23.md:69 confirms P0 OVERDUE (deadline 2026-05-07). Add GAP-087 (next free after GAP-086 in PR #819) to GAP-REGISTER, append Amendment 1 to ADR-140, update INDEX.md. Note: distinct from ClickHouse-auth fix (done this session) and from GAP-003/004 (code-complete). ADR-060 branch; no merge; build_ledger --check exit 0.
- **Preflight (read-only):** Branch `agent/factory/governance/gap087-sprod1-safeguard` (id=`governance`, ADR-060 compliant). Origin/main HEAD = ad3f2f1 (IL-605 LEDGER-MERGE-QUEUE, PR #823). ADR-140 confirmed present (PR #819 merged). GAP-079..086 confirmed present. Max il_ts = 2026-06-27T11:15:00Z. This shard il_ts = 2026-06-27T11:45:00Z (strictly greater). Max IL = 605; this shard → IL-606.
- **GAP-087 (`docs/GAP-REGISTER.md`, MODIFIED — append only):** New section "S-PROD-1 Safeguarding Production Residual — ADR-140 Amendment 1" appended with 1 row: GAP-087 S-PROD-1 production delivery OVERDUE (P0 FCA blocker). Full evidence, distinction from GAP-003/004/005 and from 2026-06-27 ClickHouse-auth fix, fix-path in 5 steps. Footer updated to include GAP-087.
- **ADR-140 Amendment 1 (`docs/adr/ADR-140-residual-debt-register-v12.md`, MODIFIED — append only):** Section "## Amendment 1 — 2026-06-27: S-PROD-1 Safeguarding Production Residual (GAP-087)" appended after References. RD-09 · S-PROD-1 with full evidence table, fix-path, regulatory basis (CASS 15 §7.15 / PS25/12 / CASS 7.15.5). No prior content deleted.
- **INDEX.md (`docs/adr/INDEX.md`, MODIFIED):** ADR-140 row description updated from "8 non-technical debts" → "8 non-technical debts + Amendment 1: S-PROD-1 GAP-087".
- **Key distinction (recorded for canonical clarity):** GAP-003 (J-engine ✅ DONE code-complete IL-SAF-01 v1) + GAP-004 (J-audit ✅ DONE) + GAP-005 (E-safeguard 🟡 IN PROGRESS) + 2026-06-27 ClickHouse-auth fix (banxe-recon exit=0) do NOT collectively constitute CASS 15 production-readiness. GAP-087 = the remaining production delivery: 3-leg tie-out (A==B==C), Midaz production hook, shortfall auto-FCA. Active work: banxe-emi-stack `agent/factory/safeguarding/wire-3leg-agent` PR #218.
- **Proof:** `build_ledger.py` exit 0; `--check` exit 0; semgrep 0 findings. Append-only: GAP-REGISTER section + ADR-140 section added, no rows deleted. Branch per ADR-060.
- **Status:** DONE — GAP-087 registered; ADR-140 Amendment 1 canonised. DO NOT MERGE — operator review required.
- **Refs:** `docs/GAP-REGISTER.md` (GAP-087 appended); `docs/adr/ADR-140-residual-debt-register-v12.md` (Amendment 1 appended); `docs/adr/INDEX.md` (ADR-140 row updated); `docs/ROADMAP-STATUS-2026-06-23.md:69` (S-PROD-1 evidence); `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` + `E-SAFEGUARD-CASS15-SPEC.md` (specs); banxe-emi-stack PR #218 (active wire-3leg-agent); ADR-056/057/060 (ledger/branch conventions); I-24 (append-only).
