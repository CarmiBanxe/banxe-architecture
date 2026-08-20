#!/usr/bin/env python3
"""validate_orgcells.py — ORG-CELL SCHEMA v1.1 validator. REPORT-ONLY.

Checks V1' / V2 / V3b / V4 / V7 across docs/orgcells/*.md.

Report-only by design: exit code is 0 even on violations until the schema is
ratified (MC-C1). The report still prints every violation — a gate that blocks
before its schema is canon would be enforcing a proposal.
Use --strict to get a non-zero exit once ratification lands.

Usage:
    python3 scripts/validate_orgcells.py [--dir docs/orgcells] [--strict]
"""
from __future__ import annotations
import argparse, glob, os, re, sys

# LINE REGISTRY (SCHEMA v1.1 §1) — closed. line -> (root kind, basis present)
LINE_REGISTRY = {
    "ENGINE_HIERARCHY": "ENGINE_DIRECTOR",
    "MLRO_LINE":        "MLRO_ROOT",
    "DPO_LINE":         "DPO_ROOT",
    "AUDIT_LINE":       "AUDIT_ROOT",
}

# V3b — function classes that constitute data-protection oversight
DPO_FUNCTION_MARKERS = (
    "dpia", "data-subject request", "data subject request", "dsr ",
    "breach-notification", "breach notification", "record of processing",
)

FIELD = re.compile(r"^\s*(cell_id|kind|reporting_line|manager_ref|department_ref|status)\s*:\s*([^#\n]+)")


def parse_cell(path: str) -> dict | None:
    """Read the first ```yaml block of a CELL file. Deliberately not a YAML parser:
    the block is a fixed 9-key record, and depending on PyYAML would make the
    validator fail to run in environments where the schema itself is readable."""
    text = open(path, encoding="utf-8", errors="replace").read()
    m = re.search(r"```yaml\n(.*?)```", text, re.S)
    if not m:
        return None
    # V3b is scoped to the functions[] section only. A cooperation row in
    # horizontal[] that merely *mentions* DPIA is correct behaviour, not a
    # violation — flagging it would train readers to ignore the validator.
    fn = re.search(r"^##+\s*functions.*?$(.*?)(?=^##+\s|\Z)", text, re.S | re.M)
    rec = {"_path": path, "_text": text, "_functions": (fn.group(1) if fn else "")}
    for line in m.group(1).splitlines():
        f = FIELD.match(line)
        if f:
            rec[f.group(1)] = f.group(2).strip().strip('"').strip()
    return rec


def validate(cells: list[dict]) -> list[tuple[str, str, str]]:
    """-> list of (rule, cell_id, message)"""
    out: list[tuple[str, str, str]] = []
    by_id = {c.get("cell_id"): c for c in cells if c.get("cell_id")}
    roots_per_line: dict[str, list[str]] = {}

    for c in cells:
        cid = c.get("cell_id", os.path.basename(c["_path"]))
        line = c.get("reporting_line")
        kind = c.get("kind")
        mgr = c.get("manager_ref")

        # --- V1' : null manager permitted ONLY for a registered line root
        if mgr in (None, "null"):
            if line not in LINE_REGISTRY:
                out.append(("V1'", cid,
                            f"null manager but reporting_line '{line}' is not in the LINE REGISTRY"))
            elif kind != LINE_REGISTRY[line]:
                out.append(("V1'", cid,
                            f"root of {line} must have kind {LINE_REGISTRY[line]}, found '{kind}'"))
            else:
                roots_per_line.setdefault(line, []).append(cid)

        # --- V2 / V4 : manager must exist and share the reporting_line
        if mgr not in (None, "null"):
            tgt = by_id.get(mgr)
            if tgt is None:
                out.append(("V2", cid, f"manager_ref '{mgr}' does not resolve to any cell"))
            elif tgt.get("reporting_line") != line:
                out.append(("V2/V4", cid,
                            f"cross-line vertical edge: '{cid}' ({line}) -> '{mgr}' "
                            f"({tgt.get('reporting_line')}) — authority across lines is unrepresentable"))

        # --- V3b : data-protection oversight implies DPO_LINE
        fbody = c.get("_functions", "").lower()
        hits = [k for k in DPO_FUNCTION_MARKERS if k in fbody]
        if hits and line != "DPO_LINE":
            out.append(("V3b", cid,
                        f"functions[] carry data-protection oversight ({', '.join(hits)}) "
                        f"but reporting_line is '{line}'"))

        # --- V7 : the line must be registered at all
        if line and line not in LINE_REGISTRY:
            out.append(("V7", cid,
                        f"reporting_line '{line}' is not in the LINE REGISTRY — "
                        f"adding a line requires a citable basis"))

    # --- V1' : exactly one root per registered line
    for line, roots in roots_per_line.items():
        if len(roots) > 1:
            out.append(("V1'", ",".join(roots), f"line {line} has {len(roots)} roots, expected exactly 1"))
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default="docs/orgcells")
    ap.add_argument("--strict", action="store_true",
                    help="exit non-zero on violations (post-ratification mode)")
    a = ap.parse_args()

    paths = sorted(glob.glob(os.path.join(a.dir, "CELL-*.md")))
    if not paths:
        print(f"no CELL-*.md under {a.dir}")
        return 0

    cells = [c for c in (parse_cell(p) for p in paths) if c]
    print(f"ORG-CELL SCHEMA v1.1 validator — REPORT-ONLY — {len(cells)} cell(s) in {a.dir}\n")
    for c in cells:
        print(f"  {c.get('cell_id','?'):20} {c.get('kind','?'):16} "
              f"{c.get('reporting_line','?'):18} manager={c.get('manager_ref','?')}")

    viol = validate(cells)
    print()
    if not viol:
        print("PASS — no violations of V1'/V2/V3b/V4/V7.")
    else:
        print(f"{len(viol)} violation(s):")
        for rule, cid, msg in viol:
            print(f"  [{rule}] {cid}: {msg}")

    lines_seen = {c.get("reporting_line") for c in cells}
    missing = [l for l in LINE_REGISTRY if l not in lines_seen]
    if missing:
        print(f"\nnote: registered lines with no cell yet: {', '.join(missing)}")

    return 1 if (viol and a.strict) else 0


if __name__ == "__main__":
    sys.exit(main())
