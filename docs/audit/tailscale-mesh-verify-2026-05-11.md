# Tailscale Mesh Verification — 2026-05-11
# ADR-035 ROADMAP Part 5 (revised) / Step 7
# Sub-terminal A | SESSION-CANON 2026-05-11 | Read-Only Audit
# Status: VERIFIED ✅

## Summary

All three nodes in the Banxe AI pool are enrolled in the same Tailscale tailnet under
`carmi@`. Direct peer-to-peer connections are established between all node pairs.
Ollama HTTP endpoints are reachable across all relevant pairs. LiteLLM on Legion is
correctly bound to loopback only (not exposed to Tailscale mesh — expected / secure).

---

## Node Inventory

| Node | MagicDNS name | Tailscale IP | LAN IP | TS version |
|------|--------------|-------------|--------|-----------|
| Legion (WSL2) | mark-legion | 100.101.218.26 | 192.168.0.75 | 1.96.4 |
| evo1 | banxe-nucbox-evo-x2 | 100.68.102.48 | 192.168.0.72 | 1.96.4 |
| evo2 | banxe-nucbox-evo-x2-2 | 100.99.208.21 | 192.168.0.15 | 1.96.4 |

All nodes: same tailnet account (`carmi@`), same version (1.96.4), Linux OS.

---

## Connection Status per Node

### Legion (`tailscale status`)
```
100.68.102.48  banxe-nucbox-evo-x2    active; direct 192.168.0.72:41641
100.99.208.21  banxe-nucbox-evo-x2-2  - (idle — activates on demand)
```

### evo1 (`tailscale status`)
```
100.101.218.26  mark-legion           active; direct 192.168.0.75:60391  tx 99796 rx 80524
100.99.208.21   banxe-nucbox-evo-x2-2  - (idle — activates on demand)
```

### evo2 (`tailscale status`)
```
100.101.218.26  mark-legion           active; direct 192.168.0.75:60391  tx 78780 rx 61508
100.68.102.48   banxe-nucbox-evo-x2   - (idle — activates on demand)
```

**Note on `-` (idle) peers:** Tailscale marks a peer as `-` when no traffic has flowed
recently. The peer is still reachable — `tailscale ping` triggers NAT hole-punch and
returns a pong within 1–3ms. This is normal Tailscale behaviour.

---

## Reachability Matrix

All tests run 2026-05-11. Method: `tailscale ping --c 3` (Tailscale layer) +
`ping -c 3` (ICMP) + `curl` (HTTP application layer).

### Tailscale-layer reachability (`tailscale ping`)

| From → To | TS IP | Path | Latency | Result |
|-----------|-------|------|---------|--------|
| Legion → evo1 | 100.68.102.48 | direct 192.168.0.72:41641 | 2ms | ✅ |
| Legion → evo2 | 100.99.208.21 | direct 192.168.0.15:41641 | 3ms | ✅ |
| evo1 → Legion | 100.101.218.26 | direct 192.168.0.75:60391 | 2ms | ✅ |
| evo1 → evo2 | 100.99.208.21 | direct 10.0.0.2:41641 | 2ms | ✅ |
| evo2 → Legion | 100.101.218.26 | direct 192.168.0.75:60391 | 2ms | ✅ |
| evo2 → evo1 | 100.68.102.48 | direct 10.0.0.1:41641 | 1ms | ✅ |

**All 6 directed pairs: direct WireGuard paths, no DERP relay required.**

### ICMP reachability (from Legion)

| Destination | TS IP | Loss | Avg RTT | Result |
|------------|-------|------|---------|--------|
| evo1 | 100.68.102.48 | 0% | 2.8ms | ✅ |
| evo2 | 100.99.208.21 | 0% | 3.3ms | ✅ |

### HTTP application layer (Ollama :11434)

| From | To | TS IP | Models returned | Result |
|------|-----|-------|----------------|--------|
| Legion | evo1 | 100.68.102.48 | 9 | ✅ |
| Legion | evo2 | 100.99.208.21 | 10 | ✅ |
| evo2 | evo1 | 100.68.102.48 | 9 | ✅ |

