"""Legion gate.exec — the ONLY fabric execution node (ADR-104 §3). DRY-RUN by default.

Accepts a proposed action + an evo1 gate.policy verdict (+ optional HITL confirmation)
and decides whether it WOULD execute. execute_enabled defaults to FALSE => it logs
\"WOULD EXECUTE: ...\" and runs NOTHING.

fail-closed REFUSE when: no valid policy verdict, correlation_id missing/invalid or
mismatched, verdict not allowed/compliant, or requires_hitl without a confirmation.

Real execution is F1.5 (HITL-activated) and is intentionally NOT implemented here — even
with execute_enabled=true this module refuses to run a real action (defense in depth).

Self-contained stdlib so it runs on Legion (the execution node) with zero deps. The
canonical correlation_id format lives in evo1 fabric_common; it is validated here, not
imported (cross-node — no shared filesystem, ADR-104 §4).
"""
from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from typing import Any, Dict, Optional

CORR_PREFIX = "fab"
EXECUTE_ENABLED = os.environ.get("GATE_EXEC_ENABLED", "false").lower() == "true"


def _utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _valid_cid(cid: Any) -> bool:
    return isinstance(cid, str) and cid.startswith(CORR_PREFIX + "-") and len(cid) >= 8


def decide(action: Dict[str, Any], verdict: Optional[Dict[str, Any]],
           hitl_confirmation: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Return {decision: WOULD_EXECUTE|REFUSED, executed, reason, correlation_id}."""
    cid = (verdict or {}).get("correlation_id")

    def refuse(reason: str) -> Dict[str, Any]:
        return {"decision": "REFUSED", "executed": False, "reason": reason,
                "correlation_id": cid, "node": "legion", "role": "exec-gate", "ts": _utc()}

    if not verdict or not _valid_cid(cid):
        return refuse("fail-closed: no valid policy verdict / correlation_id")
    if action.get("correlation_id") and action.get("correlation_id") != cid:
        return refuse("fail-closed: correlation_id mismatch (action vs verdict)")
    if not (verdict.get("allowed") and verdict.get("compliant")):
        return refuse(f"policy denied: {verdict.get('reason')}")
    if verdict.get("requires_hitl") and not hitl_confirmation:
        return refuse("fail-closed: requires_hitl=true but no HITL confirmation")

    label = f"WOULD EXECUTE: {json.dumps(action)} [cid={cid}]"
    if not EXECUTE_ENABLED:
        print(f"[gate.exec DRY-RUN] {label}", flush=True)
        return {"decision": "WOULD_EXECUTE", "executed": False, "dry_run": True,
                "reason": "execute_enabled=false (DRY-RUN); real execution = F1.5 HITL",
                "correlation_id": cid, "node": "legion", "role": "exec-gate", "ts": _utc()}
    # execute_enabled=true path — STILL refuses: real execution is F1.5 only (defense in depth)
    print(f"[gate.exec] ACTIVATION PENDING F1.5 — refusing real execution: {label}", flush=True)
    return refuse("execute_enabled=true but real execution NOT implemented until F1.5 (HITL)")


def _main() -> None:
    """CLI: stdin JSON {action, verdict, hitl_confirmation?} => decision JSON."""
    try:
        data = json.loads(sys.stdin.read() or "{}")
    except Exception:
        data = {}
    out = decide(data.get("action", {}), data.get("verdict"), data.get("hitl_confirmation"))
    print(json.dumps(out))


if __name__ == "__main__":
    _main()
