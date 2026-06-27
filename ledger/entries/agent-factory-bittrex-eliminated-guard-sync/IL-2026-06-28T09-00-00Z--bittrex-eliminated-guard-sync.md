---
il_ts: 2026-06-28T09:00:00Z
session_id: agent-factory-bittrex-eliminated-guard-sync
source: CEO
status: DONE
---
### Governance sync — Bittrex ELIMINATED + CI forward-guard recorded (docs-plane)

- **Objective:** Make ARCH governance reflect reality: Bittrex (retired crypto exchange, distinct from Bitrix CMS) is fully eliminated from EMI code AND forward-guarded in CI. Docs + ledger only; no code.
- **Evidence (not memory):** EMI origin/main 4f93870 — repo-wide git grep -il 'bittrex' = 0 (eliminated). EMI PR #262 merged the Semgrep rule banxe-no-bittrex-reintroduction (pattern (?i)bittrex, generic, ERROR; paths services/app/src/api/config; exclude tests/docs/.semgrep). Prior gap: banxe-no-bitrix-reintroduction (?i)(bitrix|битрикс) did NOT match 'bittrex'. ARCH origin/main 6602842 IL max=622; provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Deliverable:** additive dated Amendment in docs/adr/ADR-138-neuronext-retired-paybis-sole-crypto-provider.md — distinguishes Bittrex(exchange) from Bitrix(CMS), records ELIMINATED status + new guard + closed gap. Single best home (ADR-138 = crypto-provider retirement ADR); no duplication (ADR-102: no pre-existing bittrex elimination+guard record; pass-1 dossier §6 had only a brief note).
- **Perimeter / canon:** docs+ledger only; NO EMI/runtime code; bitrix+neuronext guards intact (not weakened); additive amendment (original ADR-138 decision unchanged); append-only build_ledger; sub-B/factory → MAIN per §71/§74 (NO merge — operator decides). RAR/secrets untouched.
- **Refs:** EMI PR #262 (4f93870); ADR-138; ADR-102; ADR-119/I-28; pass-1 dossier §6.
