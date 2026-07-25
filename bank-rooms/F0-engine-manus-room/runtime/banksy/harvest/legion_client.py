"""Harvest: Banksy->Legion EXTERNAL request/response client (data-gathering only)."""
import os
class LegionClient:
    """External trusted supplier. NOT shared runtime; NOT Legion private inference port."""
    def __init__(self): self.endpoint=os.environ.get("LEGION_DATA_ENDPOINT",""); self.mode="read-request-response"; self.trust="external"
    def gather(self, query):  # would call external endpoint; no live call in build
        return {"external": True, "endpoint_set": bool(self.endpoint), "mode": self.mode, "direct_inference": False}
