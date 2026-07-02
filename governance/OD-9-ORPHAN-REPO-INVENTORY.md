# OD-9 — Orphan Repository Inventory
**Date:** 2026-07-03  
**Author:** Factory Sub-Agent (Central dispatch)  
**Status:** DRAFT — For CEO/CTO Archive Decision  
**OD Reference:** CONSOLIDATION-PLAN-PHASE-2.md §9 OD-9

---

## 1. Summary

| Category | Count | Action |
|----------|-------|--------|
| CORE production | 3 | Keep — no action |
| Active platform (≤30d) | 10 | Keep — no action |
| Active legal/compliance refs | 4 | Keep — stable reference |
| ARCHIVE READY | 2 | Archive on GitHub immediately |
| ASSESS WITH OPERATOR | 3 | CEO/CTO to confirm purpose |
| Out of Banxe governance scope | 2 | No factory action required |
| Excluded from Banxe perimeter | 3 | See §6 |
| **TOTAL INVENTORIED** | **27** | |

---

## 2. CORE Production (Keep)

These repos form the regulatory and technical foundation of Banxe AI Bank. No action.

| Repo | Last update | Status | Rationale |
|------|------------|--------|-----------|
| banxe-emi-stack | 2d | ACTIVE | P0 Financial Analytics — FCA CASS 15, primary deliverable |
| banxe-architecture | 0d | ACTIVE | Architecture & governance ledger — regulatory reference |
| vibe-coding | 5d | ACTIVE | Compliance engine, AML stack — core compliance infrastructure |

---

## 3. Active Platform (≤30 days — Keep)

All repos updated within the last 30 days are under active development. No action.

| Repo | Last update | Status | Rationale |
|------|------------|--------|-----------|
| banxe-trading-frontend | 3d | ACTIVE | Trading UI — core business feature |
| banxe-trading-backend | 1d | ACTIVE | Trading backend — core business feature |
| banxe-ai-infrastructure | 0d | ACTIVE | AI infrastructure — LiteLLM + compute orchestration |
| banxe-ui | 5d | ACTIVE | UI components library |
| developer-core | 5d | ACTIVE | Developer tooling core |
| MetaClaw | 5d | ACTIVE | LiteLLM + AI compute infrastructure |
| legal-reference-fr | 5d | ACTIVE | French legal reference (active regulatory work) |
| banxe-payment-core | 11d | ACTIVE | Payment core — subject to OD-2 consolidation (separate track) |
| banxe-collaboration | 26d | ACTIVE | Collaboration tooling & infrastructure |
| factory | 25d | ACTIVE | Factory orchestration infrastructure |

---

## 4. Legal / Compliance References (Keep — Stable Content)

These repos serve as regulatory reference material. Content is stable (old commit dates are normal for reference material). Keep active for lookups and compliance evidence.

| Repo | Last update | Rationale |
|------|------------|-----------|
| france.code-civil | 81d | French civil code — RGPD/CNIL regulatory reference |
| legi_fr | 81d | French legislation reference — legislative baseline |
| legal-canon | 43d | Legal canonical reference — compliance evidence chain |
| legal-reference-fr | 5d | Active French legal reference — ongoing regulatory work |

---

## 5. Archive Recommendations

### 5a. ARCHIVE IMMEDIATELY (CEO approval requested)

Clear candidates: zero active work, explicitly named archives, or superseded infrastructure.

| Repo | Last update | Reason | Archive command |
|------|------------|--------|-----------------|
| banxe-archive-2026-04-18 | 75d | Explicitly named archive — already obsolete. Zero active commits. | `gh api -X PATCH repos/CarmiBanxe/banxe-archive-2026-04-18 -f archived=true` |
| gpt-archive-toolkit | 80d | Stale tooling for archiving. Superseded by current factory infrastructure (commit 25d). Self-referentially obsolete. | `gh api -X PATCH repos/CarmiBanxe/gpt-archive-toolkit -f archived=true` |

**Approval:** CEO/CTO signature required before archiving on GitHub. Archive by 2026-07-15.

### 5b. ASSESS WITH OPERATOR (Purpose Unknown)

Three repos have unclear purposes and have not been updated for 73-81 days. CEO/CTO to confirm whether these are active prototypes/experiments or candidates for archiving.

| Repo | Last update | Question | Recommendation |
|------|------------|---------|-----------------|
| MiroFish | 81d | Unknown purpose — active prototype/experiment? Or obsolete? | Archive unless CEO confirms active use. |
| banxe-mirofish | 80d | Unknown purpose — variant of MiroFish or separate project? | Archive unless CEO confirms active use. |
| braslina | 73d | Unknown purpose — active project? Or stale experiment? | Archive unless CEO confirms active use. |

**Action:** CEO/CTO to confirm purpose of each repo within Sprint 1 (by 2026-07-15). Default: archive if no active use case identified. File a decision ticket per repo.

---

## 6. Excluded from Banxe Perimeter

Three repositories are categorically outside the Banxe regulatory perimeter per GAP-085 and GAP-090 (scope-excluded persons/projects). These repos are NOT part of Banxe EMI stack, are NOT subject to Banxe governance, and require NO action from the Banxe factory.

