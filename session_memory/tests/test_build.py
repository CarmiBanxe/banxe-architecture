"""Builder behaviour: missing docs, determinism, role-awareness, read-only."""

from __future__ import annotations

import json
from pathlib import Path

from session_memory.build_session_pack import (
    build_pack,
    find_latest,
    prioritise,
    write_pack,
)
from session_memory.extract_handoff_facts import extract_facts
from session_memory.read_memory_pack import find_latest_pack, load_pack

FIXED = "2026-07-08T00:00:00Z"


def _repo(tmp: Path) -> Path:
    (tmp / "docs/handoff").mkdir(parents=True)
    (tmp / "MEMORY.md").write_text(
        "# Memory\n## Hard invariants\n- I-27 fail-closed\n", encoding="utf-8")
    (tmp / "docs/handoff/HANDOFF-2026-06-25.md").write_text(
        "# Handoff\n## Next actions\n- factory: prepare batch\n- read canon\n",
        encoding="utf-8")
    (tmp / "docs/handoff/session-transfer-package-2026-05-11.md").write_text(
        "# Transfer\n## Operator-gated items\n- await operator merge\n",
        encoding="utf-8")
    return tmp


def test_build_full(tmp_path):
    pack = build_pack(_repo(tmp_path), "central", FIXED)
    assert pack.generated_at == FIXED
    assert len(pack.sources) == 3
    assert pack.warnings == []
    assert any("I-27" in x for x in pack.facts.invariants)
    assert any("operator merge" in x for x in pack.facts.operator_gated)


def test_missing_handoff_doc_warns_not_crashes(tmp_path):
    (tmp_path / "MEMORY.md").write_text("# M\n## Next actions\n- x\n", encoding="utf-8")
    (tmp_path / "docs/handoff").mkdir(parents=True)
    pack = build_pack(tmp_path, "central", FIXED)
    assert "missing source: handoff" in pack.warnings
    assert "missing source: transfer" in pack.warnings
    assert len(pack.sources) == 1  # still built from MEMORY.md


def test_determinism(tmp_path):
    repo = _repo(tmp_path)
    a = build_pack(repo, "central", FIXED).to_dict()
    b = build_pack(repo, "central", FIXED).to_dict()
    assert json.dumps(a, sort_keys=True) == json.dumps(b, sort_keys=True)


def test_find_latest_prefers_iso_date(tmp_path):
    d = tmp_path / "docs/handoff"
    d.mkdir(parents=True)
    for name in ("HANDOFF-2026-06-07.md", "HANDOFF-2026-06-25.md",
                 "HANDOFF-2026-06-08.md"):
        (d / name).write_text("x", encoding="utf-8")
    assert find_latest(d, "HANDOFF-").name == "HANDOFF-2026-06-25.md"


def test_role_prioritisation_reorders_not_drops():
    facts = extract_facts(
        "## Next actions\n- read canon\n- factory: prepare batch\n- other\n")
    before = set(facts.next_actions)
    out = prioritise(facts, "factory")
    assert set(out.next_actions) == before  # nothing dropped
    assert "factory" in out.next_actions[0].lower()  # role item surfaced first


def test_write_and_reload_roundtrip(tmp_path):
    repo = _repo(tmp_path)
    pack = build_pack(repo, "central", FIXED)
    jpath = write_pack(pack, repo, markdown=True)
    assert jpath.exists()
    assert jpath.with_suffix(".md").exists()
    reloaded = load_pack(jpath)
    assert reloaded["generated_at"] == FIXED
    assert find_latest_pack(repo / "docs/generated/session-memory") == jpath


def test_sources_never_mutated(tmp_path):
    repo = _repo(tmp_path)
    mem = repo / "MEMORY.md"
    before = mem.read_bytes()
    build_pack(repo, "central", FIXED)
    write_pack(build_pack(repo, "central", FIXED), repo)
    assert mem.read_bytes() == before  # source untouched
