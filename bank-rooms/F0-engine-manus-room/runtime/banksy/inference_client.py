"""Banksy inference client — PROPOSES-ONLY (I-27), via bank LiteLLM gateway (:4000).

NOT Legion private inference (:8080). API key from env only (BANKSY_LLM_KEY) — never hardcoded.
Inference generates PROPOSALS; a human decides (I-27). No autonomous actions. Stdlib only.
"""
import os
import json
import urllib.request
import urllib.error


class InferenceClient:
    """Proposes-only inference over the bank LiteLLM gateway. Never Legion :8080."""

    def __init__(self) -> None:
        # env only; default to bank gateway :4000, NOT Legion :8080
        self.base_url = os.environ.get("BANKSY_INFERENCE_URL") or "http://127.0.0.1:4000/v1"
        self.model = os.environ.get("BANKSY_MODEL") or "banksy-bank"
        self._key = os.environ.get("BANKSY_LLM_KEY")  # env only; 0 secrets in repo
        self.proposes_only = True          # I-27 — inference proposes, human decides
        self.direct_legion_infer = False   # never Legion private inference

    def key_present(self) -> bool:
        return bool(self._key)

    def endpoint(self) -> str:
        return self.base_url

    def propose(self, prompt: str, max_tokens: int = 256) -> dict:
        """Return a PROPOSAL (never an executed action). I-27: human decides."""
        if not self._key:
            return {"proposes_only": True, "status": "pending-env-key",
                    "note": "BANKSY_LLM_KEY not set; no live call made"}
        body = json.dumps({
            "model": self.model,
            "messages": [{"role": "user", "content": prompt}],
            "max_tokens": max_tokens,
            "temperature": 0.4,
        }).encode()
        req = urllib.request.Request(
            self.base_url.rstrip("/") + "/chat/completions",
            data=body, method="POST",
            headers={"Content-Type": "application/json",
                     "Authorization": "Bearer " + self._key},
        )
        try:
            with urllib.request.urlopen(req, timeout=20) as r:  # noqa: S310 (bank gateway, env url)
                data = json.loads(r.read())
            text = data.get("choices", [{}])[0].get("message", {}).get("content", "")
            return {"proposes_only": True, "status": "ok", "proposal": text}
        except urllib.error.HTTPError as e:
            return {"proposes_only": True, "status": "http-error", "code": e.code}
        except Exception as e:  # noqa: BLE001 — never crash the engine on inference failure
            return {"proposes_only": True, "status": "error", "detail": type(e).__name__}