**Policy:** Any legal or regulatory obligations arising from scope-excluded repos are handled outside the Banxe sandbox and do not impact Banxe compliance reporting, audit trails, or FCA regulatory submissions.

---

## 7. Out of Banxe Governance Scope

These repos are Banxe-owned but do not require factory governance action.

| Repo | Rationale |
|------|-----------|
| obsidian-vault | Personal notes — not a Banxe production repo. No governance action. |
| banxe-training-data | AI training data — operator-managed, no factory action required. |

---

## 8. Governance Notes

- **No archived repos as of 2026-07-03:** All 34 repos scanned (Central's census on 2026-07-03) are ACTIVE on GitHub.
- **Post-archive net:** After archiving 2 ready candidates, net active Banxe repos = ~32 (from 34 inventoried).
- **OD-2 overlap:** `banxe-payment-core` (11d) is active and subject to separate OD-2 consolidation track — not addressed here.
- **Excluded repos:** 3 scope-excluded repos, 0 Banxe governance action.

---

## 9. Next Steps

| Decision | Owner | Deadline | Ticket |
|----------|-------|---------|--------|
| Archive `banxe-archive-2026-04-18` + `gpt-archive-toolkit` | CEO | 2026-07-15 | OD-9-ARCH-001 |
| Assess purpose: MiroFish / banxe-mirofish / braslina | CEO/CTO | 2026-07-15 | OD-9-ASSESS-002 / 003 / 004 |
| Escalate to MLRO/Board if archive impacts compliance evidence | MLRO | 2026-07-15 | (if required) |

---

## 10. Appendix: Full Repo Census (All 34)

Generated from `gh repo list CarmiBanxe --json name,isArchived,updatedAt` on 2026-07-03.

### Active Repos by Last Update (newest first)

| Repo | Last update | Category | Status |
|------|------------|----------|--------|
| banxe-architecture | 0d | CORE | KEEP |
| banxe-ai-infrastructure | 0d | Active (≤30d) | KEEP |
| banxe-trading-backend | 1d | Active (≤30d) | KEEP |
| banxe-emi-stack | 2d | CORE | KEEP |
| banxe-trading-frontend | 3d | Active (≤30d) | KEEP |
| banxe-ui | 5d | Active (≤30d) | KEEP |
| developer-core | 5d | Active (≤30d) | KEEP |
| vibe-coding | 5d | CORE | KEEP |
| MetaClaw | 5d | Active (≤30d) | KEEP |
| legal-reference-fr | 5d | Active (≤30d) | KEEP |
| banxe-payment-core | 11d | Active (≤30d) | KEEP (OD-2 track) |
| crypto-ops-monitor | 12d | Active (≤30d) | KEEP |
| banxe-repo-template | 13d | Active (≤30d) | KEEP |
| banxe-monitoring | 23d | Active (≤30d) | KEEP |
| banxe-business-processes | 24d | Active (≤30d) | KEEP |
| factory | 25d | Active (≤30d) | KEEP |
| banxe-collaboration | 26d | Active (≤30d) | KEEP |
| banxe-lexisnexis-distro | 26d | Active (≤30d) | KEEP |
| banxe-infra | 26d | Active (≤30d) | KEEP |
| banxe-platform | 26d | Active (≤30d) | KEEP |
| legal-canon | 43d | Legal reference | KEEP |
| banxe-training-data | 50d | Out of scope | KEEP (no action) |
| braslina | 73d | Unknown purpose | ASSESS |
| banxe-archive-2026-04-18 | 75d | Archive (obsolete) | ARCHIVE |
| gpt-archive-toolkit | 80d | Archive (stale) | ARCHIVE |
| banxe-mirofish | 80d | Unknown purpose | ASSESS |
| obsidian-vault | 80d | Out of scope | KEEP (no action) |
| MiroFish | 81d | Unknown purpose | ASSESS |
| france.code-civil | 81d | Legal reference | KEEP |
| legi_fr | 81d | Legal reference | KEEP |
| [Scope-excluded repo 1] | — | Excluded (GAP-085/090) | N/A |
| [Scope-excluded repo 2] | — | Excluded (GAP-085/090) | N/A |
| [Scope-excluded repo 3] | — | Excluded (GAP-085/090) | N/A |

**Total:** 34 repos scanned.  
**Active on GitHub:** 34 repos (0 archived).  
**Banxe governance:** 27 repos.  
**Excluded from governance:** 3 repos.  
**Out of Banxe scope:** 2 repos.

---

## 11. Sign-off

| Role | Name | Approval | Date |
|------|------|----------|------|
| Factory | Sub-Agent | Draft prepared | 2026-07-03 |
| CEO/CTO | [Pending] | [Archive & assess decisions] | 2026-07-15 |
| MLRO | [Pending] | [Compliance impact review] | 2026-07-15 |

---

**Document ID:** OD-9  
**Repository:** CarmiBanxe/banxe-architecture  
**Path:** governance/OD-9-ORPHAN-REPO-INVENTORY.md  
**Version:** 1.0  
**Next review:** 2026-08-01 (post-archive confirmation)
