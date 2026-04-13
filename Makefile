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
