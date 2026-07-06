# DELIVERY-CANON — STDIN-paste (`cat > file`) is the MANDATORY zero-loss delivery method

> Additive to **FACTORY-CANON** (Execution Pattern; worktree authoring; prepare-only), ADR-102
> (pointer-first / duplication), ADR-120 (worktree isolation), and I-24 (append-only audit).
> This file states the **delivery discipline** — it does not restate the linked canon.
> Applies to **ALL** terminals: Factory (Left / A), Central, Right (Orchestrating).

## 1. Purpose

Deliver large documents (RU prose, formulae, code) to disk **byte-for-byte, zero-loss**.

Root cause it solves:

- **Chat attachments corrupt encoding** — RU text arrives as mojibake (`TITLE , -` / `UOfd` / mixed
  UTF-8/CP1251 substitution) once passed through the chat channel.
- **Inline base64 paste is fragile** — line-wrap, whitespace, and terminal soft-limits truncate the
  stream silently; the decoded file passes checksum only when transport was clean, which is not
  guaranteed for large payloads.
- **Heredoc placeholders get left unfilled** — `cat <<'EOF' … EOF` with `{{PLACEHOLDER}}` markers
  routinely reaches disk with the marker still in place, producing a corrupt or partial artefact
  that only fails at verify time.

## 2. The method — STDIN-paste

- Run `cat > "<path>"`. The shell prompt disappears — stdin is open.
- The operator **pastes the FULL document**, presses **Enter**, then **Ctrl-D**.
- Bytes flow directly `paste buffer → stdin → file`. No chat encoding, no placeholder
  substitution, no intermediate render.

Zero-loss reason: the text bypasses the chat channel entirely and never touches a template
substitution engine — the file is written exactly as the operator's paste buffer contained it.

## 3. Mandatory ingestion test (same command chain, via `;`)

The write and the verify **MUST** run in the **same command chain** so the assertion binds
the file that was just delivered:

```bash
S="$HOME/banxe-dev/<file>.md"; mkdir -p "$(dirname "$S")"; cat > "$S"; \
{ [ -s "$S" ] || { echo "STOP: empty"; exit 1; }; \
  B=$(wc -c <"$S"); [ "$B" -lt 500 ] && { echo "STOP: too small ($B)"; exit 1; }; \
  echo "delivered: bytes=$B lines=$(wc -l <"$S") sha256=$(sha256sum "$S"|awk '{print $1}')"; \
  echo "corruption:"; grep -c 'TITLE , -\|UOfd\|mojibake' "$S"; }
```

Acceptance thresholds (all must hold):

- `bytes > 500` — hard floor; anything smaller is a truncated paste.
- **no leftover placeholder** — grep for `{{`, `<PLACEHOLDER>`, or the specific markers used by
  the template; count MUST be `0`.
- `domain-markers > 0` — at least one domain-specific string that MUST be present in a genuine
  document (proves the paste was the intended payload).
- `corruption-markers → 0` — `grep -c 'TITLE , -\|UOfd\|mojibake'` returns `0`.
- **print `sha256`** — this is the **zero-loss baseline** carried into archival (§4).

Any threshold miss ⇒ STOP; do not archive; re-paste.

## 4. Zero-loss archival (follow-on)

Zero-loss archival admits **TWO** valid forms — pick per SSOT need, per **ADR-161**
(Intake SSOT-persistence). Both forms preserve the source **byte-for-byte**; they differ
only in whether provenance/metadata travels **with** the body inside the archived file.

### Form (a) — Pure `cp` (file-level sha equality)

The archived file **is** the source, byte-for-byte. Verification is a file-level sha match:

```bash
D="docs/sources/<final-name>.md"
sha256sum "$S" | awk '{print $1}' > /tmp/_src.sha
cp "$S" "$D"
sha256sum "$D" | awk '{print $1}' > /tmp/_dst.sha
diff -q /tmp/_src.sha /tmp/_dst.sha || { echo "STOP: sha256 drift"; exit 1; }
```

Use when: no header is needed (raw is the artefact), or downstream tooling must see
byte-identical file hashes.

### Form (b) — Header + body (YAML-metadata header + verbatim body) — **PREFERRED for SSOT**

The archived file carries a small **YAML metadata header** (provenance, slug, intake-date,
source-type, `sha256-body`, `body-bytes`, verify command) followed by the **verbatim** source
body. Verification is body-level: `sha256(tail -c <body-bytes> <archived-file>) == sha256(source)`.

