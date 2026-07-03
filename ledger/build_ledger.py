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


def _redis_config():
    """Config for the SHARED fabric Redis counter (ADR-143-A).

    Same env vars + defaults as fabric/legion/gate_exec_consumer.py so EVERY
    terminal (evo1 / evo2 / Legion) increments ONE counter on the evo1 host over
    tailscale — that is the only thing that makes the anti-collision real.
    Explicit REDIS_HOST/REDIS_PORT override the evo1 default. NOT TL_REDIS_*
    (that is local traffic-light monitoring, a per-host 127.0.0.1 counter).
    """
    host = os.environ.get("REDIS_HOST", "100.68.102.48")  # evo1 shared counter over tailscale (matches docstring + test)
    port = int(os.environ.get("REDIS_PORT", "6379"))
    pw = os.environ.get("REDIS_PASS_FILE", os.path.expanduser("~/banxe-fabric/.vault/redis.pass"))
    return host, port, pw


def _redis_allocate(current_max):
    """Monotonic IL number strictly > current_max via atomic INCR on the SHARED
    evo1 Redis counter (banxe:il:counter). Config = _redis_config() (REDIS_HOST/
    REDIS_PORT/REDIS_PASS_FILE, default evo1 100.68.102.48:6379).

    On first contact the counter floor is seeded to the frozen sequence max
    (SET only when the counter is below it) so a fresh evo1 counter never hands
    out a number below an already-assigned one; the INCR-until-> loop is the
    atomic safety net that also covers any seed race between terminals.
    Raises on any failure (caller FAILS LOUD — see _alloc_next — unless the offline
    path is explicitly requested via BANXE_IL_ALLOCATOR=local).
    """
    RedisStreams, _RedisUnavailable = _load_fabric_redis()
    if RedisStreams is None:
        raise RuntimeError("fabric_redis not importable")
    host, port, pw = _redis_config()
    client = RedisStreams(host, port, pw)
    try:
        cur = client.get(IL_COUNTER_KEY)
        cur_int = int(cur) if cur is not None else 0
        if cur_int < current_max:  # seed floor (optimization; loop below guarantees correctness)
            client.set(IL_COUNTER_KEY, current_max)
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
    Redis failure the mint FAILS LOUD (RuntimeError) — it does NOT silently fall
    back to a local max+1 counter, because that silent degrade is exactly what
    causes cross-terminal IL collisions (the IL-thrash class: two hosts both mint
    local max+1 off the same base). The offline local counter is available ONLY
    when explicitly requested via BANXE_IL_ALLOCATOR=local (which accepts the
    race, e.g. deterministic offline runs). NB: --check never calls this path.
    """
    if os.environ.get("BANXE_IL_ALLOCATOR", "redis").lower() == "local":
        return current_max + 1
    try:
        return _redis_allocate(current_max)
    except Exception as exc:  # RedisUnavailable or import/config error
        host, port, _pw = _redis_config()
        raise RuntimeError(
            "FATAL: shared fabric Redis %s:%d unreachable (%s) — IL allocation "
            "REFUSED to prevent SILENT local-counter collisions (the IL-thrash "
            "class). Fix: point REDIS_HOST at the evo1 counter (100.68.102.48) and "
            "provide REDIS_PASSWORD / REDIS_PASS_FILE, or bring Redis up. To use the "
            "offline local counter DELIBERATELY (accepting cross-terminal race), set "
            "BANXE_IL_ALLOCATOR=local." % (host, port, exc)
        ) from exc


def find_orphans(records, sequence):
    """Return [(key, value), ...] for ORPHAN keys in `sequence`: keys in the
    ACTIVE range (value > frozen_offset) that have NO live shard in entries/.

    These are stale index-keys left behind when a branch's shard path (hence its
    shard_key hash) changed on a forced-update/rebuild — the old key lingers in
    IL-SEQUENCE.json with no backing shard (the orphan-from-rebase class, ADR-144).
    Keys with value <= frozen_offset are FROZEN-ARCHIVE entries that legitimately
    have no entries/ shard — they are NEVER orphans and are never reported here.
    """
    live = {shard_key(r) for r in records}
    fmax = frozen_offset()
    return [(k, v) for k, v in sequence.items() if k not in live and v > fmax]


def prune_orphans(numbering, records):
    """Remove ORPHAN keys (find_orphans) from `numbering` IN PLACE.

    Pruning a stale index-key is NOT a violation of append-only PRIOR ENTRIES
    (ADR-057/059-A): an orphan has no shard record in the ledger — it is debris
    in the index map, not a recorded IL. Live shard numbers and the FROZEN range
    are untouched (ADR-119: live numbers stay frozen). Returns removed [(k,v),...].
    """
    removed = find_orphans(records, numbering)
    for k, _v in removed:
        del numbering[k]
    return numbering, removed


def assign(records, use_allocator=False):
    """Return (numbering: key->int, new_keys: list) without writing.

    Existing keys keep their frozen number; new shards get the next number, in
    (il_ts, session_id, path) order (records is already sorted that way).
    On first run (empty map) this replays the legacy FROZEN-offset numbering,
    so existing shards keep EXACTLY their present IL-NNN.

    Orphan index-keys are PRUNED first (ADR-144) so they neither inflate `base`
    nor linger in the written map. use_allocator=True (live mint, write mode)
    sources each NEW number from the central Redis allocator (ADR-143).
    use_allocator=False (--check / rebuild) is fully offline + deterministic.
    """
    seq = load_sequence()
    numbering = dict(seq)
    numbering, _orphans = prune_orphans(numbering, records)  # ADR-144 — drop stale index-keys
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


def check_append_only(numbering, records):
    """Assert IL-SEQUENCE.json is append-only vs git HEAD: no RECORDED key
    removed, no existing value mutated. Returns error string or None.

    Removal of an ORPHAN index-key (no live shard, active range — ADR-144) is
    PERMITTED: an orphan is not a recorded IL, so pruning it does not violate
    append-only of prior entries. Removal of a LIVE shard's key, or of any
    frozen key, is still a violation.
    """
    head = head_sequence()
    if head is None:
        return None  # first introduction / no git context — nothing to compare
    live = {shard_key(r) for r in records}
    fmax = frozen_offset()
    for k, v in head.items():
        if k not in numbering:
            if k not in live and v > fmax:
                continue  # ADR-144: orphan prune is allowed (stale index-key, no shard)
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
        # ADR-144: orphan detection on the COMMITTED sequence — fail loudly (do NOT
        # silently prune) so a regenerate is forced. Offline + deterministic.
        orphans = find_orphans(records, load_sequence())
        if orphans:
            sys.stderr.write(
                "FAIL: ORPHAN shard_key(s) in IL-SEQUENCE.json without an entries shard: "
                + ", ".join("%s=IL-%03d" % (k, v) for k, v in sorted(orphans, key=lambda x: x[1]))
                + " — run `python ledger/build_ledger.py` to prune them (ADR-144).\n"
            )
            rc = 1
        ao = check_append_only(numbering, records)
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

    ao = check_append_only(numbering, records)
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
