from __future__ import annotations

from tools.sandbox.intent_slice import hitl_stub
from tools.sandbox.intent_slice.demo import run_slice
from tools.sandbox.intent_slice.evidence_pack import build_snapshot

TEXT = "переведи 500 EUR Ивану"


def _populated(paths):
    result = run_slice(TEXT, "client-ev", paths)
    hitl_stub.decide(result["card_id"], "approve", "op", paths)
    return result


def test_snapshot_copies_all_artifacts_and_writes_summary(paths):
    _populated(paths)
    snap = build_snapshot(paths, run_tests=False)

    assert snap.is_dir() and snap.name.startswith("snapshot-")
    assert list((snap / "cards").glob("card-*.json"))  # cards copied
    assert list((snap / "cards").glob("card-*.md"))
    assert (snap / "intent_lineage.jsonl").exists()  # lineage copied
    assert (snap / "hitl_queue.jsonl").exists()  # queue copied
    assert (snap / "pytest.txt").exists()  # pytest output file present

    summary = (snap / "summary.md").read_text(encoding="utf-8")
    for section in (
        "UTC timestamp",
        "Card artifacts: 1",
        "Lineage entries: 5",
        "HITL queue entries: 2",
        "## correlation_id",
        "## intent_id",
        "## Queue statuses",
        "## Human verdicts",
        "OPEN POINT: budget halt CLI flag absent",
        "DRAFT / NOT FOR MERGE",
    ):
        assert section in summary


def test_snapshot_summary_contains_real_ids_and_verdicts(paths):
    result = _populated(paths)
    snap = build_snapshot(paths, run_tests=False)
    summary = (snap / "summary.md").read_text(encoding="utf-8")
    assert result["correlation_id"] in summary
    assert "executed" in summary  # human verdict from queue


def test_snapshot_on_empty_slice_is_safe(paths):
    snap = build_snapshot(paths, run_tests=False)
    summary = (snap / "summary.md").read_text(encoding="utf-8")
    assert "Card artifacts: 0" in summary
    assert "(none)" in summary
