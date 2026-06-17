"""Legion gate.exec stream-consumer (F1.5 stage-3.1, ADR-104 §3).

Long-running consumer: XREADGROUP on fabric:gate:policy (verdicts from evo1 gate.policy),
runs the UNCHANGED gate_exec.decide() per verdict (fail-closed; real exec ONLY for the
low-risk idempotent allow-list; risky -> HITL/REFUSE), and audits each decision to
fabric:exec. Reuses fabric_redis (RESP client, vault password no-argv). graceful: redis
down => fail-closed degraded (logged, not silent) + backoff/retry. Scope UNCHANGED from stage-3.
"""
from __future__ import annotations

import json
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "common"))
from fabric_redis import RedisStreams, RedisUnavailable, fields_of  # noqa: E402
import gate_exec  # noqa: E402

REDIS_HOST = os.environ.get("REDIS_HOST", "100.68.102.48")  # evo1 redis over tailscale (Legion)
REDIS_PORT = int(os.environ.get("REDIS_PORT", "6379"))
REDIS_PASS_FILE = os.environ.get("REDIS_PASS_FILE", os.path.expanduser("~/banxe-fabric/.vault/redis.pass"))
POLICY_STREAM = os.environ.get("POLICY_STREAM", "fabric:gate:policy")
EXEC_STREAM = os.environ.get("EXEC_STREAM", "fabric:exec")
GROUP = os.environ.get("EXEC_GROUP", "gate-exec")
CONSUMER = os.environ.get("EXEC_CONSUMER", "legion-1")
BLOCK_MS = int(os.environ.get("EXEC_BLOCK_MS", "2000"))
COUNT = int(os.environ.get("EXEC_COUNT", "10"))
MAX_ITERS = int(os.environ.get("EXEC_MAX_ITERS", "0"))   # 0 = run forever
BACKOFF_S = int(os.environ.get("EXEC_BACKOFF_S", "5"))


def _audit_sink(redis):
    def sink(rec):
        try:
            redis.xadd(EXEC_STREAM, {"correlation_id": rec.get("correlation_id") or "",
                                     "node": "legion", "ts": rec["ts"],
                                     "type": "exec." + rec["decision"], "payload": json.dumps(rec)})
        except Exception:
            print("[consumer] WARN fabric:exec audit failed (degraded)", flush=True)
    return sink


def _handle(entry, redis):
    eid = entry[0]
    f = fields_of(entry)
    try:
        verdict = json.loads(f.get("payload", "{}"))
    except Exception:
        verdict = {}
    action = {"type": verdict.get("action_type"), "correlation_id": verdict.get("correlation_id")}
    decision = gate_exec.decide(action, verdict, audit_sink=_audit_sink(redis))
    redis.xack(POLICY_STREAM, GROUP, eid)
    print("[consumer] cid=%s action=%s -> %s :: %s"
          % (decision.get("correlation_id"), decision.get("action_type"),
             decision["decision"], decision["reason"]), flush=True)
    return decision


def main():
    print("gate.exec consumer | redis=%s:%s | %s group=%s | GATE_EXEC_ENABLED=%s"
          % (REDIS_HOST, REDIS_PORT, POLICY_STREAM, GROUP,
             os.environ.get("GATE_EXEC_ENABLED", "false")), flush=True)
    iters = 0
    redis = None
    while True:
        try:
            if redis is None:
                redis = RedisStreams(REDIS_HOST, REDIS_PORT, REDIS_PASS_FILE)
                redis.connect()
                redis.xgroup_create(POLICY_STREAM, GROUP)
                print("[consumer] connected; group ready", flush=True)
            for entry in redis.xreadgroup(GROUP, CONSUMER, POLICY_STREAM, count=COUNT, block_ms=BLOCK_MS):
                _handle(entry, redis)
        except RedisUnavailable as exc:
            print("[consumer] DEGRADED (fail-closed ADR-104 §5): redis unavailable: %s" % exc, flush=True)
            redis = None
            time.sleep(BACKOFF_S)
        iters += 1
        if MAX_ITERS and iters >= MAX_ITERS:
            print("[consumer] reached EXEC_MAX_ITERS=%d, exiting (test mode)" % MAX_ITERS, flush=True)
            break


if __name__ == "__main__":
    main()
