# Landing handoff — MAIN execution package (sub-B prepared, MAIN executes)

**Plane:** docs-plane only. **Prepared by:** sub-B (RIGHT terminal). **Executed by:** MAIN/operator.
**Canon:** sub-B is **NOT** single-writer (§71) → sub-B **не пушит/не открывает PR/не мёржит**. Этот документ — пакет для MAIN/operator. **Date:** 2026-06-27.

> **Confirmed by live audit (evidence, not memory):** вся работа sub-B существует **только в локальных worktrees**, **НЕ запушена** ни в один origin (EMI + ARCH `ls-remote` по paybis/wave-a/phase36 = **пусто**, verified). 7 открытых governance-PR в ARCH (central terminal активен → §71 single-writer; координировать во избежание IL-collision).

## Артефакты к посадке (verified HEADs)

| Repo | Branch | HEAD | Содержимое |
|---|---|---|---|
| EMI | `agent/factory/paybis/wave-a-guard` | `cfe185d` | E9 semgrep deny-rules (neuronext/bitrix) в `.semgrep/banxe-rules.yml` |
| EMI | `agent/factory/paybis/wave-a-adapter` | `2edf49d` | PaybisCryptoAdapter + webhook (100% cov, fenced, FROZEN port) |
| ARCH | `agent/factory/paybis/neuronext-retirement-adr` | `689ae66` | 16 commits, IL-545…560 (ADR-138, dossier, plan, mandatory-track E9/E10/E12, consolidation CLOSED) |
| ARCH | `agent/factory/phase36/impl-state-refresh` | `2264751` | IL-551 EMI impl-state refresh (отдельно) |

---

## ℹ SIGNATURE NOTE (not a blocker)

> **Verified facts (evidence, not memory):**
> 1. **Commits unsigned:** все коммиты ветки IL-545…562 + EMI `wave-a-*` (`cfe185d`/`2edf49d`/`42563df`) = **`%G?=N`** (unsigned; raw verify = "No signature").
> 2. **Branch-protection НЕ требует подписей:** `gh api …/branches/main/protection/required_signatures` → **`enabled = false`**. → **unsigned commits МОЖНО мёржить**; подписи **не являются merge-gate**.

**Честная коррекция (двойная):**
- Прошлые per-step «SSH-signed ✓» были **неточны** — проверка опиралась на `grep 'BEGIN SSH SIGNATURE'`, что **не** валидная верификация. Коммиты фактически `%G?=N`. *(остаётся в силе)*
- Последующий «⚠ SIGNATURE BLOCKER + mandatory re-sign gate» **переоценил серьёзность** — `required_signatures=false`, значит это **НЕ блокер** merge. *(исправлено здесь)*

**Re-sign — OPTIONAL (гигиена, не gate).** Если хочется паритета с подписанным main (`%G?=E`), MAIN может опционально пере-подписать во время rebase:
```bash
# OPTIONAL hygiene only — NOT required to merge (required_signatures=false)
git -C /home/mmber/banxe/.wt-paybis rebase --exec 'git commit --amend --no-edit -S' origin/main
git -C /home/mmber/banxe/.wt-paybis log --format='%h %G? %s' origin/main..HEAD   # проверить при желании
```
sub-B всё равно не может подписать (нет signing-key, ssh-agent off, `allowedSignersFile` unset) — но это **moot**, т.к. подпись не требуется для merge.

---

## ✅ РЕАЛЬНЫЕ required gates (branch-protection, verified `gh api`)

MAIN должен удовлетворить **именно это** (не подписи):

| Gate | Значение |
|---|---|
| **Required status checks** (должны быть GREEN) | `guardian-factory`, `guardian-project`, `guardian-ledger`, `ledger-append-only` |
| **required_linear_history** | `true` → **rebase-onto-main обязателен** (ради linear history, **не** ради подписи); merge-commits запрещены |
| **enforce_admins** | `true` (admin тоже под protection) |
| **allow_force_pushes** | `false` |
| **required_signatures** | **`false`** → подпись НЕ требуется |

---

## 1. Pre-flight (MAIN, §73)

- `git fetch origin main` в **обоих** repos.
- **IL re-id ОБЯЗАТЕЛЕН (не «возможен»):** sub-B использовал **provisional** IL-545…560 (frozen-at-merge). На ARCH **origin/main IL max = 551** (verified — main уже продвинулся 7 gov-PR-ами) → номера sub-B **гарантированно коллидируют**. MAIN регенерирует через `python ledger/build_ledger.py` **FROM ROOT** → `--check` exit 0; правит все human-facing `[IL-NNN]` под назначенные.
- Сериализовать с 7 gov-PR (strict branch protection форсирует rebase-before-merge).

## 2. ARCH landing order

a. push `agent/factory/paybis/neuronext-retirement-adr` (IL-545…562; commits `%G?=N` unsigned — **OK, подпись не требуется**, см. ℹ SIGNATURE NOTE).
b. rebase onto current `origin/main` (**обязательно** — `required_linear_history=true`) + `python ledger/build_ledger.py --check` **FROM ROOT** (re-id IL-collisions; append-only: добавлены только новые ключи, 0 mutated/removed).
   - *(optional hygiene)* пере-подписать в том же rebase `--exec 'git commit --amend --no-edit -S'` — **не gate**.
