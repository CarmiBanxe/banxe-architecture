# Adverse-Media Screening (EDD) — SP-OS1
> Date 2026-06-19 | Passport: agents/passports/adverse_media_governor.yaml | GAP-064

## 1. Regulatory basis
- MLR 2017 Reg.28 (Enhanced Due Diligence) — adverse-media mandatory for high-risk/PEP.
- FCA: negative-news screening as part of ongoing monitoring + onboarding EDD.

## 2. Scope (doustanovka on existing EDD)
- Reuses: aml_orchestrator, Ballerine KYC/KYB flow, EDD thresholds (aml_thresholds.py I-04 GBP10k/50k), Marble case mgmt, ClickHouse audit.
- Adds: adverse-media/negative-news screening layer (the only missing EDD component).

## 3. Components
- Feed: news + sanctions-adjacent sources (OpenSanctions dataset already self-hosted).
- Match: NLP entity match (name + DOB + jurisdiction) against customer profile.
- Trigger: run at onboarding when risk >= I-04, and on periodic re-screen.
- On hit: open Marble case, MLRO HITL gate (no auto-clear), append ClickHouse audit.

## 4. HITL / governance
- MLRO must review every adverse-media hit; AI may draft, never auto-clear.
- Audit trail append-only (I-24 style), 5y retention (DORA Art.14).

## 5. Integration points
- Ballerine workflow step: adverse-media check post-sanctions/PEP.
- Marble: adverse-media case type.
- Ties GAP-011 (KYC), GAP-012 (IDV), GAP-013 (KYB).
