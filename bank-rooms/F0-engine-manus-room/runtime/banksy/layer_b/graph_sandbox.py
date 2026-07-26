"""Layer-B orchestrator: graph_sandbox (bank-limited)."""
class Component:
    layer='B'; name='graph_sandbox'
    gated=False
    def describe(self): return {'layer':'B','name':'graph_sandbox','kind':'orchestrator','gated':self.gated}
