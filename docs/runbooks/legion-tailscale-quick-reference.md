# Legion Tailscale Quick Reference
# ADR-035 ROADMAP Part 5 (revised) | Updated: 2026-05-11
# Sub-terminal A | SESSION-CANON 2026-05-11

## Node Quick Reference

| Alias | Tailscale IP | LAN IP | Service |
|-------|-------------|--------|---------|
| Legion (this host) | 100.101.218.26 | 192.168.0.75 | LiteLLM :8080 (loopback only) |
| evo1 | 100.68.102.48 | 192.168.0.72 | Ollama :11434, Redis :6379 |
| evo2 | 100.99.208.21 | 192.168.0.15 | Ollama :11434 |

## Status Checks

```bash
# Show this node's Tailscale IP and peers
tailscale status

# Check a specific peer is reachable
tailscale ping 100.68.102.48     # evo1
tailscale ping 100.99.208.21     # evo2

# Show this node's Tailscale IP
tailscale ip -4

# Network diagnostics
tailscale netcheck
```

## Reach Ollama on evo1/evo2 via Tailscale

```bash
# evo1 model list (Tailscale)
curl http://100.68.102.48:11434/api/tags | python3 -c "import sys,json; d=json.load(sys.stdin); [print(m['name']) for m in d['models']]"

# evo2 model list (Tailscale)
curl http://100.99.208.21:11434/api/tags | python3 -c "import sys,json; d=json.load(sys.stdin); [print(m['name']) for m in d['models']]"

# Quick inference test on evo1 (non-streaming)
curl -s http://100.68.102.48:11434/api/generate \
  -d '{"model":"qwen3:30b-a3b","prompt":"ping","stream":false}' | python3 -c "import sys,json; print(json.load(sys.stdin)['response'])"
```

## LiteLLM on Legion

LiteLLM listens on **127.0.0.1:8080 only** — not accessible from remote nodes.
This is intentional. Access from Legion:

```bash
# Health check (requires master key)
curl http://127.0.0.1:8080/health -H "Authorization: Bearer $(grep LITELLM_MASTER_KEY ~/.config/litellm/.env | cut -d= -f2)"

# List models
curl http://127.0.0.1:8080/v1/models -H "Authorization: Bearer $(grep LITELLM_MASTER_KEY ~/.config/litellm/.env | cut -d= -f2)"
```

## Service Management

```bash
# LiteLLM (Legion systemd)
sudo systemctl status litellm
sudo systemctl restart litellm
sudo journalctl -u litellm -n 50 -f

# Tailscale (Legion)
sudo systemctl status tailscaled
```

## SSH Access

```bash
ssh evo1   # banxe-nucbox-evo-x2 (192.168.0.72 LAN)
ssh evo2   # banxe-nucbox-evo-x2-2 (192.168.0.15 LAN)

# Via Tailscale IP (works even if LAN routing changes)
ssh carmi@100.68.102.48
ssh carmi@100.99.208.21
```

## Troubleshooting

**Peer shows `-` in `tailscale status`:**
This means idle (no recent traffic), NOT unreachable. Test with `tailscale ping <IP>`.

**Cannot reach Ollama on evo1/evo2:**
1. Check Tailscale connectivity: `tailscale ping 100.68.102.48`
2. Check Ollama running: `ssh evo1 'systemctl status ollama'`
3. Check firewall: `ssh evo1 'sudo ufw status'`

**LiteLLM 401 Unauthorized:**
Normal for unauthenticated requests. Pass master key header.

**MagicDNS warning on evo1/evo2:**
Non-blocking warning about DNS resolver. Does not affect routing.
To resolve: `ssh evo1 'sudo tailscale up --accept-dns=true'` (requires evo central terminal approval — per OCAT G-INFRA-01).

---

*Verified: 2026-05-11 | All 6 directed node pairs confirmed direct WireGuard*
