"""Append-only lineage log (jsonl) + slice filesystem layout.

ADR-046 §D4: the record is durable (flush+fsync) before the flow proceeds.
Never rewrites or compacts (I-24 append-only).
"""

from __future__ import annotations

import json
import os
from dataclasses import asdict, dataclass
from pathlib import Path

from .contracts import LineageEvent


@dataclass(frozen=True)
class SlicePaths:
    base: Path

    @property
    def logs_dir(self) -> Path:
        return self.base / "logs"

    @property
    def lineage(self) -> Path:
        return self.logs_dir / "intent_lineage.jsonl"

    @property
    def cards_dir(self) -> Path:
        return self.base / "cards"

    @property
    def hitl_queue(self) -> Path:
        return self.base / "hitl_queue.jsonl"

    @classmethod
    def default(cls) -> SlicePaths:
        return cls(Path(__file__).resolve().parent)


def append_lineage_event(event: LineageEvent, paths: SlicePaths) -> None:
    paths.logs_dir.mkdir(parents=True, exist_ok=True)
    line = json.dumps(asdict(event), ensure_ascii=False)
    with paths.lineage.open("a", encoding="utf-8") as fh:
        fh.write(line + "\n")
        fh.flush()
        os.fsync(fh.fileno())


def read_lineage(paths: SlicePaths) -> list[dict]:
    if not paths.lineage.exists():
        return []
    with paths.lineage.open(encoding="utf-8") as fh:
        return [json.loads(line) for line in fh if line.strip()]
