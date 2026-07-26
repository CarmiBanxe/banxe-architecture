"""Banksy Engine assembler. Imports heart layers, applies Canon-Guardian exclusions (precise)."""
import importlib, pkgutil, pathlib, re
from . import config as _config
# precise forbidden patterns (word-boundaried); NOT loose substrings like "tor" in "orchestrator"
FORBIDDEN_RX = re.compile(
    r"\btor_[a-z]+|\bselenium\b|\bplaywright\b|\bscrapy\b|\bosint\b|\bmegatron\b|\.onion\b|socks5|"
    r"verl[./]workers[./]actor|(from|import)\s+executor\b|127\.0\.0\.1:8080|localhost:8080",
    re.I)
def _iter_layer_modules():
    base = pathlib.Path(__file__).resolve().parent
    for layer in ("layer_a","layer_b","layer_c","layer_d"):
        for mod in pkgutil.walk_packages([str(base/layer)], prefix=f"banksy.{layer}."):
            yield mod.name
def build_engine():
    cfg = _config.load()
    comps=[]
    for name in _iter_layer_modules():
        m = importlib.import_module(name)
        if hasattr(m, "Component"): comps.append(m.Component().describe())
    base = pathlib.Path(__file__).resolve().parent
    forbidden_hits=[]
    for p in base.rglob("*.py"):
        if p.name == "engine.py":  # this file defines the pattern list itself
            continue
        for line in p.read_text(errors="ignore").splitlines():
            if FORBIDDEN_RX.search(line): forbidden_hits.append((p.name, line.strip()[:40]))
    return {
        "engine":"banksy", "profile": cfg.get("engine",{}).get("profile"),
        "compiled_over_legion": cfg.get("engine",{}).get("compiled_over_legion"),
        "bind_port": cfg.get("engine",{}).get("banksy_bind_port"),
        "modules_assembled": len(comps), "heart_target": 32,
        "forbidden_hits": forbidden_hits, "legion": "external-request-response",
        "status": cfg.get("engine",{}).get("status","building"),
        "hitl_l4_signed": cfg.get("engine",{}).get("hitl_l4_signed"),
    }
