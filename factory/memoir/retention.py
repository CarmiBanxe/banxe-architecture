"""Bounded retention as config-as-data (PRECOND-02). Fail-closed: an absent /
unparseable / unbounded / schema-invalid config ⇒ no pilot start, no writes.

Bounds apply to the LIVE (recallable) entry set. Append-only history is preserved
(ADR-059) and is PII-safe because redaction runs at write; disk reclamation of
purged-but-reachable objects is Outcome C.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from datetime import timedelta
from pathlib import Path
from typing import Any

import yaml

from .errors import RetentionConfigError

SCHEMA = "memoir-retention/v1"
_DUR = re.compile(r"^P(?:(\d+)W)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?)?$")


def _duration(text: str) -> timedelta:
    m = _DUR.match(text or "")
    if not m or text in ("P", ""):
        raise RetentionConfigError(f"invalid ISO-8601 duration: {text!r}")
    w, d, h, mi = (int(x) if x else 0 for x in m.groups())
    td = timedelta(weeks=w, days=d, hours=h, minutes=mi)
    if td <= timedelta(0):
        raise RetentionConfigError("max_age must be a positive, finite duration")
    return td


@dataclass(frozen=True)
class RetentionPolicy:
    engine: str
    fork: str
    max_age: timedelta
    max_entries: int
    hard_cap_bytes: int
    purge_schedule: str


def _require(d: dict[str, Any], key: str) -> Any:
    if key not in d or d[key] in (None, ""):
        raise RetentionConfigError(f"missing required field: {key}")
    return d[key]


def load_retention(path: str | Path) -> RetentionPolicy:
    """Parse + validate. Any problem ⇒ RetentionConfigError (fail-closed)."""
    p = Path(path)
    if not p.exists():
        raise RetentionConfigError(f"retention config absent: {p}")
    try:
        raw = yaml.safe_load(p.read_text(encoding="utf-8"))
    except yaml.YAMLError as exc:
        raise RetentionConfigError(f"unparseable retention config: {exc}") from exc
    if not isinstance(raw, dict):
        raise RetentionConfigError("retention config is not a mapping")
    if raw.get("schema") != SCHEMA:
        raise RetentionConfigError(f"schema must be {SCHEMA!r}")
    bounds = _require(raw, "bounds")
    scope = _require(raw, "scope")
    purge = _require(raw, "purge")
    max_entries = int(_require(bounds, "max_entries"))
    hard_cap = int(_require(bounds, "hard_cap_bytes"))
    if max_entries <= 0 or hard_cap <= 0:
        raise RetentionConfigError("bounds must be finite positive (no unbounded)")
    return RetentionPolicy(
        engine=str(_require(raw, "engine")),
        fork=str(_require(scope, "fork")),
        max_age=_duration(str(_require(bounds, "max_age"))),
        max_entries=max_entries,
        hard_cap_bytes=hard_cap,
        purge_schedule=str(_require(purge, "purge_schedule")),
    )
