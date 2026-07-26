"""dev_fast profile guard (FAST-DEV-MODE-SPEC §4/§5): sandbox-only, fail-closed.

The profile widens limits; it never removes guardrails. Outside sandbox the
profile refuses to activate; without the profile the demo refuses to run.
"""

from __future__ import annotations

import os
from decimal import Decimal


class ProfileError(RuntimeError):
    """Fail-closed: wrong profile or non-sandbox environment."""


# FAST-DEV-MODE-SPEC §3: caps multiplier (numbers only, semantics unchanged).
DEV_FAST_BUDGET_MULTIPLIER = Decimal("10")


def require_dev_fast(env: dict[str, str] | None = None) -> None:
    e = os.environ if env is None else env
    environment = e.get("SLICE_ENVIRONMENT", "sandbox")
    if environment != "sandbox":
        raise ProfileError(
            f"dev_fast is sandbox-only; SLICE_ENVIRONMENT={environment!r} — refused (fail-closed)"
        )
    if e.get("RUNTIME_PROFILE") != "dev_fast":
        raise ProfileError("RUNTIME_PROFILE=dev_fast required for the sandbox slice — refused")
