# Shard Workflow (ADR-059 S4) — kak dobavlyat zapisi v reestr

> **Status:** ADR-059 Accepted (S4 cutover 2026-06-08).
> `INSTRUCTION-LEDGER.md` v korne — GENERIRUEMYJ read-only artefakt. Pravda zhivet v `ledger/entries/`.

## Pravilo

S S4 vse NOVYE zapisi reestra sozdayutsya TOLKO kak per-session shard-fajly. Ruchnaya pravka `INSTRUCTION-LEDGER.md` zapreshchena (guardian/ADR-057). Istoricheskie bloki IL-001..IL-162 ostayutsya zamorozhennym arhivom i ne migriruyutsya (sm. ADR-059 -> Cutover).

## Kak sozdat zapis

1. Opredeli `session_id` = imya tekushchej vetki, normalizovannoe v slug:
   - lowercase; vse simvoly krome [a-z0-9] -> `-`; szhat povtornye `-`; obrezat `-` po krayam.
   - primer: vetka `feat/ADR-059_S4 cutover` -> `feat-adr-059-s4-cutover`.
2. Vychisli salt = pervye 6 hex `sha1(session_id)`.
3. Sozdaj fajl: `ledger/entries/<session_id>/IL-<ISO8601Z>--<salt>.md`
   - timestamp v imeni: `YYYY-MM-DDTHH-MM-SSZ` (dvoetochiya zameneny na `-`).
4. Soderzhimoe — YAML front-matter + telo:

```
---
il_ts: 2026-06-08T21:03:12Z
session_id: feat-adr-059-s4-cutover
source: CEO | CTIO | auto
status: TODO | IN_PROGRESS | REVIEW | DONE | FAILED | BLOCKED
---
### <kratkij zagolovok>

- **Instrukciya:** doslovnyj tekst.
- **Shagi:** atomarnye shagi.
- **Proof:** komanda + vyvod.
- **Deviation:** otklonenie (esli bylo).
- **Blocker:** chto pomeshalo (esli FAILED/BLOCKED).
- **Refs:** ADR/IL ssylki.
```

## Vazhno

- IL-NNN nomer NE hranitsya v sharde — on prisvaivaetsya determinirovanno generatorom (`build_ledger.py`) sortirovkoj po `(il_ts, session_id, path)`.
- Shardy append-only: udalenie / pereimenovanie / pravka sushchestvuyushchih fajlov zapreshcheny (Invariant I-28, guardian `guardian-ledger-shards`).
- Pered push proveryaj lokalno: `python ledger/build_ledger.py --check`.
- Regeneraciya monolita (pri neobhodimosti): `python ledger/build_ledger.py`.

## Gates (CI)

- `guardian-ledger-shards` (S3): shard append-only + `--check` (generated == rebuild).
- `ledger-append-only` (ADR-057): immutability istorii.
- `guardian-ledger` (ADR-056): coupling — izmenenie otslezhivaemyh putej trebuet novogo IL-bloka.
