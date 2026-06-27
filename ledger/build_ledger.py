#!/usr/bin/env python3
"""build_ledger.py - ADR-059 Sprint 2 generator + ADR-119 stable IL numbering.

Deterministically composes INSTRUCTION-LEDGER.md from per-session shard
files under ledger/entries/**/IL-*.md.

Numbering (ADR-119, stable/frozen):
  IL-NNN numbers are FROZEN per shard in ledger/IL-SEQUENCE.json (append-only
  map  "<session_id>__<salt>" -> int).  A shard keeps its number for life.
  A newly-added shard NEVER renumbers prior entries: it is assigned max+1 in
  (il_ts, session_id, path) order and APPENDED to IL-SEQUENCE.json.  This ends
  the il_ts re-mint churn that the old position-based numbering required on
  every behind-PR, while preserving I-28 append-only and ADR-056/057/059.

  On first run (IL-SEQUENCE.json absent) the map is initialised by replaying
  the legacy (il_ts, session_id, path)-sorted, FROZEN-offset numbering exactly
  once, so every existing shard keeps EXACTLY its present IL-NNN.

Rendering order is by IL number (append-only by construction).

Usage:
  python ledger/build_ledger.py            # write INSTRUCTION-LEDGER.md + IL-SEQUENCE.json
  python ledger/build_ledger.py --check    # verify ledger == rebuild + sequence append-only
"""
from __future__ import annotations
import argparse
import hashlib
import json
import os
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
ENTRIES = ROOT / "ledger" / "entries"
LEDGER = ROOT / "INSTRUCTION-LEDGER.md"
FROZEN = ROOT / "ledger" / "FROZEN-ARCHIVE.md"
SEQUENCE = ROOT / "ledger" / "IL-SEQUENCE.json"

HEADER = (
    "# INSTRUCTION-LEDGER.md - Reestr instrukcij CEO/CTIO\n\n"
    "> GENERATED ARTIFACT (ADR-059, Sprint S2). Do NOT edit by hand.\n"
    "> Source of truth lives in ledger/entries/**/IL-*.md. Regenerate via\n"
    "> `python ledger/build_ledger.py`.\n\n"
    "> Append-only invariant I-28 enforced on shards (guardian, S3).\n"
)

FRONT_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n(.*)$", re.DOTALL)
SALT_RE = re.compile(r"--([0-9a-fA-F]+)\.md$")


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


def shard_key(rec):
    """Stable, collision-proof per-shard identity for IL-SEQUENCE.json:
    "<session_id>__<hex>" where <hex> = sha1(relative path)[:12].

    The path is unique per shard on the filesystem, so the key is unique even
    when two shards in the same session share a filename salt (e.g. distinct
    il_ts but identical 6-hex suffix). It is stable for life because ADR-119
    removes the il_ts re-mint that would otherwise rename a shard.
    """
    hexpart = hashlib.sha1(rec["path"].encode("utf-8")).hexdigest()[:12]
    return rec["session_id"] + "__" + hexpart


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


def frozen_offset():
    frozen = FROZEN.read_text(encoding="utf-8") if FROZEN.exists() else HEADER
    nums = [int(m) for m in re.findall(r"IL-(\d{3})", frozen)]
    return max(nums) if nums else 0


def load_sequence():
    if SEQUENCE.exists():
        return json.loads(SEQUENCE.read_text(encoding="utf-8"))
    return {}


# --- Central IL allocator (ADR-143) -----------------------------------------
# Replaces the inter-process-unsafe local `max+1` for NEW shards with an atomic
# central counter (Redis INCR) so concurrent terminals on different worktrees can
# never mint the same number (the IL-172 duplicate class). The allocator runs ONLY
# at live-mint time (write mode); --check / rebuild stay 100% offline + deterministic
# (numbers, once minted, are FROZEN in IL-SEQUENCE.json — ADR-119 Rule 8 preserved:
# the IL stays provisional, only the SOURCE of the number changes).
IL_COUNTER_KEY = "banxe:il:counter"


def _load_fabric_redis():
    """Import fabric_redis by file path (fabric/ has no package __init__).

    Returns (RedisStreams, RedisUnavailable) or (None, None) if not importable.
    """
    try:
        import importlib.util
        path = ROOT / "fabric" / "common" / "fabric_redis.py"
        spec = importlib.util.spec_from_file_location("banxe_fabric_redis", str(path))
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        return mod.RedisStreams, mod.RedisUnavailable
    except Exception:
        return None, None


