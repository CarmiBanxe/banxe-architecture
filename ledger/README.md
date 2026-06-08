# ledger/ — Append-Serialization Shards (ADR-059)

Istochnik pravdy dlya reestra instrukcij. Realizuet ADR-059: per-session
shard-fajly vmesto odnogo obshchego append-fajla, chtoby ustranit kollizii
nomerov IL i merge-konflikty pri parallelnoj rabote neskolkih sessij.

> **VAZHNO:** `INSTRUCTION-LEDGER.md` v korne — GENERIRUEMYJ artefakt
> (sm. Sprint S2). Ne redaktirovat ego rukami. Pravda zhivet zdes, v shard'ah.

## Struktura

```
ledger/
  README.md                      # etot fajl (specifikaciya)
  entries/
    <session-id>/                # odin podkatalog na sessiyu
      IL-<ISO8601Z>--<sid6>.md   # odin fajl na zapis (append-only)
```

## session-id (reshenie S1)

`session-id` = imya vetki, normalizovannoe v slug.

- Normalizaciya: nizhnij registr; vse simvoly krome [a-z0-9] -> `-`;
  povtornye `-` skleivayutsya; obrezka `-` po krayam.
  Primer: `docs/adr-059-il-append` -> `docs-adr-059-il-append`.
- Pochemu vetka: v git-workflow kanona "odna vetka = odna rabochaya sessiya",
  poetomu imya vetki estestvenno unikalno na sessiyu, chitaemo v kataloge
  i daet stabilnyj tie-break pri sborke.
- `<sid6>` = pervye 6 hex ot sha1(session-id) — korotkij salt dlya imeni fajla,
  chtoby fajly ne stalkivalis dazhe pri sovpadenii timestamp mezhdu sessiyami.

## Identifikator zapisi

```
IL-<UTC ISO8601 basic, sortiruemyj>--<sid6>
```

- Timestamp v UTC, format `YYYY-MM-DDTHH-MM-SSZ` (dvoetochiya zameneny na `-`
  dlya sovместimosti s FS). Leksikograficheskij poryadok == hronologicheskij.
- Primer fajla: `IL-2026-06-08T21-03-12Z--a1b2c3.md`
- `IL-NNN` (chelovekochitaemyj nomer) zdes NE hranitsya: on prisvaivaetsya
  determinirovanno pri sborke (S2), kak funkciya ot otsortirovannogo mnozhestva
  vseh shard'ov. Eto i ustranyaet gonku za nomer.

## Format shard-fajla (zapis)

Kazhdyj fajl — odna zapis IL v tom zhe smysle, chto i blok v starom ledger:

```markdown
---
il_ts: 2026-06-08T21:03:12Z        # UTC, istochnik poryadka
session_id: docs-adr-059-il-append # slug vetki
source: CEO | CTIO | auto
status: TODO | IN_PROGRESS | REVIEW | DONE | FAILED | BLOCKED
---

## <kratkij zagolovok zapisi>

- **Instrukciya:** doslovnyj tekst.
- **Shagi:** atomarnye shagi.
- **Proof:** komanda + vyvod (dlya DONE obyazatelno).
- **Deviation:** otklonenie (esli bylo).
- **Blocker:** chto pomeshalo (esli FAILED/BLOCKED).
- **Refs:** ADR/IL ssylki.
```

## Invariant (usilennyj I-28)

- Fajly v `ledger/entries/` tolko **dobavlyayutsya** (git status `A`).
  Modifikaciya/udalenie sushchestvuyushchih shard'ov ZAPRESHCHENY (gate, S3).
- `INSTRUCTION-LEDGER.md` raven rezultatu sborki iz shard'ov (gate, S3).

## Rollout (ADR-059)

- S0: koncepciya zafiksirovana (ADR-059 Proposed, IL-159). DONE.
- S1 (etot kommit): struktura `ledger/entries/` + specifikaciya. <- here
- S2: generator `INSTRUCTION-LEDGER.md` iz shard'ov (CI build step).
- S3: usilenie `guardian.yml` (append-only po shard'ah + generated==rebuild).
- S4: perevod sessij na shard-zapis; obshchij fajl read-only; ADR-059 Accepted.
