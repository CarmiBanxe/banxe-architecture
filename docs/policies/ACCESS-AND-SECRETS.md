# ACCESS-AND-SECRETS.md
# Banxe Access & Secrets Policy - IL-AccessPolicy-01

Status: ACTIVE
Owner: MLRO + Tech Lead
Date: 2026-04-19

## 1. Recommended rule

- All developers: read/write access to all working repositories that contain NO secrets.
- Restricted circle only: repositories that actually hold keys, credentials, or sensitive archives (production secrets, customer data exports, legal holds).

## 2. Secret-handling invariants

- I-SEC-01: Secrets MUST NOT be stored in regular shared repositories.
- I-SEC-02: If a secret is found in a shared repo, that repo is IMMEDIATELY reclassified as restricted (archived from public access, ACL tightened).
- I-SEC-03: After reclassification, git history MUST be purged (git filter-repo / BFG), and the leaked secret MUST be rotated at source.
- I-SEC-04: No new commits to the affected repo until history is clean and secret scanner (gitleaks / GitHub secret scanning) returns zero findings.

## 3. Classification tiers

- open: all developers - default for code, docs, architecture.
- restricted: named list only - infra keys, archives, legal evidence.
- archived: read-only, no new commits (e.g. collaboration).

## 4. Enforcement

- Pre-commit: gitleaks hook mandatory on every clone.
- CI: GitHub secret scanning + push protection enabled org-wide.
- Review: any new repo must declare tier in README within 24h of creation.
