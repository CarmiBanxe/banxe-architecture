---
description: Create a new Architecture Decision Record (ADR)
---

Create a new ADR in `decisions/`:

```bash
cd /home/mmber/banxe-architecture

# Get next ADR number
NEXT=$(ls decisions/ADR-*.md 2>/dev/null | wc -l)
NEXT=$((NEXT + 1))
NUM=$(printf "%03d" $NEXT)

# Create new ADR from template
cat > decisions/ADR-${NUM}-<title>.md << 'EOF'
# ADR-NNN: <Title>

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded

## Context

What situation led to this decision?

## Decision

What was decided?

## Consequences

What are the positive and negative consequences?

## Alternatives considered

What other options were evaluated?
EOF
```
