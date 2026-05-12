"""
Sandbox / Condition B / Step 4
DRAFT endpoint stub for banxe-compliance-api.

Source contract: docs/audit/condition-b-compliance-api-integration-2026-05-12.md (PR #225)
Apply: this file is a copy-paste source for banxe-emi-stack team.
       It is NOT installed in banxe-compliance-api by Sub-A.

Run mode here: standalone smoke test on Legion only (NOT production).
Entry point:   POST /v1/internal/classify-prompt

Auth assumption: internal service token (header Authorization: Bearer <token>).
Token is validated against env var BANXE_INTERNAL_SVC_TOKEN at startup.
"""
from __future__ import annotations

import os
import time
import json
import uuid
import asyncio
import hashlib
from typing import Any, Optional

try:
    from fastapi import FastAPI, Header, HTTPException, Request
    from pydantic import BaseModel
    FASTAPI_OK = True
except ImportError:
    FASTAPI_OK = False


CLASSIFIER_URL = os.environ.get(
    "CLASSIFIER_URL", "http://100.99.208.21:11434/api/generate"
)
CLASSIFIER_MODEL = os.environ.get("CLASSIFIER_MODEL", "qwen2.5:0.5b")
INTERNAL_TOKEN = os.environ.get("BANXE_INTERNAL_SVC_TOKEN", "")
TIMEOUT_S = float(os.environ.get("CLASSIFIER_TIMEOUT_S", "0.1"))
RATE_LIMIT_RPS = int(os.environ.get("CLASSIFIER_RPS", "100"))


class ClassifyRequest(BaseModel):
    prompt_hash: str
    prompt_excerpt: str
    metadata: dict


class ClassifyResponse(BaseModel):
    decision_id: str
    cls: str
    confidence: float
    audit_written: bool


def _auth(authorization: Optional[str]) -> None:
    if not INTERNAL_TOKEN:
        raise HTTPException(503, "internal token not configured")
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(401, "missing bearer")
    if authorization.removeprefix("Bearer ").strip() != INTERNAL_TOKEN:
        raise HTTPException(401, "invalid token")


async def _classify(prompt_excerpt: str) -> tuple[str, float]:
    """
    Calls evo2 Ollama qwen2.5:0.5b with a short instruction.
    Returns (cls, confidence). Times out per TIMEOUT_S.
    Failure -> ('unknown', 0.0).
    """
    instruction = (
        "Classify the following prompt into exactly one of: "
        "fraud_signal, compliance_query, reasoning_task, developer_task. "
        "Reply with only the class name."
    )
    payload = {
        "model": CLASSIFIER_MODEL,
        "prompt": f"{instruction}\n\nPrompt: {prompt_excerpt}",
        "stream": False,
        "options": {"num_predict": 8},
    }
    try:
        import httpx
        async with httpx.AsyncClient(timeout=TIMEOUT_S) as cx:
            r = await cx.post(CLASSIFIER_URL, json=payload)
            r.raise_for_status()
            data = r.json()
            text = (data.get("response") or "").strip().lower()
            for cls in ("fraud_signal", "compliance_query",
                        "reasoning_task", "developer_task"):
                if cls in text:
                    return cls, 0.7
            return "unknown", 0.0
    except Exception:
        return "unknown", 0.0


def _write_audit(decision_id: str, cls: str, confidence: float,
                 prompt_hash: str) -> bool:
    """
    Writes a row to banxe_audit.hitl_decisions (Condition D sink).
    Returns True on success, False otherwise. Caller never blocks.
    """
    try:
        from clickhouse_driver import Client
        c = Client(
            host=os.environ.get("CLICKHOUSE_HOST", "100.68.102.48"),
            port=int(os.environ.get("CLICKHOUSE_PORT", "9000")),
            user=os.environ.get("CLICKHOUSE_USER", "default"),
            password=os.environ.get("CLICKHOUSE_PASSWORD", ""),
            database="banxe_audit",
        )
        import datetime as dt
        now = dt.datetime.utcnow()
        c.execute(
            "INSERT INTO banxe_audit.hitl_decisions VALUES",
            [{
                "ts": now,
                "decision_id": uuid.UUID(decision_id),
                "level": "L0",
                "action": "classify_prompt",
                "requested_by": "banxe-compliance-api",
                "requested_at": now,
                "prompt_hash": prompt_hash,
                "classifier_out": json.dumps(
                    {"cls": cls, "confidence": confidence}
                ),
                "guardrail_hit": "",
                "operator": "automatic",
                "outcome": "approve",
                "decided_at": now,
                "rollback_path": "patches/banxe-compliance-api/README.md",
                "evidence_refs": ["PR-225-condition-b", "PR-243-condition-d"],
            }],
        )
        return True
    except Exception:
        return False


if FASTAPI_OK:
    app = FastAPI(title="banxe-compliance-api classify-prompt stub")

    @app.post("/v1/internal/classify-prompt", response_model=ClassifyResponse)
    async def classify_prompt(
        body: ClassifyRequest,
        authorization: Optional[str] = Header(None),
    ) -> ClassifyResponse:
        _auth(authorization)
        decision_id = str(uuid.uuid4())
        cls, conf = await _classify(body.prompt_excerpt)
        wrote = _write_audit(decision_id, cls, conf, body.prompt_hash)
        return ClassifyResponse(
            decision_id=decision_id,
            cls=cls,
            confidence=conf,
            audit_written=wrote,
        )


__all__ = ["app"] if FASTAPI_OK else []