c. **ADR number: renumbered 126 → ADR-138 (DONE, sub-B).** Provisional ADR-126 коллидировал с merged `ADR-126-hermes` на origin/main @ `4937778` (+ ADR-127…137 заняты) → renumbered to true next-free **138** (ADR-119). MAIN лишь **re-confirms ADR-138 ещё свободен** на момент merge (main мог продвинуться); если 138 занят — max+1 (never renumber a merged ADR).
d. убедиться, что required checks GREEN (`guardian-factory`/`guardian-project`/`guardian-ledger`/`ledger-append-only`); open PR + merge (atomic, §74).
e. *(optional)* `phase36/impl-state-refresh` отдельным PR (IL-551 → re-id).

## 3. EMI landing order

a. push `agent/factory/paybis/wave-a-guard` (E9 deny-rules) **ПЕРВЫМ**.
b. push `agent/factory/paybis/wave-a-adapter` (теперь incl. Wave-B `42563df`). Commits `%G?=N` unsigned — *(optional hygiene re-sign; не gate — EMI main signature-policy подтвердить аналогично, но подпись не блокирует)*.
c. ⚠ **PRE-MERGE FIX (verified file list — корректирует исходную записку):** после посадки guard, `banxe-no-neuronext-reintroduction` сработает на governance-docstrings со словом «NeuroNext». **Точные файлы/строки (verified `git grep`; перепроверить — Wave-B добавил ещё упоминания в `PAYBIS-WAVE-A.md`):**
   - `services/ledger/production/paybis_crypto_adapter.py` — **строка 3** (docstring «ADR-138 (NeuroNext retired …)»).
   - `services/ledger/production/PAYBIS-WAVE-A.md` — **строки 3, 5, 25** (под `services/**`, НЕ под `docs/**` → **guard exclude не применяется** → тоже сработает).
   - `services/ledger/production/paybis_webhook.py` — **НЕ содержит** «neuronext» (verified; исходная записка ошибочно его включала — **убрать из fix-листа**).

   Fix: добавить `# nosemgrep: banxe-no-neuronext-reintroduction` на эти строки **ИЛИ** переформулировать (например «the retired provider (ADR-138)» без литерала). **Перепроверить строки на момент merge** (main двигается).
d. run quality-gate (semgrep banxe-rules + tests + coverage ≥90%) → **должно быть зелёным** (после fix 3c).
e. open PR + merge.

## 4. Post-landing

Wave B строится на смёрженном Wave-A seam — но **остаётся GATED на SRC-06** (PAYBIS API spec), который **всё ещё НЕ предоставлен**. До SRC-06/07/08 + ADR-114 go-live gate live-транспорт остаётся fenced.

## 5. Canon note

sub-B **не пушит/не PR/не мёржит** ничего из этого — все действия §1–4 выполняет **MAIN/operator** per §71 (single-writer) / §74 (atomic merge). sub-B только подготовил пакет.

## 6. Corrections log (honest, no hand-waving)

1. **Unsigned fact — confirmed.** Все sub-B commits `%G?=N` (unsigned); прошлые «SSH-signed ✓» отчёты были неточны (`grep BEGIN SSH SIGNATURE` ≠ верификация). **Стоит в силе.**
2. **Blocker severity — corrected to NON-blocking.** `gh api …/required_signatures` → `enabled=false`. Подписи **не требуются** для merge → прежний «mandatory re-sign gate» был **over-stated**; downgrade до ℹ optional-hygiene. Удалён mandatory step b2 из ARCH §2 и EMI §3.
3. **Реальные gates задокументированы:** `guardian-factory/project/ledger` + `ledger-append-only` GREEN; `required_linear_history=true` (rebase обязателен ради linear history, не подписи); `enforce_admins=true`; force-push off. *(verified `gh api`)*

---

## 👉 OPERATOR EXECUTES — not sub-B (current verified commands, 2026-06-27 — ALL 5 branches)

> Выполняет **оператор/MAIN**, НЕ sub-B (§71 single-writer). sub-B подготовил пакет; команды sub-B
> **не запускает**. Подписи **не требуются** (`required_signatures=false`; все коммиты `%G?=N` mergeable).
> **State (verified live audit origin/main, IL max=565 → provisional до IL-570 collide → re-id обязателен):**

| # | Repo | Worktree | Branch | HEAD | ahead |
|---|---|---|---|---|---|
| 1 | ARCH | `.wt-paybis` | `agent/factory/paybis/neuronext-retirement-adr` | `9544c66` | 26 (IL-545…570) |
| 2 | ARCH | `.wt-implstate` | `agent/factory/phase36/impl-state-refresh` | `39e1198` | 4 (IL до 554) |
| 3 | EMI | `.wt-paybis-guard` | `agent/factory/paybis/wave-a-guard` | `cfe185d` | 1 (E9 deny-rules) |
| 4 | EMI | `.wt-paybis-wavea` | `agent/factory/paybis/wave-a-adapter` | `c21bf2e` | 6 (Wave A/B+sandbox+DI) |
| 5 | EMI | `.wt-auth-orphans` | `agent/factory/consolidation/auth-legacy-orphans` | `998040a` | 1 (E10 sca/totp delete) |

