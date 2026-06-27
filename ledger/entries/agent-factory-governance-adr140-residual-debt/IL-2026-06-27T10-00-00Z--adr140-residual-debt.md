---
il_ts: 2026-06-27T10:00:00Z
session_id: agent-factory-governance-adr140-residual-debt
source: CEO
status: DONE
---
### ADR-140 Residual Debt Register — Concept v12.0 Verification (8 non-technical gaps GAP-079..086)

- **Instrukciya:** Canonize all residual non-technical debts from Concept v12.0 16/16 verification session. All factory-fixable technical debts previously resolved. 8 operator/business/legal/org debts remain. Create ADR-140 as the governance register; append GAP-079..086 to docs/GAP-REGISTER.md; include ufw safe-sequence as Appendix A. Branch per ADR-060. No merge, no guardian bypass.
- **Preflight (read-only):** Next ADR slot = 140 (max used = 139). Last GAP = 078 (actual, not 059 as stated in task). Main HEAD at time of branch = 3355cd1. Fresh max il_ts on origin/main = 2026-06-27T09:30:00Z (ADR-139 shard). This shard il_ts = 2026-06-27T10:00:00Z (strictly greater).
- **ADR-140 (`docs/adr/ADR-140-residual-debt-register-v12.md`, NEW):** ACCEPTED. 8 residual debts registered: RD-01 C-02.1 currency mismatch (P1-product), RD-02 C-37.3 Intent-First not implemented (P1-product), RD-03 AGPL-boundary (P1-legal), RD-04 R-09.14 ufw/ports missing (P1-security), RD-05 R-09.15 Tailscale ACL (P2-network), RD-06 R-16.1 bus factor=1 (P2-org), RD-07 ss1 GDPR exposure (P2-legal), RD-08 self-hosted-runner (P3-infra). Appendix A: ufw safe-sequence (5-step install/allowlist/reload for Legion host). Cross-references: GAP-079..086.
- **GAP-REGISTER (`docs/GAP-REGISTER.md`, MODIFIED — append only):** Appended 8 rows GAP-079..GAP-086 in new section "V12.0 Verification — Residual Non-Technical Debts (ADR-140)". No prior rows deleted or modified.
- **INDEX (`docs/adr/INDEX.md`, MODIFIED):** ADR-140 row inserted; factory governance count updated 18→19.
- **Proof:** New files + this shard; INSTRUCTION-LEDGER.md regenerated via `python3 ledger/build_ledger.py`; `--check` exit 0. Append-only: tail-append only on GAP-REGISTER and INDEX. Branch `agent/factory/governance/adr140-residual-debt` matches ADR-060 pattern.
- **Status:** DONE — ADR-140 canonized; 8 non-technical debts registered; GAP-REGISTER extended to GAP-086. DO NOT MERGE — operator review required for debts requiring physical/console access (GAP-082 ufw, GAP-083 Tailscale ACL, GAP-085 GDPR notification).
- **Refs:** `docs/adr/ADR-140-residual-debt-register-v12.md` (NEW); `docs/GAP-REGISTER.md` (GAP-079..086 appended); `docs/adr/INDEX.md` (updated); ADR-139 (prior slot, Guardian system); ADR-056/057/059/060 (ledger/shard/branch conventions); I-28 (append-only).
