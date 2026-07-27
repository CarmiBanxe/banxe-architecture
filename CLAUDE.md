# ═══════════════════════════════════════════════════════════════════════════════
# BANXE AI BANK — CLAUDE.md (auto-context for Claude Code)
# Version: 2026-04-15 (refactored to .claude/rules/)
# ═══════════════════════════════════════════════════════════════════════════════

## 0. ПРЕАМБУЛА — ЧИТАЙ ПЕРВЫМ

GAP-REGISTER.md: 22/22 gaps DONE (G-09 DEFERRED), 663 теста, v7.
INVARIANTS I-21..I-28 — нарушение = БЛОКИРОВКА.
INSTRUCTION-LEDGER.md: единственный источник истины по задачам.

## 1. GOVERNANCE КАНОНЫ (НАРУШЕНИЕ = STOP)

1. Вопрос CEO → Ответ с объяснением → Акцепт CEO → Действие
2. Формат ответа: ВСЕГДА как промпт для Claude Code + коллаборанты
3. Максимальная утилизация: Task(), Bash(), Agent subspawn
4. НЕ галлюцинировать — только верифицированная информация
5. IL lifecycle: INSTRUCTION → ACCEPTED → IN_PROGRESS → VERIFY → DONE/FAILED
6. НЕТ действий без записи в IL. НЕТ "DONE" без proof.
7. CLASS_B/C (SOUL.md, rego, compliance_config) → governance gate
8. Zone RED: AI-FORBIDDEN. Zone AMBER: CLAUDE_CODE_ONLY + hooks. Zone GREEN: free.
9. Governance-решения для агентов (Autonomy Level, Trust Zone, promotion dev/staging/production, adoption внешних компонентов) принимаются rules-based логикой с обязательным human-in-the-loop согласно Developer Block v5.1 Section 30.N+1.8 и Project EMI v5.2 Section B.11.N+1.9; LLM-ассистент готовит только материалы.
10. Любые пороговые значения, лимиты, retention, escalation thresholds и иные governance-параметры хранятся в конфигурационных файлах репозитория, а не в коде и не в CLAUDE.md (Configuration-over-Hardcoding 30.N+1.9).
11. Автоматические действия, которые могут изменить клиентские средства или production-состояние, запрещены без явного human approval, зафиксированного в INSTRUCTION-LEDGER/ADR и прошедшего Promotion Gate из B.11.N+1.9.

12. Best-decision канон: вне whitelist auto-run (approval-rules.md) и вне stop-барьеров (safety-rules.md, §11) Claude Code принимает лучшее решение самостоятельно и продолжает без встречного вопроса; встречный вопрос — только при риске потери данных, необратимости или нарушения инвариантов.


## 3. ТЕКУЩЕЕ СОСТОЯНИЕ — P0 CASS 15 COMPLETE ✅ (2026-04-06)

### IL-001..IL-011 — ALL DONE ✅
| IL | Задача | Commit |
|----|--------|--------|
| IL-001 | Midaz healthcheck fix | — |
| IL-002 | Safeguarding accounts (ADR-013) | — |
| IL-003 | LedgerPort ABC + MidazAdapter | — |
| IL-004 | Instruction Ledger System (I-28) | — |
| IL-005 | Sprint 8 итог | 4c79777 |
| IL-006 | Transaction API T-01..T-15 | 8ae7dd0 |
| IL-007 | ReconciliationEngine + T-16..T-30 | 3f7060f |
| IL-008 | COMPLIANCE-MATRIX 200+ req, Ruflo 10/10 | a8f4b99 |
| IL-009 | banxe-emi-stack P0 skeleton 24 файла | ab81ecc |
| IL-010 | Frankfurter :8181 + pgAudit 17.1 deployed | 3400839 |
| IL-011 | mock-ASPSP :8888 + E2E CAMT.053 pipeline | cb782aa |

### P1 — следующий фронт (после 7 May 2026)
- Payment Rails (ClearBank/Modulr) — S4, 0% → CRITICAL
- Real IBAN validation для FA-07 Phase 1
- dbt production run против реального ClickHouse
- FIN060 PDF → RegData upload

