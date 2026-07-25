# Banksy → Legion interface (external trusted supplier) — 2026-07-23

**BANK CORE / EXTERNAL-SUPPLIER INTERFACE / DOCS-ONLY**

Banksy Engine (bank core) and Legion (external) are **two separate engines in two separate zones**. Legion is a **trusted external party/supplier** on its own laptop/zone — **not** part of the bank, **not** a shared runtime.

## Boundary
- **Direction:** Banksy → Legion (customer → trusted supplier).
- **Pattern:** request / response.
- **Purpose:** client-information gathering + access to Legion's special databases.
- **NOT:** shared runtime, shared process, or Banksy running "on" Legion.
- **Inference:** Banksy uses its **own** inference. It does **not** call Legion's private inference (e.g. `127.0.0.1:8080` llama-server) directly; Legion is reached only through this data-gathering request/response channel.

## Trust boundary
- Legion has **extra functions not permitted to Banksy** (TOR, browser, web-crawl/OSINT, proxy-scrape). These stay on Legion; Banksy (limited bank profile) never invokes them.
- Any data Banksy requests from Legion crosses an **external trust boundary** — subject to bank data-governance and `[counsel]` on cross-party data flows.

## Status
- Interface **defined, not wired** — `${LEGION_DATA_ENDPOINT}` is env-provided; no live connection established in this scaffold.

---
**This does not replace legal advice.**
