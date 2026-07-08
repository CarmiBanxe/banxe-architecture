"""Extractor behaviour: malformed input, duplicate headers, real extraction."""

from __future__ import annotations

from session_memory.extract_handoff_facts import (
    bullets,
    extract_facts,
    merge_facts,
    parse_sections,
)

GOOD = """\
# Handoff

## Repo state
- Branch main at IL-1044
- 663 tests passing

## Hard invariants
- I-27 fail-closed on regulated actions
- Do not use float for money

## Operator-gated items
- Merge requires operator approval (HITL)
- SAR filing is MLRO only

## Next actions
- Prepare R7 retrofit
- Continue fleet coverage

## First action in new session
- Restore context and read the ledger tip

## Canon / hierarchy
- ADR-131 souls format
- .claude/rules/safety-rules.md
"""


def test_successful_extraction():
    f = extract_facts(GOOD)
    assert any("IL-1044" in x for x in f.repo_state)
    assert any("I-27" in x for x in f.invariants)
    assert any("MLRO" in x for x in f.operator_gated)
    assert any("R7" in x for x in f.next_actions)
    assert f.first_action == "Restore context and read the ledger tip"
    assert any("ADR-131" in x for x in f.canon_pointers)


def test_malformed_markdown_no_headers():
    f = extract_facts("just some prose\nno headers at all\n\n1234")
    assert f.repo_state == []
    assert f.invariants == []
    assert f.first_action is None  # no next actions to fall back to


def test_empty_input():
    f = extract_facts("")
    assert f.next_actions == []
    assert f.first_action is None


def test_duplicate_headers_both_captured_and_deduped():
    text = (
        "## Next actions\n- do A\n- do B\n\n"
        "## Next actions\n- do B\n- do C\n"
    )
    f = extract_facts(text)
    assert f.next_actions == ["do A", "do B", "do C"]  # union, order-preserving dedup


def test_first_action_falls_back_to_next_action():
    text = "## Next actions\n- first thing\n- second thing\n"
    assert extract_facts(text).first_action == "first thing"


def test_bullets_prose_fallback():
    secs = parse_sections("## S\nplain line one\nplain line two\n")
    assert bullets(secs[0].body) == ["plain line one", "plain line two"]


def test_merge_is_union():
    a = extract_facts("## Hard invariants\n- I-1\n")
    b = extract_facts("## Hard invariants\n- I-1\n- I-2\n")
    assert merge_facts(a, b).invariants == ["I-1", "I-2"]
