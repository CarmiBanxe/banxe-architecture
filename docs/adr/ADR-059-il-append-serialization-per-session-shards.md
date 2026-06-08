# ADR-059: Append-Serialization для IL через per-session shards

- Status: Proposed
- Date: 2026-06-08
- Deciders: CEO, CTIO
- Related: ADR-056 (ledger-coupling merge gate), ADR-057 (ledger append-only immutability), I-28
- Ledger: IL-159

## Context

Reestr instrukcij (INSTRUCTION-LEDGER.md) ispolzuet edinyj append-fajl. Pri parallelnoj rabote neskolkih sessij (Terminal A/B, neskolko zapuskov Claude Code) vozникают:

1. Kollizii nomerov IL-NNN: dve sessii nezavisimo berut "sleduyushchij svobodnyj" nomer (naprimer IL-159) i sozdayut dublikat.
2. Merge-konflikty hvosta: obe vetki dobavlyayut blok v odin i tot zhe konec fajla, konflikt po poslednim strokam (uzhe nablyudalos na IL-154/IL-155).
3. Gonka s guardian-ledger gate: gate trebuet novyj ### IL-NNN blok, no ne zashchishchaet ot uzhe zanyatogo nomera v parallelnoj vetke.

Koren problemy: monotonnyj schetchik IL-NNN + obshchij mutable hot-spot (hvost odnogo fajla) v raspredelennoj srede bez serializacii/blokirovki.

## Decision

Zamenit "odin obshchij append-fajl" na append-only shard-fajly po sessiyam, a edinyj INSTRUCTION-LEDGER.md sdelat proizvodnym (generiruemym) artefaktom, a ne istochnikom pravdy.

### 1. Struktura (istochnik pravdy)

```
ledger/
  entries/
    <session-id>/
      IL-<ISO8601Z>--<sid6>.md
  ...
INSTRUCTION-LEDGER.md   # generiruetsya, read-only dlya lyudej
```

Kazhdaya sessiya pishet tolko v svoj podkatalog -> fajly ne peresekayutsya -> merge-konfliktov po soderzhimomu fizicheski net (git trivialno merzhit nepere­sekayushchiesya fajly).

### 2. Identifikator zapisi

Vmesto monotonnogo IL-NNN sessiya generiruet lokalno, bez koordinacii, sortiruemyj sostavnoj klyuch:

```
IL-id = <UTC ISO8601, leksikograficheski sortiruemyj> + "--" + <session-id 6 hex>
```

Primer: IL-2026-06-08T21-03-12Z--a1b2c3

- Globalno unikalen bez koordinacii (timestamp + session salt).
- Leksikograficheski sortiruem -> determinirovannyj poryadok pri sborke.
- Chelovekochitaemyj IL-NNN sohranyaetsya, no prisvaivaetsya determinirovanno PRI SBORKE.

### 3. Sborka INSTRUCTION-LEDGER.md (determinirovannaya)

CI-shag sobiraet final:

```
all = glob("ledger/entries/**/*.md")
sort by (timestamp, session-id)   # total order, tie-break po session-id
assign IL-NNN sequentially        # numeraciya prisvaivaetsya ZDES, odin raz
render -> INSTRUCTION-LEDGER.md
```

Monotonnaya numeraciya (IL-149, IL-150 ...) ostaetsya dlya lyudej i sovmestimosti, no stanovitsya funkciej ot mnozhestva shard'ov, a ne tem, chto sessiya ugadyvaet.

### 4. Usilenie append-only invarianta (I-28)

- Na shard'ah: gate proveryaet, chto v diff PR fajly v ledger/entries/ tolko dobavlyayutsya (status A); sushchestvuyushchie ne modificiruyutsya i ne udalyayutsya (git diff --diff-filter=DM po etomu puti dolzhen byt pust).
- Na generiruemom fajle: INSTRUCTION-LEDGER.md pomechen kak generated; ruchnye pravki zapreshcheny gate'om (diff protiv rezultata rebuild -> esli rashoditsya, fail).

## Consequences

Plyusy:
- Merge-konflikty po soderzhimomu ustranyayutsya polnostyu (razdelnye fajly).
- Kollizii nomerov IL ustranyayutsya (nomer prisvaivaetsya pri sborke, ne sessiej).
- Gonka dvuh PR za odin IL-NNN ischezaet (nomer ne hranitsya v vetke).
- Append-only stanovitsya strozhe: pro neizmennost otdelnyh fajlov, a ne "ne tron predydushchie stroki bolshogo fajla".

Minusy / trade-offs:
- Chasy sessij mogut rassinhronizirovatsya: poryadok ostaetsya total i determinirovan (tie-break po session-id), no "realnaya" hronologiya mozhet slegka plyt. Dlya zhurnala reshenij priemlemo.
- Nuzhen novyj CI build-step + pravilo "ne redaktirovat generated fajl rukami".
- Chtenie "chto poslednee" chut dorozhe (agregaciya shard'ov), reshaetsya generiruemym fajlom.

## Sprints (rollout plan)

- S0 (etot ADR): zafiksirovat koncepciyu append-serialization. Status Proposed. [IL-159]
- S1: zavesti ledger/entries/<session-id>/ + ledger/README.md (format IL-<ISO8601Z>--<sid6>).
- S2: generator INSTRUCTION-LEDGER.md iz shard'ov (CI build step).
- S3: usilit guardian.yml: append-only po ledger/entries/ + "generated == rebuild".
- S4: perevod sessij na shard-zapis; obshchij fajl read-only; ADR-059 -> Accepted.

## Open question

session-id privyazka: imya vetki | rol terminala (A/B) | per-run UUID. Vliyaet na tie-break i chitaemost shard-kataloga. Reshaetsya v S1.
