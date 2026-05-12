"""
LiteLLM custom_code guardrail extension with HITL audit sink emit.
Document: SANDBOX-ACTIVATION-ORDER-2026-05-12 Step 3 (Condition D)
Apply after ClickHouse DDL: sql/create-banxe-audit-hitl-decisions-2026-05-12.sql
NOT applied. Sub-A applies only under fresh Clause 17 check + HITL-ASK.
"""
from datetime import datetime, timezone
from hashlib import sha256
from uuid import uuid4
import json
import os
import pathlib

try:
    from clickhouse_driver import Client as ClickHouseClient
    CH_OK = True
except ImportError:
    CH_OK = False

REGULATED_KEYWORDS = [
    "/compliance/", "/kyc/", "/aml/",
    "kyc_id", "aml_flag", "transaction_id",
    "iban", "national_id",
]

def _client():
    return ClickHouseClient(
        host=os.environ.get("CLICKHOUSE_HOST", "100.68.102.48"),
        port=int(os.environ.get("CLICKHOUSE_PORT", "9000")),
        user=os.environ.get("CLICKHOUSE_USER", "default"),
        password=os.environ.get("CLICKHOUSE_PASSWORD", ""),
        database="banxe_audit",
    )

def _emit(level, action, prompt_hash, guardrail_hit, outcome,
          classifier_out=None, evidence_refs=None):
    row = {
        "ts": datetime.now(timezone.utc),
        "decision_id": uuid4(),
        "level": level,
        "action": action,
        "requested_by": "sub-a",
        "requested_at": datetime.now(timezone.utc),
        "prompt_hash": prompt_hash,
        "classifier_out": json.dumps(classifier_out or {}),
        "guardrail_hit": guardrail_hit,
        "operator": "automatic",
        "outcome": outcome,
        "decided_at": datetime.now(timezone.utc),
        "rollback_path": "docs/runbooks/legion-llm-router-setup.md",
        "evidence_refs": evidence_refs or ["PR-225"],
    }
    if not CH_OK:
        p = pathlib.Path.home() / "banxe-dev" / "audit-staging" / "hitl-fallback.log"
        p.parent.mkdir(exist_ok=True, parents=True)
        with p.open("a") as f:
            f.write(json.dumps({**row, "ts": row["ts"].isoformat(),
                                "requested_at": row["requested_at"].isoformat(),
                                "decided_at": row["decided_at"].isoformat(),
                                "decision_id": str(row["decision_id"])}) + "\n")
        return
    _client().execute(
        "INSERT INTO banxe_audit.hitl_decisions VALUES",
        [row],
    )

def apply_guardrail(inputs, request_data, input_type):
    texts = inputs.get("texts") or []
    prompt_text = "\n".join(texts)
    prompt_hash = sha256(prompt_text.encode("utf-8")).hexdigest()
    for kw in REGULATED_KEYWORDS:
        if kw.lower() in prompt_text.lower():
            _emit("L3", "block_regulated", prompt_hash, kw, "deny")
            return {"action": "block",
                    "reason": f"regulated path/keyword '{kw}'"}
    return {"action": "allow"}
