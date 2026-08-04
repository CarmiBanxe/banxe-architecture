# CELL — CTO / TECHNOLOGY, DATA & AI (department under ENGINE_DIRECTOR)

**STATUS: PROPOSED — pending MC-C1 counsel-review. NOT canon.** · Sandbox-only · no push
Schema: `docs/orgcells/SCHEMA.md` (12 fields, validation V1–V6)
**Second department of the org contour** (Fable-5 ruling 2026-08-04). Prepare-only.

> **Canonical rule (SCHEMA §0, verbatim):**
> «Сначала подготовь клетку — функции, вертикальная связь, горизонтальные связи,
> полномочия — как спецификацию; только затем рефактори рабочий код Banksy В эту клетку,
> извлекая исключительно функции и порядок их работы (как банк работает сегодня) и
> никогда — секреты, credentials или реальные данные (sandbox-only); этот рефактор есть
> пере-осмысление под модель AI-банка (движок-Директор), а не механический порт кода
> bank-with-agents.»

---

```yaml
cell_id: cto-dept
name: CTO — Technology, Data & AI
kind: DEPARTMENT
reporting_line: ENGINE_HIERARCHY
vertical:
  manager_ref: engine-director   # V2: same reporting_line as this cell
department_ref: null             # schema field 9: null for roots AND departments
data_policy: "sandbox-only; no secrets, no credentials, no real data"
status: PROPOSED                 # V5: no activation evidence cited → PROPOSED
```

**Why `kind: DEPARTMENT`:** Dept-5 of the parent org canon; it owns a function area
(platform, data, AI change-control, provider integration) and will own leaf cells later
(deploy-gate, model-registry, provider-onboarding). Schema field 9 makes `department_ref`
null for departments, which is the correct shape here; `CELL` would require an owning
department that does not exist.

**Why `ENGINE_HIERARCHY` and not `MLRO_LINE`:** this department carries platform and
change-control functions, not compliance-monitoring, so V3 does not force the MLRO line.
Where a technology change has a financial-crime dimension, that is handled by cross-line
**cooperation** (`horizontal` → `mlro-root`), never by moving the department.

## The two senses of "engine" — the bank↔factory interface, stated precisely

This cell is where a real ambiguity has to be resolved, because both readings are true at
once and they are not in conflict once separated:

- **Engine-as-Director** (`engine-director`, root of this tree) — the AI-BANK organisational
  authority. It dispatches intents, supervises departments and accepts their output. In that
  sense this department reports **to** it: `manager_ref: engine-director`.
- **Engine-as-platform** — the same Banksy runtime seen as an operated asset: models, model
  routing, inference endpoint, agent bus, vector store, deploy pipeline. In that sense the
  engine is a **subordinate instrument of this department**: CTO owns its build, its change
  control and its production gates.

So the engine directs the org while the CTO department owns the machine the engine runs on.
The interface **bank ↔ factory** lives exactly here: nothing produced by the factory enters
the bank except through this department's gates (HITL-013 deploy, HITL-014 AI model update).
That gate authority is **not** a vertical org edge and does not invert the tree — the engine
cannot pass its own change into production by orchestration alone, because passing it is a
human SMF26 act, not a task the Director can assign to itself.

## functions[] (PRIMARY)

| # (exec order) | name | description | input → output |
|---|---|---|---|
| 1 | `engine_platform_ownership` | Owns the engine-as-platform: model routing endpoint, agent bus, vector store, inference plane, and their configuration baseline. Operates the machine that the Director runs on; does not acquire the Director's org authority by doing so. | platform change request → applied/refused platform baseline change |
| 2 | `factory_intake` | The single admission point for factory output into the bank. Receives a factory deliverable, verifies its evidence (tests, coverage, gate results) and routes it to the correct gate function below. | factory deliverable + evidence bundle → gate-routed intake decision (to fn 3 or fn 4) |
| 3 | `i27_activation_signoff` | Owns the **I-27 activation sign-off process** — the procedure by which an agent moves from PROPOSED to ACTIVE. I-27 holds that agents may only **propose**; activation is therefore a human act, and this department owns its ordered procedure (steps in the next section). | activation dossier for a PROPOSED agent → signed activation decision (ACTIVE with cited evidence, or refused with reason) |
| 4 | `ai_model_change_control` | Change control for AI models and model routing in the bank plane: version pinning, rollback path, evaluation evidence. **Jointly gated with CRO** — this department alone cannot pass a model change. | model change request + evaluation evidence → joint CTO+CRO decision (HITL-014) |
| 5 | `production_deploy_gate` | Holds HITL-013: no production-state mutation reaches the bank without this gate, regardless of which layer produced it. | release candidate + evidence → deploy approved / blocked |
| 6 | `provider_credentials_process` | Owns the **process** for obtaining, rotating and retiring third-party provider credentials (the ED-03 class, e.g. the IDV provider). Owns the procedure, the request path, the rotation cadence and the audit record. **Never the credential values** — this cell is sandbox-only and holds no secrets, and the process it owns explicitly forbids recording values in the governance plane. | provider access requirement → approved credential-lifecycle procedure + audit record (values held outside this plane) |
| 7 | `platform_audit_emission` | Emits every gate decision (activation, model change, deploy, credential lifecycle) to the append-only audit trail so technology decisions are reconstructible. | gate decision → audit record |

