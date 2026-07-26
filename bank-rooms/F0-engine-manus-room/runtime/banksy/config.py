"""Banksy config loader (reads banksy-engine.config.toml)."""
import tomllib, pathlib
_CFG = pathlib.Path(__file__).resolve().parent.parent / "banksy-engine.config.toml"
def load():
    with open(_CFG, "rb") as f: return tomllib.load(f)
