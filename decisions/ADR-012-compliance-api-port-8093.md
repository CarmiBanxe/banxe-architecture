# ADR-012: Compliance API Port Migration :8090 → :8093

**Status:** ACCEPTED  
**Date:** 2026-04-06  
**Deciders:** CEO (Moriel Carmi)  
**Trust Zone:** AMBER  
**Change Class:** CLASS_B (port change, I-18 resolution)

---

## Context

During runtime audit on 2026-04-06, the Banxe Compliance FastAPI (`banxe-api.service`) was found
to be DOWN. Root cause: port `:8090` was occupied by GUIYON project's API
(`/data/guiyon-project/SCRIPTS/guiyon_api.py`, hardcoded `uvicorn.run(app, host="0.0.0.0", port=8090)`).

This violated Invariant I-18 (GUIYON excluded from Banxe, shared ports forbidden).

Additionally, `sar_generator.py` was missing from the compliance module, causing an import crash.
Both issues are resolved in this ADR.

**Ports discovered occupied on GMKtec (2026-04-06):**

| Port | Process | Owner |
|------|---------|-------|
| :8084 | banxe-watchman | BANXE |
| :8085 | uvicorn (screener) | BANXE |
| :8088 | deep-search | BANXE |
| :8089 | pii-proxy (Presidio) | BANXE |
| :8090 | guiyon_api.py | GUIYON ← CONFLICT |
| :8091 | hitl-dashboard/app.py | BANXE (HITL Dashboard — deployed, not spec-only) |
| :8092 | guiyon bridge_api.py | GUIYON |
| :8093 | (free) | — |
| :8094 | verify_api.py | BANXE |

**Note:** HITL Dashboard found deployed at :8091 — contradicts previous audit finding of "spec only".
This requires a separate audit update.

---

## Decision

Migrate **Banxe Compliance API** from `:8090` to `:8093` (permanent).

- `banxe-api.service` ExecStart updated: `--port 8090` → `--port 8093`
- `sar_generator.py` created in `src/compliance/` and deployed to `/data/banxe/compliance/`
- `tf-keras` installed in compliance-env to resolve DeepFace dependency
- All canonical documentation updated: SERVICE-MAP.md, COMPLIANCE-ARCH.md, COMPOSABLE-ARCH.md,
  HITL-DASHBOARD-SPEC.md, DEFERRED-PROJECTS.md, MEMORY.md

**Rejected alternative — Option B (reclaim :8090):** Would require coordinating GUIYON port migration,
blocking Midaz Integration Sprint indefinitely.

---

## Consequences

### Positive
- I-18 RESOLVED: BANXE (:8093) and GUIYON (:8090/:8092) ports fully separated
- I-23 VERIFIED: emergency-stop endpoint accessible at :8093
- Compliance API operational: `{"status":"degraded"}` (yente unreachable, non-blocking)
- `sar_generator.py` now exists and is production-deployed

### Negative / Watch
- All references to `:8090` in docs updated; historical files (diagnostic-report.md, SYSTEM-STATE.md)
  retain old port as historical record
- `status: degraded` due to yente unreachable — tracked separately, non-blocking for Midaz Sprint
- RED zone files (`canon/modules/DEV.md`) retain `:8090` — require CLASS_B review by MLRO+CEO+CTIO
  before update (separate commit, not part of this ADR)

---

## Verification

```bash
# Service status
systemctl is-active banxe-api   # → active

# Health check
curl http://127.0.0.1:8093/api/v1/health
# → {"status":"degraded","checks":{"watchman":"ok","jube":"ok","clickhouse":"ok","postgres":"ok","redis":"ok"}}

# I-23: Emergency stop
curl http://127.0.0.1:8093/api/v1/compliance/emergency-stop/status
# → {"active":false,...}
```

---

## Related

- Invariant I-18 (GUIYON exclusion, shared ports forbidden)
- Invariant I-23 (emergency stop before any decision)
- DEF-001 (port conflict audit finding, 2026-04-06)
- GAP-REGISTER v7 (all 22 gaps remain valid; port number does not affect gap status)
