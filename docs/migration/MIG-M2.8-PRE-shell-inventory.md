# MIG-M2.8-PRE — Legacy Frontend Shell Inventory + Migration Mapping (addendum, docs-only, no merge)

> **Type:** addendum к MIG-M2.8-PRE (roster-audit IL-424 + collision-matrix IL-429). **Status:**
> roster НЕ выбран — operator gate. Завершает M2.8-precondition фактуру legacy-стороной.
> **Canon:** ADR-102 (Duplication Audit), ADR-103 (legacy read-only server-side), factory-only
> (shell = read-only audit), no `--admin`/`--auto`/bypass, ADR-059-A append-only,
> **«не галлюцинировать — только верифицированная информация»**.
> **Baseline:** banxe-architecture origin/main `f94719a`; max il_ts IL-429+.
> **Source (read-only, verified):** `/srv/banxe-legacy/work/banxe-code/banxe` (canonical ADR-103
> legacy path).

---

## 1. Scope

Финальное дополнение M2.8-precondition: **inventory legacy frontend shells** (verified src-counts,
package-names, frameworks) + **role-mapping skeleton** для будущей миграции в canonical EMI
frontend target. Canonical target **НЕ выбирается фабрикой** (operator gate, §7); mapping
применим к любому из roster A/B/C.

> **Verification note:** все числа ниже — из read-only обхода canonical legacy-пути; где они
> расходятся с ранее заявленными данными — расхождение явно отмечено (§5a). Канон запрещает
> переносить непроверенные факты.

---

## 2. Live web frontend shells (verified)

| Legacy dir | package name | framework | src files | Роль |
|---|---|---|---|---|
| `banxe-dashboard` | `banxe-dashboard` | React | **3084** | customer web (крупнейший) |
| `banxe-trade-view-new` | `web-boilerplate-ilink` | React | 589 | trading web (new) |
| `banxe-admin-panel-new` | `banxe-admin-panel` | React | 269 | back-office admin (new) |
| `banxe-trade-view` | `cex_front_admin` | React | 178 | trading/CEX admin (old) |
| `banxe-id-frontend` | `banxe-id` | React | 102 | identity/KYC frontend |
| `banxe-manual-payments` | `banxe-manual-payments` | React | 84 | manual-payments ops |

Все — React (webpack/vite). Суммарно ~4.3k src-файлов; `banxe-dashboard` доминирует.

---

## 3. Live mobile shells (verified)

| Legacy dir | package name | framework | src files | Роль |
|---|---|---|---|---|
| `banxe-frontend-mobile` | `Banxe` | React Native | 47 | customer mobile |
| `dashboard-mobile` | `reactNativeBoilerplate` | React Native | 35 | dashboard mobile |

---

## 4. Dead / empty shells — retire (no migration)

| Legacy dir | src files | Причина |
|---|---|---|
| `banxe-admin-panel` | 6 | superseded by `banxe-admin-panel-new` |
| `banxe-acl-frontend` | 0 | пусто |
| `banxe-user-admin-panel` | 0 | пусто |

---

## 5. Target-mapping skeleton (role → canonical app; БЕЗ выбора canonical)

| Legacy shell | Роль | → Canonical app (любой roster A/B/C) |
|---|---|---|
| banxe-dashboard | customer web | `web` (customer) |
| banxe-trade-view-new / banxe-trade-view | trading | `web` (trading module) |
| banxe-admin-panel-new | back-office admin | `web` (admin) |
| banxe-id-frontend | identity/KYC ui | `web` (id) — **KYC-смежно: scope под I-27 gate** |
| banxe-manual-payments | payments ops | `web` (ops) |
| banxe-frontend-mobile | customer mobile | `mobile` |
| dashboard-mobile | dashboard mobile | `mobile` (слить с customer или retire — решается при миграции) |

> Mapping иллюстративный; конкретный canonical app зависит от operator roster-выбора (A/B/C) и
> collision-resolution (IL-429).

### 5a. Divergence от ранее заявленной фактуры (verified-контроль)

| Объект | Заявлено ранее | Verified (этот аудит) | Вывод |
|---|---|---|---|
| `banxe-auth` / `banxe_auth` | auth **web** shell (~301) | `auth-api` — **NestJS backend** (nest-cli.json, src=54) | **НЕ frontend shell** → исключён из frontend roster (это backend auth-сервис) |
| `banxe-tompayment` (tompayment-web) | product web (~1275) | **0 файлов** в clone (пусто / submodule не populated) | live product web **НЕ подтверждён** в canonical legacy clone → требует отдельной верификации источника до включения в миграцию |

> Per канон «не галлюцинировать»: эти два объекта **не включены** в live web-shells (§2) до
> подтверждения. Operator может уточнить источник для tompayment, если он живёт вне основного clone.

---

## 6. M2.8 sequencing hint (gated на roster-выбор)

Предлагаемый порядок миграции (по приоритету/размеру; стартует ПОСЛЕ operator roster-выбора):

1. **customer web** — `banxe-dashboard` (крупнейший, наибольшая ценность) first.
2. **admin / payments ops** — `banxe-admin-panel-new`, `banxe-manual-payments`.
3. **trading** — `banxe-trade-view-new` (+ дедуп с `banxe-trade-view`).
4. **identity** — `banxe-id-frontend` (**KYC-смежно → координация с I-27 gate**).
5. **mobile** — `banxe-frontend-mobile` (+ решение по `dashboard-mobile`).
6. **retire** — dead shells (§4) без миграции.

(`banxe-tompayment` — только после подтверждения источника, §5a.)

---

## 7. Open governance item

- **Roster-выбор (A/B/C) = operator-решение** (M2.8 precondition). Фабрика НЕ выбирает canonical.
- **Миграция shells стартует ПОСЛЕ** operator roster-выбора + collision-resolution (IL-429):
  отдельный шаг (ADR + ledger) фиксирует canonical target + mapping (§5) + sequencing (§6).
- **M2.8-precondition фактура теперь complete:** roster-audit (IL-424) + collision-matrix (IL-429)
  + shell-inventory (этот документ).
- **KYC-смежность:** `banxe-id-frontend` миграция координируется с KYC/KYB/AML gate (I-27 HITL-L4
  sign-off) — identity ui не мигрируется в обход I-27 scope.

---

### Refs
MIG-M2.8-PRE-frontend-roster-audit.md (IL-424); MIG-M2.8-PRE-collision-matrix.md (IL-429);
MIG-CLOSURE-non-gated-complete.md (IL-428); legacy `/srv/banxe-legacy/work/banxe-code/banxe`
(verified read-only); ADR-102, ADR-103, ADR-059-A; I-27.
