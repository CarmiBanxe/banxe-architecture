"""Evidence pack generator for the sandbox Intent Launch Slice (stdlib only).

Run: RUNTIME_PROFILE=dev_fast python3 -m tools.sandbox.intent_slice.evidence_pack
Creates evidence/snapshot-<UTC>/ with copies of cards/, lineage jsonl,
hitl_queue.jsonl, pytest output and summary.md. Sources are append-only and
are never modified — copy only. DRAFT / NOT FOR MERGE.
"""

from __future__ import annotations

import json
import shutil
import subprocess  # noqa: S404 — pytest self-run, list args, no shell
import sys
from datetime import UTC, datetime
from pathlib import Path

from .lineage_log import SlicePaths

OPEN_POINT = "OPEN POINT: budget halt CLI flag absent; validated via pytest/API path"


def _read_jsonl(path: Path) -> list[dict]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8") as fh:
        return [json.loads(line) for line in fh if line.strip()]


def _run_pytest(tests_dir: Path, out_file: Path) -> str:
    proc = subprocess.run(  # noqa: S603
        [sys.executable, "-m", "pytest", str(tests_dir), "-q"],
        capture_output=True,
        text=True,
        check=False,
    )
    text = proc.stdout + proc.stderr
    out_file.write_text(text, encoding="utf-8")
    return "PASS" if proc.returncode == 0 else f"FAIL (rc={proc.returncode})"


def build_snapshot(paths: SlicePaths, *, run_tests: bool = True) -> Path:
    stamp = datetime.now(UTC).strftime("%Y%m%dT%H%M%SZ")
    snap = paths.base / "evidence" / f"snapshot-{stamp}"
    snap.mkdir(parents=True, exist_ok=True)

    card_files: list[Path] = []
    if paths.cards_dir.exists():
        shutil.copytree(paths.cards_dir, snap / "cards", dirs_exist_ok=True)
        card_files = sorted(paths.cards_dir.glob("card-*.json"))
    if paths.lineage.exists():
        shutil.copy2(paths.lineage, snap / "intent_lineage.jsonl")
    if paths.hitl_queue.exists():
        shutil.copy2(paths.hitl_queue, snap / "hitl_queue.jsonl")

    if run_tests:
        test_status = _run_pytest(paths.base / "tests", snap / "pytest.txt")
    else:
        (snap / "pytest.txt").write_text("SKIPPED (test mode)\n", encoding="utf-8")
        test_status = "SKIPPED"

    lineage = _read_jsonl(paths.lineage)
    queue = _read_jsonl(paths.hitl_queue)
    cards = [json.loads(p.read_text(encoding="utf-8")) for p in card_files]

    correlation_ids = sorted(
        {e["correlation_id"] for e in lineage if "correlation_id" in e}
        | {c["correlation_id"] for c in cards if "correlation_id" in c}
    )
    intent_ids = sorted({c["intent_id"] for c in cards if "intent_id" in c})
    statuses = sorted({q["status"] for q in queue if "status" in q})
    verdicts = [
        f"{q.get('card_id', '?')}: {q['status']} (by {q.get('decided_by', '?')})"
        for q in queue
        if q.get("type") == "decision"
    ]

    lines = [
        "# Intent Slice — evidence snapshot",
        "",
        f"- UTC timestamp: {stamp}",
        f"- Card artifacts: {len(card_files)}",
        f"- Lineage entries: {len(lineage)}",
        f"- HITL queue entries: {len(queue)}",
        f"- Tests: {test_status}",
        "",
        "## correlation_id",
        *([f"- {c}" for c in correlation_ids] or ["- (none)"]),
        "",
        "## intent_id",
        *([f"- {i}" for i in intent_ids] or ["- (none)"]),
        "",
        "## Queue statuses",
        *([f"- {s}" for s in statuses] or ["- (none)"]),
        "",
        "## Human verdicts",
        *([f"- {v}" for v in verdicts] or ["- (none)"]),
        "",
        f"> {OPEN_POINT}",
        "",
        "> DRAFT / NOT FOR MERGE · sandbox-only",
        "",
    ]
    (snap / "summary.md").write_text("\n".join(lines), encoding="utf-8")
    return snap


def main() -> int:
    snap = build_snapshot(SlicePaths.default())
    print(f"snapshot: {snap}")
    print((snap / "summary.md").read_text(encoding="utf-8"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
