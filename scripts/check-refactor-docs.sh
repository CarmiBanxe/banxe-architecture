#!/usr/bin/env bash
set -euo pipefail

cd /home/mmber/banxe-architecture

echo '--- repo ---'
pwd

echo '--- branch ---'
git branch --show-current 2>/dev/null || true

echo '--- status ---'
git status -sb | head -2 || true

echo '--- legacy refactor docs count ---'
shopt -s nullglob
files=(docs/refactor/legacy/*.md)
echo "${#files[@]}"

echo '--- legacy refactor docs list ---'
if ((${#files[@]} == 0)); then
  echo 'No files found in docs/refactor/legacy/'
else
  printf '%s\n' "${files[@]}"
fi

echo '--- canon files ---'
canon_files=(docs/canon/*.md)
if ((${#canon_files[@]} == 0)); then
  echo 'No files found in docs/canon/'
else
  printf '%s\n' "${canon_files[@]}" | head -10
fi
