"""T01–T05: fail-closed redaction (PRECOND-01)."""

from __future__ import annotations

import pytest

from factory.memoir.errors import RedactionUncertain, RedZoneDropped
from factory.memoir.redaction import RegexEntropyRedactor, redact_or_refuse

R = RegexEntropyRedactor()

LEAKY = (
    "card 4111111111111111 iban GB82WEST12345698765432 "
    "key AKIAIOSFODNN7EXAMPLE gh ghp_1234567890abcdefghij1234567890abcd "
    "jwt eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.abc123def456ghi789 "
    "API_SECRET=supersecretvalue1234567 mail alice@example.com"
)


def test_T01_redaction_leak_none_stored():
    out = R.redact(LEAKY)
    for raw in ("4111111111111111", "GB82WEST12345698765432",
                "AKIAIOSFODNN7EXAMPLE", "ghp_1234567890abcdefghij1234567890abcd",
                "supersecretvalue1234567", "alice@example.com"):
        assert raw not in out, raw
    assert "[REDACTED:" in out


def test_T02_fail_closed_on_engine_error():
    class Boom:
        def redact(self, text: str) -> str:
            raise RuntimeError("engine down / timeout")

    with pytest.raises(RedactionUncertain):
        redact_or_refuse(Boom(), "anything")


def test_T03_uncertainty_is_dropped():
    # secret-shaped token, len>=32, entropy in the gray band [3.5,4.5) → refuse
    tok = "AaBbCcDdEeFfGgH" * 3  # 45 chars, 15 distinct → entropy ~3.91
    with pytest.raises(RedactionUncertain):
        R.redact(f"blob {tok} end")


def test_T04_red_zone_drop_not_mask():
    with pytest.raises(RedZoneDropped):
        R.redact("investigation aml_case 4471 flagged")
    # RED-zone raises → whole record refused (dropped, never a masked partial)


def test_T05_semantic_path_redaction():
    red_key = redact_or_refuse(R, "notes/alice@example.com/summary")
    assert "alice@example.com" not in red_key
    assert "[REDACTED:EMAIL]" in red_key
