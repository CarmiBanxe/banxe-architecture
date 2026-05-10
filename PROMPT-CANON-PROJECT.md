# PROMPT-CANON-PROJECT

Канон промптов на уровне проекта BANXE EMI AI Bank.
Покрывает governance, архитектуру, регуляторику, ledger.

## 1. Два контура
- Контур фабрики (banxe-architecture): governance, конституция, циклы, амендменты, Spec-First Auditor, ledger, паспорта агентов.
- Контур продукта (banxe-emi-stack): EMI-банк, FCA-compliance, AML/KYC, payments, crypto, open banking, SCA, recon, reporting, audit.
- Оба контура должны быть синхронизированы через mirror-записи в обоих INSTRUCTION-LEDGER.md.

## 2. INSTRUCTION-LEDGER.md под IL-LEDGER-NORM-001
Обязательные поля каждого IL-блока:
- parent-cycle
- amendment-ref (или explicit "n/a")
- source
- status (proposed / accepted / integrated / superseded / rejected / deferred)
- status-history (хронологический, append-only)
- scope
- integration-rule
- anchors (CANON / GATE / INVARIANTS / REGULATORY / HITL ROLES)
- verification (triple-check + sha256-anchors реальных файлов)
- deviations (если есть)
- privileged-ops (git tag / gh release / git push: EXECUTED|NOT EXECUTED)
- successor
- notes

Порядок блоков — хронологический по дате `proposed`.
Status-history — append-only, без модификации старых записей.
Блок status: integrated не редактировать, кроме добавления `superseded-by`.

## 3. Spec-First Auditor v2 (12 блоков)
Pre-commit гейт всех коммитов в обоих репо.
Блокирует нарушения конституции / канона / quality gate.

## 4. Инварианты (I-XX)
- I-01: Decimal для всех amount / score / threshold / rate.
- I-02: BLOCKED_JURISDICTIONS / BLOCKED_CURRENCIES.
- I-04: EDD £10k threshold (CBPII / PISP).
- I-24: append-only stores и audit logs.
- I-27: HITL L4 для всех privileged операций.
- I-28: quality gate (ruff 0 issues, tests 100%, coverage >= 35%).

## 5. Регуляторные привязки
- FCA: PSD2 Art.65-67, RTS on SCA, PSR 2017, PS22/9 Consumer Duty,
  CASS 7.15, CASS 15, FCA SUP 16, FCA DISP, FCA SYSC 6.1, FCA PRIN 11/12,
  FG21/1 vulnerability, PROD, COBS 2.1, PERG 15.5.
- EU: PSD2, EBA RTS on SCA.
- US: FATCA (IRC §1471-1474).
- OECD: CRS MCAA.

## 6. HITL роли
- COMPLIANCE_OFFICER: consent revoke, TPP suspend, US person change.
- MLRO: CRS override, SAR filing.
- CFO: FIN060 generate / approve, board reports.
- COMPLAINTS_OFFICER: redress > £500.
- FRAUD_ANALYST: suspicious device confirm.
- SECURITY_OFFICER: ATO lock / unlock.
- CTIO: AI feedback approval.

## 7. Артефакты на цикл
- manifest.md (cycle-NNN-<name>/manifest.md)
- outcomes.md
- amendments в constitution/amendments/
- sha256-anchors всех новых артефактов в ledger

## 8. Out-of-scope discipline
- Любой untracked scope регистрируется как parking IL до коммита.
- Parking IL переходит в DONE через resolve-step с реальным proof SHA.
- Не оставлять untracked >1 сессии.

## 9. Mixed-scope deviation
- Если несколько IL приземлились в один commit (как Sprint-39 Phase 54
  IL-CMS-01 + IL-MCP-01 + IL-TRC-01), это нарушение канона "один scope =
  один commit".
- Не переписывать историю, но явно фиксировать в `deviations:` ledger-блока.
- Anchor всех IL — на тот же proof SHA.

