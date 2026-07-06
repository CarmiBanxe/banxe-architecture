#!/usr/bin/env bash
# scripts/log-status-report.sh
# Ops reporting utility — reads task-log files under $LOG_GLOB and emits a
# single markdown summary of their state to $STATUS_PATH. Analogous to a CI
# summary: pure read + report, no state mutation on the inputs.
#
# Layout / pattern reference: scripts/novelty-watcher.sh + systemd/novelty-
# watcher.{service,timer} (ADR-102 reference-not-restate — this script does
# NOT duplicate the watcher's logic; it borrows the shape of a config-over-
# hardcode, EnvironmentFile-driven, Type=oneshot systemd oneshot).
#
# Invariants:
#   * Plain bash. No LLM calls. No network calls to the logs' authors.
#   * Log files are OPENED READ-ONLY. This script NEVER modifies, truncates,
#     rotates, deletes, or moves any input log — ever. It only calls `stat`,
#     `wc`, `grep`, `tail` against them.
#   * Config-over-hardcoding (CLAUDE.md §10 / approval-rules.md): every
#     tunable — LOG_GLOB, STATUS_PATH, STALE_SECS, JOB_MATCH — is read from
#     the environment. Systemd exposes them via EnvironmentFile; the
#     runbook documents the sample .env.
#   * Atomic write on $STATUS_PATH — via a tempfile in the same directory
#     followed by `mv -f`. A partial file NEVER exists at the target path.
#
# Config knobs (all env-driven):
#   LOG_GLOB    - shell glob for input logs; default '/tmp/sp*-*.log'.
#   STATUS_PATH - markdown output path; default $HOME/banxe-dev/DISPATCH-STATUS.md.
#   STALE_SECS  - a log without a finish marker whose mtime is older than
#                 this many seconds is classified INCOMPLETE; default 1800.
#   JOB_MATCH   - pgrep pattern for counting active jobs; default 'claude -p'.
#
# State classification per log file:
#   EMPTY       - file size == 0.
#   FINISHED    - file contains a line matching '^\[[A-Z].*=.*\]' (the
#                 canonical single-line completion marker used by the
#                 existing /tmp/sp*-*.log ecosystem).
#   IN_PROGRESS - no finish marker AND mtime younger than STALE_SECS.
#   INCOMPLETE  - no finish marker AND mtime older than STALE_SECS.
#
# Anchors:
#   * scripts/novelty-watcher.sh + systemd/novelty-watcher.{service,timer}
#     (pattern reference, ADR-102 — NOT copied, referenced).
#   * CLAUDE.md §10 Configuration-over-Hardcoding.
#   * safety-rules.md destructive-op verify-step (this script has no
#     destructive op; explicit read-only contract stated above).

set -euo pipefail

# --------------------------------------------------------------------------
# Config-over-Hardcoding: read tunables from env with documented defaults.
# --------------------------------------------------------------------------
LOG_GLOB="${LOG_GLOB:-/tmp/sp*-*.log}"
STATUS_PATH="${STATUS_PATH:-${HOME}/banxe-dev/DISPATCH-STATUS.md}"
STALE_SECS="${STALE_SECS:-1800}"
JOB_MATCH="${JOB_MATCH:-claude -p}"

log() { printf 'log-status-report: %s\n' "$*" >&2; }
die() { printf 'log-status-report: ERROR: %s\n' "$*" >&2; exit 1; }

# --------------------------------------------------------------------------
# Ensure output directory exists and is writable. If the directory is
# missing / not creatable, exit non-zero with a diagnostic (per spec item 5).
# --------------------------------------------------------------------------
STATUS_DIR="$(dirname -- "${STATUS_PATH}")"
if [ ! -d "${STATUS_DIR}" ]; then
  mkdir -p -- "${STATUS_DIR}" 2>/dev/null \
    || die "output directory unavailable: ${STATUS_DIR}"
fi
[ -w "${STATUS_DIR}" ] || die "output directory not writable: ${STATUS_DIR}"

# --------------------------------------------------------------------------
# Collect log paths matching LOG_GLOB, sorted newest-first by mtime. The
# glob may be a shell pattern; enable nullglob so an empty match becomes an
# empty list rather than a literal string.
# --------------------------------------------------------------------------
shopt -s nullglob
# shellcheck disable=SC2206 # intentional word-split for glob expansion
LOG_FILES=( ${LOG_GLOB} )
shopt -u nullglob

# Sort by mtime descending (newest first). `stat -c %Y` is POSIX-ish on
# GNU coreutils (Linux). We collect (mtime,path) pairs and sort numerically.
SORTED_PATHS=()
if [ "${#LOG_FILES[@]}" -gt 0 ]; then
  while IFS= read -r line; do
    SORTED_PATHS+=( "${line#*|}" )
  done < <(
    for f in "${LOG_FILES[@]}"; do
      [ -e "${f}" ] || continue
      printf '%s|%s\n' "$(stat -c '%Y' -- "${f}")" "${f}"
    done | sort -t'|' -k1,1 -rn
  )
