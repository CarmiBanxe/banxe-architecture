# MIG-M2.4 — OB-delta Completion Note (docs-only, no merge)

> **Type:** migration completion note (docs-only). **Status:** OB-delta backlog ИСЧЕРПАН.
> **Scope:** BANXE.RAR → EMI open-banking (M2.4) delta. Read-only свод по уже смёрдженным
> substep-ам M2.4-INT + M2.4a/b/c/d/e. Никакого нового кода; KYC/M2.8 не затрагиваются.
> **Canon:** ADR-102 (Duplication Audit), ADR-103 (server-only), ADR-059-A (sharded append-only
> ledger), factory-only execution (shell = read-only audit), no `--admin`/`--auto`, no bypass.
> **Baseline:** origin/main HEAD `74ec485`; max il_ts `IL-422 @ 2026-06-22T03:15:00Z`.

---

## 1. OB-delta summary (M2.4-INT + M2.4a/b/c/d/e)

| Substep | Тема | Результат | IL-id | Merge-SHA / PR |
|---|---|---|---|---|
| **M2.4-INT** | open-banking ↔ payment-engine integration bridge | **integration** (bridge wiring) | IL-395 | code `b3c936d`; arch #636 |
| **M2.4a/b** | domestic-scheduled / standing-order payments delta | **covered** (existing standing_order_engine / schedule_executor; IL-SOD-01) | IL-401 / IL-402 | declare-covered batch #643 → #645 |
| **M2.4c** | file/bulk payments delta | **covered** (existing batch_payments router + file_parser/batch_creator) | IL-418 / IL-419 | declare-covered batch #662 → #663 |
| **M2.4d** | international-scheduled payments delta | **genuine-gap scaffold** (intl_scheduled.py, cross-border state-machine) | IL-420 | code #210; arch #665 |
| **M2.4e** | intl funds-confirmation + CBPII consent lifecycle | **partial → thin facade** (cbpii_consent.py; check delegated, не re-impl) | IL-422 | code `35033ac` (emi-stack #212); arch `74ec485` (#666) |

Все substep-ы на `main`. Открытых MIG PR нет.

---

## 2. Classification breakdown

| Класс | Count | Substeps |
|---|---|---|
| integration (bridge) | 1 | M2.4-INT |
| covered (declare-covered, существующая поверхность) | 2 | M2.4a/b, M2.4c |
| genuine-gap scaffold | 1 | M2.4d |
| partial → thin facade | 1 | M2.4e |
| **Итого OB-delta substeps** | **5** (+ INT) | — |

**Дисциплина:** каждый covered-вывод подтверждён ОБЯЗАТЕЛЬНЫМ read-only preflight (ADR-102) —
существующая поверхность найдена и перечислены consumers ДО любого решения; ни одного
дубль-scaffold не создано там, где поверхность уже есть.

---

## 3. Non-gated backend backlog — ИСЧЕРПАН

Non-gated backend-работа миграции BANXE.RAR → EMI **полностью закрыта**:

- **OB-delta** (M2.4-INT + M2.4a/b/c/d/e) — закрыт (см. §1).
- **ABS-delta** (abs-posting → ledger via LedgerPort) — covered (IL ABS-posting COVERED).
- **identity genuine-gaps** (abs-info-field #1, login-history #2, SRP #3) — scaffolded + merged.
- Сводный **coverage-acceptance** зафиксирован: **IL-415 / IL-416** (migration coverage-acceptance).

→ За пределами gated-направлений (§4) новых backend-substep-ов в OB-delta/ABS/identity **нет**.

---

## 4. Оставшиеся 2 gated трека

| Трек | Precondition gate | Состояние | Что разрешено сейчас |
|---|---|---|---|
| **KYC/KYB/AML** | **I-27 HITL-L4 sign-off** (governance-решение оператора) | NOT STARTED (gated) | только advisory-descriptive материалы; **никакого кода без sign-off** |
| **M2.8 frontend** | **frontend roster audit** (banxe-platform vs banxe-ui) | NOT STARTED (gated) | audit-материалы; код после roster-решения |

Ни один из треков **не начинается** без явного operator gate-решения. KYC/KYB/AML дополнительно
защищён инвариантом I-27 (HITL-L4) и каноном «Skip AML/KYC validation — FORBIDDEN».

---

## 5. Anti-dup итог (ADR-102 финальная статистика)

| Категория | Count | Примечание |
|---|---|---|
| Mis-scaffolds avoided | **7** | 5 covered/reconcile + 2 target-mismatch (preflight остановил дубль/неверный таргет) |
| Precise genuine-gap scaffolds | **3** | abs-info-field, login-history, SRP (identity) |
| OB-delta scaffolds/facades | **2** | M2.4d intl-scheduled (genuine-gap) + M2.4e CBPII (thin facade) |
| Coverage-audit sweep | **1** | одним проходом классифицирован остаток вместо per-substep blocker-циклов |

ADR-102 preflight предотвратил каждый потенциальный дубль; каждый созданный артефакт — либо
genuine-gap, либо thin facade, ссылающийся (не дублирующий) на существующую поверхность.

---

## 6. Governance-learnings (подтверждены)

1. **Preflight-discipline** — ОБЯЗАТЕЛЬНЫЙ read-only ADR-102 preflight перед любым scaffold;
   covered/partial/genuine-gap классификация ДО кода.
2. **Coverage-audit-sweep** — один сводный аудит остатка вместо повторяющихся blocker-циклов.
3. **In-branch remediation (no bypass)** — CI/CodeRabbit findings чинятся в ветке; никогда
   `--admin`/`--auto`/branch-protection-bypass.
4. **Factory-only execution** — shell строго read-only audit; все state-changes через фабрику в
   изолированных server-side (evo1) worktrees (ADR-103).
5. **Append-only монотонный il_ts** — ADR-059-A; il_ts строго возрастает; при churn —
   rebase + regenerate + bump; build_ledger `--check` зелёный перед push.

---

## 7. Acceptance + что разблокирует каждый gate

- **Acceptance:** OB-delta (M2.4) + ABS-delta + identity genuine-gaps закрыты на `main`; non-gated
  backend backlog миграции исчерпан; coverage-acceptance IL-415/416 в силе.
- **Разблокировка KYC/KYB/AML:** operator **I-27 HITL-L4 sign-off** → стартует KYC/KYB/AML track
  (до этого — только advisory-descriptive, без кода).
- **Разблокировка M2.8 frontend:** **frontend roster audit** (banxe-platform vs banxe-ui) →
  стартует M2.8 frontend track.
- **Чистая точка:** на этом завершается non-gated фабричная работа; далее — только два gated
  operator gate-решения выше.

---

### Refs
MIG-M2.4 (OB gap-audit), MIG-M2.4-INT (IL-395), MIG-M2.4a/b (IL-401/402), MIG-M2.4c (IL-418/419,
#662/#663), MIG-M2.4d (IL-420, #210/#665), MIG-M2.4e (IL-422, #212→`35033ac` / #666→`74ec485`);
migration coverage-acceptance (IL-415/416); ADR-102, ADR-103, ADR-059-A; I-01, I-05, I-27, I-28.
