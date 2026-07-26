"""Harvest: tool-framework (adapted from tool_calling/registry + base_tool TEMPLATE). Substrate."""
class BaseTool:
    name="base"; profile="bank"
    def schema(self): return {"name": self.name, "profile": self.profile}
class ToolRegistry:
    def __init__(self): self._t={}
    def register(self, tool): self._t[tool.name]=tool
    def names(self): return sorted(self._t)