## 5. АРХИТЕКТУРА CBS

ADR-013: Midaz PRIMARY, Fineract FALLBACK. Composable, НЕ монолит.
LedgerPort (Hexagonal): методы определены (G-16 pattern).
I-28: все CBS операции через LedgerPort, прямые HTTP ЗАПРЕЩЕНЫ.

---

## SESSION CONTINUITY PROTOCOL (инвариант — нарушение = P1 дефект)

После завершения ЛЮБОЙ задачи: проверить незавершённый план:
```bash
grep -c "pending\|⏳\|IN_PROGRESS" /home/mmber/banxe-architecture/INSTRUCTION-LEDGER.md
```
Напомнить CEO о незавершённых задачах. При старте новой сессии — первое сообщение:
```
🔄 Восстановление контекста... Последний IL: IL-0XX | Тесты: NNN/NNN
📋 Незавершённый план: N задач (P0 дедлайн: 7 мая — safeguarding)
Продолжить с Задачи N или есть другие приоритеты?
```

### Текущий активный план:
| # | Задача | Приоритет | Статус |
|---|--------|-----------|--------|
| 1 | Safeguarding deploy GMKtec (systemd timer, n8n shortfall alert) | P0 CASS 7 May | ⏳ IL-043 |
| 2 | FastAPI REST API Layer (9 routers, JWT, dependency injection) | P1 | ⏳ |
| 3 | Notification Service S17-03 | P1 | ⏳ |
| 4 | Redis VelocityTracker (sorted sets, 24h/30d windows) | P1 | ⏳ |
| 5 | Fraud + AML Pipeline Wiring S9-05 | P1 | ⏳ |
| 6 | Consumer Duty S9-06 FCA PS22/9 | P1 | ⏳ |

---

## Полные правила: см. `.claude/rules/*.md`

- `compliance.md` — Invariants I-01..I-28, Hard Constraints, 6 контуров
- `infrastructure.md` — GMKtec ports, SERVICE-MAP, open-source stack
- `agents.md` — Skills Governance, Orchestration, FinDev Agent
- `cass15.md` — P0 Stack Map, FA-01..FA-07, safeguarding accounts
- `testing.md` — верификация, key commits, blocked tasks protocol
- `approval-rules.md` — авто-одобрение команд
- `gsd-methodology.md` — GSD 7 фаз, IL формат
- `safety-rules.md` — запрещённые действия

## Quality Hook (BUG-006)
Activate LucidShark/Semgrep pre-commit: `git config core.hooksPath .githooks`

## Setup — local git hooks (ADR-060, run once per checkout/terminal)
On every fresh checkout / new terminal bootstrap, run: `bash scripts/install-hooks.sh`
(idempotent — sets `core.hooksPath .githooks` + installs the pre-push branch-name gate that mirrors
`guardian-branch-naming`; catches a non-compliant branch `<id>` BEFORE push/PR — see ADR-060 amendment 2026-06-21).

## Session bootstrap — AUTO-activate hooks (FIRST step of EVERY session, self-healing)
> Supersedes the "run once" framing above: run as the **first step of EVERY terminal session**, not just once.
**Step 0 of any session / agent bootstrap:** `bash scripts/install-hooks.sh`
Idempotent + self-healing — it re-asserts `core.hooksPath=.githooks` + the executable pre-push gate and
self-checks (fails loudly if it could not activate). Cheap to run every session; closes the "manual
onboarding" gap so the ADR-060 branch-name gate is never silently inactive.

# Агенты: читать INSTRUCTION-LEDGER.md → ACCEPTED → работать → VERIFY → DONE

---
# Best-decision rule: no clarifying questions

В этом проекте (architecture-bank-operating-model-20260718) агент действует по канону best-decision:

- Агент НЕ задаёт уточняющих вопросов оператору по умолчанию.
- Агент обязан сам принимать следующий лучший шаг (best decision) на основе:
  - актуального live-shell аудита,
  - ADR-162 (best-decision-principle),
  - ADR-164 (best-decision-agent-method),
  - канонических roadmap и sprint-планов,
  - существующих implementation артефактов (например, tools/sandbox/intent_slice/).
