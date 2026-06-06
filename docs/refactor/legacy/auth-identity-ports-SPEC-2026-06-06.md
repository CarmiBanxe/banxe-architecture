# Refactor SPEC #12 — Auth/Identity ports group (IAMPort + TokenManagerPort + TwoFactorPort)

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_PORT; NEW-driven; surfaces new capability C19 auth/identity)
Scope: 8 PORT-ADAPTER auth/identity/2fa legacy projects -> IAMPort + TokenManagerPort + TwoFactorPort
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/ on evo1; CLASS_PORT.tsv
NEW capability: C19 (authentication / identity / 2FA) — NEW gap surfaced by CLASS_PORT NEW-driven sweep; not in original C1-C18; mandatory for EMI
Related: ADR-015 2FA; ADR-017 containerised Keycloak; R2 IAM Stabilization PREP (in main); SPEC #5 (banxe-baas consumer)
Owner: Terminal B (smart refactor)

## Purpose

NEW-driven sweep of CLASS_PORT surfaced a capability gap: C19 (auth/identity/2FA), mandatory for any EMI but absent from the original C1-C18 (which were derived from ADR-021 five ports + roadmap). Legacy has 8 auth/identity projects. This SPEC defines three new Hexagonal ports (IAMPort, TokenManagerPort, TwoFactorPort) backed by Keycloak (ADR-017) and consolidates the 8 legacy adapters. PRIORITY-MAP must be amended to add C19.

## Legacy inventory + decision (8 projects -> 3 ports)

- IAMPort: banxe-identity-config-manager + banxe-identity + banxe-acl -> Keycloak-backed identity/access; dedupe 2 identity copies; ACL -> Keycloak roles.
- TokenManagerPort: auth-service + banxe_auth + banxe-auth-backend + banxe-auth (4 copies!) -> ONE canonical token service on Keycloak OIDC; dedupe 4 -> 1.
- TwoFactorPort: banxe-2fa -> TOTP/SMS 2FA per ADR-015; keep, modernise.

Major finding: 4 duplicate auth services in legacy -> consolidate to one TokenManagerPort on Keycloak OIDC. This is a key tech-debt reduction surfaced only by NEW-driven sweep.

## Three new ports (high-level, Keycloak-backed)

```typescript
export interface TokenManagerPort {
  issueToken(userId: string, scopes: string[]): Promise<{ accessToken: string; refreshToken: string; expiresIn: number }>;
  refresh(refreshToken: string): Promise<{ accessToken: string; expiresIn: number }>;
  revoke(token: string): Promise<void>;
  introspect(token: string): Promise<{ active: boolean; userId?: string; scopes?: string[] }>;
}

export interface IAMPort {
  getUserRoles(userId: string): Promise<string[]>;
  hasPermission(userId: string, permission: string): Promise<boolean>;
  assignRole(userId: string, role: string): Promise<void>;
}

export interface TwoFactorPort {
  enroll(userId: string, method: "totp" | "sms"): Promise<{ secret?: string; qr?: string }>;
  verify(userId: string, code: string): Promise<boolean>;
  isEnrolled(userId: string): Promise<boolean>;
}
```

All three back onto Keycloak (ADR-017): TokenManagerPort = OIDC tokens, IAMPort = realm roles, TwoFactorPort = KC OTP policy.

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + 3-port decision (this SPEC) + C19 PRIORITY-MAP amendment flag.
- Phase B (Terminal B): scaffold one banxe-auth service exposing all three ports on Keycloak OIDC.
- Phase C (Terminal B): dedupe 4 legacy auth services -> one TokenManagerPort; 3 identity -> IAMPort; 2fa -> TwoFactorPort.
- Phase D (Terminal B): contract tests per port; session-timeout per R2 PREP baseline.
- Phase E (Terminal B): cut all callers to banxe-auth ports; remove 8 legacy auth/identity services.
- Phase F (Terminal B): tag 8 legacy projects ARCHIVE; record in IL.

## Risk register tie-in

- R2 IAM Stabilization (in main): this SPEC is the Hexagonal-port layer over the R2 Keycloak baseline.
- R-SEC-NEW-07 (4 duplicate auth services): security risk from divergent auth logic; consolidation to one TokenManagerPort closes it.
- R-PRIV-04 (identity PII): IAMPort role/permission data under ADR-021 PII routing.

## Acceptance criteria

- 3 ports (IAMPort, TokenManagerPort, TwoFactorPort) defined; one banxe-auth service implements all on Keycloak.
- 4 legacy auth services deduplicated to one; 3 identity to one; no lost auth rule.
- Contract tests per port; session-timeout per R2 PREP.
- PRIORITY-MAP amended with C19 (auth/identity/2FA).
- 8 legacy projects ARCHIVE.

## References

- ADR-015 2FA; ADR-017 containerised Keycloak
- R2-IAM-STABILIZATION-PREP (in main)
- NEW-PROJECT-PRIORITY-MAP-2026-06-06.md (to be amended with C19)
- CLASS_PORT.tsv (8 auth/identity/2fa rows)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF Auth/Identity ports SPEC #12 (CLASS_PORT; NEW-driven C19; 3 new ports) ===
