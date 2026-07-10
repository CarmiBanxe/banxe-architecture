"""session_memory — deterministic session-memory substrate over repo artifacts.

Read/prepare/propose only. It never mutates source memory or handoff docs and
never expands authority; its output is a regenerable cache the operator reads at
session start. See README.md.
"""

from __future__ import annotations

from .schemas import SCHEMA_VERSION

__all__ = ["SCHEMA_VERSION"]
