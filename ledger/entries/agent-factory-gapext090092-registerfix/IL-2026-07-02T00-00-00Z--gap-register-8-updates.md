---
il_ts: 2026-07-02T00:00:00Z
session_id: agent-factory-gapext090092-registerfix
source: factory
status: DONE
parent_il: IL-122-INTENT-FIRST-CANON-2026-06-07
---

### IL — GAP-REGISTER 8 updates: 042/043/044 DONE, 080 seam note, formalize 088/089, add P1 GAP-090/091/092

- **What:** `docs/GAP-REGISTER.md` — 8 targeted edits to close completed gaps and register new P1 architectural gaps identified during 2026-07-02 audit.
- **Changes (1a–1i):**
  - 1a: GAP-042 → ✅ DONE (PR #266 merged — safeguarding recon)
  - 1b: GAP-043 → ✅ DONE (PR #267 merged — FIN060 generation)
  - 1c: GAP-044 → ✅ DONE (PR #268 merged — Frankfurter FX rates)
  - 1d: GAP-080 description updated — backend seam `services/intent_layer/` EXISTS in banxe-emi-stack (INTENT_LAYER_ENABLED=false, ADR-049 ACCEPTED/not-deployed). Frontend repo confirmed: CarmiBanxe/banxe-trading-frontend (trading channel only; consumer channel absent). Tracked as GAP-091.
  - 1e: GAP-088 formalized as table row — adorsys PSD2 gateway integration (previously inline note)
  - 1f: GAP-089 formalized as table row — Midaz CBS production migration (previously inline note)
  - 1g: GAP-090 NEW P1 — OpenClaw LiteLLM bypass: 3 OpenClaw processes (ctio/:18791, moa/:18789, mycarmibot/:18793) bypass LiteLLM :4000 directly. No audit trail, no quota enforcement. Note: GUIYON :18794 categorically excluded — absolute prohibition, not in Banxe scope.
  - 1h: GAP-091 NEW P1 — ADR-049 Intent-First deployment gap: YAML=ACCEPTED, body=PROPOSED, runtime=NOT_DEPLOYED. Blocks C-37.3/GAP-080.
  - 1i: GAP-092 NEW P1 — Guardian webhook delivery gap: Guardian (:8195/:8196) not delivering required_status_checks to GitHub. Blocks merge without --admin.
- **Invariants:** I-24 append-only (DONE statuses only added, no rows removed); GUIYON exclusion enforced in GAP-090 text.
- **Refs:** GAP-042 (PR #266), GAP-043 (PR #267), GAP-044 (PR #268); ADR-049 (Intent-First); ADR-045 §D7 (governance context).