### LiteLLM on Legion (:8080)

| From | To | Result | Reason |
|------|-----|--------|--------|
| evo2 | Legion:8080 (TS) | ❌ connection refused | **Expected** — LiteLLM binds `127.0.0.1:8080` only |

LiteLLM service confirmed listening: `127.0.0.1:8080` (loopback). Remote access
intentionally not exposed. Canonical clients (banxe-emi-stack, Claude Code) run
on Legion and connect to localhost. This is the correct security posture.

---

## DERP / NAT Check (Legion)

```
Report:
  * UDP: true
  * IPv4: yes (90.116.185.11:60383)
  * MappingVariesByDestIP: false
  * CaptivePortal: false
  * Nearest DERP: London (33.4ms)
  * DERP latency:
    - lon: 33.4ms (London)
    - ams: 52.1ms (Amsterdam)
    - par: 55.7ms (Paris)
```

All connections to evo1 and evo2 established as **direct** (WireGuard peer-to-peer).
DERP relay (London) is a fallback only — not in use for any pair.

---

## DNS Health Warning (Non-Blocking)

Both evo1 and evo2 report:
```
# Health check:
#     - Tailscale can't reach the configured DNS servers. Internet connectivity may be affected.
```

This is a Tailscale MagicDNS resolver issue on the NUCBox nodes. It does **not**
affect Tailscale routing or WireGuard connections — confirmed by successful pings and
HTTP calls. Root cause: NUCBox DNS config (systemd-resolved / /etc/resolv.conf) may
not point to Tailscale's `100.100.100.100` resolver. Remediation deferred — non-blocking
for AI pool operations which use IP addresses directly.

---

## Security Observations

| # | Observation | Severity | Notes |
|---|------------|----------|-------|
| S-01 | LiteLLM bound to 127.0.0.1 only | INFO (positive) | Correct — not exposed to mesh |
| S-02 | All TS connections are direct (no relay) | INFO (positive) | WireGuard P2P, no DERP bounce |
| S-03 | All 3 nodes on same tailnet account `carmi@` | INFO | Single-account tailnet, no ACL segmentation |
| S-04 | MagicDNS DNS warning on evo1/evo2 | LOW | Does not affect routing; remediate if MagicDNS names needed |

---

## Topology Diagram

```
                     Tailscale Mesh (WireGuard encrypted)
     +-----------------------------------------------------------+
     |                                                           |
     |   Legion (WSL2)           evo1                evo2       |
     |   mark-legion             banxe-nucbox-x2    banxe-x2-2  |
     |   100.101.218.26          100.68.102.48      100.99.208.21|
     |   192.168.0.75            192.168.0.72       192.168.0.15 |
     |                                                           |
     |   LiteLLM :8080(lo)       Ollama :11434      Ollama :11434|
     |   TS daemon active        TS daemon active   TS daemon active|
     |                                                           |
     |   <------------------------------------------------------> |
     |      Direct WireGuard (all pairs, ~1-3ms LAN)            |
     +-----------------------------------------------------------+
```

---

## Verdict

| Check | Status |
|-------|--------|
| All 3 nodes enrolled in same tailnet | ✅ |
| All 3 nodes same TS version (1.96.4) | ✅ |
| All 6 directed pairs reachable via `tailscale ping` | ✅ |
| ICMP reachability Legion-evo1, Legion-evo2 | ✅ |
| Ollama HTTP reachable across Tailscale (3 pairs tested) | ✅ |
| All connections direct WireGuard (no DERP relay) | ✅ |
| LiteLLM correctly NOT exposed on Tailscale | ✅ |
| DNS warning on evo1/evo2 | WARN non-blocking |

**OVERALL: MESH VERIFIED** — Ready for pool-aware routing in future roadmap steps.

---

Generated by Sub-terminal A under SESSION-CANON 2026-05-11 | Read-only audit
