# KYC Provider Port CONTRACT SPEC (Python Canon)

Date: 2026-06-06
Status: SPEC (Python-canon translation for factory rollout)
Scope: banxe-architecture main as canonical source for KYC factory consumption

## Status

This document is the Python-canon continuation of the existing KYC provider contract specification. The prior KYC CONTRACT SPEC was TypeScript-oriented and lived on feature branches, not in main. This file re-expresses the same contract semantics in the Python port style used by the target runtime.

## Why Python canon is mandatory for this target

Central verified that the target runtime is `banxe-emi-stack/services/kyc/`, and that this area is Python-only. The target already contains `kyc_port.py`, `factory.py`, and `mock_kyc_workflow.py`. Across the target repo, service ports follow the Python `*_port.py` pattern rather than TypeScript interfaces.

Because the target is an existing Python service boundary, the contract consumed by the factory must be written in Python port canon:
- `abc.ABC`
- `@abstractmethod`
- `async def`
- `snake_case`
- port-first wording consistent with other service ports

This is a contract specification, not executable runtime code. Python interface snippets below are normative examples of contract shape.

## Contract goals

The KYC Provider Port defines the canonical integration boundary between the NEW EMI BANXE application/domain layers and provider-specific KYC adapters.

The contract preserves:
- identical business semantics to the prior KYC contract
- webhook behavior aligned with ADR-034
- idempotent handling of mutating and replayable events
- conformance-test orientation with 11 required contract checks
- provider isolation inside adapter implementations

The contract is implementation-neutral. It describes what an adapter must do, not how a provider SDK must be wired.

## Canonical Python interface

```python
from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any, Mapping, Sequence


class KycProviderPort(ABC):
    @abstractmethod
    async def start_case(
        self,
        *,
        subject_id: str,
        correlation_id: str,
        idempotency_key: str,
        payload: Mapping[str, Any],
    ) -> Mapping[str, Any]:
        ...

    @abstractmethod
    async def get_case_status(
        self,
        *,
        provider_case_id: str,
        correlation_id: str,
    ) -> Mapping[str, Any]:
        ...

    @abstractmethod
    async def submit_document(
        self,
        *,
        provider_case_id: str,
        correlation_id: str,
        idempotency_key: str,
        document_payload: Mapping[str, Any],
    ) -> Mapping[str, Any]:
        ...

    @abstractmethod
    async def list_required_documents(
        self,
        *,
        provider_case_id: str,
        correlation_id: str,
    ) -> Sequence[Mapping[str, Any]]:
        ...

    @abstractmethod
    async def ingest_webhook_event(
        self,
        *,
        headers: Mapping[str, str],
        body: Mapping[str, Any],
        received_at: str,
    ) -> Mapping[str, Any]:
        ...
```

The interface above is canonical for naming and async shape. Concrete repos may add internal typed DTOs, but must not change contract meaning.

## Method-by-method contract semantics

### `start_case()`

Intent:
Open or resume a KYC case for a subject in an idempotent way.

Minimal input shape:
- `subject_id`
- `correlation_id`
- `idempotency_key`
- `payload` with provider-required case bootstrap data

Minimal output shape:
- canonical internal case reference
- provider case reference
- canonical status
- accepted timestamp or equivalent tracking metadata

Rules:
- repeated calls with the same semantic input and same `idempotency_key` must not create duplicate provider cases
- adapter must return a stable contract-level result for replayed requests
- provider-specific identifiers must be mapped into canonical fields

Failure classes:
- validation failure
- provider rejection
- transport or provider unavailable
- replay conflict if payload differs for the same `idempotency_key`

### `get_case_status()`

Intent:
Read the current provider-side state for a KYC case and map it into the canonical status model.

Minimal input shape:
- `provider_case_id`
- `correlation_id`

Minimal output shape:
- provider case reference
- canonical status
- provider raw status code or value
- last updated timestamp if available

Rules:
- read-only operation; no `idempotency_key` required
- mapping must be deterministic and contract-testable
- provider-only states must still collapse into canonical status buckets

Failure classes:
- case not found
- provider unavailable
- invalid identifier

### `submit_document()`

Intent:
Attach or submit a document to an existing KYC case.

Minimal input shape:
- `provider_case_id`
- `correlation_id`
- `idempotency_key`
- `document_payload`

Minimal output shape:
- provider case reference
- submitted document reference if available
- canonical document-processing status

Rules:
- duplicate submissions under the same `idempotency_key` must be replay-safe
- adapter must not create duplicate downstream submissions for retries
- result must preserve enough identifiers for later webhook reconciliation

