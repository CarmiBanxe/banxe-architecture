#!/usr/bin/env python3
"""
scripts/import_archimate.py — ArchiMate Model Import Pipeline
S13-00 | banxe-architecture

Parses Archi exports (Open Exchange XML + CSV) and generates:
  archimate/parsed/elements.json        — all elements with types
  archimate/parsed/relations.json       — all relationships
  archimate/parsed/views.json           — all views with contents
  archimate/parsed/SERVICE-MAP-GENERATED.md — auto-generated service map

ArchiMate type → banxe-emi-stack domain mapping:
  ApplicationComponent → services/ modules
  BusinessProcess      → workflows
  TechnologyService    → infrastructure (Docker, GMKtec)
  DataObject           → models/ (Pydantic)

Usage:
    python3 scripts/import_archimate.py [--xml PATH] [--csv-dir PATH] [--output-dir PATH]
    make import-archimate

FCA compliance: no external calls, no secrets, pure local file processing.
"""

from __future__ import annotations

import argparse
import csv
import json
import logging
from pathlib import Path
from typing import Any

logger = logging.getLogger("banxe.archimate.importer")

# ── ArchiMate 3.0 Open Exchange namespace ────────────────────────────────────
_ARCHIMATE_NS = "http://www.opengroup.org/xsd/archimate/3.0/"
_NS = {"a": _ARCHIMATE_NS}

# ── ArchiMate type → banxe domain mapping ────────────────────────────────────
ARCHIMATE_TYPE_TO_DOMAIN: dict[str, str] = {
    "ApplicationComponent": "services",
    "ApplicationFunction": "services",
    "ApplicationService": "api",
    "ApplicationInterface": "api",
    "BusinessProcess": "workflows",
    "BusinessFunction": "workflows",
    "BusinessService": "workflows",
    "BusinessRole": "roles",
    "BusinessActor": "roles",
    "TechnologyService": "infrastructure",
    "TechnologyFunction": "infrastructure",
    "Node": "infrastructure",
    "SystemSoftware": "infrastructure",
    "DataObject": "models",
    "Artifact": "models",
    "ConstraintElement": "compliance",
    "Requirement": "compliance",
    "Principle": "compliance",
}

# ── Default paths ─────────────────────────────────────────────────────────────
_REPO_ROOT = Path(__file__).resolve().parent.parent
_XML_DEFAULT = _REPO_ROOT / "archimate" / "banxe-model.xml"
_CSV_DEFAULT = _REPO_ROOT / "archimate" / "csv"
_OUTPUT_DEFAULT = _REPO_ROOT / "archimate" / "parsed"


# ── XML Parser ────────────────────────────────────────────────────────────────


def parse_xml(xml_path: Path) -> dict[str, Any]:
    """
    Parse ArchiMate Open Exchange XML file.

    Returns dict with keys: elements, relationships, views, property_definitions
    """
    from lxml import etree  # type: ignore[import-untyped]

    if not xml_path.exists():
        logger.warning("XML model not found at %s — returning empty model", xml_path)
        return {"elements": [], "relationships": [], "views": [], "property_definitions": []}

    tree = etree.parse(str(xml_path))  # noqa: S320
    root = tree.getroot()

    elements = _parse_elements(root)
    relationships = _parse_relationships(root)
    views = _parse_views(root)
    prop_defs = _parse_property_definitions(root)

    logger.info(
        "XML parsed: %d elements, %d relationships, %d views",
        len(elements),
        len(relationships),
        len(views),
    )
    return {
        "elements": elements,
        "relationships": relationships,
        "views": views,
        "property_definitions": prop_defs,
    }


def _parse_elements(root: Any) -> list[dict[str, Any]]:
    """Extract all elements from the model."""
    results: list[dict[str, Any]] = []
    elements_node = root.find("a:elements", _NS)
    if elements_node is None:
        return results

    for elem in elements_node.findall("a:element", _NS):
        identifier = elem.get("identifier", "")
        elem_type = elem.get("{http://www.w3.org/2001/XMLSchema-instance}type", "")
        # Strip namespace prefix if present (xsi:type may include ns prefix)
        if ":" in elem_type:
            elem_type = elem_type.split(":")[-1]

        name_node = elem.find("a:name", _NS)
        name = name_node.text if name_node is not None else ""

        doc_node = elem.find("a:documentation", _NS)
        documentation = doc_node.text if doc_node is not None else ""

        properties = _parse_element_properties(elem)

        banxe_domain = ARCHIMATE_TYPE_TO_DOMAIN.get(elem_type, "unknown")

        results.append(
            {
                "id": identifier,
                "type": elem_type,
                "name": name,
                "documentation": documentation,
                "banxe_domain": banxe_domain,
                "properties": properties,
            }
        )

    return results


