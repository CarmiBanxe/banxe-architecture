"""Fail-closed redaction (PRECOND-01). Runs BEFORE any commit so no raw value
is ever stored — history/blame/checkout/rollback therefore hold redacted content
only. Deny-by-default: on any uncertainty the caller MUST refuse the write.

Mirrors the emi-stack ``PresidioRedactor`` *pattern* (Presidio-first + deterministic
regex fallback behind a ``PiiRedactorPort`` seam) — it imports no project-side code
(perimeter). Regex/entropy fallback is the default and is fully deterministic.
"""

from __future__ import annotations

import math
import re
from collections import Counter
from typing import Protocol

from .errors import RedactionUncertain, RedZoneDropped

# ── entropy thresholds (secret-shaped tokens only) ──
_MASK_ENTROPY = 4.5     # ≥ ⇒ confident secret → mask
_GRAY_MIN = 3.5         # [3.5, 4.5) on a long token ⇒ uncertain → refuse
_UNCLASSIFIED_LEN = 32

# ── ordered detectors: (class, pattern) ; masked as [REDACTED:CLASS] ──
_PRIVATE_KEY = re.compile(
    r"-----BEGIN [A-Z ]*PRIVATE KEY-----.*?-----END [A-Z ]*PRIVATE KEY-----", re.S)
_ENV_SECRET = re.compile(
    r"(?im)^\s*[A-Z0-9_]*(?:PASSWORD|SECRET|TOKEN|APIKEY|API_KEY|PRIVATE_KEY|"
    r"ACCESS_KEY)[A-Z0-9_]*\s*=\s*(\S+)")
_SECRET_PREFIX = re.compile(
    r"\b(?:AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|"
    r"sk-[A-Za-z0-9]{20,}|AIza[0-9A-Za-z_\-]{20,})\b")
_JWT = re.compile(r"\beyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\b")
_EMAIL = re.compile(r"\b[\w.+-]+@[\w-]+\.[\w.-]+\b")
_IBAN = re.compile(r"\b[A-Z]{2}\d{2}[A-Z0-9]{11,30}\b")
_CARD = re.compile(r"\b(?:\d[ -]?){13,19}\b")
_SORT = re.compile(r"\b\d{2}-\d{2}-\d{2}\b")
_PHONE = re.compile(r"\b\+?\d[\d ]{7,14}\d\b")
_TOKEN = re.compile(r"[A-Za-z0-9+/=_\-]{20,}")
_PLACEHOLDER = re.compile(r"\[REDACTED:[A-Z]+\]")

# RED-zone data markers → DROP the whole record (not mask)
DEFAULT_RED_ZONE = re.compile(
    r"(?i)\b(?:sar-\d|sanctions?_hit|pep_match|aml_case|kyc_result|pan=|"
    r"ledger_balance|safeguarding_shortfall)\b")


def shannon(s: str) -> float:
    if not s:
        return 0.0
    n = len(s)
    return -sum((c / n) * math.log2(c / n) for c in Counter(s).values())


def _luhn(num: str) -> bool:
    d = [int(c) for c in num if c.isdigit()]
    if not 13 <= len(d) <= 19:
        return False
    chk = 0
    for i, x in enumerate(reversed(d)):
        x = x * 2 if i % 2 else x
        chk += x - 9 if x > 9 else x
    return chk % 10 == 0


def _secretish(tok: str) -> bool:
    """Mixed-case OR base64-special — excludes plain hex (git shas) / plain digits."""
    return (any(c.islower() for c in tok) and any(c.isupper() for c in tok)) or \
        any(c in "+/=_-" for c in tok)


class PiiRedactorPort(Protocol):
    """DI seam. A redactor returns masked text or raises (fail-closed)."""

    def redact(self, text: str) -> str: ...


class RegexEntropyRedactor:
    """Deterministic default. Presidio may replace it via the port; on Presidio
    error/timeout the caller passes through here or refuses (fail-closed)."""

    def __init__(self, red_zone: re.Pattern[str] = DEFAULT_RED_ZONE) -> None:
        self._red = red_zone

    def redact(self, text: str) -> str:
        if self._red.search(text):
            raise RedZoneDropped("RED-zone content — dropped, not masked")
        out = _PRIVATE_KEY.sub("[REDACTED:PRIVATE_KEY]", text)
        out = _ENV_SECRET.sub(lambda m: m.group(0).replace(m.group(1), "[REDACTED:SECRET]"), out)
        out = _SECRET_PREFIX.sub("[REDACTED:SECRET]", out)
        out = _JWT.sub("[REDACTED:JWT]", out)
        out = _EMAIL.sub("[REDACTED:EMAIL]", out)
        out = _IBAN.sub("[REDACTED:IBAN]", out)
        out = _CARD.sub(lambda m: "[REDACTED:CARD]" if _luhn(m.group(0)) else "[REDACTED:NUM]", out)
        out = _SORT.sub("[REDACTED:SORT_CODE]", out)
        out = _PHONE.sub("[REDACTED:PHONE]", out)
        out = self._entropy_pass(out)
        return out

    def _entropy_pass(self, text: str) -> str:
        result = text
        for m in _TOKEN.finditer(text):
            tok = m.group(0)
            if _PLACEHOLDER.fullmatch(tok) or not _secretish(tok):
                continue
            ent = shannon(tok)
            if ent >= _MASK_ENTROPY:
                result = result.replace(tok, "[REDACTED:SECRET]")
            elif ent >= _GRAY_MIN and len(tok) >= _UNCLASSIFIED_LEN:
                raise RedactionUncertain(
                    f"unclassified secret-shaped token (entropy {ent:.2f})")
        return result


def redact_or_refuse(redactor: PiiRedactorPort, text: str) -> str:
    """Single choke-point. Any engine error/timeout ⇒ RedactionUncertain (refuse).
    Covers content AND semantic-path keys (call it on both)."""
    try:
        return redactor.redact(text)
    except (RedZoneDropped, RedactionUncertain):
        raise
    except Exception as exc:  # engine crash/timeout ⇒ deny-by-default
        raise RedactionUncertain(f"redaction engine error: {exc!r}") from exc
