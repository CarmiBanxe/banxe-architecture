"""Layer-B orchestrator: midaz_agent (bank-limited). # gated Midaz/MCP->ledger [counsel]"""
class Component:
    layer='B'; name='midaz_agent'
    gated=True
    def describe(self): return {'layer':'B','name':'midaz_agent','kind':'orchestrator','gated':self.gated}
