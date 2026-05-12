# ADR Index — banxe-architecture

Generated: 2026-05-12
Generator: Sprint D2 (one-shot)
Source: `docs/adr/ADR-*.md`

This index enumerates every ADR file currently present under `docs/adr/` in the
canonical `banxe-architecture` repository (Layer 2 / project documentation). It also
records explicit MISSING rows for ADR numbers that are referenced from other
documentation but have no body in this repo (most bank-side ADRs live in the
`banxe-emi-stack` source repository; the factory-side ADR numbering has gaps to be
backfilled).

The generator script is reproduced at the bottom for re-execution by Central.

---

## Real ADR files in `docs/adr/`

| Number | Title                                                                     | Status   | Date       | Path                                                          |
|--------|---------------------------------------------------------------------------|----------|------------|---------------------------------------------------------------|
| 027    | Claude Code permissions reclassification                                  | ACCEPTED | 2026-05-05 | [`ADR-027-claude-code-permissions-reclassification.md`](./ADR-027-claude-code-permissions-reclassification.md) |
| 031    | AI Execution Policy — Meta-Plane vs Inference-Plane                       | ACCEPTED | 2026-05-03 | [`ADR-031-ai-execution-policy.md`](./ADR-031-ai-execution-policy.md) |
| 032    | GLM-4.5-Air Distributed Inference (USB4 RPC)                              | ACCEPTED | 2026-05-03 | [`ADR-032-glm45-air-distributed.md`](./ADR-032-glm45-air-distributed.md) |
| 033    | ufw Perimeter Posture per Host                                            | ACCEPTED | 2026-05-03 | [`ADR-033-ufw-perimeter.md`](./ADR-033-ufw-perimeter.md) |
| 034    | Aider/Continue Routes — ai / ai-heavy / reasoning                         | ACCEPTED | 2026-05-03 | [`ADR-034-aider-routes.md`](./ADR-034-aider-routes.md) |
| 035    | AI Pool Roadmap 2026-05-11                                                | Proposed | 2026-05-11 | [`ADR-035-ai-pool-roadmap-2026-05-11.md`](./ADR-035-ai-pool-roadmap-2026-05-11.md) |

## MISSING (gap analysis)

ADR numbers referenced elsewhere (project documentation, bank source repo
`banxe-emi-stack/docs/adr/`, master-document, IL) but **without a body in this
repository's `docs/adr/`**. To be backfilled in SD2 (factory canon side) and D3
(project canon side). Titles are left blank to avoid fabrication.

| Number     | Title | Status  | Date | Path | Note                                                                |
|------------|-------|---------|------|------|---------------------------------------------------------------------|
| 001–026    | —     | MISSING | —    | —    | Range gap; to be backfilled in SD2 (factory canon) / D3 (project)   |
| 028        | —     | MISSING | —    | —    | Referenced (KYC re-verification triggers, bank-side); to be backfilled in SD2 / D3 |
| 029        | —     | MISSING | —    | —    | Referenced (Postgres backup strategy, bank-side); to be backfilled in SD2 / D3 |
| 030        | —     | MISSING | —    | —    | Referenced (Auth rate-limit policy, bank-side); to be backfilled in SD2 / D3 |
| 036        | —     | MISSING | —    | —    | Range gap; to be backfilled in SD2 (factory canon) / D3 (project)   |
| 037        | —     | MISSING | —    | —    | Range gap; to be backfilled in SD2 (factory canon) / D3 (project)   |
| 038        | —     | MISSING | —    | —    | Placeholder referenced from `../project/security/README.md`; to be backfilled in SD2 / D3 |

> Note: ADRs 027, 029, 030, 032, 033, 034, 035 in the **bank source repo**
> (`banxe-emi-stack/docs/adr/`) have distinct titles from the factory-side
> ADRs of the same number in this canonical repo. The MISSING rows above
> document the GAP in the canonical repo; they do not assert that the bank-side
> ADRs are missing from their own repo.

## Generator script

Reproducible enumeration script. Run from the repository root:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd docs/adr
{
  echo "| Number | Title | Status | Date | Path |"
  echo "|--------|-------|--------|------|------|"
  for f in ADR-*.md; do
    [ -e "$f" ] || continue
    num=$(echo "$f" | sed -E 's/^ADR-?0*([0-9]+).*/\1/' | awk '{printf "%03d", $1}')
    title=$(awk '/^# /{sub(/^# +/, ""); sub(/^ADR-?[0-9]+[ —-]+/, ""); print; exit}' "$f")
    if [ -z "$title" ]; then
      title=$(awk -F': ' '/^title:/{print $2; exit}' "$f")
    fi
    status=$(awk -F'[: |]+' '
      /^Status:/        {print $2; exit}
      /^- Status:/      {print $3; exit}
      /^\| Status \|/   {gsub(/^\| Status \| */, ""); gsub(/ *\|.*$/, ""); print; exit}
      /^status:/        {print $2; exit}
    ' "$f")
    [ -z "$status" ] && status="UNKNOWN"
    date=$(awk -F'[: |]+' '
      /^Date:/          {print $2; exit}
      /^\*\*Date:/      {gsub(/^\*\*Date:\*\* */, ""); print; exit}
      /^\| Date \|/     {gsub(/^\| Date \| */, ""); gsub(/ *\|.*$/, ""); print; exit}
      /^date:/          {print $2; exit}
    ' "$f")
    [ -z "$date" ] && date=$(git log -1 --format=%cI -- "$f" 2>/dev/null | cut -c1-10)
    [ -z "$date" ] && date="—"
    printf "| %s | %s | %s | %s | [\`%s\`](./%s) |\n" "$num" "$title" "$status" "$date" "$f" "$f"
  done
}
```
