#!/usr/bin/env python3
"""GapTrackerAgent — mandatory gap status reporter for BANXE EMI."""

import re
import sys
from pathlib import Path
from datetime import date

GAP_FILE = Path(__file__).parent.parent / "docs" / "GAP-REGISTER.md"
TODAY = date.today().isoformat()


def parse_gaps():
    text = GAP_FILE.read_text()
    pattern = r'\|\s*(GAP-\d+)\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|(?:\s*(.+?)\s*\|)?\s*(❌|⚠️|✅)[^\|]*\|'
    return re.findall(pattern, text)


def print_status():
    gaps = parse_gaps()
    open_p0 = []
    overdue = []
    in_progress = []

    for g in gaps:
        gid, desc, sprint, owner, deadline, status = g
        if '❌' in status:
            if 'May 2026' in deadline or 'NOW' in deadline:
                open_p0.append((gid, desc.strip()[:60], deadline.strip()))
            if 'OVERDUE' in desc:
                overdue.append((gid, desc.strip()[:60]))
        elif '⚠️' in status:
            in_progress.append((gid, desc.strip()[:60]))

    print("=" * 65)
    print("  GapTrackerAgent — BANXE EMI Gap Status Report")
    print(f"  Date: {TODAY}")
    print("=" * 65)

    if open_p0:
        print("\n🔴 P0 CRITICAL — FCA AUTHORISATION AT RISK:")
        for gid, desc, dl in open_p0:
            print(f"  {gid}: {desc}")
            print(f"         Deadline: {dl}")

    if overdue:
        print("\n⛔ OVERDUE ITEMS:")
        for gid, desc in overdue:
            print(f"  {gid}: {desc}")

    if in_progress:
        print("\n⚠️  IN PROGRESS:")
        for gid, desc in in_progress:
            print(f"  {gid}: {desc}")

    total = len(gaps)
    open_count = sum(1 for g in gaps if '❌' in g[5])
    done_count = sum(1 for g in gaps if '✅' in g[5])
    wip_count = total - open_count - done_count
    print(f"\n📊 Total: {total} gaps | Open: {open_count} | Done: {done_count} | In Progress: {wip_count}")
    print("=" * 65)
    print("  ⚠️  Return to GAP-REGISTER.md before closing session.")
    print("=" * 65)


def print_sprint(sprint_label="Sprint 12"):
    gaps = parse_gaps()
    sprint_items = [g for g in gaps if sprint_label in g[2] and '❌' in g[5]]
    print(f"\n📋 Open items for {sprint_label}:")
    for g in sprint_items:
        gid, desc, sprint, owner, deadline, status = g
        print(f"  {gid}: {desc.strip()[:60]}  [Owner: {owner.strip()}]")
    print(f"\nTotal open in {sprint_label}: {len(sprint_items)}")


def update_gap(gap_id: str, new_status: str):
    """Update a single GAP status in the register."""
    text = GAP_FILE.read_text()
    emoji_map = {"DONE": "✅", "WIP": "⚠️", "OPEN": "❌"}
    new_emoji = emoji_map.get(new_status.upper(), new_status)

    pattern = rf'(\|\s*{re.escape(gap_id)}\s*\|[^\n]+)\|\s*[❌⚠️✅][^\|]*\|'
    replacement = rf'\1| {new_emoji} {new_status} |'
    updated = re.sub(pattern, replacement, text)

    if updated == text:
        print(f"WARNING: {gap_id} not found or already at {new_status}")
        return

    GAP_FILE.write_text(updated)
    print(f"✅ {gap_id} updated to {new_status}")


if __name__ == "__main__":
    args = sys.argv[1:]

    if not args or "--status" in args:
        print_status()
    elif "--sprint" in args:
        idx = args.index("--sprint")
        sprint = args[idx + 1] if idx + 1 < len(args) else "Sprint 12"
        print_sprint(sprint)
    elif "--update" in args:
        # Usage: --update GAP-001 DONE
        idx = args.index("--update")
        if idx + 2 < len(args):
            update_gap(args[idx + 1], args[idx + 2])
        else:
            print("Usage: gap-tracker.py --update GAP-XXX DONE|WIP|OPEN")
    elif "--help" in args:
        print("GapTrackerAgent")
        print("  --status              Show P0 critical + overdue + in-progress")
        print("  --sprint Sprint 12    Show open items for a sprint")
        print("  --update GAP-001 DONE Mark a gap as done/wip/open")
    else:
        print_status()
