"""Layer-B orchestrator: tier_workers (bank-limited)."""
class Component:
    layer='B'; name='tier_workers'
    gated=False
    def describe(self): return {'layer':'B','name':'tier_workers','kind':'orchestrator','gated':self.gated}
