# Canon Violations — 2026-05-04 reference list

**Source session:** `CarmiBanxe/banxe-emi-stack` 2026-05-03 → 2026-05-04 (Comet/Claude as agent, Moriel Carmi as operator).
**Purpose:** Test cases для conversation-guard (G-CANON-01) и onboarding reference для новых AI-агентов.

## Таблица 13 нарушений

| # | Нарушение | Категория | Канон секция | Guardian-shim ловит после G-GUARD-01? | Нужен conversation-guard? |
|---|---|---|---|---|---|
| 1 | Длинный план вместо одной команды | OCAT | §1 | ❌ semantic | ✅ |
| 2 | Переспрашивание "хочешь A или B" | autonomy | §4 | ❌ | ✅ |
| 3 | Markdown в bash случайно | syntax | §1 | ✅ partial (long unquoted text) | ✅ |
| 4 | Параллельные команды в одном промте | OCAT | §1 | ❌ | ✅ |
| 5 | Печать `secret_len=32` | security | §8 | ❌ | ✅ |
| 6 | Длинные промты без разбиения | length | §5 | ❌ | ✅ |
| 7 | Адресат без пометки | addressing | §2 | ❌ | ✅ |
| 8 | Sprint 9c retry chain без pivot (8 OOM-fixes) | strategic | §4 (best decision) | ❌ | ✅ smart heuristic |
| 9 | Quote-escape errors в gh pr create --body | syntax | — | ⚠️ partial | ❌ |
| 10 | sed pattern miss из-за `$$` | syntax | — | ⚠️ partial | ❌ |
| 11 | "Принимай лучшее решение" не выполнял | autonomy | §4 | ❌ | ✅ |
| 12 | Memory из bio устаревшая | factual | §6 (verify scope) | ❌ | ❌ требует repo audit перед claims |
| 13 | Работал в неправильном sandbox repo первые часы | scope | §6 | ❌ | ✅ verify scope at start |

## Распределение покрытия

- **Guardian-shim (bash-level)**: 3 из 13 ловит (полностью или частично) — ~23%.
- **Conversation-guard (G-CANON-01, проектируется)**: 10 из 13 — ~77%.
- **Out of scope automation**: 2 из 13 (#9 quote-escape, #10 sed) — это требует test-before-execute pattern, не canon enforcement.
- **Memory drift (#12)**: требует repo audit перед factual claims, а не canon-guard.

## Ключевой вывод

Большинство нарушений канона — **semantic**, не syntactic. Bash-level guard их не ловит. **Conversation-level guard критичен** для производственного использования AI-агентов в banxe stack.
