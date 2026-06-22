# MIG-INDEX — Migration Final-State Register (docs-only, no merge)

> **Type:** navigational index + final-state register всей миграции BANXE.RAR → EMI. **Single entry
> point** для operator gate-решения. Агрегатор (не дубль) — ссылается на существующие MIG-доки/IL.
> **Canon:** factory-only (shell = read-only audit), no `--admin`/`--auto`/bypass, ADR-059-A
> append-only, ADR-102/ADR-103, «не галлюцинировать» (IL-id verified из ledger).
> **Baseline:** banxe-architecture origin/main `97de1e4`; 66 файлов в `docs/migration/`; 0 открытых
> MIG PR. **Non-gated миграция CLOSED.**

---

## 1. Scope

Единый индекс/реестр всех migration-артефактов на main: что сделано, где IL, какой статус, что
осталось (gated). Создаётся как навигатор перед operator gate-решением (roster / KYC). Roster
canonical и KYC scope здесь **не выбираются** (operator gates, §7).

---

## 2. M1.x audit-cycle (deepread / advisory-surface)

> Read-only legacy deepread + advisory-surface manifest (M1-cycle). Boundary-аудиты:

| Doc | Тема | Статус |
|---|---|---|
| `MIG-M1.1-open-banking-dup-audit.md` | open-banking dup-audit | closed |
| `MIG-M1.2-abs-dup-audit.md` | ABS dup-audit | closed |
| `MIG-M1.3-payments-accounts-boundary.md` | payments/accounts boundary | closed |
| `MIG-M1.4-identity-auth-boundary.md` + `MIG-M1.4.1-auth-dup-audit.md` | identity/auth boundary + dup | closed |
| `MIG-M1.5-sepa-split.md` | SEPA split | closed |
| `MIG-M1.6-platform-reference-config.md` | platform reference config | closed |
| `MIG-M1.7-frontend-crypto-earn.md` | frontend + crypto-earn surface | closed |
| `MIG-M1.8-acceptance.md` | M1-cycle acceptance | closed |
| `M1.1–M1.26` advisory-surface deepread specs | crypto/earn/instruments/markets/catalogue manifest | closed |

---

## 3. M2 core + reconciles

| Substep | Doc | Результат | IL |
|---|---|---|---|
| M2.0 | `MIG-M2.0-mapping-v0-update-and-shared-libs-dedup.md` | mapping v0 + shared-libs dedup | — |
| M2.1 payments engine | scaffold → banxe-payment-core | scaffold | **IL-378** |
| M2.2 accounts SoT | scaffold → banxe-emi-stack (balance-free) | scaffold | **IL-374** |
| M2.3 identity/auth | `MIG-M2.3-BLOCKER…` + `…RESCOPE-gap-audit` | blocker→reconcile (covered) | **IL-391** |
| M2.4 open-banking | `MIG-M2.4-BLOCKER…` + `…RESCOPE-gap-audit` | blocker→reconcile (covered) | **IL-384** |
| M2.5 ABS | `MIG-M2.5-BLOCKER…` + `…RESCOPE-gap-audit` | blocker→reconcile (covered) | **IL-387** |
| M2.6 SEPA rail | scaffold → banxe-payment-core | scaffold | **IL-380** |
| M2.7 platform-core | `MIG-M2.7-BLOCKER…` + `…RESCOPE-consume-from-shared-libs` | blocker→re-scope (consume shared-libs) | **IL-372** |
| M2.5-BIF Bifrost | `MIG-M2.5-BIF-BLOCKER-target-mismatch.md` | blocker→retarget→scaffold (emi-stack) | **IL-398** |
| M2.8 acceptance | `MIG-M2.8-acceptance.md` | M2-cycle checkpoint | **IL-393** |

---

## 4. OB-delta (M2.4 family)

