#!/bin/bash
# il-check.sh — Instruction Ledger status check (I-28)
# Показывает незавершённые инструкции CEO/CTIO
# Запуск: bash ~/banxe-architecture/scripts/il-check.sh
set -euo pipefail

IL="$HOME/banxe-architecture/INSTRUCTION-LEDGER.md"

if [ ! -f "$IL" ]; then
    echo "⚠️  INSTRUCTION-LEDGER.md не найден: $IL"
    exit 1
fi

echo "=== INSTRUCTION LEDGER STATUS [I-28] ==="
echo "Файл: $IL"
echo "Обновлён: $(date -r "$IL" '+%Y-%m-%d %H:%M')"
echo ""

PENDING=$(grep -c '⏳ PENDING\b' "$IL" 2>/dev/null || true)
IN_PROG=$(grep -c 'IN_PROGRESS\b' "$IL" 2>/dev/null || true)
VERIFY=$(grep -c '\bVERIFY\b' "$IL" 2>/dev/null || true)
DONE=$(grep -c 'DONE ✅' "$IL" 2>/dev/null || true)
FAILED=$(grep -c '\bFAILED\b' "$IL" 2>/dev/null || true)
BLOCKED=$(grep -c '\bBLOCKED\b' "$IL" 2>/dev/null || true)

echo "✅ DONE:        $DONE"
echo "⏳ PENDING:     $PENDING"
echo "🔄 IN_PROGRESS: $IN_PROG"
echo "🔍 VERIFY:      $VERIFY"
echo "❌ FAILED:      $FAILED"
echo "🚫 BLOCKED:     $BLOCKED"
echo ""

OPEN=$((PENDING + IN_PROG + VERIFY))
if [ "$OPEN" -gt 0 ]; then
    echo "=== НЕЗАВЕРШЁННЫЕ ($OPEN) ==="
    grep -B3 '⏳ PENDING\|IN_PROGRESS\|VERIFY' "$IL" | grep -E '^### IL-|Статус:' | sed 's/^/  /' || true
    echo ""
    echo "⛔ [I-28] Завершите незавершённые IL перед новой задачей."
else
    echo "✅ Все инструкции выполнены. Готов к новой задаче."
fi