def _redis_allocate(current_max):
    """Monotonic IL number strictly > current_max via atomic Redis INCR.

    Config: TL_REDIS_HOST/TL_REDIS_PORT (default 127.0.0.1:6379); password vault
    file REDIS_PASS_FILE (~/banxe-fabric/.vault/redis.pass). The counter is kept
    >= the frozen sequence max: a fresh/behind counter is bumped (repeat INCR) until
    it exceeds current_max, so no number below an already-assigned one is handed out.
    Raises on any failure (caller degrades to local max+1).
    """
    RedisStreams, _RedisUnavailable = _load_fabric_redis()
    if RedisStreams is None:
        raise RuntimeError("fabric_redis not importable")
    host = os.environ.get("TL_REDIS_HOST", "127.0.0.1")
    port = int(os.environ.get("TL_REDIS_PORT", "6379"))
    pw = os.environ.get("REDIS_PASS_FILE", os.path.expanduser("~/banxe-fabric/.vault/redis.pass"))
    client = RedisStreams(host, port, pw)
    try:
        val = client.incr(IL_COUNTER_KEY)
        # Monotonicity guarantee: never return a number <= the frozen sequence max.
        while val <= current_max:
            val = client.incr(IL_COUNTER_KEY)
        return val
    finally:
        client.close()


def _alloc_next(current_max):
    """Allocate the next IL number for a NEW shard (live mint only).

    Source = central Redis counter (cross-process atomic anti-collision). On ANY
    Redis failure, degrade to local max+1 with a loud RACE warning (ADR-104 §5
    graceful degrade — never crash the build). Set BANXE_IL_ALLOCATOR=local to
    force the offline path explicitly (used by --check-equivalent deterministic runs).
    """
    if os.environ.get("BANXE_IL_ALLOCATOR", "redis").lower() == "local":
        return current_max + 1
    try:
        return _redis_allocate(current_max)
    except Exception as exc:  # RedisUnavailable or import/config error
        sys.stderr.write(
            "WARN: Redis allocator unavailable (%s); fallback to local max+1 — "
            "RACE POSSIBLE if multiple terminals mint concurrently.\n" % exc
        )
        return current_max + 1


def assign(records, use_allocator=False):
    """Return (numbering: key->int, new_keys: list) without writing.

    Existing keys keep their frozen number; new shards get the next number, in
    (il_ts, session_id, path) order (records is already sorted that way).
    On first run (empty map) this replays the legacy FROZEN-offset numbering,
    so existing shards keep EXACTLY their present IL-NNN.

    use_allocator=True (live mint, write mode) sources each NEW number from the
    central Redis allocator (ADR-143). use_allocator=False (--check / rebuild)
    is fully offline + deterministic: it only ever reproduces already-frozen
    numbers, and any (unexpected) new key falls back to local max+1.
    """
    seq = load_sequence()
    numbering = dict(seq)
    base = max(numbering.values()) if numbering else frozen_offset()
    new_keys = []
    for r in records:
        k = shard_key(r)
        if k not in numbering:
            num = _alloc_next(base) if use_allocator else base + 1
            if num <= base:  # strict-monotonic clamp (allocator must never regress)
                num = base + 1
            base = num
            numbering[k] = num
            new_keys.append(k)
    return numbering, new_keys


def render(records, numbering):
    frozen = FROZEN.read_text(encoding="utf-8") if FROZEN.exists() else HEADER
    out = [frozen.rstrip("\n") + "\n"]
    ordered = sorted(records, key=lambda r: numbering[shard_key(r)])
    for r in ordered:
        num = "IL-{:03d}".format(numbering[shard_key(r)])
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


def dump_sequence(numbering):
    """Serialise IL-SEQUENCE.json deterministically (keys in IL-number order)."""
    ordered = dict(sorted(numbering.items(), key=lambda kv: (kv[1], kv[0])))
    return json.dumps(ordered, indent=2, ensure_ascii=False) + "\n"