fi

# --------------------------------------------------------------------------
# Count active jobs matching JOB_MATCH. `pgrep -c` returns a count; a
# non-matching pattern exits non-zero which we normalise to 0. No signal is
# sent, no process is inspected beyond its command line.
# --------------------------------------------------------------------------
ACTIVE_COUNT="$(pgrep -c -f -- "${JOB_MATCH}" 2>/dev/null || echo 0)"

# --------------------------------------------------------------------------
# Classify one file. Prints "STATE|SUMMARY|MTIME_ISO" on stdout.
# READ-ONLY: only stat / wc / grep / tail invoked against the file.
# --------------------------------------------------------------------------
classify_one() {
  local f="$1"
  local size mtime now age state summary marker_re='^\[[A-Z].*=.*\]'
  size="$(stat -c '%s' -- "${f}" 2>/dev/null || echo 0)"
  mtime="$(stat -c '%Y' -- "${f}" 2>/dev/null || echo 0)"
  now="$(date -u +%s)"
  age=$(( now - mtime ))

  if [ "${size}" -eq 0 ]; then
    state="EMPTY"
    summary=""
  else
    # Search for a finish marker (last match wins for summary).
    local last_marker
    last_marker="$(grep -E -- "${marker_re}" "${f}" 2>/dev/null | tail -n1 || true)"
    if [ -n "${last_marker}" ]; then
      state="FINISHED"
      summary="${last_marker}"
    elif [ "${age}" -lt "${STALE_SECS}" ]; then
      state="IN_PROGRESS"
      summary="$(tail -n1 -- "${f}" 2>/dev/null || true)"
    else
      state="INCOMPLETE"
      summary="$(tail -n1 -- "${f}" 2>/dev/null || true)"
    fi
  fi

  # Compact / escape summary for a markdown table cell:
  #   * strip CR;
  #   * collapse pipes into fullwidth pipes so they don't split the row;
  #   * clamp to ~180 chars.
  summary="$(printf '%s' "${summary}" | tr -d '\r' | sed 's/|/｜/g')"
  if [ "${#summary}" -gt 180 ]; then
    summary="${summary:0:177}..."
  fi

  local mtime_iso
  mtime_iso="$(date -u -d "@${mtime}" +'%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || echo '-')"
  printf '%s|%s|%s\n' "${state}" "${summary}" "${mtime_iso}"
}

# --------------------------------------------------------------------------
# Derive a job label from the log basename: '/tmp/sp08-pipeline.NNN.log'
# -> 'sp08-pipeline'. Falls back to the basename minus '.log'.
# --------------------------------------------------------------------------
job_label() {
  local base="$1"
  base="${base##*/}"
  base="${base%.log}"
  # Drop a trailing '.NNNNN' timestamp/pid segment if present.
  base="$(printf '%s' "${base}" | sed -E 's/\.[0-9]+$//')"
  printf '%s' "${base}"
}

# --------------------------------------------------------------------------
# Compose the markdown report into a tempfile in the target directory,
# then `mv -f` into place — atomic on the same filesystem.
# --------------------------------------------------------------------------
TMP="$(mktemp -- "${STATUS_DIR}/.log-status-report.XXXXXX")"
trap 'rm -f -- "${TMP}"' EXIT

{
  now_iso="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  host_short="$(hostname 2>/dev/null || echo '-')"
  printf '# DISPATCH-STATUS\n\n'
  printf '_generated: %s (UTC) on %s by scripts/log-status-report.sh_\n\n' \
    "${now_iso}" "${host_short}"
  printf -- '- **config:** `LOG_GLOB=%s` / `STATUS_PATH=%s` / `STALE_SECS=%ss` / `JOB_MATCH=%s`\n' \
    "${LOG_GLOB}" "${STATUS_PATH}" "${STALE_SECS}" "${JOB_MATCH}"
  printf -- '- **active jobs (pgrep -c -f "%s"):** %s\n\n' \
    "${JOB_MATCH}" "${ACTIVE_COUNT}"

  if [ "${#SORTED_PATHS[@]}" -eq 0 ]; then
    printf '_no log files matched `%s` at scan time._\n' "${LOG_GLOB}"
  else
    printf '| job | log | state | summary | mtime |\n'
    printf '|---|---|---|---|---|\n'
    for f in "${SORTED_PATHS[@]}"; do
      IFS='|' read -r state summary mtime_iso <<< "$(classify_one "${f}")"
      job="$(job_label "${f}")"
      # Basename for the log column keeps the row short; full path is in the
      # config line above (LOG_GLOB) and the operator can re-derive it.
      printf '| %s | `%s` | %s | %s | %s |\n' \
        "${job}" "${f##*/}" "${state}" "${summary}" "${mtime_iso}"
    done
  fi
} > "${TMP}"

mv -f -- "${TMP}" "${STATUS_PATH}"
trap - EXIT

log "wrote ${STATUS_PATH} (files=${#SORTED_PATHS[@]} active=${ACTIVE_COUNT})"
