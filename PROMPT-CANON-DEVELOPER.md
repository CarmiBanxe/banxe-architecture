# PROMPT-CANON-DEVELOPER

Канон промптов для AI-ассистента (Claude / Comet / Perplexity), работающего с
банковской платформой BANXE EMI на стороне разработчика.

## 1. Один большой скрипт, не серия мелких команд
- Не дробить на множественность.
- Полный исполняемый блок одной пастой.
- Если терминал падает на multiline / heredoc — использовать
  `cat > /tmp/script.sh << 'EOF' ... EOF && bash /tmp/script.sh`.

## 2. Продуманные команды без переспросов
- Сразу давать готовое решение.
- Никаких "если хочешь", "приемлемо ли", "это ок?".
- Принимать взвешенное оптимальное решение по следующему шагу самому.

## 3. 100% или OPEN
- Задача закрыта только с proof + quality check + явным статусом в ledger.
- Никакого middle ground.
- При невозможности закрыть — фиксировать как OPEN-тикет с blocker.

## 4. Один scope = один commit = один proof SHA
- Не смешивать чужие фичи в свой scope.
- `git add -A` запрещён без allowlist.
- `git reset HEAD` перед `git add` обязателен.
- `git commit -o <path>` для гарантии scope-чистоты.

## 5. ASCII-only в Python-коде
- Em-dash `—` в Python без `#` ломает парсер.
- Только обычный ASCII-дефис `-` в коде.
- Em-dash допустим только внутри `# комментариев` и в `.md` документации.

## 6. Heredoc-дисциплина
- Не вводить multiline прямо в shell (часто обрывается на `>`).
- Использовать `cat > /tmp/script.sh << 'EOF'` с одинарными кавычками
  для защиты от подстановки переменных.
- Для длинных скриптов — base64-доставка одной короткой командой.

## 7. Parking out-of-scope
- Не удалять чужие файлы.
- Перемещать в `/tmp/banxe-parking-<scope>-<ts>/`.
- Регистрировать в INSTRUCTION-LEDGER.md как parking IL.

## 8. Откат чужих модификаций перед pytest
- `git checkout HEAD -- <files>` если они импортируют то, чего нет.
- Не править чужие модули "по дороге".

## 9. Proof SHA берётся после реального commit, не до
- Не записывать в ledger SHA, который ещё не существует.
- Anchor verification: `git log --oneline -- <scoped files>` должен
  включать заявленный SHA.

## 10. Pre-commit hook bypass — только осознанно
- `SKIP=pytest-fast git commit ...` допустим для documentation-only коммитов
  при условии явной фиксации факта bypass в commit message.
- Никогда не пропускать Spec-First Auditor v2.
- Никогда не пропускать ruff/bandit/semgrep на code-коммитах.

## 11. Push — privileged action
- Push origin требует явного `yes` от человека.
- Не выполняется автоматически по канону.
- Каждый push фиксируется в ledger через `privileged-ops: git push origin main: EXECUTED`.

## 12. Memory across sessions
- В конце сессии — handoff в `/tmp/banxe_handoff_<date>_<hhmm>.md`.
- Включает: статус IL, proof SHA, blockers, parking, next-session prompt.
- Используется при старте следующей сессии вместо устных воспоминаний.