### ARCH landing (2 branches: #1 dossier, #2 impl-state)
```bash
# push both
git -C /home/mmber/banxe/.wt-paybis     push -u origin agent/factory/paybis/neuronext-retirement-adr   # 26 commits, IL-545…570
git -C /home/mmber/banxe/.wt-implstate  push -u origin agent/factory/phase36/impl-state-refresh         # 4 commits, IL до 554
# per branch: rebase (linear history) → re-id IL (origin max=565, collision certain) → --check FROM ROOT
git -C /home/mmber/banxe/.wt-paybis     rebase origin/main && (cd /home/mmber/banxe/.wt-paybis && python3 ledger/build_ledger.py && python3 ledger/build_ledger.py --check)
git -C /home/mmber/banxe/.wt-implstate  rebase origin/main && (cd /home/mmber/banxe/.wt-implstate && python3 ledger/build_ledger.py && python3 ledger/build_ledger.py --check)
# ADR renumbered 126→138 already (DONE; 125-137 occupied on origin/main) — MAIN re-confirms 138 still free at merge; required checks GREEN (guardian-factory/project/ledger + ledger-append-only); PR + merge each (atomic, §74)
```

### EMI landing (3 branches, ORDER MATTERS: #3 guard → #4 adapter → #5 auth-orphans)
```bash
# 1. PRE-MERGE nosemgrep fix on the ADAPTER branch (so E9 guard stays green once both land).
#    Verified neuronext targets on c21bf2e (legitimate ADR-138 retirement refs, re-verify lines at run time — main moved):
#      services/ledger/production/PAYBIS-WAVE-A.md          (5 refs: ~lines 6,8,28,102,153)  → <!-- nosemgrep: banxe-no-neuronext-reintroduction --> OR reword
#      services/ledger/production/paybis_crypto_adapter.py  (1 ref: ~line 3)                 → # nosemgrep: banxe-no-neuronext-reintroduction OR reword
#    (provider/sandbox/wave_b/webhook contain NO 'neuronext', verified.)
# 2. push in order
git -C /home/mmber/banxe/.wt-paybis-guard    push -u origin agent/factory/paybis/wave-a-guard            # E9 FIRST
git -C /home/mmber/banxe/.wt-paybis-wavea    push -u origin agent/factory/paybis/wave-a-adapter          # Wave A/B + sandbox + DI-gate
git -C /home/mmber/banxe/.wt-auth-orphans    push -u origin agent/factory/consolidation/auth-legacy-orphans  # E10 sca/totp deletion
# 3. per branch: rebase + quality-gate GREEN (semgrep banxe-rules + tests ≥90% + ruff)
#    auth-orphans MUST keep: pytest -k auth = 185 passed + pytest --collect-only clean (no import errors from removals)
# 4. PR + merge each
```

## Notes
- **sub-B does NOT push/PR/merge** ничего из этого (§71 single-writer = MAIN). sub-B prepared only.
- **signatures NOT required** (`required_signatures=false`); commits `%G?=N` mergeable (re-sign optional hygiene).
- **after landing:** PAYBIS sandbox = **flag-gated, default OFF** (zero regression); **legacy `sca`+`totp`
  удалены** (E10 wave-1, branch #5). Live activation остаётся gated на: **SRC-06** + sandbox base-URL/creds +
  **Onboarding/Fee** + **CASP T&C 2026-07-01** + **TR/MLRO go-live** (ADR-114).
- **governance-drift flag (separate, CENTRAL action — НЕ sub-B):** `docs/CRYPTO-BLOCK.md` не согласован с
  ADR-108 (0 ADR-108/paybis refs, 46 neuronext) — рекомендуется central-обновление (superseded-by-ADR-108
  + re-base I-30/32/33/36); см. `PAYBIS-LEGACY-FLOW-MAP.md §3`.

### Refs
Live audit 2026-06-27 (5 branches: ARCH `9544c66` 26-ahead IL-545…570 + `39e1198` 4-ahead IL≤554; EMI `cfe185d`/
`c21bf2e`/`998040a`; origin IL max=565; neuronext `git grep` on `c21bf2e` → PAYBIS-WAVE-A.md ×5 + paybis_crypto_adapter.py:3;
required checks guardian-factory/project/ledger + ledger-append-only; `required_signatures=false`); §71/§73/§74;
ADR-138/119/114/108; PLAN §1A/§5A; `PAYBIS-SANDBOX-STATE.md`, `PAYBIS-GOVERNANCE-FACTS.md`, `PAYBIS-LEGACY-FLOW-MAP.md`.