## 10. Linkage между ledger и git
- Каждый IL-блок status: integrated должен ссылаться на реальный git SHA.
- Anchor verification: SHA должен присутствовать в `git log -- <scoped files>`.
- Иначе — anchor correction commit (см. IL-LINT-03 case 7708d4c → ba3fccc).

## 11. Контур-синхронность
- Любой IL в emi-stack ledger дублируется как mirror в architecture ledger.
- Mirror содержит: linked-commit (full SHA), supersedes (если есть),
  sha256-anchors emi-stack working tree.

## 12. Сессионная дисциплина
- Каждая сессия начинается с `git status / git log -10` обоих репо.
- Каждая сессия заканчивается handoff-файлом в `/tmp/`.
- Открытые задачи фиксируются как IL TODO/OPEN в ledger.

## 13. Язык общения и стиль (BINDING)

> Operator directive 2026-05-10 11:00 CEST: "добавим в канон обязательное общение на русском языке понятным простым языком".
> Anchor: bootstrap canon v3 §7 ENHANCED v3 (operator-supplied 2026-05-09) уже декларирует bilingual принцип; это §13 формализует как permanent binding для всех Perplexity / Comet / Factory / Claude Code сессий с этим оператором.

### 13.1 Язык общения с оператором
- Все ответы оператору и пояснения — на **русском языке**.
- Используется простой понятный язык — избегается тяжёлый технический жаргон без необходимости.
- Если технический термин необходим — даётся короткое пояснение в скобках при первом упоминании.
- Длинные технические дампы не пересказываются дословно — выделяется суть и значение для проекта.

### 13.2 Технические артефакты — английский
- Commit messages, IL records (имя + scope + status + anchors fields), GAP IDs (G-*), invariant IDs (I-*), file names, git commands, code blocks, log output — на **английском языке** для технической точности и совместимости с tooling (Spec-First Auditor, Guardian, gitleaks, CI).
- Markdown секции в каноне могут быть на английском или русском по контексту артефакта; смешанные русско-английские блоки допустимы там где это естественно (как в bootstrap canon v3 §0 + ADR русские разделы).

### 13.3 Bilingual подход (обоснование)
- **Русский** — обсуждение, обоснование решений, пояснения оператору, отчёты о статусе, summary длинных операций, ответы на вопросы.
- **Английский** — технический контент в коде, commit messages, IL field values, command output, regulatory references (FCA SUP, MLR 2017, GDPR Art.NN — стандартные сокращения), API names.
- Переключение между языками внутри одного ответа допустимо когда оно повышает clarity (например русское объяснение что делает английская git-команда).

### 13.4 Стиль изложения для оператора
- Без лести и пустых фраз ("отличный вопрос", "это интересно") — сразу к сути.
- Без emoji кроме случаев когда оператор их использует первым.
- Цитаты из канона / ADR / IL приводить точно (с правильным ID), не пересказывать.
- При неуверенности — явно говорить "не уверен" / "нужна проверка", не маскировать.
- Длинный ответ структурировать заголовками для удобного чтения.

### 13.5 Применимость binding
- Binding активен для всех сессий с CEO Moriel Carmi / operator Mark на проекте BANXE EMI AI Bank.
- В ответах в Slack / Telegram / GitHub PR descriptions / chat — приоритет русского для discussion-уровня, английского для technical-уровня (PR titles, commit messages, IL anchors).
- При работе с другими операторами / контрибьюторами язык определяется по их первичному сообщению (если они пишут по-английски — отвечать по-английски).

### 13.6 Cross-references
- bootstrap canon v3 §7 ENHANCED v3 (originating directive)
- ADR-025 Agent Interaction Canon (Session Rules 1..7)
- amendment-30.N Perplexity Relay Protocol (transparency principle)
- IL-LEDGER-NORM-001 (английский для IL field structure preserved)