- Если есть неоднозначность, агент:
  - сам выбирает один лучший вариант,
  - явно помечает OPEN POINTS в отчёте,
  - НЕ останавливается и НЕ переспрашивает, если это не нарушает INVARIANTS.md.
- Вопросы оператору допускаются только как исключение:
  - если без ответа нельзя соблюсти INVARIANTS.md или безопасность,
  - и это должно быть явно помечено как EXCEPTION TO NO-QUESTIONS RULE.
- Это правило распространяется на все сессии Claude Code в данном репозитории до отдельной отмены через CLAUDE.md / MEMORY.md.

---
# Feature implementation canon

- Every feature the operator loads goes through `docs/canon/FEATURE-EVALUATION-AND-PLACEMENT-CANON-2026-07-20.md`: Step 1 (value assessment, factory vs Banksy) → placement decision (FACTORY ONLY / BANKSY ONLY / SHARED / REJECT) → Step 2 (implementation) — in that order, before any code/prompt/workflow change begins.
- ACCEPT is not an endpoint. An accepted feature MUST be implemented in behavior — factory code/prompts/orchestration for FACTORY ONLY or SHARED Phase A, Banksy/project code for BANKSY ONLY or SHARED Phase B. A document or guide is a specification for that implementation, never a substitute for it.
- A feature that is ACCEPTED but only documented, with no corresponding behavior change, violates this canon. If a feature cannot be safely implemented, it must be reclassified REJECT (risk/misfit) — never left sitting as an unimplemented "paper guide."
- When a feature reaches ACCEPT, Claude Code must propose and execute the concrete change matching its placement — not stop at "another document" — unless that document *is* the implementation (e.g., this file, or canon agents actually read/enforce).
- This rule binds every Claude Code session in this repo going forward, the same way the Best-decision rule above does, until amended here or in `MEMORY.md`.

---
# Default UI design skill

- For UI generation, interface redesign, frontend polish, visual review, component styling, or dashboard/landing/admin UX work, Claude Code MUST proactively load/apply `/apple-design` as the default design skill — unless the operator explicitly requests a different style/system.
- `/apple-design` is a **principle-based design-quality reference**, not an effects/motion-decoration pack — it governs typography, layout, restraint, and visual hierarchy quality, applied *in addition to*, not instead of, this repo's own `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` governance (design tokens, component lifecycle, accessibility).
- Local registration: `.claude/skills/apple-design/SKILL.md`.
- Placement per `docs/canon/FEATURE-EVALUATION-AND-PLACEMENT-CANON-2026-07-20.md`: SHARED — installed in the factory now (Phase A); propagation into a Banksy/product fork (Phase B) awaits a concrete fork target and is not yet done.

---
# Артефактный канон

- В каждый момент времени допускается только один активный артефакт спринта. Claude Code не ведёт параллельных веток работы, не разбрасывается по нескольким артефактам одновременно.
- После получения вывода по спринту или прямой команды от оператора следующий артефакт создаётся автоматически по принципу лучшего решения для текущего состояния фабрики и проекта — без дополнительной болтовни и обсуждений вокруг.
- Прямая команда («сделай <X>») трактуется как указание на следующий артефакт: Claude Code формирует конкретный артефакт (команды shell, промпт, план спринта), а исполняет или применяет его оператор. Никаких уточняющих вопросов и параллельных артефактов.
- Claude Code обязан читать и соблюдать этот канон в каждой сессии этого репозитория; попытки вести несколько линий артефактов одновременно считаются нарушением фабричного режима работы.

---
# Shell command canon

- "сделай <X>" means: prepare concrete shell commands for <X>, to be executed by the operator. Claude Code MUST respond with commands only (and minimal labels), not with questions or discussion.
- Shell audits, greps, ls/find trees, and similar checks should be expressed as shell commands when requested, following this rule.
- This canon applies to all future Claude Code sessions in this repo until amended in CLAUDE.md or MEMORY.md.
- Consistent with the Best-decision rule above: the existing safety/INVARIANTS.md exception still applies — this canon governs response *format* (commands, not discussion) for routine requests, it does not remove the narrow exception for cases where proceeding without a question would violate INVARIANTS.md or safety.

---