**Mandatory header fields:**

- `sha256-body:` — sha256 of the verbatim body (**not** of the file).
- `body-bytes:` — exact byte count of the verbatim body.
- `verify:` — the exact command that reproduces the equality
  (`tail -c <body-bytes> <this-file> | sha256sum  ==  sha256-body`).

**Verify example** (paste-ready, same-chain):

```bash
D="docs/sources/<final-name>.md"
BB=$(grep -m1 '^body-bytes:' "$D" | awk '{print $2}')
SB=$(grep -m1 '^sha256-body:' "$D" | awk '{print $2}')
CALC=$(tail -c "$BB" "$D" | sha256sum | awk '{print $1}')
[ "$CALC" = "$SB" ] || { echo "STOP: body sha drift ($CALC != $SB)"; exit 1; }
[ "$CALC" = "$(sha256sum "$S" | awk '{print $1}')" ] || { echo "STOP: body != source"; exit 1; }
```

Use when: the source is an SSOT intake artefact and provenance MUST travel with the body
(academic paper, concept doc, regulatory text). This is the **preferred** form under
ADR-161 because header+body carries slug, intake-date, source-type, and provenance
alongside the bytes — a pure `cp` loses them.

### Critical clarification — file-sha of Form (b) is NOT drift

`sha256(<Form-(b) file>) ≠ sha256(<source>)` by construction — the header adds bytes.
This is **NOT** a zero-loss violation. The zero-loss assertion for Form (b) is
`sha256(tail -c body-bytes)`, not `sha256(file)`. A file-level sha comparison against
Form (b) is a **category error**; do not raise a STOP on it.

### Discipline (both forms, per FACTORY-CANON Execution Pattern)

- **Prepare-only** — no activation, no mint, no merge at delivery step.
- **Worktree (ADR-120)** — the archival step runs inside a session worktree, never in the
  shared checkout.
- **Paired PROPOSED shard** — every archival lands with an IL shard at `PROPOSED`; the
  operator mints and merges under HITL.

**Proven baseline (Form (b))** — EMI BANXE engine paper archived as
`docs/sources/emi-banxe-engine-2026-07-06.md`: `body-bytes = 49979`, `123 domain markers`,
`corruption = 0`,
`sha256-body = 9ef1b0308d9602a795b408111b1bddb3e127a9728f15b0cc4b3aea4a2257ef34`. This is
the reference case for what "zero-loss delivery + Form (b) archival" looks like end-to-end.

## 5. Hard rules (cross-terminal)

1. **Interactive editors are FORBIDDEN for delivery** — `nano`, `vim`, `code`, or any other
   interactive editor MUST NOT be used to receive the paste. Shell scripts only. Interactive
   editors reintroduce encoding decisions and defeat the byte-for-byte guarantee.
2. **Chat-attachment is NOT a valid zero-loss channel** for large documents — it corrupts
   encoding (RU → mojibake) and MUST NOT be used to deliver documents that will be archived.
3. **Inline base64 paste is NOT a valid zero-loss channel** for large documents — line-wrap
   and terminal buffering silently truncate the stream. STDIN-paste is the standard.
4. **The verify chain is mandatory** — a write without the same-chain ingestion test (§3) is
   not a delivery; it is an unverified paste. Do not archive it.
5. **Same discipline in all three terminals** — Factory (Left / A), Central, and Right
   (Orchestrating) all use STDIN-paste for large-document delivery. There is no
   terminal-specific alternative.
6. **Additive, not overriding** — this canon does not replace the FACTORY-CANON Execution
   Pattern; it specifies *how* the operator-paste step of that pattern is performed. Prepare-
   only, worktree authoring, PROPOSED shard, and operator merge under HITL all remain in
   force.

## 6. Anchors

- `docs/factory/FACTORY-CANON.md` — Execution Pattern; worktree authoring; prepare-only.
- `docs/sources/` — where verbatim source documents live post-archival.
- `docs/adr/ADR-161-intake-ssot-persistence.md` — Intake SSOT-persistence; header+body
  Form (b) is the canonical SSOT persistence pattern (this doc references it, does not
  restate it).
- `docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md` — pointer-first
  discipline; this doc references FACTORY-CANON rather than restating it.
- `docs/adr/ADR-120-per-session-worktree.md` — worktree isolation for the archival `cp`.
- `.claude/rules/compliance.md` — I-24 (append-only audit) — the sha256 baseline is the
  audit anchor.
