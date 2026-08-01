#!/usr/bin/env python3
"""detect_impact.py — GitNexus blast-radius / risk gate (PHASE 1, sandbox-scope).

LICENSE DISCLAIMER: GitNexus is licensed under PolyForm-Noncommercial-1.0.0.
Sandbox/TRAINING use only without a license. PROD/commercial use requires a
purchased GitNexus license.

Contract (docs/canon/GITNEXUS-CODE-CONTOUR-DIRECTIVE.md, enrich -> impact -> act):
  * Reads the staged diff (``git diff --staged``).
  * If the GitNexus MCP tooling is live (GITNEXUS_MCP_ENDPOINT set AND the
    ``gitnexus`` binary on PATH), delegates blast-radius + risk computation to
    the real tool. HIGH risk without operator ack => exit 1 (fail-closed).
  * If 0 tools are connected: NO-MOCK — the graph is never simulated. Prints
    the disclaimer, reports risk="UNKNOWN" and exits with code 78 (EX_CONFIG).

Python 3.11+, stdlib only. Idempotent (read-only over git state).
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys

EX_OK: int = 0
EX_FAIL_CLOSED: int = 1
EX_CONFIG: int = 78  # sysexits.h — "MCP not connected" contract code

DISCLAIMER: str = (
    "GitNexus license: PolyForm-Noncommercial-1.0.0. Sandbox use only without a "
    "license; PROD/commercial use requires a purchased GitNexus license."
)


def staged_diff() -> str:
    """Return the staged diff text (empty string when nothing is staged)."""
    proc = subprocess.run(
        ["git", "diff", "--staged"], capture_output=True, text=True, check=False
    )
    return proc.stdout


def staged_files() -> list[str]:
    """Return the list of staged file paths."""
    proc = subprocess.run(
        ["git", "diff", "--staged", "--name-only"],
        capture_output=True,
        text=True,
        check=False,
    )
    return [line for line in proc.stdout.splitlines() if line.strip()]


def mcp_available() -> bool:
    """Local-only probe: endpoint configured AND real binary present (no network)."""
    return bool(os.environ.get("GITNEXUS_MCP_ENDPOINT")) and (
        shutil.which("gitnexus") is not None
    )


def emit_org_overlay(files: list[str], *, note_prefix: str = "") -> None:
    """Report-time org overlay (ADR-176 red line; spec impact-org-overlay-spec.md).

    ADDITIVE side-effect only: prints a separate "GitNexus org-overlay:" block.
    NEVER raises and never touches exit codes — any failure degrades to a stderr
    note. No write-back into .gitnexus (org joins the code graph at report time).
    """
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        if script_dir not in sys.path:
            sys.path.insert(0, script_dir)
        from build_org_contour import build_overlay  # lazy: overlay stays optional
        overlay = build_overlay(files)
        print("GitNexus org-overlay: " + json.dumps(overlay, ensure_ascii=False))
        if note_prefix:
            print(note_prefix, file=sys.stderr)
    except Exception as exc:  # defensive by contract: overlay must never block
        print(f"[org-overlay] degraded: {exc}", file=sys.stderr)


def run_real_detect_impact(files: list[str]) -> int:
    """Delegate to the real GitNexus CLI when MCP tooling is live.

    NO-MOCK: this wrapper never invents graph results. Any tool failure or an
    unparsable response is treated as fail-closed (exit 1), never as low risk.
    HIGH risk requires explicit operator ack via GITNEXUS_ACK=1.
    """
    proc = subprocess.run(
        ["gitnexus", "detect-impact", "--staged", "--json"],
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        print("gitnexus detect-impact failed — fail-closed.", file=sys.stderr)
        print(proc.stderr.strip(), file=sys.stderr)
        return EX_FAIL_CLOSED
    try:
        payload: dict[str, object] = json.loads(proc.stdout)
        risk = str(payload.get("risk", "UNKNOWN")).upper()
        blast = payload.get("blast_radius", [])
    except (json.JSONDecodeError, TypeError):
        print("Unparsable detect-impact output — fail-closed (no-mock).", file=sys.stderr)
        return EX_FAIL_CLOSED

    print(f"GitNexus impact: risk={risk} blast_radius={blast!r} files={len(files)}")
    if risk == "HIGH" and os.environ.get("GITNEXUS_ACK") != "1":
        print(
            "FAIL-CLOSED: HIGH risk without operator confirmation "
            "(set GITNEXUS_ACK=1 to acknowledge).",
            file=sys.stderr,
        )
        return EX_FAIL_CLOSED
    emit_org_overlay(files)
    return EX_OK


def main() -> int:
    """Entry point: enrich -> impact -> act gate over the staged change-set."""
    print(DISCLAIMER, file=sys.stderr)

    files = staged_files()
    if not files:
        print("No staged changes — nothing to assess.", file=sys.stderr)
        return EX_OK

    if not mcp_available():
        # NO-MOCK: without the live graph we do not guess.
        print(
            "MCP not connected — enrich/reindex unavailable; "
            'risk="UNKNOWN"; running in reminder+fail-closed mode.',
            file=sys.stderr,
        )
        emit_org_overlay(
            files,
            note_prefix=(
                "org_overlay_note: code graph unavailable (78); "
                "org overlay from map/rosters only"
            ),
        )
        return EX_CONFIG

    _ = staged_diff()  # reserved for future tool stdin handoff; read-only
    return run_real_detect_impact(files)


if __name__ == "__main__":
    raise SystemExit(main())
