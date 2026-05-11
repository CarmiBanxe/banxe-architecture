# Do-Not-Do List — Legion AI Dev Environment

**Scope:** Legion WSL2 dev workstation
**Effective:** 2026-05-11
**Authority:** SESSION-CANON-2026-05-11, ADR-035, I-71..I-74

---

These five rules are hard constraints. No exception, no workaround, no
"just for testing" bypass.

---

1. **Never send dev traffic to evo2.**
   evo2 (`http://evo2:*`) is a production inference worker serving live customer
   workloads (fraud classifier, large-model RPC). Any dev traffic — including
   health checks, model list queries, or routing fallbacks — causes resource
   starvation during business hours and pollutes production inference logs.
   The LiteLLM router on Legion must never list evo2 as a backend.

2. **Never mount or symlink `/data/kyc`, `/data/transactions`, or `/data/aml`
   into `~/banxe-dev/`.**
   These paths contain regulated personal data. Mounting them into the Legion
   dev environment exposes them to OfficeCLI, LiteLLM tool-use extensions,
   and any MCP server running under Legion. Symlinks are equally prohibited:
   Claude Code and LiteLLM both traverse symlinks without warning.

3. **Never run `litellm` or `officecli` as root under WSL2.**
   Root in WSL2 shares the Windows host token store and can escape the
   namespace boundary to reach host-mounted NFS shares (including evo1/evo2
   shared volumes). All dev processes must run as the unprivileged user `mmber`.

4. **Never remove or comment out the `block-regulated-paths` guardrail in
   `~/banxe-dev/llm-router/config.yaml`.**
   Without this guardrail, any evo1 timeout silently falls through to
   Anthropic Claude. A single prompt containing a real IBAN, KYC identifier,
   or AML flag would then be transmitted to an external API, violating
   UK GDPR Art. 46 and FCA PS25/12. There is no operational justification
   that outweighs this risk.

5. **Never commit `~/.bashrc` exports, `config.yaml`, or any file containing
   `ANTHROPIC_API_KEY` or `LLM_ROUTER_MASTER_KEY` to any branch in
   `banxe-emi-stack` or `banxe-architecture`.**
   The Semgrep rule `banxe-hardcoded-secret` detects inline secrets.
   It does NOT detect secrets in files that are sourced at runtime (e.g., a
   committed `~/.bashrc`). The `.gitignore` entry for
   `~/banxe-dev/llm-router/config.yaml` and the host-level
   `~/.claude/settings.local.json` must remain in place. Both controls
   must be active simultaneously; one without the other is insufficient.
