---
name: apple-design
description: Default principle-based design-quality skill for UI generation, interface redesign, frontend polish, visual review, component styling, and dashboard/landing/admin UX work. Use proactively for any banking/product UI, dashboard, landing page, settings/admin surface, or frontend cleanup pass, unless the operator explicitly requests a different design system.
---

# Apple Design

## Purpose

Default design-quality reference for web/product UI work in this factory and its
downstream forks (SHARED per
`docs/canon/FEATURE-EVALUATION-AND-PLACEMENT-CANON-2026-07-20.md`). It is a
**principle-based reference** — typography, layout, restraint, visual hierarchy — not an
effects/motion-decoration pack, and not a replacement for this repo's own UI/UX
governance canon.

## When to apply

Proactively, without waiting to be asked, for:
- UI generation
- interface redesign
- frontend polish
- visual review
- component styling
- dashboard / landing / admin UX work

Skip it only when the operator explicitly asks for a different style/system — that
explicit request wins.

## Honesty note on this entry's scope

This repo does not itself define `/apple-design`'s full design-principle content — no
document in this repo describes it (confirmed by repo-wide search before this file was
created). This `SKILL.md` is a **binding/trigger entry**, not a reimplementation: its job
is to make the default-usage rule discoverable and live for this session and future ones,
by pointing to the skill by name rather than fabricating its content.

- If `/apple-design` is available as a loaded skill in the current session, invoke it for
  the task types above.
- If it is not available in a given session, fall back to this repo's own content-level
  authority for UI/UX quality: `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` (design
  tokens, component lifecycle, accessibility governance) — do not invent Apple-specific
  guidance in its place.

## Relationship to existing canon

- Does not duplicate or override `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` — that
  document remains this repo's governance authority for design tokens, component
  contribution/deprecation lifecycle, and accessibility (WCAG 2.1 AA). This skill adds a
  design-quality lens on top, applied together with that canon, not instead of it.
- Registered per `CLAUDE.md`'s "Default UI design skill" section (root instruction layer)
  and implemented (not left paper-only) per `CLAUDE.md`'s "Feature implementation canon"
  section.
