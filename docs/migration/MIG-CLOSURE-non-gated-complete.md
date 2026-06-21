# MIG-CLOSURE — Non-Gated Migration Complete (docs-only, no merge)

> **Type:** migration closure record (docs-only). **Status:** non-gated фабричная миграция
> BANXE.RAR → EMI **ЗАВЕРШЕНА и принята на main**.
> **Canon:** factory-only (shell = read-only audit), no `--admin`/`--auto`/bypass, ADR-059-A
> append-only ledger, ADR-102 (Duplication Audit), ADR-103 (server-only), parallel-session
> isolation (Rule 6).
> **Baseline:** banxe-architecture origin/main `4ae0d5b`; max il_ts IL-424 @ 2026-06-22T04:15:00Z;
> 0 открытых MIG PR.

---

## 1. Scope

Финальная фиксация: **вся non-gated фабричная работа** миграции BANXE.RAR → EMI завершена,
смёрджена на `main` и принята. Остаются **только 2 gated-трека** (§5), ожидающие operator
gate-решений; фабрика их **не начинает**. Этот документ — closure-запись (read-only свод; никакого
нового кода, никаких изменений в gated-зонах).

---

## 2. Full delivered map

### M2 core
| Substep | Тема | Home | IL / SHA |
|---|---|---|---|
| M2.1 | payments engine | banxe-payment-core | scaffold (#19→#618) |
| M2.2 | accounts SoT (balance-free) | banxe-emi-stack | scaffold (#201→#616) |
| M2.3 | identity/auth | banxe-emi-stack | reconcile/gap-audit (IL re #632/#633) |
| M2.6 | SEPA rail-consumer | banxe-payment-core | scaffold (#20→#622) |
| M2.7 | platform-core contracts | shared-libs (re-scope) | RESCOPE (#612→#614) |
| M2.8-acceptance | M2-cycle checkpoint | banxe-architecture | (#635) |

### Follow-ups / integration
| Substep | Тема | IL / SHA |
|---|---|---|
| M2.4-INT | open-banking ↔ payment-engine bridge | IL-395 / bridge `b3c936d` (#636) |
| M2.5-BIF | Bifrost Wave-D adapter (retarget→emi-stack) | triple-merge (#206→#640→#642) |

### OB-delta
| Substep | Класс | IL / SHA |
|---|---|---|
| M2.4a/b scheduled | covered | IL-401/402 (#643→#645) |
| M2.4c file/bulk | covered | IL-418/419 (#662→#663) |
| M2.4d intl-scheduled | genuine-gap scaffold | IL-420 (#210→#665) |
| M2.4e CBPII funds-confirmation | partial → thin facade | IL-422 / emi `35033ac` (#212→#666) |

### ABS + identity
| Substep | Класс | IL / SHA |
|---|---|---|
| abs-posting → ledger (LedgerPort) | covered | (#648→#651) |
| abs-info-field | genuine-gap scaffold | emi `72334ce` (#207→#656) |
| login-history | genuine-gap scaffold | emi `4378207` (#208→#657) |
| SRP (security-sensitive) | genuine-gap scaffold | emi `1e39ad1` (#209→#658) |

### Acceptance & reconcile records
| Запись | IL / SHA |
|---|---|
| ABS/identity coverage-audit | (#655) |
| migration coverage-acceptance | IL-415/416 (#660) |
| OB-delta-completion note | IL-423 / `4d08d1d` (#668) |
| frontend roster reconcile/gap-audit (M2.8-PRE) | IL-424 / `4ae0d5b` (#670) |
| **non-gated closure (this record)** | **IL-428** |

---

## 3. Anti-dup финал (ADR-102)

| Категория | Count |
|---|---|
| Mis-scaffolds avoided (preflight) | **7** (5 covered/reconcile + 2 target-mismatch) |
| Identity genuine-gap scaffolds | **3** (abs-info-field, login-history, SRP) |
| OB-delta scaffolds/facades | **2** (M2.4d intl-scheduled, M2.4e CBPII facade) |
| Coverage/declare-covered sweeps | M2.4a/b, M2.4c, abs-posting + сводный coverage-audit |
| Reconcile/gap-аудиты | **2** (M2.4-OB-delta-completion, M2.8-PRE roster) |

ADR-102 preflight предотвратил каждый потенциальный дубль; каждый артефакт — genuine-gap,
thin facade (ссылка не дублирование), или declare-covered.

---

## 4. Backend homes resolved

| Домен | Canonical home |
|---|---|
| accounts SoT, open-banking, ABS, identity/auth, GL-posting, scheduled, batch | **banxe-emi-stack** |
| payments engine, SEPA rail | **banxe-payment-core** |
| platform-core contracts (`@banxe/*`) | **banxe-shared-libs** (consume, M2.7 re-scope) |

---

## 5. Gated-треки (НЕ начаты — ожидают operator)

| Трек | Precondition gate | Состояние |
|---|---|---|
| **(A) M2.8 frontend** | **operator roster-выбор** (см. MIG-M2.8-PRE / IL-424): banxe-ui canonical · banxe-platform canonical · split по ролям — с разведением namespace-коллизии `@banxe/shared`+`@banxe/mobile` + унификацией Next-версии | NOT STARTED |
| **(B) KYC/KYB/AML** | **I-27 HITL-L4 sign-off** (governance) | NOT STARTED; advisory-descriptive only, без кода до sign-off |

Фабрика roster **не выбирает** и KYC scope **не трогает** — оба чисто operator gates.

---

## 6. Governance-learnings (канон, подтверждены)

1. **Preflight-discipline** — ОБЯЗАТЕЛЬНЫЙ read-only ADR-102 preflight перед любым scaffold;
   covered/partial/genuine-gap классификация ДО кода.
2. **Coverage-sweep** — один сводный аудит остатка вместо повторяющихся blocker-циклов.
3. **In-branch remediation (no bypass)** — CI/CodeRabbit findings чинятся в ветке; никогда
   `--admin`/`--auto`/branch-protection-bypass. `guardian-branch-naming` (advisory ADR-060)
   не required — merge штатный.
4. **Factory-only execution** — shell строго read-only audit; все state-changes через фабрику в
   изолированных server-side (evo1) worktrees (ADR-103).
5. **Append-only монотонный il_ts** — ADR-059-A; il_ts строго возрастает; при churn —
   rebase + regenerate + bump; build_ledger `--check` зелёный перед push.
6. **Parallel-session isolation (Rule 6)** — чужие ветки (`adr117-*`, `central/*`,
   `archstack002/sp-*`) и PR (#667) не трогаются/не авто-резолвятся; дубликат закрыт только по
   operator-санкции, ветка сохранена.

---

## 7. Acceptance

- **Non-gated фабричная миграция BANXE.RAR → EMI — CLOSED.** Всё в §2 на `main`; 0 открытых MIG PR;
  build_ledger `--check` exit 0; append-only intact.
- **Разблокировка M2.8 frontend:** operator roster-выбор → отдельный шаг фиксирует canonical
  frontend target (ADR + ledger) → старт M2.8 track.
- **Разблокировка KYC/KYB/AML:** operator I-27 HITL-L4 sign-off → старт track (до этого только
  advisory-descriptive, без кода).
- **До operator gate-решения** новых non-gated/gated substep-ов нет; фабрика roster не выбирает,
  KYC scope не трогает.

---

### Refs
MIG-M2.1/2.2/2.3/2.6/2.7, MIG-M2.8 (acceptance), MIG-M2.4-INT (IL-395), MIG-M2.5-BIF,
MIG-M2.4a/b/c/d/e (IL-401/402/418/419/420/422), MIG-ABS-posting, MIG abs-info-field/login-history/
SRP, MIG coverage-acceptance (IL-415/416), MIG-M2.4-OB-delta-completion (IL-423),
MIG-M2.8-PRE-frontend-roster-audit (IL-424); ADR-102, ADR-103, ADR-059-A; I-27, I-28.
