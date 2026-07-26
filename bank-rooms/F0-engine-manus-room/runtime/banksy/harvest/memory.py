"""Harvest: memory (adapted from Legion memory_aware_streaming TEMPLATE). Role-2."""
class Memory:
    def __init__(self, max_history_length=50, summary_threshold=40):
        self.max_history_length=max_history_length; self.summary_threshold=summary_threshold; self._h=[]
    def remember(self, item): self._h.append(item); self._h=self._h[-self.max_history_length:]
    def summary(self): return {"kept": len(self._h), "use_summary": len(self._h)>=self.summary_threshold}
