#!/usr/bin/env python3
"""build_ledger.py - ADR-059 Sprint 2 generator.

Deterministically composes INSTRUCTION-LEDGER.md from per-session shard
files under ledger/entries/**/IL-*.md.

Ordering (stable): primary by `il_ts` (UTC), tie-break by `session_id`,
then by filename. IL-NNN numbers are assigned sequentially from this
sorted order, so they are a pure function of the shard set (no race).

Usage:
  python ledger/build_ledger.py            # write INSTRUCTION-LEDGER.md
  python ledger/build_ledger.py --check    # verify file == rebuild (CI)
"""
from __future__ import annotations
import argparse
import hashlib
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
ENTRIES = ROOT / "ledger" / "entries"
LEDGER = ROOT / "INSTRUCTION-LEDGER.md"
FROZEN = ROOT / "ledger" / "FROZEN-ARCHIVE.md"

HEADER = (
    "# INSTRUCTION-LEDGER.md - Reestr instrukcij CEO/CTIO\n\n"
    "> GENERATED ARTIFACT (ADR-059, Sprint S2). Do NOT edit by hand.\n"
    "> Source of truth lives in ledger/entries/**/IL-*.md. Regenerate via\n"
    "> `python ledger/build_ledger.py`.\n\n"
    "> Append-only invariant I-28 enforced on shards (guardian, S3).\n"
)

FRONT_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n(.*)$", re.DOTALL)


def parse_front_matter(text):
    m = FRONT_RE.match(text)
    if not m:
        raise ValueError("missing YAML front-matter delimited by ---")
    raw, body = m.group(1), m.group(2)
    meta = {}
    for line in raw.splitlines():
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        if ":" not in line:
            raise ValueError("bad front-matter line: " + line)
        key, val = line.split(":", 1)
        meta[key.strip()] = val.strip()
    return meta, body.strip()


def sid6(session_id):
    return hashlib.sha1(session_id.encode("utf-8")).hexdigest()[:6]


def collect():
    records = []
    if not ENTRIES.is_dir():
        return records
    for path in sorted(ENTRIES.rglob("IL-*.md")):
        text = path.read_text(encoding="utf-8")
        meta, body = parse_front_matter(text)
        for required in ("il_ts", "session_id", "source", "status"):
            if required not in meta:
                raise ValueError(str(path) + ": missing field " + required)
        records.append({
            "il_ts": meta["il_ts"],
            "session_id": meta["session_id"],
            "source": meta["source"],
            "status": meta["status"],
            "body": body,
            "sid6": sid6(meta["session_id"]),
            "path": path.relative_to(ROOT).as_posix(),
        })
    records.sort(key=lambda r: (r["il_ts"], r["session_id"], r["path"]))
    return records


def render(records):
    frozen = FROZEN.read_text(encoding="utf-8") if FROZEN.exists() else HEADER
    nums = [int(m) for m in re.findall(r"IL-(\d{3})", frozen)]
    offset = max(nums) if nums else 0
    out = [frozen.rstrip("\n") + "\n"]
    for i, r in enumerate(records, start=offset + 1):
        num = "IL-{:03d}".format(i)
        out.append(
            "\n---\n\n### " + num + " - " + r["session_id"]
            + " @ " + r["il_ts"] + "\n\n"
            + "- **il_ts:** " + r["il_ts"] + "\n"
            + "- **session_id:** " + r["session_id"] + "\n"
            + "- **source:** " + r["source"] + "\n"
            + "- **status:** " + r["status"] + "\n"
            + "- **shard:** `" + r["path"] + "`\n\n"
            + r["body"] + "\n"
        )
    return "".join(out)


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true",
                    help="verify INSTRUCTION-LEDGER.md == rebuild")
    args = ap.parse_args(argv)
    records = collect()
    content = render(records)
    if args.check:
        current = LEDGER.read_text(encoding="utf-8") if LEDGER.exists() else ""
        if current != content:
            sys.stderr.write(
                "FAIL: INSTRUCTION-LEDGER.md is out of sync with shards.\n"
                "Run: python ledger/build_ledger.py\n"
            )
            return 1
        sys.stdout.write("ledger-build check OK\n")
        return 0
    LEDGER.write_text(content, encoding="utf-8")
    sys.stdout.write("Wrote " + str(LEDGER) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
