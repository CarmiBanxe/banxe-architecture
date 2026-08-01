"""Tests: org-overlay wiring in detect_impact.py (spec impact-org-overlay-spec.md).

Invariants under test (ADR-176 + merged spec): exit codes 0/1/78 unchanged;
overlay is additive-only; overlay failure degrades (never raises, never blocks);
no overlay emission on the fail-closed exit-1 path.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path
from types import SimpleNamespace
from typing import Any

import pytest

SCRIPTS_DIR = Path(__file__).resolve().parents[2] / "scripts" / "gitnexus"
sys.path.insert(0, str(SCRIPTS_DIR))

import build_org_contour  # noqa: E402
import detect_impact as di  # noqa: E402


def _fake_cli(risk: str) -> Any:
    payload = json.dumps({"risk": risk, "blast_radius": ["nodeA"]})
    return lambda *a, **k: SimpleNamespace(returncode=0, stdout=payload, stderr="")


def test_exit_codes_unchanged(monkeypatch: pytest.MonkeyPatch,
                              capsys: pytest.CaptureFixture[str]) -> None:
    monkeypatch.setattr(di, "staged_files", lambda: [])
    assert di.main() == di.EX_OK

    monkeypatch.setattr(di, "staged_files",
                        lambda: ["bank-rooms/F2-payments-room/x.py"])
    monkeypatch.setattr(di, "mcp_available", lambda: False)
    assert di.main() == di.EX_CONFIG  # 78 kept even though overlay ran
    out, err = capsys.readouterr()
    assert "GitNexus org-overlay:" in out
    assert "org_overlay_note: code graph unavailable (78)" in err


def test_overlay_additive_on_success(monkeypatch: pytest.MonkeyPatch,
                                     capsys: pytest.CaptureFixture[str]) -> None:
    monkeypatch.setattr(di, "staged_files",
                        lambda: ["bank-rooms/F2-payments-room/x.py"])
    monkeypatch.setattr(di, "staged_diff", lambda: "")
    monkeypatch.setattr(di, "mcp_available", lambda: True)
    monkeypatch.setattr(di.subprocess, "run", _fake_cli("LOW"))
    assert di.main() == di.EX_OK
    out, _ = capsys.readouterr()
    assert "GitNexus impact: risk=LOW blast_radius=['nodeA'] files=1" in out
    assert "GitNexus org-overlay:" in out
    overlay = json.loads(out.split("GitNexus org-overlay: ", 1)[1].splitlines()[0])
    assert overlay["impacted_departments"][0]["room"] == "F2-payments-room"


def test_overlay_failure_degrades(monkeypatch: pytest.MonkeyPatch,
                                  capsys: pytest.CaptureFixture[str]) -> None:
    def boom(files: list[str]) -> dict[str, object]:
        raise RuntimeError("map unreadable")

    monkeypatch.setattr(build_org_contour, "build_overlay", boom)
    monkeypatch.setattr(di, "staged_files", lambda: ["any.py"])
    monkeypatch.setattr(di, "mcp_available", lambda: False)
    assert di.main() == di.EX_CONFIG  # exit contract untouched by overlay failure
    out, err = capsys.readouterr()
    assert "[org-overlay] degraded: map unreadable" in err
    assert "GitNexus org-overlay:" not in out


def test_no_emit_on_fail_closed(monkeypatch: pytest.MonkeyPatch,
                                capsys: pytest.CaptureFixture[str]) -> None:
    monkeypatch.setattr(di, "staged_files", lambda: ["any.py"])
    monkeypatch.setattr(di, "staged_diff", lambda: "")
    monkeypatch.setattr(di, "mcp_available", lambda: True)
    monkeypatch.setattr(di.subprocess, "run", _fake_cli("HIGH"))
    monkeypatch.delenv("GITNEXUS_ACK", raising=False)
    assert di.main() == di.EX_FAIL_CLOSED
    out, err = capsys.readouterr()
    assert "org-overlay" not in out  # blocked path must not imply safety
    assert "FAIL-CLOSED" in err
