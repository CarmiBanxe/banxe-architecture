#!/usr/bin/env python3
"""B3 org-contour producer — read-only overlay for GitNexus impact reports.

LICENSE: GitNexus = PolyForm-Noncommercial-1.0.0. Sandbox/TRAINING use only
(GITNEXUS_ENV=sandbox); PROD/commercial use requires a purchased license.

Canon: PHASE3-ORG-CONTOUR-VERDICT B/B3. Directive p.25-26: the code graph
carries ONLY code relations; the org layer is SEPARATE and is joined to code
exclusively via cross-link edges B1_OWNED_BY / B2_OWNS_PATH. This script never
touches the code graph (no KuzuDB required) and never writes to the repo.

NO-MOCK: every owner/agent comes from real artifacts —
  B2: config/gitnexus/org-path-ownership.map.yaml (room globs -> owner_line),
  B1: bank-rooms/*/agents-roster.md (registry-generated; source_path column)
      enriched from agents/passports/*.yaml (+ config/agents/passports/).
Ambiguity is NEVER guessed: unmatched paths -> "unowned_paths", rooms pending
operator decisions (todo_operator) -> "unresolved_departments".

Output (additive contract, GITNEXUS-PHASE3-CROSSLINK-INTEGRATION-NOTE.md):
  {impacted_departments, accountable_agents, unresolved_departments,
   unowned_paths} — Phase-1 fields risk/blast_radius/files are NOT emitted
here and stay unchanged in detect_impact.py.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
MAP_PATH = REPO_ROOT / "config/gitnexus/org-path-ownership.map.yaml"
ROOMS_DIR = REPO_ROOT / "bank-rooms"
PASSPORT_DIRS = (REPO_ROOT / "agents/passports",
                 REPO_ROOT / "config/agents/passports")


@dataclass
class Room:
    name: str
    prefix: str                      # glob "bank-rooms/X/**" -> prefix "bank-rooms/X/"
    owner_line: str | None = None
    core_exempt: bool = False


@dataclass
class RosterAgent:
    agent_id: str
    name: str
    source_path: str
    human_double: str
    smf: str
    status: str
    room: str
    passport: dict[str, str] = field(default_factory=dict)


def _unquote(raw: str) -> str:
    val = raw.split("#", 1)[0].strip() if not raw.strip().startswith('"') \
        else raw.strip()
    if val.startswith('"'):
        end = val.find('"', 1)
        return val[1:end] if end > 0 else val.strip('"')
    return val.strip()


def parse_ownership_map(path: Path) -> tuple[dict[str, Room], list[str]]:
    """Targeted parser for the known map.yaml shape (stdlib-only, no pyyaml)."""
    rooms: dict[str, Room] = {}
    todo: list[str] = []
    current: Room | None = None
    section = ""
    for line in path.read_text(encoding="utf-8").splitlines():
        if re.match(r"^(rooms|service_tags|resolved_todo|todo_operator)\s*:", line):
            section = line.split(":", 1)[0].strip()
            if section == "todo_operator" and "[]" not in line:
                section = "todo_operator_list"
            continue
        if section == "rooms":
            m_room = re.match(r"^  (F\d[\w-]*)\s*:\s*$", line)
            if m_room:
                current = Room(name=m_room.group(1), prefix="")
                rooms[current.name] = current
                continue
            if current and (m_kv := re.match(r"^    (\w+)\s*:\s*(.+)$", line)):
                key, val = m_kv.group(1), _unquote(m_kv.group(2))
                if key == "path":
                    current.prefix = val[:-2] if val.endswith("**") else val
                elif key == "owner_line":
                    current.owner_line = val
                elif key == "core_exempt":
                    current.core_exempt = val.lower() == "true"
        elif section == "todo_operator_list" and line.strip().startswith("- "):
            todo.append(line.strip()[2:].strip('"'))
    return rooms, todo


def parse_passports(dirs: tuple[Path, ...]) -> dict[str, dict[str, str]]:
    """Index passports by normalized agent_id AND name (top-level keys only)."""
    wanted = {"agent_id", "name", "department", "bounded_context", "role",
              "human_double", "status"}
    index: dict[str, dict[str, str]] = {}
    for d in dirs:
        for f in sorted(d.glob("*.yaml")) if d.is_dir() else []:
            data: dict[str, str] = {}
            for line in f.read_text(encoding="utf-8").splitlines():
                if m := re.match(r"^([a-z_]+)\s*:\s*(.+)$", line):
                    if m.group(1) in wanted:
                        data[m.group(1)] = _unquote(m.group(2))
            for key in ("agent_id", "name"):
                if key in data:
                    index[_norm(data[key])] = data
    return index


def _norm(s: str) -> str:
    return re.sub(r"[^a-z0-9]", "", s.lower())


def parse_rosters(rooms_dir: Path,
                  passports: dict[str, dict[str, str]]) -> list[RosterAgent]:
    agents: list[RosterAgent] = []
    for roster in sorted(rooms_dir.glob("*/agents-roster.md")):
        room = roster.parent.name
        for line in roster.read_text(encoding="utf-8").splitlines():
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if len(cells) < 9 or not cells[0].startswith("AG-"):
                continue
            agent = RosterAgent(agent_id=cells[0], name=cells[1],
                                source_path=cells[2], human_double=cells[4],
                                smf=cells[5], status=cells[8], room=room)
            agent.passport = passports.get(_norm(agent.name),
                                           passports.get(_norm(agent.agent_id), {}))
            agents.append(agent)
    return agents


def resolve(files: list[str], rooms: dict[str, Room], todo: list[str],
            roster: list[RosterAgent]) -> dict[str, object]:
    impacted: dict[str, dict[str, object]] = {}
    accountable: dict[str, dict[str, object]] = {}
    unowned: list[str] = []
    by_source = {a.source_path: a for a in roster}
    for f in files:
        room = next((r for r in rooms.values()
                     if r.prefix and f.startswith(r.prefix)), None)
        hit = by_source.get(f) or next(
            (a for a in roster if f.endswith(a.source_path)), None)
        if room:
            impacted[room.name] = {"room": room.name,
                                   "owner_line": room.owner_line,
                                   "core_exempt": room.core_exempt}
            for a in roster:
                if a.room == room.name:
                    accountable[a.agent_id] = _agent_entry(a, "room-roster")
        if hit:
            accountable[hit.agent_id] = _agent_entry(hit, "source_path")
            impacted.setdefault(hit.room, {
                "room": hit.room,
                "owner_line": rooms.get(hit.room, Room(hit.room, "")).owner_line,
                "core_exempt": rooms.get(hit.room, Room(hit.room, "")).core_exempt})
        if not room and not hit:
            unowned.append(f)
    return {"impacted_departments": sorted(impacted.values(),
                                           key=lambda d: str(d["room"])),
            "accountable_agents": sorted(accountable.values(),
                                         key=lambda a: str(a["agent_id"])),
            "unresolved_departments": todo,
            "unowned_paths": unowned}


def _agent_entry(a: RosterAgent, matched_by: str) -> dict[str, object]:
    entry: dict[str, object] = {
        "agent_id": a.agent_id, "name": a.name, "room": a.room,
        "human_double": a.human_double, "smf": a.smf, "status": a.status,
        "matched_by": matched_by, "provenance": "agents-roster.md"}
    if a.passport:
        entry["passport"] = {k: a.passport[k] for k in
                             ("department", "bounded_context", "human_double")
                             if k in a.passport}
    return entry


def staged_files() -> list[str]:
    out = subprocess.run(["git", "diff", "--staged", "--name-only"],
                         cwd=REPO_ROOT, capture_output=True, text=True,
                         check=True)
    return [l for l in out.stdout.splitlines() if l.strip()]


def build_overlay(files: list[str]) -> dict[str, object]:
    rooms, todo = parse_ownership_map(MAP_PATH)
    passports = parse_passports(PASSPORT_DIRS)
    roster = parse_rosters(ROOMS_DIR, passports)
    return resolve(files, rooms, todo, roster)


def self_test() -> int:
    samples = ["bank-rooms/F2-payments-room/x.py",
               "bank-rooms/F0-engine-manus-room/y.py",
               "services/aml/tx_monitor.py",
               "totally/unmapped/path.py"]
    overlay = build_overlay(samples)
    print(json.dumps({"samples": samples, "overlay": overlay},
                     indent=2, ensure_ascii=False))
    rooms, todo = parse_ownership_map(MAP_PATH)
    print(f"\n[self-test] rooms mapped: {len(rooms)} "
          f"(core_exempt: {sum(r.core_exempt for r in rooms.values())}); "
          f"todo_operator rows: {len(todo)}; "
          f"passports indexed: {len(parse_passports(PASSPORT_DIRS))}; "
          f"roster agents: {len(parse_rosters(ROOMS_DIR, {}))}",
          file=sys.stderr)
    return 0


def main(argv: list[str]) -> int:
    if "--self-test" in argv:
        return self_test()
    files = staged_files() if "--staged" in argv \
        else [a for a in argv[1:] if not a.startswith("--")]
    print(json.dumps(build_overlay(files), indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
