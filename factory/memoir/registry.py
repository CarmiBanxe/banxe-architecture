"""Runtime XOR guard (PRECOND-04): a fork runs agentmemory XOR memoir, never both.

This is one of the three XOR layers (config `engine:` key + CI guard
`scripts/check-memory-xor.sh` + this single-registry). The ledger (ADR-059)
remains the source of truth; memoir is never a competing record.
"""

from __future__ import annotations

from .errors import XorViolation

_ACTIVE: str | None = None
_ALLOWED = ("memoir", "agentmemory")


def register_engine(name: str) -> None:
    """Register the one memory engine for this process/fork. A second, different
    engine raises XorViolation (deny-by-default)."""
    global _ACTIVE
    if name not in _ALLOWED:
        raise XorViolation(f"unknown memory engine: {name!r}")
    if _ACTIVE is not None and _ACTIVE != name:
        raise XorViolation(f"{name!r} refused — {_ACTIVE!r} already active (XOR)")
    _ACTIVE = name


def active_engine() -> str | None:
    return _ACTIVE


def reset() -> None:
    """Test-only: clear the registry."""
    global _ACTIVE
    _ACTIVE = None
