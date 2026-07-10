#!/usr/bin/env bash
# safe-push.sh — the ONLY sanctioned push wrapper for factory branches.
# Always uses --force-with-lease; refuses dangerous flags. Canon: never plain
# --force, never --no-verify, never --admin. Pass normal push args, e.g.:
#   tools/factory/safe-push.sh -u origin agent/factory/<id>/<slug>
set -euo pipefail

for arg in "$@"; do
  case "$arg" in
    --force|-f|--force=*)
      echo "REFUSED: plain --force is forbidden (use --force-with-lease, applied automatically)"; exit 1 ;;
    --no-verify)
      echo "REFUSED: --no-verify is forbidden (pre-push gates are mandatory)"; exit 1 ;;
    --admin)
      echo "REFUSED: --admin is forbidden"; exit 1 ;;
  esac
done

echo "safe-push: git push --force-with-lease $*"
exec git push --force-with-lease "$@"
