"""factory.memoir — git-like versioned memory, factory-pilot MVP (ADR-165, gated).

Content-only memory VCS: branch/commit/rollback/blame/checkout over an isolated
bare git repo, with fail-closed redaction, bounded retention, and XOR enforcement.
It confers NO authority (PRECOND-07): memory describes, never authorizes. PROPOSED
/ gated — this package delivers code + tests; it does not activate production capture.
"""

from __future__ import annotations

from .errors import (
    MemoirError,
    PerimeterViolation,
    RedactionUncertain,
    RedZoneDropped,
    RetentionConfigError,
    XorViolation,
)

__all__ = [
    "MemoirError",
    "PerimeterViolation",
    "RedactionUncertain",
    "RedZoneDropped",
    "RetentionConfigError",
    "XorViolation",
]
