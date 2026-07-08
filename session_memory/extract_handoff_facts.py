"""Deterministic markdown → structured facts extraction.

Pure functions only (no filesystem, no clock). Given the same text the output
is byte-identical. The extractor is heuristic but explicit: it maps section
titles (and, as a fallback, bullet content) to canonical fields via keyword
sets. It never raises on malformed / header-less / duplicate-header input.
"""

from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass

from .schemas import ExtractedFacts

_HEADER = re.compile(r"^(#{1,6})\s+(.*\S)\s*$")
_BULLET = re.compile(r"^\s*(?:[-*+]|\d+[.)])\s+(.*\S)\s*$")

# title/content keyword sets per field (lowercase, substring match)
KEYWORDS: dict[str, tuple[str, ...]] = {
    "invariants": ("invariant", "hard constraint", "must not", "fail-closed",
                   "fail closed", "i-2", "do not"),
    "operator_gated": ("operator", "hitl", "human-in", "ceo approval",
                       "gated", "approval", "await", "ratif", "smf"),
    "next_actions": ("next action", "next step", "todo", "pending",
                     "continue", "остал", "queue"),
    "canon_pointers": ("canon", "hierarchy", "constitution", "adr-",
                       ".claude/rules", "rules/", "pointer", "anchor"),
    "repo_state": ("repo state", "status", "current state", "summary",
                   "branch", "il-tip", "restoration", "context"),
}
_FIRST_ACTION = ("first action", "first message", "resume", "start with",
                 "on start", "session start")


def sha256_text(text: str) -> str:
    """Stable content hash of the source (audit trail)."""
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


@dataclass(frozen=True)
class Section:
    """A markdown section: header title + its body lines (excl. header)."""

    level: int
    title: str
    body: tuple[str, ...]


def parse_sections(text: str) -> list[Section]:
    """Split markdown into sections. Header-less text → one untitled section."""
    sections: list[Section] = []
    cur_title, cur_level, buf = "", 0, []
    started = False
    for line in text.splitlines():
        m = _HEADER.match(line)
        if m:
            if started:
                sections.append(Section(cur_level, cur_title, tuple(buf)))
            cur_level, cur_title, buf, started = len(m.group(1)), m.group(2), [], True
        else:
            buf.append(line)
            started = True
    if started:
        sections.append(Section(cur_level, cur_title, tuple(buf)))
    return sections


def bullets(body: tuple[str, ...]) -> list[str]:
    """Extract bullet/numbered items; fall back to non-empty prose lines."""
    items = [m.group(1).strip() for ln in body if (m := _BULLET.match(ln))]
    if items:
        return items
    return [ln.strip() for ln in body if ln.strip() and not ln.startswith(">")]


def _dedup(seq: list[str]) -> list[str]:
    """Order-preserving dedup."""
    seen: set[str] = set()
    out: list[str] = []
    for x in seq:
        if x and x not in seen:
            seen.add(x)
            out.append(x)
    return out


def _match(title: str, keys: tuple[str, ...]) -> bool:
    low = title.lower()
    return any(k in low for k in keys)


def _collect(sections: list[Section], keys: tuple[str, ...]) -> list[str]:
    """All bullets under any section whose title matches; deduped, ordered."""
    out: list[str] = []
    for sec in sections:  # duplicate headers → both contribute
        if _match(sec.title, keys):
            out.extend(bullets(sec.body))
    return _dedup(out)


def _first_action(sections: list[Section], fallback: list[str]) -> str | None:
    for sec in sections:
        if _match(sec.title, _FIRST_ACTION):
            b = bullets(sec.body)
            if b:
                return b[0]
    return fallback[0] if fallback else None


def extract_facts(text: str) -> ExtractedFacts:
    """Extract all canonical fields from one document (deterministic)."""
    sections = parse_sections(text)
    facts = ExtractedFacts(
        repo_state=_collect(sections, KEYWORDS["repo_state"]),
        invariants=_collect(sections, KEYWORDS["invariants"]),
        operator_gated=_collect(sections, KEYWORDS["operator_gated"]),
        next_actions=_collect(sections, KEYWORDS["next_actions"]),
        canon_pointers=_collect(sections, KEYWORDS["canon_pointers"]),
    )
    facts.first_action = _first_action(sections, facts.next_actions)
    return facts


def merge_facts(a: ExtractedFacts, b: ExtractedFacts) -> ExtractedFacts:
    """Union two fact sets (append-only, deduped). ``a`` wins for first_action."""
    return ExtractedFacts(
        repo_state=_dedup(a.repo_state + b.repo_state),
        invariants=_dedup(a.invariants + b.invariants),
        operator_gated=_dedup(a.operator_gated + b.operator_gated),
        next_actions=_dedup(a.next_actions + b.next_actions),
        canon_pointers=_dedup(a.canon_pointers + b.canon_pointers),
        first_action=a.first_action or b.first_action,
    )
