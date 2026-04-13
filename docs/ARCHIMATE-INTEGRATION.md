# ArchiMate Integration — banxe-architecture

## Overview

This document describes how the Banxe EMI architecture is modelled in
**Archi Tool** and imported into the `banxe-architecture` repository as
machine-readable data for agents and validators.

## Why ArchiMate?

- **Open standard** (Open Group, ISO/IEC 42010) — vendor-neutral
- **Archi Tool** is free, cross-platform, and generates Open Exchange XML
- **Machine-readable**: XML/JSON formats can be validated against the codebase
- **Three-layer view**: Business / Application / Technology (aligned with FCA SYSC)
- **Traceability**: ArchiMate elements → `services/` modules → API endpoints

## Integration pipeline

```
Archi Tool
    ↓ (File → Export → Open Exchange XML)
archimate/banxe-model.xml
    ↓
scripts/import-archimate.py
    ↓
archimate/parsed/
    ├── elements.json         → agent: look up service by name/type
    ├── relations.json        → agent: trace dependencies
    ├── views.json            → agent: which elements are on which diagram
    └── SERVICE-MAP-GENERATED.md → CI: compare with SERVICE-MAP.md
```

## Key concepts

### Element types used

| ArchiMate Layer | Type | Example |
|----------------|------|---------|
| Application | ApplicationComponent | Safeguarding Service |
| Application | ApplicationService | `GET /v1/safeguarding/position` |
| Business | BusinessProcess | Daily Reconciliation (CASS 7.15.17R) |
| Technology | TechnologyService | Midaz CBS (:8095) |
| Technology | Node | GMKtec NUC server |
| Data | DataObject | TransactionRecord (Pydantic) |
| Motivation | Principle | I-05: Decimal only for money |

### Relationship types used

| Type | Meaning |
|------|---------|
| Serving | Component X serves/calls component Y |
| Composition | Process X is composed of service Y |
| Flow | Data flows from X to Y (e.g. audit trail) |
| Realization | Service X realizes business process Y |

## Workflow

### Updating the model

1. Open `archimate/banxe-model.xml` in Archi
2. Make changes to the model
3. **File → Save** (saves native `.archimate` format)
4. **File → Export → Open Exchange XML** → overwrite `archimate/banxe-model.xml`
5. Run `make import-archimate` to regenerate parsed files
6. Commit both `banxe-model.xml` and `archimate/parsed/`

### Adding a new service

When a new service is added to `banxe-emi-stack`:
1. Add an `ApplicationComponent` element in Archi
2. Set properties: `banxe-domain`, `banxe-module`, `banxe-status`
3. Draw relationships to dependent services
4. Export and run `make import-archimate`
5. Run `make validate-archimate` — should pass

### CI integration

The `make validate-archimate` target checks that all service names in
`SERVICE-MAP.md` have a corresponding element in the ArchiMate model.
This runs in the quality gate pipeline.

## FCA traceability

ArchiMate views provide FCA-required architectural documentation:
- **CASS 7.15 view** — safeguarding + reconciliation architecture
- **SM&CR view** — IAM roles, senior manager responsibilities
- **Payment flow view** — FPS/SEPA/SEPA Instant rail architecture

These views satisfy FCA's requirement for documented architectural evidence
in support of FCA authorisation and ongoing supervision.

## Dependency: lxml

The import script requires `lxml` (already installed in the venv):
```bash
pip install lxml
```

No external services are called — pure local file processing.
