# S13.8 Legion :8180 Collision Verify — G-FACTORY-05 Reclassification

Document ID: AUDIT-S13-8-LEGION-8180-2026-05-13
Status: VERIFIED — G-FACTORY-05 reclassified to FALSE-COLLISION (ADR-017 canonical Legion authority)
Sprint: S13.8 (extends G-FACTORY-04 monitor; closes G-FACTORY-05)
Date: 2026-05-13 23:55 CEST
Executor: Central read-only shell diagnostic.
Anchors: ADR-017 (KC IAM cutover); G-FACTORY-04 (line 3830 reclassified MONITOR/VERIFY 2026-05-06); G-FACTORY-05 (line 7971 origin S12.1 evidence); IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12; S12.4 HOLD lift conditions (line 7977).

## Diagnostic findings (read-only, 2026-05-13 23:50 CEST)

### Legion (mark-legion, Tailscale 100.101.218.26)
- ss -tlnp :8180 → `0.0.0.0:8180 LISTEN` active.
- Java processes: 2 KC procs (pid 1303 from 21:46, pid 503364 from 23:53). Both `quay.io/keycloak/keycloak:26.2.5` containerized with `--hostname=100.101.218.26 --http-port=8180 --import-realm`.
- Docker reveals: `keycloak-banxe-emi` container (port `0.0.0.0:8180->8180/tcp`) + `keycloak-banxe-emi-pg-test` container (port `8181->8180/tcp` test instance) + `keycloak-banxe-emi-pg` Postgres backend.
- This matches ADR-017 KC IAM cutover canonical configuration.

### evo1 (banxe-NucBox-EVO-X2, Tailscale 100.99.208.21 / 100.68.102.48)
- ss -tlnp :8180 → java pid 6508 active.
- curl :8180/health/ready → HTTP 404 (expected: KC 26.x exposes /health on :9000 management plane, not :8180 data plane per S12.1 evidence line 7938).

### Tailscale state
- mark-legion 100.101.218.26 (canonical KC authority per ADR-017)
- evo1 100.99.208.21 + 100.68.102.48
- direct route 192.168.0.72:41641 active

## Analysis vs G-FACTORY-05 origin description

S12.1 evidence (line 7971) described G-FACTORY-05 as: "Legion :8180 logical collision with evo1 KC — clients may authenticate against wrong KC".

Actual state (2026-05-13):
1. **ADR-017 KC IAM cutover** declares Legion 100.101.218.26:8180 as canonical authority for `banxe-emi` realm.
2. Legion :8180 = **canonical**; evo1:8180 = **secondary/dev (legacy from incident timeframe pre-cutover)**.
3. 2 Java processes on Legion = containerised KC + test KC (NOT orphan; expected per containerization design).
4. G-FACTORY-04 was already reclassified MONITOR/VERIFY on 2026-05-06 (IL line 3830) under identical reasoning: "Containerised Keycloak on Legion is the expected canonical state (ADR-017 + G-IAM-08)".

G-FACTORY-05 is a **continuation of the same misclassification** that G-FACTORY-04 corrected on 2026-05-06. Both arose from interpreting ADR-017 design as collision.

## Verdict

**G-FACTORY-05 → CLOSED as FALSE-COLLISION.** No destructive cleanup required. ADR-017 already designates Legion 100.101.218.26:8180 as canonical KC authority. evo1:8180 remains as secondary/legacy and may be addressed separately (S12.x or new sprint) if dual-host KC is not desired long-term.

## Impact on S12.4 HOLD lift

S12.4 HOLD lift conditions (per IL line 7977):
1. G-IAM-08 fixed — STILL OPEN (PREP DONE Sub-B PR #133, deploy HITL-gated)
2. G-IAM-09 fixed — STILL OPEN (PREP DONE Sub-B PR #134, deploy HITL-gated)
3. **G-FACTORY-05 resolved or operator-waived — RESOLVED via this reclassification ✅**
4. Explicit operator go-trigger — pending

After this commit: S12.4 HOLD lift remaining = G-IAM-08 + G-IAM-09 deploy (HITL-gated) + operator go-trigger.

## Anchors

ADR-017 (KC IAM cutover); IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12 (line 7938; G-FACTORY-05 origin line 7971); IL-OPS-G-FACTORY-04-OBSERVED-2026-05-06 (line 3830; precedent reclassification); Sprint S13.8, S12.4; G-FACTORY-04, G-FACTORY-05; banxe-emi-stack PR #133 (G-IAM-08), PR #134 (G-IAM-09); IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12; IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12; IL-CANON-PERSISTENCE-SHELL-FIXATION-2026-05-12.
