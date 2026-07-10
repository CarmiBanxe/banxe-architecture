"""Typed errors for the memoir factory-pilot. Every one is fail-closed: when it
raises, nothing is persisted / no capability is granted."""

from __future__ import annotations


class MemoirError(Exception):
    """Base class."""


class RedactionUncertain(MemoirError):
    """Deny-by-default: the redactor could not confidently classify a span
    (unknown class / parser failure / partial match / engine error/timeout).
    The write MUST be refused (PRECOND-01)."""


class RedZoneDropped(MemoirError):
    """Content is RED-zone (payment-core/KYC/AML/sanctions/ledger-derived).
    The whole record is DROPPED, not masked (PRECOND-01/06)."""


class RetentionConfigError(MemoirError):
    """Retention config absent/unparseable/unbounded/schema-invalid → no start,
    no writes (PRECOND-02)."""


class XorViolation(MemoirError):
    """A second memory engine tried to activate in the same fork
    (agentmemory XOR memoir — PRECOND-04)."""


class PerimeterViolation(MemoirError):
    """Factory-fork-only breach or cross-perimeter attempt (PRECOND-05/ADR-117)."""


class AuthorityViolation(MemoirError):
    """A memory op attempted to touch code/ledger/prod state (PRECOND-07)."""
