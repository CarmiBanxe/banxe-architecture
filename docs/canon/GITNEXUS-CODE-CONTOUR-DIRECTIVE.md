# GITNEXUS-CODE-CONTOUR-DIRECTIVE — постоянный код-контур (operator directive)

> **STATUS: DIRECTIVE ACTIVE (поведенческая норма фабрики) / IMPLEMENTATION PENDING (PROD-gate-спринт).**
> ⚠ SANDBOX / TRAINING context (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false).
> Basis: ТРЕБОВАНИЕ ОПЕРАТОРА (mmber), post-#1152 (IL-1101 chain). Scope: **CODE-CONTOUR only.**
> Enforcement: fail-closed over backlog features. STEP14, ENGREF01, 2026-07-27.

## Что действует всегда (директива, дословно по операторскому приказу)

- **GitNexus — обязательный код-контур для всех репозиториев fleet** (banking-engine,
  safeguarding-engine, webhook/orchestrators, apar_agent, channel_c_sepa_orchestrator, …).
- Claude Code MUST использовать GitNexus MCP при любой правке кода:
  - **PreToolUse hook → enrich** (граф-контекст перед каждым поиском/правкой);
  - **PostToolUse hook → reindex** (авто-переиндексация после коммита).
- **CI gate: `detect_impact`** (pre-commit) — blast-radius + risk level ДО коммита.
  Высокий risk без явного подтверждения оператора = **FAIL-CLOSED** (блок merge).

## Каждый промт фабрики

Каждый промт фабрики ОБЯЗАН напоминать про GitNexus (**enrich → impact → act**).
Игнор графа при правке связанного кода = нарушение канона.

## Границы

- Приказ покрывает **ТОЛЬКО код-связи** (calls / imports / inheritance / flows).
- **ОРГ-связи** (agents→depts→departments; org-chart-v2) — НЕ здесь: орг-контур — отдельным решением,
  ждёт вердикта Fable5 (FABLE5-REQ — см. OPEN POINTS: секция в приказе не доставлена).

## PROD-gate (внедрение)

- Внедрение hooks/CI-gate проходит **через PROD-gate со спринтом** (не hotfix, не «вслепую»).
- **Pre-condition:** верифицировано покрытие языков стека (VERIFY — см. OPEN POINTS: секция не доставлена).

## Состояние применимости (зафиксировано при регистрации, 2026-07-27)

| Условие | Статус |
|---|---|
| GitNexus MCP подключён к сессиям фабрики | ❌ НЕТ (ToolSearch: 0 инструментов) — **блокирующий pre-condition**: до подключения MCP директива исполняется в части «напоминание в каждом промте» и «fail-closed на высокорисковые правки связанного кода без графа», hooks/enrich/reindex технически недоступны |
| PreToolUse/PostToolUse hooks в settings | не настроены — часть PROD-gate-спринта внедрения |
| CI `detect_impact` gate | не существует — часть PROD-gate-спринта |
| Языковое покрытие стека (VERIFY) | не верифицировано — секция приказа не доставлена |

## OPEN POINTS

1. **Обрыв приказа:** секции **FABLE5-REQ** (орг-контур) и **VERIFY** (языковое покрытие), на которые
   ссылается текст, не получены — дослать; директива зарегистрирована по доставленной части.
2. GitNexus MCP отсутствует в сессии — подключение (оператор/инфра) = первый шаг PROD-gate-спринта.
3. Внедренческий спринт (hooks + detect_impact CI) — кандидат в roadmap как S-GITNEXUS
   (регистрация в BANK-ORGANIZATION-ROADMAP — при следующем правочном окне roadmap, чтобы не плодить
   правки; директива действует независимо от регистрации спринта).

---
*STEP14 | ENGREF01 | DIRECTIVE ACTIVE / IMPLEMENTATION PENDING | код-контур only | sandbox-labeled.*