### Function 3 in detail — the I-27 activation sign-off procedure (ordered)

The layer-2 blockage is procedural, not technical: agent records exist in volume
(**142 + 104 agent records, of which ACTIVE = 7** per the operator's floor-2 count) while
activation has no owned, repeatable procedure. This function supplies it.

| Step | Input | Action | Output |
|---|---|---|---|
| 3.1 | PROPOSED agent record | Completeness check: passport present, functions declared, owning cell identified, HITL band declared | complete / returned-incomplete |
| 3.2 | complete dossier | Line check: the agent's owning cell resolves on a valid `vertical` chain (V2), and any compliance-monitoring function sits on `MLRO_LINE` (V3) | line-valid / rejected as mis-placed |
| 3.3 | line-valid dossier | Authority check: the agent's declared authority does not exceed its cell's authority, and touches no non-delegable act (SAR / PEP / sanctions reversal) | authority-valid / rejected |
| 3.4 | authority-valid dossier | Evidence check per V5: activation evidence is cited, not asserted | evidence-cited / stays PROPOSED |
| 3.5 | evidence-cited dossier | **Human sign-off, SMF26** (with CRO where the change is an AI model change — HITL-014) | signed decision |
| 3.6 | signed decision | Status transition recorded with the citation, and emitted to audit (fn 7) | ACTIVE with cited evidence, or refusal with reason |

**Non-negotiable:** step 3.5 cannot be performed by the engine, by an agent, or by this cell
acting alone in software. I-27 makes activation a human act; steps 3.1–3.4 may be prepared
mechanically, step 3.5 may not.

### Function 6 in detail — what "owning credentials" means and does not mean

This department owns the **lifecycle procedure**: who may request provider access, what
evidence justifies it, who approves, how rotation is scheduled, how retirement is verified,
and what audit record each step leaves. It does **not** hold, store, mirror, or document
credential values anywhere in this governance plane. The ED-03 class (IDV provider access,
referenced by path only) is blocked today on that missing procedure rather than on any
technical impediment — which is why the fix is a process artefact and not a config change.

## horizontal[]

| peer_ref | interaction |
|---|---|
| `mlro-root` *(MLRO_LINE)* | **Cross-line cooperation — permitted by V4, explicitly NOT authority.** Where a platform, model or provider change touches financial-crime surface (screening, monitoring, SAR-adjacent data), this department **notifies and consults** the MLRO line and receives back a binding determination on that dimension. It does not task that line, cannot overrule it, and acquires no SAR/PEP/sanctions authority by operating the platform those functions run on. Neither direction is expressible as a `vertical` edge (V2). |
| `safeguarding-recon` *(ENGINE_HIERARCHY)* | Same-line peer cooperation, not supervision. This department supplies the platform and deploy path for the safeguarding/reconciliation services; that department owns the banking correctness of its own functions. Neither manages the other — both attach to `engine-director`. |
| `dpo` *(independent line — see `CELL-DPO.md`)* | **Cooperation only, and deliberately asymmetric.** This department notifies the DPO of processing changes and DPIA-triggering platform work; the DPO reviews and may object. This department must **never** appear on the DPO's `vertical` chain — CTO determines means of processing, so authority over the DPO would be a GDPR conflict of interest (Art. 38(3)). See the DPO cell's independence proof. |

## authority

- **Alone:** platform baseline changes with no bank-plane or model dimension; steps 3.1–3.4 of the activation procedure; scheduling and audit of the credential lifecycle; audit emission.
- **Escalated / joint (never alone):**
  - **HITL-013 — production deploy** (SMF26 human act; the engine has no bypass);
  - **HITL-014 — AI model update** (SMF26 **jointly with CRO**; a model change carries a risk dimension this department does not own);
  - **HITL-015 — security** (with CEO), per the SMF mapping referenced below;
  - **I-27 activation sign-off**, step 3.5 — human, not automatable.
- **Outside its authority entirely (not "escalated"):** anything on the MLRO line — SAR filing, PEP approval, sanctions reversal — and any instruction to the DPO regarding DPO tasks.
- **HITL binding:** AUTO > 90 confidence · REVIEW 70–90 · BLOCK < 70. Gate definitions are referenced, never restated — `banxe-emi-stack: services/hitl/org_roles.py` (cross-repo, path-only).

## What this cell clears, and what remains open

| Gap id | Effect of this cell | Status |
|---|---|---|
| **F2-OP-03** | The layer-2 activation blockage was an **unowned procedure**: agent records exist in volume, ACTIVE = 7, and no cell owned the sign-off path. Function 3 assigns that ownership and supplies the ordered procedure with an explicit human step. | **cleared as a specification** — clearing in fact requires the procedure to be exercised |
| **F2-OP-05** | Credential access (ED-03 class) was blocked on a missing lifecycle procedure, not on a technical impediment. Function 6 assigns ownership of that procedure while keeping values out of this plane. | **cleared as a specification** — same caveat |

> **[UNKNOWN] — declared, not papered over.** The identifiers `F2-OP-03` and `F2-OP-05` do
> not resolve to any definition inside this repository (grep over `*.md` returns nothing);
> they come from a floor-2 operational gap register held elsewhere. This cell therefore
> addresses them **as described in the authoring task** and cites them by id only. Before
> either is marked closed, its authoritative definition must be produced and checked against
> functions 3 and 6 — an id match is not a closure proof.

## source_refs[] (paths only — ADR-102, never duplicated)

| Path | Resolution | What is referenced |
|---|---|---|
| `governance/CANONICAL-ORG-CHART-v2.md` | **repo-local** | Dept-5 "CTO / Technology, Data, AI", SMF26 owner, 1st line of defence |
| `docs/architecture/BANK-OPERATING-MODEL-FOUR-FLOORS-2026-07-18.md` | **repo-local** | CTO = SMF26; gates HITL-013/014/015; CTO as the practical bank↔factory interface; FLOOR-2 activation state |
| `banxe-emi-stack: services/hitl/org_roles.py` | cross-repo (path-only) | SMF role mapping and HITL gate definitions this cell must respect |

## INVARIANT CHECK (exercises V1–V6 on this record)

- **V1 — SATISFIED.** `vertical.manager_ref` is non-null; this record adds no third root.
- **V2 — SATISFIED.** `manager_ref = engine-director`; `reporting_line(cto-dept) = ENGINE_HIERARCHY` and `reporting_line(engine-director) = ENGINE_HIERARCHY` — the manager resolves within the same line.
- **The gate authority does not invert the edge.** Holding HITL-013/014 does not make this department the manager of `engine-director`; gates are human acts bound to SMF26, expressed in `authority`, not in `vertical`. The schema has no field in which "the department gates its manager" could be written as authority over the root — and that is correct: the Director orchestrates, the human gates.
- **V3 — NOT TRIGGERED.** No compliance-monitoring function class is carried here; monitoring of financial-crime surface stays on the MLRO line, reached only through `horizontal`.
- **V4 — SATISFIED.** All three cross-references (`mlro-root`, `safeguarding-recon`, `dpo`) are `horizontal`; no inter-tree or cross-line `vertical` edge is declared.
- **V5 — SATISFIED.** `status: PROPOSED`; no activation evidence is cited, and none is claimed.
- **V6 — SATISFIED.** All three `source_refs[]` are paths; no source content is duplicated into this record.

## MT-05 note

No `aml_orchestrator` reference is made or resolved here. The identity conflict stays FROZEN.

---
**This does not replace legal advice.**
