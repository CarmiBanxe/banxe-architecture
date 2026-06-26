---
il_ts: 2026-06-26T22:30:00Z
session_id: agent-factory-sub-b-paybis-arch-conformance
source: CEO
status: DONE
---
### PAYBIS migration — canonicalize MANDATORY track "Architecture Conformance & Service Consolidation"

- **Objective:** Fix as a HARD requirement (not nice-to-have) that the PAYBIS migration keeps microservice architecture BUT smart-refactors to significantly reduce service count / duplicate / versioned / deprecated variants, removes Bitrix + NeuroNext process footprint, maps legacy onto existing target ports (adapt-not-transplant), and uses mandatory shell-audit evidence. Docs-plane only; factory-orchestration only.
- **Live audit (evidence, not memory):** banxe-emi-stack origin/main@a27ab27 — 107 service dirs; 3 `*_v[0-9]`; 22 `*/legacy/*`; 5 `*/production/*_stub.py`; 0 `_old/_deprecated/_copy/_new`; **neuronext=0, bitrix=0** in services/app (removal already satisfied → forward-guard + consolidation, not code-deletion). banxe-architecture origin/main IL max=546 (governance merged ahead); this shard on PAYBIS dossier branch agent/factory/paybis/neuronext-retirement-adr. Provisional IL = max+1 frozen-at-merge (Rule 8; MAIN re-ids on rebase).
- **Canonicalized into in-branch artifacts:** PLAN §1A MANDATORY TRACK (7 sub-goals + baseline evidence table + track epics E9 extended-with-bitrix / E10 consolidation / E12 conformance-map) + PLAN §5A migration-completeness acceptance HARD GATE (no wave complete unless: provider/process replacement done; architecture conformance checked; service-count/duplication audited; legacy/versioned leftovers removed-or-explicitly-parked-with-justification); DOSSIER §4 HARD-REQUIREMENT reference.
- **Completeness rule (per wave):** replacement done + conformance checked + duplication-reduction audited + leftovers removed-or-parked (parked-list in IL/doc; no silent residue). Overall PAYBIS-completeness additionally requires ADR-114 go-live gate closed + SRC-06/07/08 ingested + neuronext/bitrix footprint=0 (E9 CI-guard green).
- **Wave A reflection:** PARTIAL — Wave A (IL-552) already conforms (FROZEN CryptoLedgerPort respected = adapt-not-transplant; PAYBIS-only; non-custodial map; no NeuroNext/Bitrix). NOT yet done in Wave A: actual consolidation pass (E10 the 3+22+5 variants), E9 CI forward-guard, E12 conformance-map — these are dedicated sprints (A-S2/A-S3 + E12). So the mandatory track is now canonical but only partially executed.
- **Perimeter / canon:** docs-plane only; no runtime/code/secrets; no cross-repo write; no invented repo facts (all counts from read-only shell audit); isolated worktree off arch origin/main; signed; sub-B hands to MAIN per §71/§74; factory-orchestration only (no direct conflict-prone execution).
- **Deliverable:** PLAN §1A + §5A, DOSSIER §4 update, this IL shard.
- **Refs:** PLAN (IL-551), DOSSIER (IL-546), Wave-A (IL-552), ADR-126/108/114; ADR-102; shell-audit emi@a27ab27; I-28/ADR-119.
