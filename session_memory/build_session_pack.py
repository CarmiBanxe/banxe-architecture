"""Build a normalized session-start pack from repo memory/handoff artifacts.

Reads (never writes) MEMORY.md + the latest ``docs/handoff/HANDOFF-*.md`` and
``docs/handoff/session-transfer-package-*.md``; extracts structured fields;
emits a single deterministic JSON (optionally a markdown summary) into
``docs/generated/session-memory/`` — a regenerable cache, never a source doc.

CLI (read-only against sources): ``build`` | ``inspect`` | ``latest``.
"""

from __future__ import annotations

import argparse
import datetime as _dt
import json
import re
from pathlib import Path

from . import read_memory_pack as reader
from .extract_handoff_facts import extract_facts, merge_facts, sha256_text
from .schemas import SCHEMA_VERSION, ExtractedFacts, SessionPack, SourceDoc

OUT_DIR = Path("docs/generated/session-memory")
_DATE = re.compile(r"(\d{4}-\d{2}-\d{2})")

# role → tokens whose matching items are surfaced first (never dropped)
ROLE_FOCUS: dict[str, tuple[str, ...]] = {
    "central": ("operator", "canon", "hitl", "ratif", "merge"),
    "factory": ("factory", "gate", "ledger", "build", "prepare"),
    "sub-a": ("sub-a", "worktree", "commit"),
    "sub-b": ("sub-b", "trading", "trading-001"),
}


def find_latest(directory: Path, prefix: str) -> Path | None:
    """Newest ``<prefix>*.md`` by ISO date in filename, else by mtime."""
    cands = sorted(directory.glob(f"{prefix}*.md"))
    if not cands:
        return None

    def key(p: Path) -> tuple[str, float]:
        m = _DATE.search(p.name)
        return (m.group(1) if m else "0000-00-00", p.stat().st_mtime)

    return max(cands, key=key)


def _source(repo: Path, rel: Path, kind: str) -> tuple[SourceDoc, str]:
    text = rel.read_text(encoding="utf-8")
    doc = SourceDoc(
        path=str(rel.relative_to(repo)),
        kind=kind,
        lines=text.count("\n") + 1,
        sha256=sha256_text(text),
    )
    return doc, text


def _prioritise(items: list[str], role: str) -> list[str]:
    focus = ROLE_FOCUS.get(role.lower())
    if not focus:
        return items
    hot = [x for x in items if any(t in x.lower() for t in focus)]
    cold = [x for x in items if x not in hot]
    return hot + cold


def prioritise(facts: ExtractedFacts, role: str) -> ExtractedFacts:
    """Role-aware reordering. Reorders only; never adds/removes truth."""
    facts.next_actions = _prioritise(facts.next_actions, role)
    facts.canon_pointers = _prioritise(facts.canon_pointers, role)
    return facts


def build_pack(repo: Path, role: str = "central",
               now_iso: str | None = None) -> SessionPack:
    """Assemble the pack. Missing optional docs → warnings, still builds."""
    now = now_iso or _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    plan = [
        (repo / "MEMORY.md", "memory"),
        (find_latest(repo / "docs/handoff", "HANDOFF-"), "handoff"),
        (find_latest(repo / "docs/handoff", "session-transfer-package-"), "transfer"),
    ]
    sources: list[SourceDoc] = []
    facts = ExtractedFacts()
    warnings: list[str] = []
    for path, kind in plan:
        if path is None or not path.exists():
            warnings.append(f"missing source: {kind}")
            continue
        doc, text = _source(repo, path, kind)
        sources.append(doc)
        facts = merge_facts(facts, extract_facts(text))
    facts = prioritise(facts, role)
    return SessionPack(SCHEMA_VERSION, now, role, sources, facts, warnings)


def write_pack(pack: SessionPack, repo: Path, *, markdown: bool = False) -> Path:
    """Write JSON (+ optional .md) into the regenerable generated cache."""
    out = repo / OUT_DIR
    out.mkdir(parents=True, exist_ok=True)
    stamp = pack.generated_at.replace(":", "").replace("-", "")
    jpath = out / f"session-pack-{stamp}.json"
    jpath.write_text(json.dumps(pack.to_dict(), indent=2, ensure_ascii=False) + "\n",
                     encoding="utf-8")
    if markdown:
        (out / f"session-pack-{stamp}.md").write_text(
            reader.format_summary(pack.to_dict()), encoding="utf-8")
    return jpath


def _cli(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="session_memory",
                                 description="Deterministic session-memory substrate.")
    sub = ap.add_subparsers(dest="cmd", required=True)
    b = sub.add_parser("build", help="build + write a session pack")
    b.add_argument("--role", default="central")
    b.add_argument("--repo", default=".")
    b.add_argument("--md", action="store_true", help="also emit markdown summary")
    b.add_argument("--now", default=None, help="fixed UTC stamp (deterministic)")
    ins = sub.add_parser("inspect", help="print a pack summary (read-only)")
    ins.add_argument("path")
    lat = sub.add_parser("latest", help="print the newest generated pack (read-only)")
    lat.add_argument("--repo", default=".")
    args = ap.parse_args(argv)

    if args.cmd == "build":
        repo = Path(args.repo).resolve()
        pack = build_pack(repo, args.role, args.now)
        jpath = write_pack(pack, repo, markdown=args.md)
        print(f"wrote {jpath.relative_to(repo)}  "
              f"(sources={len(pack.sources)}, warnings={len(pack.warnings)})")
        return 0
    if args.cmd == "inspect":
        print(reader.format_summary(reader.load_pack(Path(args.path))))
        return 0
    latest = reader.find_latest_pack(Path(args.repo).resolve() / OUT_DIR)
    if latest is None:
        print("no generated pack found; run `build` first")
        return 1
    print(reader.format_summary(reader.load_pack(latest)))
    return 0


if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(_cli())
