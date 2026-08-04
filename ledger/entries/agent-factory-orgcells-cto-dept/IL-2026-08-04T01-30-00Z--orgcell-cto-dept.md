---
il_ts: 2026-08-04T01:30:00Z
session_id: agent-factory-orgcells-cto-dept
source: CEO
status: PREPARED
---
### ORG-DEPT-05 — CTO / Technology, Data & AI cell authored (ENGINE_HIERARCHY, PROPOSED)

- **Decision:** authored `docs/orgcells/CELL-CTO-DEPT.md` — Dept-5 of the parent org canon as
  the second department of the org contour, per the Fable-5 org-cells ruling 2026-08-04.
  `cell_id: cto-dept`, `kind: DEPARTMENT`, `reporting_line: ENGINE_HIERARCHY`,
  `vertical.manager_ref: engine-director` (V2 same-line), `department_ref: null`,
  `status: PROPOSED`. Twelve schema fields complete; SCHEMA §0 rule carried verbatim.
- **Bank↔factory interface resolved by separating two senses of "engine":** engine-as-Director
  is the org root that supervises this department (`manager_ref`), while engine-as-platform
  (models, routing, bus, vector store, deploy path) is a subordinate instrument this
  department owns and gates. Gate authority (HITL-013 deploy, HITL-014 model update with CRO,
  HITL-015 security with CEO) is expressed in `authority`, never as a `vertical` edge — the
  Director cannot pass its own change into production, because passing it is a human SMF26 act.
- **F2-OP-03 addressed as specification:** function 3 `i27_activation_signoff` assigns
  ownership of the activation procedure that was previously unowned (agent records in volume,
  ACTIVE = 7) and supplies six ordered steps (completeness → line-validity V2/V3 → authority →
  V5 evidence → **human SMF26 sign-off** → recorded transition + audit). I-27 keeps step 3.5
  human: steps 3.1–3.4 may be prepared mechanically, 3.5 may not.
- **F2-OP-05 addressed as specification:** function 6 `provider_credentials_process` owns the
  credential **lifecycle procedure** (request path, approval, rotation cadence, retirement,
  audit record) for the ED-03 class, while values stay entirely outside this plane —
  sandbox-only, no secrets recorded anywhere in the governance plane.
- **[UNKNOWN] declared:** identifiers `F2-OP-03` / `F2-OP-05` do not resolve to any definition
  inside this repository (grep over `*.md` returns nothing) — they belong to a floor-2 gap
  register held elsewhere. Both are addressed as described in the authoring task and cited by
  id only; neither may be marked closed until its authoritative definition is produced and
  checked against functions 3 and 6. An id match is not a closure proof.
- **Invariants:** V1 satisfied (non-null manager, no new root); V2 satisfied
  (`cto-dept` → `engine-director`, both ENGINE_HIERARCHY); V3 not triggered (no
  compliance-monitoring class — that stays on the MLRO line, reached only via `horizontal`);
  V4 satisfied (`mlro-root`, `safeguarding-recon`, `dpo` all horizontal); V5 satisfied
  (PROPOSED, no evidence claimed); V6 satisfied (three source_refs, paths only). MT-05
  `aml_orchestrator` untouched and still FROZEN.
- **Perimeter:** prepare-only, mutations confined to `docs/orgcells/` + this shard; no push,
  no merge (HITL); session-lock held in this worktree (MT-11); sandbox-only, no secrets.
- **Refs:** `docs/orgcells/CELL-CTO-DEPT.md`; `docs/orgcells/SCHEMA.md` (12 fields, V1–V6);
  `docs/orgcells/CELL-ENGINE-DIRECTOR.md` (manager); `governance/CANONICAL-ORG-CHART-v2.md`
  (Dept-5, SMF26); `docs/architecture/BANK-OPERATING-MODEL-FOUR-FLOORS-2026-07-18.md`;
  `banxe-emi-stack: services/hitl/org_roles.py` (cross-repo, path-only); I-27; MC-C1.
  IL provisional, NOT hardcoded (ADR-119 Rule 8); append-only (ADR-059-A), il_ts strictly
  greater than the origin/main maximum at authoring time.