def head_sequence():
    """IL-SEQUENCE.json as committed at git HEAD (or None if absent/no git)."""
    try:
        blob = subprocess.run(
            ["git", "show", "HEAD:ledger/IL-SEQUENCE.json"],
            cwd=str(ROOT), capture_output=True, text=True,
        )
    except (OSError, ValueError):
        return None
    if blob.returncode != 0 or not blob.stdout.strip():
        return None
    try:
        return json.loads(blob.stdout)
    except json.JSONDecodeError:
        return None


def check_append_only(numbering):
    """Assert IL-SEQUENCE.json is append-only vs git HEAD: no existing key
    removed, no existing value mutated. Returns error string or None."""
    head = head_sequence()
    if head is None:
        return None  # first introduction / no git context — nothing to compare
    for k, v in head.items():
        if k not in numbering:
            return "IL-SEQUENCE.json append-only violation: key removed: " + k
        if numbering[k] != v:
            return ("IL-SEQUENCE.json append-only violation: value mutated for "
                    + k + " (" + str(v) + " -> " + str(numbering[k]) + ")")
    return None


# Historical IL-value duplicates that predate the global-uniqueness gate (ADR-133).
# Renumber is FORBIDDEN (ADR-119), so these are accepted as known-debt; only NEW
# duplicate values are rejected. See docs/adr/ADR-133-*.md and the #799 debt record.
ALLOWED_DUP_VALUES = {540}


def check_global_uniqueness(numbering):
    """Assert IL-SEQUENCE.json VALUES are globally unique (ADR-133), closing the
    shard_key gap (uniqueness was enforced only per filesystem path, not per IL
    number). Allowlisted historical dups (ALLOWED_DUP_VALUES) pass; any other value
    assigned to >1 shard fails. Returns error string or None."""
    counts = {}
    for v in numbering.values():
        counts[v] = counts.get(v, 0) + 1
    bad = sorted(v for v, n in counts.items() if n > 1 and v not in ALLOWED_DUP_VALUES)
    if bad:
        return ("IL-SEQUENCE.json global-uniqueness violation (ADR-133): value(s) "
                "assigned to >1 shard: " + ", ".join("IL-%03d" % v for v in bad)
                + " (renumber forbidden ADR-119; new duplicates rejected). "
                "Allowlisted historical dups: "
                + ", ".join("IL-%03d" % v for v in sorted(ALLOWED_DUP_VALUES)))
    return None


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true",
                    help="verify INSTRUCTION-LEDGER.md == rebuild + sequence append-only")
    args = ap.parse_args(argv)
    records = collect()
    # --check / rebuild: offline + deterministic (no Redis). Live write: central
    # Redis allocator mints any NEW shard number (ADR-143).
    numbering, _new = assign(records, use_allocator=not args.check)
    content = render(records, numbering)
    seq_content = dump_sequence(numbering)

    if args.check:
        rc = 0
        current = LEDGER.read_text(encoding="utf-8") if LEDGER.exists() else ""
        if current != content:
            sys.stderr.write(
                "FAIL: INSTRUCTION-LEDGER.md is out of sync with shards.\n"
                "Run: python ledger/build_ledger.py\n"
            )
            rc = 1
        cur_seq = SEQUENCE.read_text(encoding="utf-8") if SEQUENCE.exists() else ""
        if cur_seq != seq_content:
            sys.stderr.write(
                "FAIL: ledger/IL-SEQUENCE.json is out of sync with shards.\n"
                "Run: python ledger/build_ledger.py\n"
            )
            rc = 1
        ao = check_append_only(numbering)
        if ao:
            sys.stderr.write("FAIL: " + ao + "\n")
            rc = 1
        gu = check_global_uniqueness(numbering)
        if gu:
            sys.stderr.write("FAIL: " + gu + "\n")
            rc = 1
        if rc == 0:
            sys.stdout.write("ledger-build check OK\n")
        return rc

    ao = check_append_only(numbering)
    if ao:
        sys.stderr.write("FAIL: " + ao + "\n")
        return 1
    gu = check_global_uniqueness(numbering)
    if gu:
        sys.stderr.write("FAIL: " + gu + "\n")
        return 1
    LEDGER.write_text(content, encoding="utf-8")
    SEQUENCE.write_text(seq_content, encoding="utf-8")
    sys.stdout.write("Wrote " + str(LEDGER) + " + " + str(SEQUENCE) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
