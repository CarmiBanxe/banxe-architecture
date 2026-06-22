# MIG-M2.8-PRE — tompayment Provenance-Resolution (correction-addendum, docs-only, no merge)

> **Type:** provenance-resolution addendum к MIG-M2.8-PRE-verify-resolution (IL-432, §2). **Closes**
> остаточный tompayment provenance follow-up. **Status:** roster НЕ выбран — operator gate.
> **Canon:** ADR-102, ADR-103 (legacy read-only), factory-only (shell = read-only audit), no
> `--admin`/`--auto`/bypass, ADR-059-A append-only, «не галлюцинировать» (provenance + correction).
> **Baseline:** banxe-architecture origin/main `ffc0646`; max il_ts IL-436+.

---

## 1. Scope

Закрытие остаточного tompayment provenance follow-up (открытого в verify-resolution IL-432 §2 и в
shell-inventory IL-431 §5a) точной re-audit фактурой. Roster canonical здесь **не выбирается**
(operator gate). Фабрика clone между хостами **не реплицирует** (operator/infra) — но, как показал
re-audit, репликация и не требуется (см. §3 correction).

---

## 2. Re-audit result (read-only, both hosts) — CORRECTED

| Host / path | tompayment-web | Содержимое |
|---|---|---|
| Legion `/tmp/bx-legacy/banxe-code/banxe/tompayment-web` | **POPULATED** | 1462 files / 1286 src, pkg `banxe-tompayment`, React+webpack |
| **evo1 `/srv/banxe-legacy/work/banxe-code/banxe/tompayment-web`** | **POPULATED** | **1462 files / 1286 src, pkg `banxe-tompayment`, React** |

> **tompayment-web присутствует на ОБОИХ хостах, включая canonical evo1 `/srv`.** Прежнее «absent
> on /srv / 0 файлов» — **ошибочно** (см. §3).

---

## 3. Root cause — directory-name lookup error (НЕ clone-divergence)

- Реальная директория shell = **`tompayment-web`** (суффикс `-web`).
- Прежние аудиты (shell-inventory IL-431 §5a; verify-resolution IL-432 §2) и follow-up-премиса
  искали путь **`banxe-tompayment`** — это **package-имя** (`"name": "banxe-tompayment"` внутри
  `tompayment-web/package.json`), а **не** имя директории. Lookup по `banxe-tompayment` → пусто →
  ложный вывод «0 файлов / absent».
- На canonical evo1 `/srv` есть ровно один `*tompayment*` dir — `tompayment-web` — и он
  **populated** (1462 files).
- **Это НЕ clone-source divergence между хостами и НЕ submodule-проблема** — это ошибка имени пути
  в предыдущих аудитах. `/srv`-clone полный относительно tompayment.

---

## 4. Status — tompayment = LIVE, verified-evo1

- `tompayment-web` (pkg `banxe-tompayment`, React/webpack, 1286 src) = **LIVE product web shell**,
  **[verified-evo1]** (присутствует на canonical `/srv`-clone).
- Прежний provenance-флаг **[operator-attested]** (verify-resolution IL-432 §2) → **повышен до
  [verified-evo1]**. Корректирует false-negative в IL-431/IL-432.

---

## 5. Required action — NONE (correction supersedes follow-up)

- **Clone-refresh `/srv` НЕ требуется** — tompayment-web уже присутствует на canonical evo1 `/srv`.
- Остаточный follow-up из IL-432 §2 («refresh `/srv`-clone для verified-evo1») — **снят**:
  предпосылка (absent on /srv) была ошибочной.
- Фабрика по-прежнему **не реплицирует** clone между хостами (operator/infra) — здесь это и не
  нужно.

---

## 6. M2.8 impact

- tompayment-web полностью верифицирован на canonical-хосте → **нет блокера** на его
  shell-migration в M2.8 (canonical clone доступен).
- Corrected live-web-shell roster (verify-resolution IL-432 §4) подтверждён: tompayment-web
  остаётся в roster как product-web, теперь со статусом [verified-evo1].

---

## 7. Open item

- **tompayment provenance follow-up = CLOSED** (verified-evo1; correction directory-name lookup).
- **M2.8-precondition фактура — fully complete, без остаточных provenance-флагов:** roster-audit
  (IL-424) + collision-matrix (IL-429) + shell-inventory (IL-431) + verify-resolution (IL-432) +
  tompayment-provenance (этот документ).
- M2.8 frontend остаётся **gated** на operator roster-выбор (banxe-ui / banxe-platform / split).
- KYC/KYB/AML — независимый gate, только после I-27 HITL-L4 sign-off.

---

### Refs
MIG-M2.8-PRE-verify-resolution.md (IL-432 §2 — corrected); MIG-M2.8-PRE-shell-inventory.md (IL-431
§5a — corrected false-negative); MIG-M2.8-PRE-collision-matrix.md (IL-429); MIG-M2.8-PRE-frontend-
roster-audit.md (IL-424); MIG-INDEX-final-state-register.md (IL-436); legacy `tompayment-web`
(pkg `banxe-tompayment`) on `/srv` (verified-evo1) + `/tmp` (Legion); ADR-102, ADR-103, ADR-059-A;
I-27.