def _parse_element_properties(elem: Any) -> dict[str, str]:
    """Extract properties from an element node."""
    props: dict[str, str] = {}
    props_node = elem.find("a:properties", _NS)
    if props_node is None:
        return props

    for prop in props_node.findall("a:property", _NS):
        prop_ref = prop.get("propertyDefinitionRef", "")
        val_node = prop.find("a:value", _NS)
        if val_node is not None and val_node.text:
            props[prop_ref] = val_node.text

    return props


def _parse_relationships(root: Any) -> list[dict[str, Any]]:
    """Extract all relationships."""
    results: list[dict[str, Any]] = []
    rels_node = root.find("a:relationships", _NS)
    if rels_node is None:
        return results

    for rel in rels_node.findall("a:relationship", _NS):
        identifier = rel.get("identifier", "")
        rel_type = rel.get("{http://www.w3.org/2001/XMLSchema-instance}type", "")
        if ":" in rel_type:
            rel_type = rel_type.split(":")[-1]

        source = rel.get("source", "")
        target = rel.get("target", "")

        name_node = rel.find("a:name", _NS)
        name = name_node.text if name_node is not None else ""

        results.append(
            {
                "id": identifier,
                "type": rel_type,
                "source": source,
                "target": target,
                "name": name,
            }
        )

    return results


def _parse_views(root: Any) -> list[dict[str, Any]]:
    """Extract all views (diagrams)."""
    results: list[dict[str, Any]] = []
    views_root = root.find("a:views", _NS)
    if views_root is None:
        return results

    diagrams = views_root.find("a:diagrams", _NS)
    if diagrams is None:
        return results

    for view in diagrams.findall("a:view", _NS):
        identifier = view.get("identifier", "")
        view_type = view.get("{http://www.w3.org/2001/XMLSchema-instance}type", "")

        name_node = view.find("a:name", _NS)
        name = name_node.text if name_node is not None else ""

        nodes = [
            {
                "id": node.get("identifier", ""),
                "elementRef": node.get("elementRef", ""),
                "type": node.get("type", ""),
            }
            for node in view.findall("a:node", _NS)
        ]

        results.append(
            {
                "id": identifier,
                "type": view_type,
                "name": name,
                "nodes": nodes,
                "node_count": len(nodes),
            }
        )

    return results


def _parse_property_definitions(root: Any) -> list[dict[str, str]]:
    """Extract property definitions."""
    results: list[dict[str, str]] = []
    prop_defs = root.find("a:propertyDefinitions", _NS)
    if prop_defs is None:
        return results

    for pd in prop_defs.findall("a:propertyDefinition", _NS):
        identifier = pd.get("identifier", "")
        pd_type = pd.get("type", "string")
        name_node = pd.find("a:name", _NS)
        name = name_node.text if name_node is not None else ""
        results.append({"id": identifier, "type": pd_type, "name": name})

    return results


# ── CSV Parser ────────────────────────────────────────────────────────────────


def parse_csv(csv_dir: Path) -> dict[str, Any]:
    """
    Parse Archi CSV export directory.

    Archi exports 3 files: elements.csv, relations.csv, properties.csv
    Returns dict with same structure as parse_xml() for compatibility.
    """
    elements_path = csv_dir / "elements.csv"
    relations_path = csv_dir / "relations.csv"
    properties_path = csv_dir / "properties.csv"

    elements: list[dict[str, Any]] = []
    if elements_path.exists():
        elements = _parse_csv_elements(elements_path)

    relationships: list[dict[str, Any]] = []
    if relations_path.exists():
        relationships = _parse_csv_relations(relations_path)

    # Merge properties into elements
    if properties_path.exists():
        _merge_csv_properties(elements, properties_path)

    logger.info(
        "CSV parsed: %d elements, %d relationships",
        len(elements),
        len(relationships),
    )
    return {
        "elements": elements,
        "relationships": relationships,
        "views": [],
        "property_definitions": [],
    }


