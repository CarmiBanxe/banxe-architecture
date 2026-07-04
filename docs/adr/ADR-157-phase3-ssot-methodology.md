# ADR-157 — Phase 3 SSOT: Methodology and Per-Domain Source of Truth
**Date:** 2026-07-04  
**Status:** Accepted  
**Deciders:** Factory (Central dispatch)  
**Replaces:** N/A  
**Superseded by:** N/A  
**References:** ADR-156 (Sandbox mode), ADR-005 (Protocol DI), ADR-120/121 (worktrees), GLOBAL-PROGRAM-PLAN.md §3  

---

## Context

Phase 1 (census) and Phase 2 (consolidation analysis) confirmed seven duplicate-trap artifacts spanning three repositories. Phase 2 produced resolution packages for all seven traps (T2.1–T2.6, OD-1–OD-9 series, merged 2026-07-03). Phase 3 opens with no outstanding duplicate conflicts.

Phase 3's mandate per GLOBAL-PROGRAM-PLAN.md §3 is:

> SINGLE SOURCE OF TRUTH (SSOT) — Unified domain map, service registry, agent passport authoritative location; migration plan from 3-repo to 2-repo stable state.

This ADR establishes:
1. The methodology for declaring and maintaining SSOT per domain.
2. The canonical location for each domain's SSOT record.
3. The classification rules distinguishing research artifacts from production implementations.
4. The governance protocol for future SSOT updates.

---

## Decision

### D-1: SSOT Methodology — Two-Tier Classification

Every code artifact in the Banxe AI Bank system is classified as exactly one of:

| Tier | Name | Definition | Repo | Example |
|------|------|------------|------|---------|
| T-A | **Production SSOT** | FCA-regulated, HITL-gated, append-only audited, deployed to evo1/evo2 | banxe-emi-stack | `services/aml/tx_monitor.py` |
| T-B | **Research Reference** | Prototype, no HITL gate, no regulatory submission path, may be archived | vibe-coding (→ archive) | `vibe-coding/src/compliance/tx_monitor.py` |

**Rule:** Only T-A artifacts are authoritative. T-B artifacts are cited for design context only.  
**Rule:** Any T-B artifact that has an equivalent T-A artifact in banxe-emi-stack MUST be classified in a governance document (OD series) before vibe-coding is archived.  
**Rule:** No T-B artifact may be imported into any T-A service. Zero cross-repo coupling is a hard invariant.

### D-2: Per-Domain SSOT Registry

The canonical per-domain SSOT registry lives at:

```
banxe-architecture/governance/PHASE-3-SSOT-PLAN.md  §3
```

This file is:
- **Append-only** (I-24) — amendments via AMENDMENT-NNN sections only.
- **Operator-approved** — changes require PR to banxe-architecture main branch.
- **Updated when** a domain changes canonical repo, path, or operational status.

### D-3: Agent Passport SSOT

**Canonical location:** `banxe-architecture/docs/STAFF-MATRIX-v3.md`

Protocol:
1. Every agent (activated or PROPOSED) has exactly one passport row in STAFF-MATRIX-v3.
2. New agents are added as PROPOSED; activation requires L4 HITL sign-off per agent-authority.md.
3. In Sandbox mode (ADR-156), factory may register and test PROPOSED agents without sign-off; production promotion still requires MLRO attestation.
4. Passport schema: `.soul.md` file at `agents/compliance/soul/<agent-name>.soul.md` (rule 80-ai-agents.md).

### D-4: Service Registry SSOT

**Canonical location:** `banxe-emi-stack/infra/DEPLOYMENT-MANIFEST.md`

This file is the single authoritative registry of:
- Which services exist and their roles.
- Node assignment (evo1 vs evo2).
- Port allocation.
- Health check endpoint and strategy.
- External API key dependency (BT-NNN reference).

Updates to `DEPLOYMENT-MANIFEST.md` follow append-only discipline for stability records. Node reassignments require factory task (not direct edit).

### D-5: 3-Repo → 2-Repo Target State

**Target:** banxe-architecture (governance) + banxe-emi-stack (production). vibe-coding → GitHub Archive.

**Conditions for archive:**
- All OD-resolution packages merged (OD-1 through OD-7, OD-9).
- Zero cross-repo imports verified (grep test).
- Operator executes GitHub Archive action (operator action, not factory).

**Post-archive:** Any reference to research artifacts redirects to archived repo URL + pinned snapshot citation in MASTER-ORG-CODE-RUNTIME-DOSSIER.md §3.

