"""Typed data structures for the session-memory pack (deterministic, JSON-able).

No I/O here. These schemas are the stable contract between the extractor
(``extract_handoff_facts``), the builder (``build_session_pack``) and any
downstream reader. Append-only discipline: schemas evolve by adding optional
fields, never by mutating the meaning of an existing one.
"""

from __future__ import annotations

from dataclasses import asdict, dataclass, field
from typing import Any

SCHEMA_VERSION = "session-pack/v1"

# Canonical field keys extracted from memory/handoff docs.
FIELD_KEYS = (
    "repo_state",
    "invariants",
    "operator_gated",
    "next_actions",
    "first_action",
    "canon_pointers",
)


@dataclass(frozen=True)
class SourceDoc:
    """One source document that fed the pack (never mutated)."""

    path: str
    kind: str  # memory | handoff | transfer
    lines: int
    sha256: str


@dataclass
class ExtractedFacts:
    """Structured fields pulled out of the source documents."""

    repo_state: list[str] = field(default_factory=list)
    invariants: list[str] = field(default_factory=list)
    operator_gated: list[str] = field(default_factory=list)
    next_actions: list[str] = field(default_factory=list)
    first_action: str | None = None
    canon_pointers: list[str] = field(default_factory=list)


@dataclass
class SessionPack:
    """The single machine-readable artifact emitted at session start."""

    schema: str
    generated_at: str
    role: str
    sources: list[SourceDoc]
    facts: ExtractedFacts
    warnings: list[str] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        """Deterministic, JSON-serialisable dict (stable key order)."""
        return {
            "schema": self.schema,
            "generated_at": self.generated_at,
            "role": self.role,
            "sources": [asdict(s) for s in self.sources],
            "facts": asdict(self.facts),
            "warnings": list(self.warnings),
        }
