"""Read-only reader for generated session packs.

Never writes. Loads a pack JSON, renders a human markdown summary, and finds
the newest pack in the generated cache. Used by the ``inspect`` / ``latest``
CLI verbs and importable on its own.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

_STAMP = re.compile(r"session-pack-(\d{8}T\d{6}Z)\.json$")


def load_pack(path: Path) -> dict[str, Any]:
    """Load a pack JSON as a plain dict (raises on unreadable/invalid JSON)."""
    return json.loads(Path(path).read_text(encoding="utf-8"))


def find_latest_pack(out_dir: Path) -> Path | None:
    """Newest ``session-pack-*.json`` by embedded UTC stamp, else mtime."""
    cands = sorted(Path(out_dir).glob("session-pack-*.json"))
    if not cands:
        return None

    def key(p: Path) -> tuple[str, float]:
        m = _STAMP.search(p.name)
        return (m.group(1) if m else "", p.stat().st_mtime)

    return max(cands, key=key)


def _block(title: str, items: list[str], limit: int = 12) -> list[str]:
    if not items:
        return [f"## {title}", "_(none extracted)_", ""]
    lines = [f"## {title}"]
    lines += [f"- {x}" for x in items[:limit]]
    if len(items) > limit:
        lines.append(f"- … (+{len(items) - limit} more)")
    lines.append("")
    return lines


def format_summary(pack: dict[str, Any]) -> str:
    """Deterministic markdown summary of a pack (read-only rendering)."""
    facts = pack.get("facts", {})
    out = [
        f"# Session pack — role: {pack.get('role', '?')}",
        f"> schema {pack.get('schema')} · generated {pack.get('generated_at')}",
        "",
        "## Sources",
    ]
    out += [f"- `{s['path']}` ({s['kind']}, {s['lines']} ln)"
            for s in pack.get("sources", [])] or ["_(no sources)_"]
    out.append("")
    fa = facts.get("first_action")
    out += ["## First action in new session", f"- {fa}" if fa else "_(none)_", ""]
    out += _block("Repo state", facts.get("repo_state", []))
    out += _block("Hard invariants", facts.get("invariants", []))
    out += _block("Operator-gated items", facts.get("operator_gated", []))
    out += _block("Next actions", facts.get("next_actions", []))
    out += _block("Canon / hierarchy pointers", facts.get("canon_pointers", []))
    warnings = pack.get("warnings", [])
    if warnings:
        out += _block("Warnings", warnings)
    return "\n".join(out).rstrip() + "\n"
