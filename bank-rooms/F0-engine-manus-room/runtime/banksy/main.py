"""Banksy Engine entrypoint. Binds banksy_bind_port, serves /health and /status. Stdlib only."""
import sys, json, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from banksy.engine import build_engine
from banksy.harvest.decision_framework import DecisionFramework
from banksy.harvest.memory import Memory
from banksy.harvest.tool_registry import ToolRegistry
from banksy.harvest.legion_client import LegionClient

STATE = build_engine()
STATE.update({
    "role_1": "ceo-conductor(proposes-only)", "role_2": "client-pm-friend",
    "decision_framework_proposes_only": DecisionFramework().proposes_only,
    "memory": Memory().summary(), "tools": ToolRegistry().names(),
    "legion_link": LegionClient().gather("healthcheck"),
})
# GL-post-20: wire proposes-only inference via bank LiteLLM gateway (:4000, NOT Legion :8080).
from banksy.inference_client import InferenceClient
_inf = InferenceClient()
STATE.update({
    "inference_wired": True,
    "inference_endpoint": _inf.endpoint(),          # bank gateway :4000
    "inference_proposes_only": _inf.proposes_only,  # I-27 — proposes, human decides
    "inference_key_present": _inf.key_present(),     # env-only; False → [pending env key]
    "direct_legion_infer": _inf.direct_legion_infer, # False — never Legion :8080
})

# GL-post-21: surface live MCP tools when endpoint_set=true (backend :8000 round-trip green).
from banksy.config import load as _load_cfg
_ts = _load_cfg().get("tools_staged", {})
_reg = ToolRegistry()
if _ts.get("endpoint_set"):
    for _n in _ts.get("declared", []):
        _reg.register(type("_T", (), {"name": _n, "profile": "bank"})())
    STATE["tools"] = _reg.names()
    STATE["tools_endpoint_set"] = True
    STATE["tools_endpoint"] = _ts.get("endpoint", "")
else:
    STATE["tools_endpoint_set"] = False
GREEN = (STATE["modules_assembled"] > 0 and not STATE["forbidden_hits"]
         and STATE["compiled_over_legion"] is False)
HEALTH = "green" if GREEN else "not-green"

class H(BaseHTTPRequestHandler):
    def _send(self, obj, code=200):
        b = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b)
    def do_GET(self):
        if self.path == "/health":
            self._send({"status": HEALTH, "engine": "banksy",
                        "modules": STATE["modules_assembled"], "port": STATE["bind_port"]})
        elif self.path == "/status":
            self._send(STATE)
        else:
            self._send({"error": "not found"}, 404)
    def log_message(self, *a):
        pass

if __name__ == "__main__":
    port = STATE["bind_port"] or 8200
    srv = ThreadingHTTPServer(("127.0.0.1", port), H)
    print("BANKSY listening on 127.0.0.1:%d health=%s modules=%d" % (port, HEALTH, STATE["modules_assembled"]))
    srv.serve_forever()
