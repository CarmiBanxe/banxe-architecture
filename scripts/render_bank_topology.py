#!/usr/bin/env python3
"""Render bank topology projections from the agent registry.

Canon (ADR-BANK-TOPOLOGY-03): the agent registry is the authoritative fact
table; the tree, the floor plan and the accountability map are PROJECTIONS of
it. Diagrams are generated, never hand-drawn and never committed as canon.

Usage:
    python scripts/render_bank_topology.py [--registry PATH] [--out PATH]

Exit codes: 0 ok, 1 registry unreadable or malformed.
"""
from __future__ import annotations

import argparse
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path

DEFAULT_REGISTRY = Path("docs/governance/AGENT-REGISTRY-BANK-MASTER-2026-07-22.md")
COLUMNS = (
    "agent_id", "canonical_name", "source_path", "class", "room", "department",
    "floor", "human_double", "SMF", "decision_or_tooling", "hitl_gate", "status",
)
# Rooms whose control authority is RESERVED: they run on the shared trunk but
# the director holds no command edge over them (ADR-BANK-TOPOLOGY-03 §MLRO).
RESERVED_CONTROL_ROOMS = frozenset({"F3-aml", "F4-audit-cell"})


@dataclass(frozen=True)
class Agent:
    agent_id: str
    canonical_name: str
    room: str
    department: str
    floor: str
    human_double: str
    smf: str
    kind: str
    hitl_gate: str
    status: str

    @property
    def is_decision(self) -> bool:
        return self.kind.lower().startswith("decision")

    @property
    def reserved_control(self) -> bool:
        return self.room in RESERVED_CONTROL_ROOMS


def parse_registry(path: Path) -> list[Agent]:
    """Parse every markdown table row whose first cell is an AG- identifier."""
    agents: dict[str, Agent] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.startswith("| AG-"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < len(COLUMNS):
            raise ValueError(f"malformed row ({len(cells)} cells): {line[:80]}")
        row = dict(zip(COLUMNS, cells))
        agents[row["agent_id"]] = Agent(
            agent_id=row["agent_id"],
            canonical_name=row["canonical_name"],
            room=row["room"],
            department=row["department"],
            floor=row["floor"],
            human_double=row["human_double"],
            smf=row["SMF"],
            kind=row["decision_or_tooling"],
            hitl_gate=row["hitl_gate"],
            status=row["status"],
        )
    if not agents:
        raise ValueError(f"no agent rows found in {path}")
    return sorted(agents.values(), key=lambda a: a.agent_id)


def render_tree(agents: list[Agent]) -> str:
    """Trunk -> floors -> rooms. Reserved-control rooms are marked, not nested
    under the director: the shared runtime is one tree, authority is not."""
    by_floor: dict[str, dict[str, list[Agent]]] = defaultdict(lambda: defaultdict(list))
    for a in agents:
        by_floor[a.floor][a.room].append(a)
    out = ["```mermaid", "graph TD", '  TRUNK["TRUNK / director engine<br/>orchestration"]']
    for floor in sorted(by_floor):
        out.append(f'  {floor}["{floor}"]')
        out.append(f"  TRUNK --> {floor}")
        for room, members in sorted(by_floor[floor].items()):
            node = room.replace("-", "_")
            reserved = room in RESERVED_CONTROL_ROOMS
            label = f"{room}<br/>{len(members)} agents"
            if reserved:
                label += "<br/>RESERVED CONTROL<br/>(no command edge)"
            out.append(f'  {node}["{label}"]')
            out.append(f"  {floor} -.-> {node}" if reserved else f"  {floor} --> {node}")
    out.append("```")
    return "\n".join(out)


def render_occupancy(agents: list[Agent]) -> str:
    rows = ["| floor | room | agents | decision | tooling | reserved-control |",
            "|---|---|--:|--:|--:|---|"]
    by_room: dict[tuple[str, str], list[Agent]] = defaultdict(list)
    for a in agents:
        by_room[(a.floor, a.room)].append(a)
    for (floor, room), members in sorted(by_room.items()):
        decisions = sum(1 for m in members if m.is_decision)
        mark = "YES" if room in RESERVED_CONTROL_ROOMS else "-"
        rows.append(
            f"| {floor} | {room} | {len(members)} | {decisions} | "
            f"{len(members) - decisions} | {mark} |"
        )
    return "\n".join(rows)


def render_accountability(agents: list[Agent]) -> str:
    """Human double / SMF map: who answers for which agents (last-mile human)."""
    counts: Counter[tuple[str, str]] = Counter(
        (a.human_double or "-", a.smf or "-") for a in agents
    )
    rows = ["| human double | SMF | agents | gap |", "|---|---|--:|---|"]
    for (double, smf), count in counts.most_common():
        gap = "NO HUMAN DOUBLE" if double in {"-", ""} else ""
        rows.append(f"| {double} | {smf} | {count} | {gap} |")
    return "\n".join(rows)


def render_report(agents: list[Agent], registry: Path) -> str:
    decisions = sum(1 for a in agents if a.is_decision)
    orphans = sum(1 for a in agents if a.human_double in {"-", ""})
    gated = sum(1 for a in agents if a.hitl_gate not in {"-", ""})
    reserved = sum(1 for a in agents if a.reserved_control)
    return "\n\n".join([
        "# BANK TOPOLOGY — generated projection",
        "> GENERATED by `scripts/render_bank_topology.py` from "
        f"`{registry}`. Do not edit by hand; regenerate instead "
        "(ADR-BANK-TOPOLOGY-03: registry is the fact, this is a view).",
        "## Counters",
        "\n".join([
            f"- agents: **{len(agents)}**",
            f"- decision-class: **{decisions}** / tooling-class: **{len(agents) - decisions}**",
            f"- reserved-control (no director command edge): **{reserved}**",
            f"- with HITL gate: **{gated}**",
            f"- without human double: **{orphans}**",
        ]),
        "## Tree (trunk -> floors -> rooms)", render_tree(agents),
        "## Floor occupancy", render_occupancy(agents),
        "## Accountability (last-mile human)", render_accountability(agents),
    ]) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--registry", type=Path, default=DEFAULT_REGISTRY)
    parser.add_argument("--out", type=Path, default=None)
    args = parser.parse_args()
    try:
        agents = parse_registry(args.registry)
    except (OSError, ValueError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    report = render_report(agents, args.registry)
    if args.out:
        args.out.write_text(report, encoding="utf-8")
        print(f"wrote {args.out} ({len(agents)} agents)")
    else:
        print(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