Failure classes:
- unsupported document type
- invalid case state
- provider rejection
- transport or provider unavailable
- replay conflict

### `list_required_documents()`

Intent:
Return the current set of missing or required documents for the case.

Minimal input shape:
- `provider_case_id`
- `correlation_id`

Minimal output shape:
- list of required-document descriptors
- canonical requirement category per item where possible

Rules:
- read-only operation
- output should be stable for contract tests even if provider fields differ
- provider verbosity must be normalized into canonical descriptors

Failure classes:
- case not found
- provider unavailable

### `ingest_webhook_event()`

Intent:
Accept a provider webhook or event and turn it into a canonical KYC contract event.

Minimal input shape:
- `headers`
- `body`
- `received_at`

Minimal output shape:
- canonical event type
- provider event reference or deduplication key
- linked provider case reference if known
- processing decision: `accepted`, `duplicate`, `rejected`, or `needs_manual_review`

Rules:
- webhook processing must follow ADR-034 replay and duplicate-handling discipline
- duplicate deliveries must not produce duplicate state transitions
- signature or authentication verification may vary by implementation, but the contract result must normalize into canonical processing decisions
- acknowledgment semantics are constrained by audit persistence rules below

Failure classes:
- invalid signature or authentication
- malformed payload
- unknown event type
- duplicate replay
- provider case link missing
- internal persistence failure

## ADR-034 webhook contract

Webhook handling is a first-class part of the port contract, not an adapter afterthought.

Contract requirements:
- incoming webhook events must be deduplicated using provider event identity or a canonical replay key derived from the request
- duplicate deliveries must resolve deterministically to a non-destructive result
- webhook-derived state changes must be traceable to a correlation chain
- webhook processing must support auditability suitable for later compliance and troubleshooting review
- no success acknowledgment may be treated as final until the required audit persistence step completes

The contract does not require a single transport or framework. It requires deterministic semantics across providers.

## Idempotency and replay rules

Mutating methods in this contract are:
- `start_case()`
- `submit_document()`
- `ingest_webhook_event()` when the event changes internal state

For all mutating paths:
- `idempotency_key` is mandatory for operator or API initiated writes
- replay with the same semantic payload must return the same contract outcome class
- replay with a conflicting payload under the same `idempotency_key` must surface a contract-level replay conflict
- adapters must never create duplicate downstream actions merely because the caller retried

For externally delivered webhook events:
- replay protection may use provider event id, delivery id, or canonical replay fingerprint
- duplicate deliveries must be recognized and mapped to a safe duplicate outcome

## 11-test conformance model

Any implementation claiming conformance to this contract must pass 11 test categories:

1. start-case happy path
2. start-case idempotent replay with same payload
3. start-case replay conflict with different payload under same key
4. get-case-status canonical mapping
5. submit-document happy path
6. submit-document idempotent replay
7. list-required-documents canonical normalization
8. webhook happy path accepted
9. webhook duplicate delivery deduplicated
10. webhook malformed or invalid-auth rejected
11. audit-persistence gate enforced before final acknowledgment or result completion

These are contract categories. Concrete repos may expand the suite, but must not weaken these checks.

## Scope decision for existing kyc_port.py

Target file already exists: `services/kyc/kyc_port.py`.

This contract spec is NOT blanket permission to overwrite `services/kyc/**`.

Default intended rollout scope:
- primary write target: `services/kyc/kyc_port.py`
- companion read-only context: `services/kyc/factory.py`, `services/kyc/mock_kyc_workflow.py`

Any change beyond `services/kyc/kyc_port.py` requires a separate diff-based justification.

Rollout mode is:
- contract-align existing port
- not greenfield replace
- not broad directory rewrite

This distinction is mandatory because the target service already has working code and factory rollout must not erase existing behavior blindly.

## Rollout constraints for factory

The factory should consume this spec from `banxe-architecture` main only after it is merged there.

Factory rollout against `banxe-emi-stack` must:
- treat `services/kyc/kyc_port.py` as the only default write target
- read neighboring files only for compatibility context
- preserve Python port style already present in the service tree
- generate a diff that can be reviewed as contract alignment, not speculative rewrite
- avoid touching unrelated KYC service files unless explicitly authorized by a later spec or operator instruction

## Exit criteria

This spec is complete when:
- the KYC contract is fully expressed in Python port canon
- webhook semantics remain aligned with ADR-034 behavior
- idempotency and replay rules are explicit
- the 11-test conformance model is preserved
- the scope decision for existing `kyc_port.py` is unambiguous
- Central can merge this file into `banxe-architecture` main and use it as the canonical source for KYC factory rollout