def _parse_csv_elements(path: Path) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    with path.open(encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            elem_type = row.get("Type", "")
            banxe_domain = ARCHIMATE_TYPE_TO_DOMAIN.get(elem_type, "unknown")
            results.append(
                {
                    "id": row.get("ID", ""),
                    "type": elem_type,
                    "name": row.get("Name", ""),
                    "documentation": row.get("Documentation", ""),
                    "banxe_domain": banxe_domain,
                    "properties": {},
                }
            )
    return results


def _parse_csv_relations(path: Path) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    with path.open(encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            results.append(
                {
                    "id": row.get("ID", ""),
                    "type": row.get("Type", ""),
                    "source": row.get("Source", ""),
                    "target": row.get("Target", ""),
                    "name": row.get("Name", ""),
                }
            )
    return results


def _merge_csv_properties(elements: list[dict[str, Any]], path: Path) -> None:
    """Merge properties.csv data into elements list."""
    prop_map: dict[str, dict[str, str]] = {}
    with path.open(encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            elem_id = row.get("ID", "")
            key = row.get("Key", "")
            value = row.get("Value", "")
            if elem_id and key:
                prop_map.setdefault(elem_id, {})[key] = value

    for elem in elements:
        if elem["id"] in prop_map:
            elem["properties"].update(prop_map[elem["id"]])


# ── Output generators ─────────────────────────────────────────────────────────


def write_json_outputs(model: dict[str, Any], output_dir: Path) -> list[Path]:
    """Write elements.json, relations.json, views.json to output_dir."""
    output_dir.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []

    for key, filename in [
        ("elements", "elements.json"),
        ("relationships", "relations.json"),
        ("views", "views.json"),
    ]:
        path = output_dir / filename
        with path.open("w", encoding="utf-8") as f:
            json.dump(model[key], f, indent=2, ensure_ascii=False)
        written.append(path)
        logger.info("Wrote %s (%d items)", path, len(model[key]))

    return written


def generate_service_map(model: dict[str, Any], output_dir: Path) -> Path:
    """
    Generate SERVICE-MAP-GENERATED.md from ArchiMate elements.

    Groups by banxe_domain and lists elements per domain.
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    path = output_dir / "SERVICE-MAP-GENERATED.md"

    # Group elements by domain
    domains: dict[str, list[dict[str, Any]]] = {}
    for elem in model["elements"]:
        domain = elem.get("banxe_domain", "unknown")
        domains.setdefault(domain, []).append(elem)

    # Build relationship index for summary
    rel_counts: dict[str, int] = {}
    for rel in model["relationships"]:
        rel_counts[rel["type"]] = rel_counts.get(rel["type"], 0) + 1

    lines: list[str] = [
        "# SERVICE-MAP-GENERATED.md",
        "<!-- AUTO-GENERATED by scripts/import_archimate.py — DO NOT EDIT -->",
        "<!-- Source: archimate/banxe-model.xml -->",
        "",
        "## Banxe EMI Architecture — Service Map",
        "",
        f"Generated from ArchiMate model | Elements: {len(model['elements'])} | "
        f"Relationships: {len(model['relationships'])} | Views: {len(model['views'])}",
        "",
    ]

    # Domain sections
    domain_order = [
        "api", "services", "workflows", "infrastructure",
        "models", "compliance", "roles", "unknown"
    ]
    for domain in domain_order:
        elems = domains.get(domain, [])
        if not elems:
            continue
        lines.append(f"## {domain.title()}")
        lines.append("")
        lines.append("| Name | Type | Module/Host | Status |")
        lines.append("|------|------|-------------|--------|")
        for elem in sorted(elems, key=lambda e: e["name"]):
            props = elem.get("properties", {})
            module = (
                props.get("banxe-module")
                or props.get("banxe-host")
                or ""
            )
            status = props.get("banxe-status", "")
            lines.append(
                f"| {elem['name']} | {elem['type']} | `{module}` | {status} |"
            )
        lines.append("")

    # Relationships summary
    if rel_counts:
        lines.append("## Relationships")
        lines.append("")
        lines.append("| Type | Count |")
        lines.append("|------|-------|")
        for rel_type, count in sorted(rel_counts.items(), key=lambda x: -x[1]):
            lines.append(f"| {rel_type} | {count} |")
        lines.append("")

    # Views summary
    if model["views"]:
        lines.append("## Views (Diagrams)")
        lines.append("")
        for view in model["views"]:
            lines.append(f"- **{view['name']}** — {view['node_count']} nodes")
        lines.append("")

    with path.open("w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    logger.info("Wrote SERVICE-MAP-GENERATED.md (%d elements)", len(model["elements"]))
    return path


def validate_service_map(model: dict[str, Any], service_map_path: Path) -> list[str]:
    """
    Validate that elements in SERVICE-MAP.md are in the ArchiMate model.

    Returns list of validation errors. Empty list = all good.
    """
    if not service_map_path.exists():
        return [f"SERVICE-MAP.md not found at {service_map_path}"]

    element_names = {e["name"].lower() for e in model["elements"]}
    errors: list[str] = []

    with service_map_path.open(encoding="utf-8") as f:
        content = f.read()

    # Simple heuristic: find lines with | ... | pattern (markdown table rows)
    import re

    for line in content.splitlines():
        m = re.match(r"\|\s*\*?\*?([A-Za-z][^|*]+?)\*?\*?\s*\|", line)
        if m:
            name = m.group(1).strip()
            if name and not name.startswith("-") and name.lower() not in element_names:
                # Only warn — SERVICE-MAP may have more entries than the model
                errors.append(f"Service '{name}' found in SERVICE-MAP.md but not in ArchiMate model")

    return errors


# ── Merged model (XML + CSV) ──────────────────────────────────────────────────


def load_model(xml_path: Path, csv_dir: Path) -> dict[str, Any]:
    """
    Load model from XML (primary) with CSV fallback/merge.

    XML is authoritative when it exists. CSV fills in gaps.
    """
    xml_model = parse_xml(xml_path)
    csv_model = parse_csv(csv_dir)

    if xml_model["elements"]:
        # XML has data — use it as primary, merge any CSV-only elements
        xml_ids = {e["id"] for e in xml_model["elements"]}
        csv_only = [e for e in csv_model["elements"] if e["id"] not in xml_ids]
        if csv_only:
            logger.info("Merging %d CSV-only elements not in XML", len(csv_only))
            xml_model["elements"].extend(csv_only)
        return xml_model

    # XML empty — use CSV
    logger.info("XML model empty, using CSV data")
    return csv_model


# ── CLI entry point ───────────────────────────────────────────────────────────


def main() -> int:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s [archimate] %(message)s")

    parser = argparse.ArgumentParser(
        description="Import ArchiMate model → JSON + SERVICE-MAP (S13-00)"
    )
    parser.add_argument(
        "--xml", type=Path, default=_XML_DEFAULT, help="Path to Open Exchange XML"
    )
    parser.add_argument(
        "--csv-dir", type=Path, default=_CSV_DEFAULT, help="Path to Archi CSV export directory"
    )
    parser.add_argument(
        "--output-dir", type=Path, default=_OUTPUT_DEFAULT, help="Output directory for parsed files"
    )
    parser.add_argument(
        "--validate", action="store_true", help="Validate against SERVICE-MAP.md after import"
    )
    parser.add_argument(
        "--service-map", type=Path,
        default=_REPO_ROOT / "SERVICE-MAP.md",
        help="Path to SERVICE-MAP.md for validation",
    )
    args = parser.parse_args()

    model = load_model(args.xml, args.csv_dir)

    if not model["elements"]:
        logger.error("No elements found — check XML and CSV paths")
        return 1

    written = write_json_outputs(model, args.output_dir)
    svc_map_path = generate_service_map(model, args.output_dir)
    written.append(svc_map_path)

    print(f"✅ ArchiMate import complete — {len(written)} files written to {args.output_dir}/")
    for p in written:
        rel = p.relative_to(_REPO_ROOT)
        count = len(json.loads(p.read_text())) if p.suffix == ".json" else "md"
        print(f"   {rel}  ({count})")

    if args.validate:
        errors = validate_service_map(model, args.service_map)
        if errors:
            print(f"\n⚠️  Validation warnings ({len(errors)}):")
            for e in errors[:10]:
                print(f"   {e}")
        else:
            print("\n✅ Validation passed — SERVICE-MAP.md consistent with ArchiMate model")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
