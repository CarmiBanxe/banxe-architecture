"""Layer-B orchestrator: budget (bank-limited)."""
class Component:
    layer='B'; name='budget'
    gated=False
    def describe(self): return {'layer':'B','name':'budget','kind':'orchestrator','gated':self.gated}
