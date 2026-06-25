# Makefile — banxe-architecture
# S13-00 | ArchiMate Import Pipeline
#
# Usage:
#   make import-archimate       — parse banxe-model.xml + CSV → JSON + SERVICE-MAP
#   make validate-archimate     — validate SERVICE-MAP.md matches ArchiMate model
#   make import-validate        — import + validate in one step
#   make clean-archimate        — remove generated files (archimate/parsed/)

.PHONY: import-archimate validate-archimate import-validate clean-archimate help

PYTHON     := python3
IMPORT_SCR := scripts/import_archimate.py
XML_PATH   := archimate/banxe-model.xml
CSV_DIR    := archimate/csv
OUTPUT_DIR := archimate/parsed
SVC_MAP    := SERVICE-MAP.md

# ── Import ────────────────────────────────────────────────────────────────────

import-archimate:
	@echo "▶ Importing ArchiMate model..."
	$(PYTHON) $(IMPORT_SCR) \
		--xml $(XML_PATH) \
		--csv-dir $(CSV_DIR) \
		--output-dir $(OUTPUT_DIR)
	@echo "✅ Import complete — see $(OUTPUT_DIR)/"

# ── Validate ──────────────────────────────────────────────────────────────────

validate-archimate:
	@echo "▶ Validating ArchiMate model vs SERVICE-MAP.md..."
	$(PYTHON) $(IMPORT_SCR) \
		--xml $(XML_PATH) \
		--csv-dir $(CSV_DIR) \
		--output-dir $(OUTPUT_DIR) \
		--validate \
		--service-map $(SVC_MAP)

# ── Import + Validate ─────────────────────────────────────────────────────────

import-validate: import-archimate validate-archimate
	@echo "✅ Import + validation complete"

# ── Clean ─────────────────────────────────────────────────────────────────────

clean-archimate:
	@echo "▶ Removing generated files..."
	rm -rf $(OUTPUT_DIR)
	@echo "✅ Cleaned $(OUTPUT_DIR)/"

# ── Help ──────────────────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "Banxe Architecture — ArchiMate Pipeline"
	@echo ""
	@echo "  make import-archimate    Parse XML/CSV → JSON + SERVICE-MAP-GENERATED.md"
	@echo "  make validate-archimate  Check SERVICE-MAP.md vs ArchiMate model"
	@echo "  make import-validate     Run both in sequence"
	@echo "  make clean-archimate     Remove archimate/parsed/"
	@echo ""
	@echo "  Export from Archi:"
	@echo "    File → Export → Open Exchange XML → archimate/banxe-model.xml"
	@echo "    File → Export → CSV → archimate/csv/"
	@echo ""

# ── Training runner (S-FAC-63, R2) ──
#   make train         → scripts/train.sh run     (T0 scaffold, host-aware)
#   make train-dry     → scripts/train.sh dry-run (validate matrix↔passports, no writes)
#   make train-verify  → scripts/train.sh verify  (gate: mandatory skill ⇒ passport binding)
.PHONY: train train-dry train-verify

train:
	@bash scripts/train.sh run

train-dry:
	@bash scripts/train.sh dry-run

train-verify:
	@bash scripts/train.sh verify

# ── Factory status report («ОТЧЁТ ФАБРИКИ») — S executable collector ──
#   make report          → scripts/factory-report.sh (RU text, read-only audit)
#   make report-json     → scripts/factory-report.sh --json (machine-readable)
#   make report-self-test→ scripts/factory-report.sh --self-test (hermetic, no host)
.PHONY: report report-json report-self-test

report:
	@bash scripts/factory-report.sh

report-json:
	@bash scripts/factory-report.sh --json

report-self-test:
	@bash scripts/factory-report.sh --self-test

# ── Skills-binding audit (read-only proposals; no passport mutation) ──
#   make skills-audit            → scripts/skills-bind-audit.sh (RU text proposals)
#   make skills-audit-json       → scripts/skills-bind-audit.sh --json
#   make skills-audit-self-test  → scripts/skills-bind-audit.sh --self-test (hermetic)
.PHONY: skills-audit skills-audit-json skills-audit-self-test

skills-audit:
	@bash scripts/skills-bind-audit.sh

skills-audit-json:
	@bash scripts/skills-bind-audit.sh --json

skills-audit-self-test:
	@bash scripts/skills-bind-audit.sh --self-test

# ── DORA metrics (repo-derived proxy; read-only; live infra AWAITS OPERATOR) ──
#   make dora            → scripts/dora-collect.sh (RU text, D-1..D-4 vs targets)
#   make dora-json       → scripts/dora-collect.sh --json
#   make dora-self-test  → scripts/dora-collect.sh --self-test (hermetic, synthetic)
.PHONY: dora dora-json dora-self-test

dora:
	@bash scripts/dora-collect.sh

dora-json:
	@bash scripts/dora-collect.sh --json

dora-self-test:
	@bash scripts/dora-collect.sh --self-test

# ── Model Risk Management validator (read-only; thresholds/classification AWAITS OPERATOR) ──
#   make mrm            → scripts/mrm-validate.sh (RU text, per-tier card coverage)
#   make mrm-json       → scripts/mrm-validate.sh --json
#   make mrm-self-test  → scripts/mrm-validate.sh --self-test (hermetic)
.PHONY: mrm mrm-json mrm-self-test

mrm:
	@bash scripts/mrm-validate.sh

mrm-json:
	@bash scripts/mrm-validate.sh --json

mrm-self-test:
	@bash scripts/mrm-validate.sh --self-test

# ── Quality gate (repo-local; code-metric KPIs DELEGATED → project CI) ──
#   make quality            → scripts/quality-gate.sh (RU text; local gates + delegated/awaits)
#   make quality-json       → scripts/quality-gate.sh --json
#   make quality-self-test  → scripts/quality-gate.sh --self-test (hermetic)
.PHONY: quality quality-json quality-self-test

quality:
	@bash scripts/quality-gate.sh

quality-json:
	@bash scripts/quality-gate.sh --json

quality-self-test:
	@bash scripts/quality-gate.sh --self-test
