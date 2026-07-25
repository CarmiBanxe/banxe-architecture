"""Layer-B orchestrator: midaz_client (bank-limited). # gated Midaz/MCP->ledger [counsel]"""
class Component:
    layer='B'; name='midaz_client'
    gated=True
    def describe(self): return {'layer':'B','name':'midaz_client','kind':'orchestrator','gated':self.gated}
