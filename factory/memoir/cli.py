"""CLI surface (ADR-165 §3): store / recall / branch / rollback / blame /
checkout / purge. No daemon, no FastAPI, no MCP (Outcome-C only). Explicit calls.
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path

from .retention import load_retention
from .store import GitMemoryStore

DEFAULT_CONFIG = "config/memoir/retention.yaml"
DEFAULT_REPO = os.environ.get(
    "MEMOIR_REPO", str(Path.home() / ".local/share/banxe-memoir/memory.git"))


def _store(args: argparse.Namespace) -> GitMemoryStore:
    policy = load_retention(args.config)  # fail-closed if invalid
    return GitMemoryStore(args.repo, policy, code_root=args.code_root or None)


def _build_parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser(prog="memoir",
                                 description="Factory-pilot versioned memory (gated).")
    ap.add_argument("--config", default=DEFAULT_CONFIG)
    ap.add_argument("--repo", default=DEFAULT_REPO)
    ap.add_argument("--code-root", default=os.getcwd())
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("store")
    p.add_argument("key")
    p.add_argument("content")
    p = sub.add_parser("recall")
    p.add_argument("entry")
    p.add_argument("--ref", default=None)
    p = sub.add_parser("checkout")
    p.add_argument("entry")
    p.add_argument("ref")
    p = sub.add_parser("blame")
    p.add_argument("entry")
    p = sub.add_parser("branch")
    p.add_argument("name")
    p.add_argument("--from", dest="src", default=None)
    p = sub.add_parser("rollback")
    p.add_argument("entry")
    p.add_argument("to_ref")
    sub.add_parser("purge")
    return ap


def _cli(argv: list[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    st = _store(args)
    if args.cmd == "store":
        print(st.store(args.key, args.content))
    elif args.cmd == "recall":
        print(st.recall(args.entry, args.ref) or "(absent)")
    elif args.cmd == "checkout":
        print(st.checkout(args.entry, args.ref) or "(absent)")
    elif args.cmd == "blame":
        print("\n".join(st.blame(args.entry)))
    elif args.cmd == "branch":
        st.branch_from(args.name, args.src)
        print(f"branch {args.name}")
    elif args.cmd == "rollback":
        print(st.rollback(args.entry, args.to_ref))
    else:
        st.purge()
        print("purged")
    return 0


if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(_cli())
