# Factory Watchdog / NOC / Auto-Remediation

> ADR-WDG-01 (PROPOSED) | I-75 (PROPOSED) | G-WDG-01..04

Unified heartbeat + health-check + auto-remediation system for Banxe AI Bank infrastructure.

## Structure

```
ops/watchdog/
├── README.md              # This file
├── config.yaml            # Heartbeat/health-check configuration
├── registry.yaml          # Critical entity registry
├── watchdog.timer         # systemd timer (15m cadence)
├── watchdog.service       # systemd service unit
└── healthcheck.py         # Heartbeat/health-check script (scaffold)
```

## Status

SCAFFOLD — not yet operational. Pending:
1. ADR-WDG-01 acceptance (operator ratification)
2. Implementation sprint (Track J, J-Phase 1..7)
3. Integration testing
4. Operator approval for systemd deployment

## Quick start (future)

```bash
# Install timer
sudo cp watchdog.timer watchdog.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now watchdog.timer

# Manual run
python3 healthcheck.py --mode heartbeat   # 15m quick check
python3 healthcheck.py --mode extended    # 30m extended check
python3 healthcheck.py --mode audit       # 60m full audit
```
