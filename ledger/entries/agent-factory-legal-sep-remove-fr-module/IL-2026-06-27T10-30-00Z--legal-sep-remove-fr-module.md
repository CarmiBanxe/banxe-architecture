---
il_ts: 2026-06-27T10:30:00Z
session_id: agent-factory-legal-sep-remove-fr-module
source: CEO
status: DONE
---
### Legal separation residual: remove FR_MODULE.md from banxe-architecture → legal-reference-fr

- **Instrukciya:** PLAN_LEGAL_SEPARATION_2026-05-20 mandates removing legal artifacts from banking repos. FR_MODULE.md (canon/modules/FR_MODULE.md) is a personal French law reference module (criminal procedure, child custody, police deontology — guiyon/laval/SCI context; banking_refs=0). It was missed in the original separation. Task: copy to legal-reference-fr, remove from banxe-architecture, update all 7 reference files. Two PRs, neither merged.
- **Banking compliance check (VERIFIED SAFE):** FR_MODULE v3.1 — zero FCA/EMI/CASS/PSD2/AML content. Activation references in canon files (CANON.md, LEGAL.md, CORE.md) describe personal-assistant profile routing, not banking compliance rules. Safe to remove from banking repo without any regulatory or operational impact.
- **Destination decision:** `CarmiBanxe/legal-reference-fr` — "France legal reference: Code civil + Légifrance dumps". FR_MODULE content (CPP, Code civil, Code pénal, Légifrance, Judilibre, ArianeWeb) matches repo purpose. No `legal-canon` repo exists. Provenance header added to destination copy.
- **Removed:** `canon/modules/FR_MODULE.md` (DELETE, 7 pages French law procedure module, v3.1-banxe 2026-03-30)
- **References updated (7 files, no lines deleted — only annotations added):**
  - `canon/CANON.md` — tree diagram + 4 profile table entries: note → legal-reference-fr
  - `canon/modules/LEGAL.md` — §5 "Взаимодействие с FR_MODULE": added [LEGAL SEPARATION] block
  - `canon/modules/CORE.md` — KA-09 activation line: note → legal-reference-fr
  - `AGENTS.md` — 2 CANON listing lines: removed FR_MODULE.md, note → legal-reference-fr
  - `docs/COLLAB.md` — instruction hierarchy line: note → legal-reference-fr
  - `MEMORY.md` — modules table: strikethrough + [MOVED → legal-reference-fr]
- **NOT updated (historical archives):** `.sync-backup-20260406-*/` (tracked but are frozen snapshots), `docs/sessions/SESSION-2026-05-10-UNIFIED-CANON-ROADMAP.md` (historical session record).
- **GAP note:** This is a legal-separation residual found post-V12.0 verification. To be registered as GAP-087 after PR #819 (ADR-140 GAP-079..086) merges onto main.
- **Legal repo PR:** `CarmiBanxe/legal-reference-fr` — branch `add/fr-module-from-banxe` adds `modules/FR_MODULE.md` with provenance header.
- **Refs:** `canon/modules/FR_MODULE.md` (removed); `CarmiBanxe/legal-reference-fr/modules/FR_MODULE.md` (destination); PLAN_LEGAL_SEPARATION_2026-05-20; ADR-140 §RD-07 (ss1/legal domain same track); IL-603.
