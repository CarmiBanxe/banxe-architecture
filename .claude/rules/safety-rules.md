# Safety Rules

## Безопасность и ограничения

### ЗАПРЕЩЕНО:
- Удалять файлы без подтверждения CEO
- Удалять репозитории
- Менять права доступа
- Выполнять финансовые операции
- Размещать конфигурацию разработчика в ~/projects/
- Хардкодить значения в коде (использовать Config-as-Data)

### РАЗМЕЩЕНИЕ:
- Конфигурация разработчика: ТОЛЬКО ~/developer/.claude/
- Проекты: ~/projects/
- НЕ смешивать настройки разработчика с проектами

### ПРИ ОШИБКЕ:
- Остановиться
- Сообщить CEO
- НЕ пытаться исправить автоматически без подтверждения

---

## Destructive operation verify-step (canon)

> Added 2026-05-06 per IL-FA-01-CLOSE lesson learned (sudo rm -rf in Phase E-fix3 was issued without verifying actual content of target path).

### Rule

ANY destructive bash operation (`rm -rf`, `git reset --hard`, `git clean -fd`, `docker rm -fv`, `truncate`, `dd of=`, `>file`, `mkfs`, `wipefs`, `shred`, `find ... -delete`) MUST be preceded by a **verify-step** that confirms:

1. The target path/object EXISTS.
2. The target content is what the issuer believes (size, mtime, key file presence — at least one).
3. If the operation is on shared infrastructure (`/usr/share/`, `/var/lib/`, `/etc/`, `/data/`), the verify-step MUST also confirm operator-side ownership/expectations.

### Pattern

```bash
# Verify-step (read-only, fail-fast):
[ -e "$TARGET" ] || { echo "STOP: $TARGET does not exist"; exit 1; }
ls -la "$TARGET" | head -3
du -sh "$TARGET" 2>/dev/null
# Optional sanity check based on operation type:
[ "$(stat -c %s "$TARGET")" -lt 1073741824 ] || { echo "STOP: $TARGET >1GB, double-check"; exit 1; }

# Now safe to issue destructive op (after explicit go):
# rm -rf "$TARGET"
```

### Forbidden patterns

- `sudo rm -rf "$VAR" 2>/dev/null` (silent stderr suppression masks errors).
- `rm -rf /path/...` without preceding `ls -la /path/...`.
- Destructive ops as side-effect of `cat ... > file` or `tee` over canonical paths.
- Any destructive op in a long pipeline where intermediate failure produces undefined target.

### Application scope

This rule applies to:

- Perplexity supervisor when issuing bash commands to operator.
- Claude Code when generating bash commands.
- Any agent in the fleet with `claude.bash` scope through Guardian-shim.

Guardian-shim (claude.bash POST /audit) SHOULD flag destructive patterns without verify-step as `warn` or `block` per project canon.

### Anchors

- IL-FA-01-CLOSE lesson learned point E-fix3 (PR #80)
- IL-FACTORY-02 (related — env hygiene)
- approval-rules.md "Требует подтверждения CEO" (existing stop-barrier)
- CLAUDE.md §11 (production-state mutation gate)
- ADR-026 (Guardian third family)
