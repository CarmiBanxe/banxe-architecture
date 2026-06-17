"""Legion gate.exec — fabric execution node (ADR-104 §3). F1.5 stage-3: REAL execution
for a narrow LOW-RISK idempotent allow-list only.

GATE_EXEC_ENABLED (default false). When true, ONLY actions in low-risk-allowlist.json whose
entry is explicitly idempotent actually execute; everything else is REFUSED. Risky actions
(payment/withdraw/trade/transfer/custody/key-ops) carry requires_hitl from gate.policy and
are NEVER auto-executed: without a human HITL token => REFUSE; even WITH a token, real risky
execution is out of stage-3 scope (not in the allow-list) => REFUSE.

fail-closed: no valid verdict / cid mismatch / not allowed+compliant / fabric degraded
(policy returns allowed=false) / non-idempotent / disallowed URL scheme => REFUSE. gate.exec
acts ONLY on an evo1 gate.policy verdict; it never self-initiates.

Configuration (timeout, endpoint URLs, allowed schemes, the allow-list) lives in
low-risk-allowlist.json (Config-over-Hardcoding, CLAUDE.md §10); env vars may override the
config FILE location only. Self-contained stdlib (Legion-deployable, zero deps). The
correlation_id format is validated here, not imported (cross-node, no shared FS, §4). The
fabric:exec audit is via an injected sink (no secret handled in this module).
"""
from __future__ import annotations

import json
import os
import sys
import urllib.request
from datetime import datetime, timezone
from typing import Any, Callable, Dict, Optional
from urllib.parse import urlparse

CORR_PREFIX = "fab"
HERE = os.path.dirname(os.path.abspath(__file__))
EXECUTE_ENABLED = os.environ.get("GATE_EXEC_ENABLED", "false").lower() == "true"
CONFIG_PATH = os.environ.get("LOW_RISK_ALLOWLIST", os.path.join(HERE, "low-risk-allowlist.json"))
HITL_TOKEN_DIR = os.environ.get("HITL_TOKEN_DIR", os.path.expanduser("~/banxe-fabric/hitl"))


def _utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _valid_cid(cid: Any) -> bool:
    return isinstance(cid, str) and cid.startswith(CORR_PREFIX + "-") and len(cid) >= 8


def _config() -> Dict[str, Any]:
    try:
        with open(CONFIG_PATH) as fh:
            return json.load(fh)
    except Exception:
        return {}  # fail-closed: no config => nothing executes


def _hitl_present(cid: str) -> bool:
    """A human HITL confirmation = a token file <cid>.confirm. The factory never creates it."""
    return os.path.isfile(os.path.join(HITL_TOKEN_DIR, f"{cid}.confirm"))


def _run_idempotent(action_type: str, cfg: Dict[str, Any], cid: str) -> Dict[str, Any]:
    """Execute the idempotent read handler for a low-risk action (no side effects)."""
    ec = cfg.get("exec_config", {})
    url = ec.get("endpoints", {}).get(action_type)
    if not url:
        raise ValueError(f"no endpoint configured for {action_type}")
    scheme = urlparse(url).scheme
    if scheme not in ec.get("allowed_url_schemes", ["http", "https"]):
        raise ValueError(f"disallowed URL scheme: {scheme}")
    req = urllib.request.Request(url, headers={"X-Correlation-Id": cid})
    with urllib.request.urlopen(req, timeout=int(ec.get("timeout_s", 6))) as resp:  # noqa: S310 (scheme checked)
        body = json.loads(resp.read().decode())
    return {"read": action_type, "source": url, "observed_status": body.get("status")}


def decide(action: Dict[str, Any], verdict: Optional[Dict[str, Any]],
           audit_sink: Optional[Callable[[Dict[str, Any]], None]] = None) -> Dict[str, Any]:
    """Gate + (real, low-risk-idempotent-only) execution. Returns an exec record; audits if a sink is given."""
    cid = (verdict or {}).get("correlation_id")

    def out(decision: str, executed: bool, reason: str, result: Any = None) -> Dict[str, Any]:
        rec = {"decision": decision, "executed": executed, "reason": reason,
               "correlation_id": cid, "node": "legion", "role": "exec-gate",
               "action_type": (action or {}).get("type"), "result": result, "ts": _utc()}
        if audit_sink:
            try:
                audit_sink(rec)
            except Exception:
                pass
        return rec

    if not verdict or not _valid_cid(cid):
        return out("REFUSED", False, "fail-closed: no valid policy verdict / correlation_id")
    if action.get("correlation_id") and action.get("correlation_id") != cid:
        return out("REFUSED", False, "fail-closed: correlation_id mismatch (action vs verdict)")
    if not (verdict.get("allowed") and verdict.get("compliant")):
        return out("REFUSED", False, f"policy denied: {verdict.get('reason')}")
    if verdict.get("requires_hitl") and not _hitl_present(cid):
        return out("REFUSED", False, "fail-closed: requires_hitl=true but no human HITL token")
    cfg = _config()
    atype = (action or {}).get("type")
    spec = cfg.get("low_risk_allowlist", {}).get(atype)
    if not spec or spec.get("idempotent") is not True:
        return out("REFUSED", False,
                   f"real execution restricted to low-risk idempotent allow-list; '{atype}' not eligible "
                   f"(risky/non-idempotent real execution is a later stage, HITL-gated)")
    if not EXECUTE_ENABLED:
        return out("WOULD_EXECUTE", False, "execute_enabled=false (DRY-RUN); set GATE_EXEC_ENABLED=true to activate")
    try:
        result = _run_idempotent(atype, cfg, cid)
    except Exception as exc:
        return out("REFUSED", False, f"fail-closed: idempotent handler error: {exc}")
    return out("EXECUTED", True, "low-risk idempotent action executed", result)


def _main() -> None:
    try:
        data = json.loads(sys.stdin.read() or "{}")
    except Exception:
        data = {}
    print(json.dumps(decide(data.get("action", {}), data.get("verdict"))))


if __name__ == "__main__":
    _main()
