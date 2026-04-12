# ARCHITECTURE-18-COMPLIANCE-KB.md
## Banxe AI Bank — Compliance Knowledge Base Service
### RAG-Powered Regulatory Document Intelligence (IL-CKS-01)

---

## 1. Overview

The Compliance Knowledge Base (KB) is a Retrieval-Augmented Generation (RAG) service that enables AI compliance agents to search, cite, and reason over regulatory documents in real-time.

### Problem
Compliance officers and AI agents need instant access to FCA handbooks, EU AML directives, FATF recommendations, and internal SOPs during decision-making (KYC reviews, SAR generation, risk assessments).

### Solution
A semantic search engine backed by ChromaDB vector database that chunks, embeds, and indexes regulatory documents, then provides contextual answers with precise citations.

---

## 2. Architecture

```
┌─────────────────────────────────────────────┐
│              API Layer (8 endpoints)            │
│   GET health|notebooks|citations                │
│   POST query|search|compare|ingest              │
└───────────────────┬─────────────────────────┘
                    │
┌───────────────────┴─────────────────────────┐
│              KB Service (kb_service.py)           │
│   RAG query | semantic search | version compare  │
└───┬───────┬───────┬───────┬───────┬───────┬───┘
    │       │       │       │       │       │
    v       v       v       v       v       v
 Chunker  PDF    Markdown  URL   Embedding ChromaDB
 (512tok) Parser  Parser  Scraper Service  Store
```

---

## 3. Components

### 3.1 Storage Layer
| Component | Implementation | Test Double |
|-----------|---------------|-------------|
| ChromaDB Store | `ChromaDBStore` (production) | `InMemoryChromaStore` |
| Embedding Service | `SentenceTransformerEmbeddingService` | `InMemoryEmbeddingService`, `FixedEmbeddingService` |

### 3.2 Ingestion Pipeline
| Parser | Input | Technology |
|--------|-------|------------|
| PDF Parser | .pdf files | PyMuPDF + unstructured.io fallback |
| Markdown Parser | .md files | ATX + Setext heading detection |
| URL Scraper | Web pages | httpx + BeautifulSoup4 |
| Chunker | Raw text | Semantic chunking: 512 tokens, 50 overlap, section-aware |

### 3.3 Data Models (Pydantic)
```
ComplianceDocument
  ├── id, title, source_url, version, jurisdiction
  ├── content, metadata, tags
  └── chunks: list[DocumentChunk]

DocumentChunk
  ├── id, document_id, content, position
  ├── embedding: list[float]
  └── metadata: section, page, heading

Citation
  ├── document_title, section, page
  ├── relevant_text, confidence_score
  └── url, access_date

KBQueryRequest → KBQueryResult
  ├── query, notebook_filter, top_k
  └── results: list[Citation], answer, confidence
```

---

## 4. API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|--------|
| GET | `/v1/kb/health` | Service health check |
| GET | `/v1/kb/notebooks` | List all regulatory notebooks |
| GET | `/v1/kb/notebooks/{id}` | Get notebook details |
| GET | `/v1/kb/citations/{id}` | Get citation details |
| POST | `/v1/kb/query` | RAG query with answer + citations |
| POST | `/v1/kb/search` | Semantic search (no generation) |
| POST | `/v1/kb/compare` | Compare document versions |
| POST | `/v1/kb/ingest` | Ingest new documents |

---

## 5. MCP Tools (6 instruments)

Registered in `banxe_mcp/server.py` for AI agent access:

| Tool | Purpose | Used By |
|------|---------|---------|
| `kb_list_notebooks` | Browse available notebooks | All compliance agents |
| `kb_get_notebook` | Get notebook metadata | ComplianceReviewer |
| `kb_query` | RAG query with citations | KYCAgent, SARGenerator, RiskScorer |
| `kb_search` | Semantic search | TransactionMonitor, AlertAnalyzer |
| `kb_compare_versions` | Diff regulation versions | RegulatoryReporter |
| `kb_get_citations` | Fetch full citation chain | SARGenerator, MLROAssistant |

---

## 6. Regulatory Notebooks

### Configured (config/compliance_notebooks.yaml)
| Notebook | Jurisdiction | Sources |
|---------|-------------|--------|
| EU-AML | EU | 4AMLD, 5AMLD, 6AMLD, EBA guidelines, FATF recommendations |
| UK-FCA | UK | FCA Handbook, MLR 2017, POCA 2002, SYSC, SUP, COBS, CASS 15 |
| Internal-SOP | Internal | Company policies, procedures, training materials |
| Case-History | Internal | Past SAR cases, investigation templates, decision precedents |

**Total: 22 regulatory source documents indexed**

---

## 7. Integration Points

```
KYCAgent ──────┐
SARGenerator ───┤
RiskScorer ─────┤
TransactionMonitor┤───→ Compliance KB ───→ ChromaDB
AlertAnalyzer ────┤     (MCP tools)        (vectors)
MLROAssistant ────┤
ComplianceReviewer┘
```

### Use Case Examples
1. **KYC Review**: KYCAgent queries KB for latest EDD requirements by jurisdiction
2. **SAR Generation**: SARGenerator pulls POCA 2002 s.330 citation for SAR template
3. **Risk Assessment**: RiskScorer checks MLR 2017 Reg.28-33 for risk factor guidance
4. **Version Tracking**: RegulatoryReporter compares 5AMLD vs 6AMLD changes

---

## 8. Testing

| Category | Tests | Coverage |
|----------|-------|----------|
| Storage (ChromaDB) | 12 | InMemoryChromaStore |
| Embeddings | 10 | InMemory + Fixed stubs |
| Chunker | 15 | Various text lengths |
| PDF Parser | 8 | Mock PDF data |
| Markdown Parser | 10 | ATX + Setext |
| URL Scraper | 8 | httpx mock |
| KB Service (RAG) | 15 | Full integration |
| API Endpoints | 10 | FastAPI TestClient |
| **TOTAL** | **88** | **100% pass** |

---

## 9. Deployment

**Docker:** `docker/docker-compose.compliance-kb.yaml`

Services:
- `compliance-kb-api` — FastAPI service
- `chromadb` — Vector database
- Volumes: persistent ChromaDB storage

---

> Document Version: 1.0 | Created: Phase 4 | IL-CKS-01
> Last Updated: 2026-04-12 | Status: ACTIVE
> Cross-references: COMPLIANCE-FRAMEWORK.md, FEATURE-REGISTRY.md (F-011, F-012, F-014), JOB-DESCRIPTIONS.md