### D-6: Duplicate Classification Protocol (for future discoveries)

If a new duplicate is discovered after Phase 3, the factory follows this protocol:

1. Add entry to `docs/GAP-REGISTER.md` as GAP-NNN (type: SSOT-CONFLICT, severity: HIGH/MEDIUM/LOW).
2. Produce a T2.N analysis document under `governance/T2.N-OD-N-*.md` using the same pattern as T2.1–T2.6.
3. Classify as T-A (production SSOT) vs T-B (research reference) using D-1 criteria.
4. If code change needed (retire, port, or merge): open PR to the relevant repo; link GAP entry.
5. Close GAP after PR merges and PHASE-3-SSOT-PLAN.md §3 is updated (via amendment).

### D-7: SSOT Governance Repository

`banxe-architecture` is the **governance SSOT repository**. It owns:
- Instruction Ledger (INSTRUCTION-LEDGER.md + ledger/)
- ADR registry (docs/adr/)
- GAP register (docs/GAP-REGISTER.md)
- Staff/Agent passports (docs/STAFF-MATRIX-v3.md)
- Program plans (governance/GLOBAL-PROGRAM-PLAN.md, PHASE-3-SSOT-PLAN.md)
- Duplicate trap analysis (governance/T2.N-* series)

No production code lives in banxe-architecture. No governance docs live exclusively in banxe-emi-stack.

---

## Consequences

### Positive

- **Single authoritative answer** per domain: engineers and regulators can find the canonical path without cross-repo confusion.
- **Archived vibe-coding reduces cognitive overhead** and eliminates the risk of accidentally referencing a research prototype in a production context.
- **Duplicate trap protocol (D-6)** ensures future conflicts are classified quickly and systematically rather than accumulating.
- **Passport SSOT (D-3)** prevents agent sprawl — no unregistered agents can appear in production.

### Negative / Risks

- **BT-001/BT-004/BT-005/BT-010 blockers** mean 4 of 22 domains remain CODE-READY rather than LIVE. SSOT designation is stable; operational status changes when API keys land.
- **GAP-080 (Intent Layer)** is STAGED — banxe-emi-stack owns the domain, but SkillRouter is incomplete. Phase 4 will resolve this.
- **vibe-coding archive** is an operator action (GitHub UI) — factory cannot execute it. Risk: delay in archive leaves T-B artifacts technically reachable. Mitigation: zero-coupling invariant (D-1) prevents any live dependency.

### Neutral

- This ADR does not add, remove, or move any production code.
- This ADR does not change the IL protocol, Guardian configuration, or branch protection rules.
- Sandbox mode (ADR-156) remains in effect; all sign-off gates in this ADR are N/A until operator explicitly lifts sandbox.

---

## Alternatives Considered

### Alt-A: Single-repo target (merge banxe-emi-stack into banxe-architecture)

Rejected. Mixing governance docs with production Python code violates the four-floor architecture (ADR-153). CI pipelines, Semgrep, and Ruff would collide. Governance repo must stay docs-only.

### Alt-B: Keep vibe-coding active indefinitely as "research sandbox"

Rejected. Active research sandbox creates ongoing confusion about canonical authority. The seven OD-resolution packages prove that research prototypes are mistaken for production candidates. Archiving eliminates the confusion permanently.

### Alt-C: Per-domain SSOT in separate files (one file per domain)

Rejected. A single table in PHASE-3-SSOT-PLAN.md §3 is scannable and cross-referenced. Per-domain files would require a directory index and create the same N-file lookup problem that Phase 1 census had to solve.

---

## References

- GLOBAL-PROGRAM-PLAN.md §3 — Phase 3 mandate
- MASTER-ORG-CODE-RUNTIME-DOSSIER.md §3-4 — domain census and duplicate traps
- governance/PHASE-3-SSOT-PLAN.md — per-domain SSOT table (companion document)
- ADR-005 — Protocol DI pattern (T-A service architecture)
- ADR-120/121 — Worktree mandate (all banxe-architecture git work)
- ADR-146 — Two-repo stable state (precursor decision)
- ADR-156 — Sandbox mode (Phase 3 gate removal)
- compliance-boundaries.md — domain separation rules
- agent-authority.md — autonomy levels and HITL gates
- docs/GAP-REGISTER.md — GAP-080 (Intent Layer), GAP-093 (evo1 SSH)
