# GITNEXUS PHASE 3 — CROSSLINK INTEGRATION NOTE (B3 → Phase 1 detect_impact)

> **LICENSING / DISCLAIMER:** GitNexus = **PolyForm-Noncommercial-1.0.0**. Sandbox/TRAINING — без лицензии;
> **«PROD/commercial use requires a purchased GitNexus license.»** **DESIGNED-FOR-PROD.**
> ⚠ SANDBOX / TRAINING (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false). files-only, NO живой KuzuDB.

## Принцип совместимости

Контракт Phase 1 (`scripts/gitnexus/detect_impact.py`): **`risk` / `blast_radius[]` / `files` — НЕ меняется.**
B3 только **добавляет** поля: `impacted_departments` (ребро **B2 OWNS_PATH**: staged-пути → владеющие
департаменты по `config/gitnexus/org-path-ownership.map.yaml`) и `accountable_agents` (ребро **B1 OWNED_BY**:
код-узлы → агент/роль через passport-reference `agents/passports/**`). Потребители Phase 1 продолжают
работать без изменений; новые поля читают только org-aware потребители (комплаенс-отчёты, Decision Lineage).

## Расширенный вывод — ILLUSTRATIVE SCHEMA (это ФОРМА, не реальные данные графа — NO-MOCK)

```jsonc
// illustrative schema — field shapes only; no live graph was queried to produce this
{
  "risk": "HIGH",                                   // Phase 1 contract — unchanged
  "blast_radius": ["<code-node-ref>", "..."],       // Phase 1 contract — unchanged
  "files": ["bank-rooms/F2-payments-room/runtime/<file>.py"],   // unchanged
  "impacted_departments": [                         // NEW (B2), additive
    {"department": "Payment Operations", "via_glob": "bank-rooms/F2-payments-room/**"}
  ],
  "accountable_agents": [                           // NEW (B1), additive
    {"agent_id": "<from passport>", "passport": "agents/passports/<...>.yaml",
     "department": "<passport.department>", "owner": "<passport.governance.owner>"}
  ]
}
```

## Порядок обогащения (когда MCP/граф живые — Phase 2+)

1. Phase 1 как сейчас: staged → real `gitnexus detect-impact` → `risk`/`blast_radius`/`files`
   (0 tools ⇒ UNKNOWN/78 — fail-closed, без изменений).
2. **B2:** `files` ∩ globs из `org-path-ownership.map.yaml` → `impacted_departments`
   (пути из `todo_operator` НЕ резолвятся — честный пропуск до операторского сведения).
3. **B1:** узлы `blast_radius` → passport-reference → `accountable_agents`
   (узел без паспорта ⇒ поле «unowned» — сигнал в S2-перепись штата, не выдумка владельца).
4. Fail-closed сохраняется: HIGH risk без `GITNEXUS_ACK=1` = блок; org-поля риск НЕ понижают никогда
   (могут только эскалировать: задет Safeguarding/AML-департамент ⇒ кандидат на подъём до HIGH — правило
   настраивается оператором, по умолчанию выключено).

## Границы

Орг-граф отдельен (вердикт B/B3, `GITNEXUS-PHASE3-ORG-CONTOUR-VERDICT.md`); код-граф в KuzuDB — external ref;
никакой живой инстанциации в этой фазе; неоднозначности — TODO-operator в map.yaml.

---
*PHASE 3 выдача | ENGREF01 | additive-only контракт | files-only, not committed | 2026-07-27.*

## Builder (implemented)

`scripts/gitnexus/build_org_contour.py` (2026-08-01, sandbox/PolyForm-NC, stdlib-only, read-only) —
producer B3-оверлея по этому контракту. Вход: staged-файлы (`--staged`) или argv-пути. Выход
(additive-only): `{impacted_departments, accountable_agents, unresolved_departments, unowned_paths}` —
Phase-1 поля risk/blast_radius/files НЕ эмитятся и не меняются (остаются в detect_impact.py; этот PR
detect_impact.py не трогает — скрипт импортируем, интеграция отдельным шагом).
Резолюция NO-MOCK: B2 — map.yaml (18 room-глобов; F0 core_exempt помечается, не «владеется»;
todo_operator-строки уходят в unresolved_departments честным пропуском); B1 — room-ростеры
`bank-rooms/*/agents-roster.md` (registry-generated, 129 агентов; колонка source_path даёт точечный
матч код-путь→агент) с обогащением из паспортов `agents/passports/` + `config/agents/passports/`;
не-сматченные пути → unowned_paths (сигнал, не выдумка). Самопроверка: `--self-test`.
