# MIG-M2.8-PRE — §5a Verify-Items Resolution (tompayment + auth) (correction-addendum, docs-only, no merge)

> **Type:** correction-addendum к MIG-M2.8-PRE-shell-inventory (IL-431). **Status:** roster НЕ
> выбран — operator gate. Закрывает 2 открытых §5a verify-айтема.
> **Canon:** ADR-102, ADR-103 (legacy read-only), factory-only (shell = read-only audit), no
> `--admin`/`--auto`/bypass, ADR-059-A append-only, **«не галлюцинировать — только верифицированная
> информация»** (provenance каждого факта помечен).
> **Baseline:** banxe-architecture origin/main `6e81797`; max il_ts IL-431+.
> **Sources:** operator-attested clone `/tmp/bx-legacy/banxe-code/banxe` (tompayment); evo1
> re-verified `/srv/banxe-legacy/work/banxe-code/banxe` (auth disambiguation).

---

## 1. Scope

Закрытие двух verify-айтемов, открытых в shell-inventory (IL-431, §5a):
1. источник `banxe-tompayment` (ранее «0 файлов» в `/srv`-clone);
2. классификация `banxe-auth` (backend vs frontend).

Это correction к shell-inventory; **canonical target по-прежнему НЕ выбирается фабрикой** (§7).

> **Provenance note (канон не-галлюцинировать):** ниже у каждого факта указан источник —
> **[verified-evo1]** (переподтверждён на evo1 `/srv`) либо **[operator-attested]** (из
> `/tmp/bx-legacy`, на evo1 недоступен для переверификации). Смешение не допускается.

---

## 2. tompayment resolution — [operator-attested]

- **Operator-attested (`/tmp/bx-legacy/banxe-code/banxe`):** `banxe-tompayment` POPULATED —
  **1462 files / 1286 src**, React + webpack, НЕ submodule → **LIVE product web shell**, ВХОДИТ в
  roster.
- **Причина прежнего «0 файлов»:** артефакт другого clone-пути (`/srv` vs `/tmp`) — на `/srv`-clone
  директория пустая/неинициализированная.
- **Transparency (evo1 re-check):** на evo1 присутствует только `/srv`-clone, где
  `banxe-tompayment` = **0 файлов** (не submodule, без `.git`-pointer); путь `/tmp/bx-legacy`
  на evo1 **отсутствует** → фабрика приняла tompayment-резолюцию **на operator-attestation**, без
  независимой переверификации. **Follow-up:** освежить `/srv`-clone (или указать canonical
  clone-путь), чтобы tompayment стал [verified-evo1] перед стартом его миграции.

**Вывод:** `banxe-tompayment` принят как LIVE product web shell (operator-attested); до refresh
`/srv`-clone остаётся помеченным provenance-флагом.

---

## 3. auth disambiguation — [verified-evo1]

Переподтверждено на evo1 (`/srv/banxe-legacy/work/banxe-code/banxe`):

| Dir | package | признаки | Классификация |
|---|---|---|---|
| `banxe-auth` (дефис) | `auth-api` | `@nestjs/core`, `nest-cli.json` present | **NestJS backend** → ВНЕ frontend roster (auth-сервис; покрыт **M2.3** identity/auth reconcile) |
| `banxe_auth` (подчёркивание) | `banxe-auth` | `react`, нет `nest-cli.json` | **React web frontend** → **LIVE auth web shell**, ВХОДИТ в roster (html через webpack-plugin, не static `public/index.html`) |

**Вывод:** auth web-shell для roster = **`banxe_auth`** (underscore). `banxe-auth` (dash) —
backend, исключён. Прежняя shell-inventory §5a-пометка про `banxe-auth` подтверждена и уточнена
(нужный frontend — underscore-вариант).

---

## 4. Corrected live web-shell roster

| Shell | Роль | provenance |
|---|---|---|
| `banxe-dashboard` | customer web | [verified-evo1] |
| `banxe-tompayment` | product web | **[operator-attested]** |
| `banxe-trade-view-new` / `banxe-trade-view` | trading | [verified-evo1] |
| `banxe_auth` (underscore) | auth web | [verified-evo1] |
| `banxe-admin-panel-new` | back-office admin | [verified-evo1] |
| `banxe-id-frontend` | identity/KYC ui | [verified-evo1] |
| `banxe-manual-payments` | payments ops | [verified-evo1] |

Исключены из frontend roster: `banxe-auth` (dash, NestJS backend — M2.3-covered).

---

## 5. Updated role mapping

- **Web-роли:** добавлен `banxe-tompayment` → product-web (operator-attested); auth-shell
  уточнён на `banxe_auth` (underscore).
- **Mobile / retire-list:** БЕЗ изменений относительно shell-inventory (IL-431):
  mobile = `banxe-frontend-mobile` + `dashboard-mobile`; retire = `banxe-admin-panel` (dash, 6
  src) + `banxe-acl-frontend` (0) + `banxe-user-admin-panel` (0).
- Mapping role→canonical app остаётся применим к любому roster A/B/C (см. shell-inventory §5).

---

## 6. Net effect on M2.8

- **Оба §5a verify-айтема CLOSED** (tompayment resolution + auth disambiguation).
- **Shell-roster финализирован** (с одним provenance-флагом на tompayment до refresh `/srv`-clone).
- **M2.8-precondition фактура complete:** roster-audit (IL-424) + collision-matrix (IL-429) +
  shell-inventory (IL-431) + verify-resolution (этот документ).
- Миграция shells остаётся **gated** на operator roster-выбор.

---

## 7. Open governance item

- **Roster-выбор (A/B/C) = operator-решение** (M2.8 precondition). Фабрика НЕ выбирает canonical.
- **Миграция стартует ПОСЛЕ** operator roster-выбора + collision-resolution (IL-429): отдельный
  шаг (ADR + ledger) фиксирует canonical target + mapping + sequencing.
- **Остаточный follow-up (не блокирует roster-выбор):** refresh `/srv` legacy-clone, чтобы
  `banxe-tompayment` стал [verified-evo1] перед стартом его конкретной миграции.
- **KYC-смежность:** `banxe-id-frontend` миграция координируется с I-27 HITL-L4 gate.

---

### Refs
MIG-M2.8-PRE-shell-inventory.md (IL-431, §5a); MIG-M2.8-PRE-collision-matrix.md (IL-429);
MIG-M2.8-PRE-frontend-roster-audit.md (IL-424); MIG-M2.3 (identity/auth reconcile — backend
auth-api covered); legacy `/tmp/bx-legacy/...` (operator-attested), `/srv/banxe-legacy/...`
(verified-evo1); ADR-102, ADR-103, ADR-059-A; I-27.