| Substep | Класс | IL |
|---|---|---|
| M2.4-INT integration bridge | integration | **IL-395** |
| M2.4a/b scheduled | covered (`MIG-M2.4ab-declare-covered.md`) | IL-401/402 |
| M2.4c file/bulk | covered (`MIG-M2.4c-COVERED-batch-payments.md`) | **IL-418**/419 |
| M2.4d intl-scheduled | genuine-gap scaffold | **IL-420** |
| M2.4e CBPII funds-confirmation | partial → thin facade | **IL-422** |
| OB-delta completion note | aggregate | **IL-423** |

---

## 5. Genuine-gaps (backend) + periphery blockers

### 5a. Backend genuine-gaps — CLOSED in banxe-emi-stack
| Gap | Surface | PR / IL |
|---|---|---|
| #1 abs-info-field | `services/abs/info_field.py` | #207 / **IL-412** |
| #2 login-history | `services/auth/login_history.py` (masked_ip, fail-closed) | #208 / **IL-413** |
| #3 SRP | `services/auth/srp.py` (handshake, placeholder-only) | #209 / **IL-414** |

### 5b. Periphery → banxe-platform — BLOCKER (no scaffold; covered + target-mismatch)
| Трек | Doc | IL |
|---|---|---|
| SRP → platform | `MIG-SRP-blocker-banxe-platform.md` | **IL-434** |
| login-history → platform | `MIG-login-history-blocker-banxe-platform.md` | **IL-435** |

> Оба periphery-scaffold трека (auto-mode-инициированные) завернуты препроверкой preflight (fail-closed):
> backend covered (#208/#209) + banxe-platform = frontend-клиент → scaffold противопоказан.
> Frontend touchpoints = generated client-contracts, материализуются в M2.8 (§7).

---

## 6. Acceptance / closure / precondition records

| Запись | Doc | IL |
|---|---|---|
| ABS-posting | `MIG-ABS-posting-BLOCKER…` + `…COVERED-gl-service.md` | **IL-405** |
| ABS/identity coverage-audit | `MIG-ABS-identity-coverage-audit.md` | **IL-411** |
| migration coverage-acceptance | `MIG-coverage-acceptance.md` | IL-415 / **IL-416** |
| non-gated CLOSURE | `MIG-CLOSURE-non-gated-complete.md` | **IL-428** |
| M2.8-PRE roster-audit | `MIG-M2.8-PRE-frontend-roster-audit.md` | **IL-424** |
| M2.8-PRE collision-matrix | `MIG-M2.8-PRE-collision-matrix.md` | **IL-429** |
| M2.8-PRE shell-inventory | `MIG-M2.8-PRE-shell-inventory.md` | **IL-431** |
| M2.8-PRE verify-resolution | `MIG-M2.8-PRE-verify-resolution.md` | **IL-432** |
| **MIG-INDEX (this register)** | `MIG-INDEX-final-state-register.md` | **IL-436** |

---

## 7. Open gated tracks (НЕ начаты — operator gates)

| Трек | Precondition gate | Что разблокирует |
|---|---|---|
| **(A) M2.8 frontend** | **operator roster-выбор**: banxe-ui canonical / banxe-platform canonical / split (см. M2.8-PRE quartet IL-424/429/431/432) | фиксация canonical target (ADR+ledger) + collision-resolution (`@banxe/shared`+`@banxe/mobile`, Next-унификация) + shell-migration (M1.7 shells; frontend SRP/login-history как generated client-contracts) → старт M2.8 |
| **(B) KYC/KYB/AML** | **I-27 HITL-L4 sign-off** | старт track; до sign-off — только advisory-descriptive, без кода |

**Остаточный follow-up (не блокирует roster-выбор):** refresh `/srv` legacy-clone для перевода
`banxe-tompayment` из [operator-attested] в [verified-evo1] (M2.8-PRE verify-resolution IL-432).

> Фабрика roster **не выбирает** и KYC scope **не трогает**. Без operator gate-решения новых
> substep-ов нет; scaffold без подтверждённого genuine gap не делается (fail-closed).

---

### Refs
Все MIG-доки в `docs/migration/` (66 файлов); banxe-emi-stack #207/#208/#209; banxe-payment-core
(M2.1/M2.6); banxe-shared-libs (M2.7); ADR-102, ADR-103, ADR-059-A; I-27, I-28.
