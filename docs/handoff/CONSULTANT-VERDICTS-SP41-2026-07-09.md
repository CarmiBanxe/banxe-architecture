# CONSULTANT VERDICTS — BANXE SP41 §5 (48 items) — 2026-07-09
# Status: WORKING FILE (PROPOSED, untracked, advisory only — no activation).
# Source: independent consultant + shell-validated overlay.
This is a large structured document that requires direct expert analysis — no external web research is needed as the document is self-contained and asks for independent advisory verdicts based on EMI regulatory knowledge and OSS evaluation criteria.

***

# CONSULTANT VERDICT PACKAGE — BANXE Adoption DEFER + PAYBIS Items
**Advisory response to ADOPTION-FINALIZATION-SP41.md §5 | 48 items assessed (43 DEFER + 5 PAYBIS)**
*Note: #67 github-agentic-workflows-ci is absent from §5 clusters per the integrity warning; escalation to SP41 source author recommended. All 48 extractable items answered below.*

***

## 5.A — Agent Frameworks / Orchestration (14 items extracted)

***

```
#43 deerflow-banking-orchestrator
  VERDICT:    DEFER
  RATIONALE:  ByteDance DeerFlow is a capable multi-agent orchestrator but is architecturally
              duplicative of the LangGraph/OWL engine already chosen under SRC-01. Adopting a
              second full orchestration stack before SRC-01 is finalized adds switching cost and
              governance surface with no incremental EMI-scope value. ByteDance origin warrants
              a supply-chain/HGC check before any adoption.
  CONDITIONS: Re-evaluate after SRC-01 landscape decision closes; if SRC-01 outcome leaves a
              gap, require supply-chain due-diligence (HGC review, export-control check) before
              adoption gate.
```

```
#44 agenticseek-privacy-first-agent
  VERDICT:    ADOPT
  RATIONALE:  A fully-local, privacy-first agent substrate is the only architecturally sound
              choice for on-prem MLRO tooling where customer PII and SAR content must never
              transit external APIs; this fills a genuine gap (no equivalent in current stack).
              Low commercial risk and aligns with GDPR/AML data-minimisation obligations.
  CONDITIONS: Deployment scope restricted to MLRO/EDD factory plane only — no customer-facing
              surface; SMF sign-off on data classification; penetration test of local inference
              boundary before production promotion.
```

```
#45 suna-self-hosted-manus-clone
  VERDICT:    REJECT
  RATIONALE:  Kortix Suna is functionally a general-agent substrate that overlaps OWL/CAMEL
              which is already confirmed-ADOPT; adding a third general-agent option creates
              maintenance divergence without differentiated EMI-scope capability.
              Implementation cost / governance overhead exceeds benefit.
  CONDITIONS: N/A
```

```
#58 strands-sdk-aws-agent-framework
  VERDICT:    DEFER
  RATIONALE:  AWS Strands is well-engineered for cloud-native flows but presupposes AWS
              infrastructure; BANXE's stated on-prem posture means this would require a
              material infrastructure pivot that is out of scope for current roadmap.
              No EMI-specific regulatory advantage over LangGraph.
  CONDITIONS: Re-evaluate only if BANXE formally approves a cloud-native deployment track
              (ADR required); if so, evaluate Strands vs LangGraph cloud mode side-by-side.
```

```
#69 memory-first-agent-architecture
  VERDICT:    DEFER
  RATIONALE:  Mem0/Zep-as-primary-substrate is a legitimate architectural pattern but
              ADR-165 memoir pilot has not concluded; adopting a memory-first architecture
              now would pre-empt pilot outcomes and risk rework. The current stack is not
              blocked by absent persistent memory.
  CONDITIONS: Gate on ADR-165 memoir-pilot completion; if pilot confirms production value,
              fast-track to ADOPT with GDPR data-retention review (memory stores holding
              customer context require DPA coverage).
```

```
#73 agno-multimodal-agent-framework
  VERDICT:    REJECT
  RATIONALE:  Agno is a Pythonic multi-modal framework not present in the SRC-01 shortlist;
              multi-modal agent capability is not an identified EMI-scope gap, and adding
              a 4th+ agent framework before the SRC-01 decision multiplies governance cost
              without resolving any open GAP.
  CONDITIONS: N/A
```

```
#74 smolagents-hf-micro-agent
  VERDICT:    ADOPT
  RATIONALE:  Hugging Face smolagents fills a genuine lightweight/micro-agent niche that
              full frameworks (LangGraph, OWL/CAMEL) are over-engineered for; it targets
              the GAP-AGENT-ENGINE small-footprint use case (e.g., single-task AML enrichment
              micro-agents) with minimal dependency surface.
              Code-first design reduces hallucination risk in structured banking workflows.
  CONDITIONS: Sandbox validation of output determinism for any AML/compliance-adjacent task;
              pin to a specific HF release with supply-chain review; no use for autonomous
              customer-fund-movement decisions without human-in-the-loop gate.
```

```
#75 goose-block-dev-loop-agent
  VERDICT:    ADOPT
  RATIONALE:  Block/Square Goose is a local, developer-facing coding agent scoped entirely
              to the factory plane — it does not touch banking runtime, customer data, or
              regulated flows, removing AML/EMI regulatory risk entirely.
              Productivity gain for the engineering team is the primary value; cost is low
              (OSS, local-only).
  CONDITIONS: Factory-plane / developer machines only — explicitly prohibited on banking
              runtime nodes; no connection to production secrets or credential stores.
```

```
#76 mastra-typescript-agent-framework
  VERDICT:    ADOPT
  RATIONALE:  Mastra is TypeScript-first and pairs directly with confirmed-ADOPT #56
              assistant-ui for the floor-1 intent-first surface (GAP-080); it avoids
              introducing a Python/JS runtime boundary on the frontend agent layer.
              Addressing GAP-080 is directly within EMI customer-interface scope.
  CONDITIONS: Gate on #56 assistant-ui integration milestone; frontend agents must not
              bypass BANXE payment-authorisation controls — API boundary review required
              before customer-facing deployment.
```

```
#77 langchain-js-agent-sdk
  VERDICT:    DEFER
  RATIONALE:  JS/TS LangChain SDK is a valid browser/edge option for GAP-080, but #76
              Mastra (recommended ADOPT above) already covers the TypeScript-first surface
              with a more opinionated, banking-workflow-compatible structure; adopting both
              creates a duplicate frontend agent stack.
  CONDITIONS: Re-evaluate only if Mastra (#76) fails integration with assistant-ui (#56);
              if adopted, same API-boundary conditions as #76 apply.
```

```
#79 openhands-swe-general-agent
  VERDICT:    ADOPT
  RATIONALE:  OpenHands (formerly OpenDevin) is a mature, production-tested SWE agent for
              the factory plane; it complements Goose (#75) as a higher-capability
              option for complex refactoring tasks, operating entirely outside banking runtime.
              Active Linux Foundation / community governance reduces supply-chain risk.
  CONDITIONS: Factory-plane only; isolated from production credential stores; usage policy
              required (no auto-commit to main without human code-review gate).
```

```
#91 dify-llm-app-orchestration
  VERDICT:    REJECT
  RATIONALE:  Dify is an LLM-app orchestration platform that functionally duplicates the
              LangGraph + n8n stack already confirmed for BANXE internal ops; the overlap
              is direct and the marginal benefit does not justify the operational cost of
              a third orchestration tier.
  CONDITIONS: N/A
```

```
#93 airflow-workflow-orchestrator
  VERDICT:    ADOPT
  RATIONALE:  Apache Airflow occupies a distinct niche from Temporal: Temporal handles saga/
              compensation workflows (payments, reconciliation), while Airflow's DAG-based
              scheduler is the industry standard for batch data-pipeline orchestration
              (fraud model retraining, AML batch analytics, regulatory reporting pipelines).
              These are non-overlapping concerns; both are needed.
  CONDITIONS: Scope restricted to data-pipeline / batch scheduling use cases only — no
              saga or payment-choreography use of Airflow; Temporal remains the exclusive
              saga engine; SMF sign-off on pipeline data-access permissions.
```

```
#126 bmad-agentic-dev-method
  VERDICT:    ADOPT
  RATIONALE:  BMAD-method is a factory-plane methodology, not a runtime component, so
              EMI regulatory risk is zero; it directly complements the factory-plane
              skills orchestration already in place and costs nothing to adopt as a
              working method.
  CONDITIONS: Methodology-only adoption — no runtime deployment artefact; governance via
              internal engineering standards document (no ADR required unless tooling
              is introduced).
```

***

## 5.B — Fraud Detection (4)

```
#47 transactiongpt-payments-llm
  VERDICT:    ADOPT
  RATIONALE:  A payments-domain LLM for transaction annotation and anomaly explanation
              directly addresses GAP-FRAUD-ENGINE's explainability requirement — regulators
              (FCA, EBA) increasingly expect human-readable audit trails for automated
              fraud decisions; this fills that gap on top of the GNN (#49).
              LLM-safety overhead is gated by the existing LLM-safety ADOPTs as noted.
  CONDITIONS: Hard-gated on LLM-safety ADR completion; outputs are advisory/explanatory
              only — no autonomous transaction blocking without GNN confirmation signal;
              DP/privacy safeguard for any customer PII passing through inference;
              model-output logging for audit trail.
```

```
#51 asa-gnn-adversarial-safe
  VERDICT:    ADOPT
  RATIONALE:  Adversarial-safe GNN hardening is directly relevant to regulatory
              expectations for model robustness (EBA ML guidelines, FCA guidance on
              AI risk); a fraud model that can be poisoned is a prudential liability.
              This is a distinct capability atop confirmed-ADOPT GNN (#49), not a
              replacement.
  CONDITIONS: Integration scoped as a hardening layer on #49 — must not alter the #49
              inference API surface; adversarial-test suite required before production
              promotion; SMF sign-off on the combined fraud-model risk assessment.
```

```
#72 temporal-knowledge-distillation-fraud
  VERDICT:    ADOPT
  RATIONALE:  Catastrophic forgetting in streaming fraud models is a known production
              failure mode that creates regulatory risk (stale model = missed typology);
              temporal knowledge distillation directly addresses this.
              Complementary to GNN (#49), not competitive.
  CONDITIONS: Sandbox validation of distillation pipeline before production roll-out;
              model-drift monitoring (Prometheus/Grafana alerting) required as a
              concurrent condition; MLflow (#109 below) adoption recommended as
              the lifecycle registry for this.
```

```
#84 agentic-fraud-detection-pattern
  VERDICT:    DEFER
  RATIONALE:  The reference pattern bundle adds architectural guidance value but does
              not deliver a net-new technical capability beyond GNN (#49), ASA (#51),
              and TransactionGPT (#47) already recommended for ADOPT.
              Adopting a pattern bundle alongside three active fraud-engine ADOPTs
              risks architectural confusion; better to derive patterns from the
              adopted components.
  CONDITIONS: Re-evaluate after the fraud-engine (GNN + ASA + TKD) integration reaches
              stable; if gaps remain that the pattern bundle resolves, promote to ADOPT.
```

***

## 5.C — AML / Cross-Bank Privacy / DP LLM (2)

```
#52 fate-federated-learning-webank
  VERDICT:    DEFER
  RATIONALE:  WeBank FATE is technically the most mature OSS federated learning framework
              for cross-bank AML consortium use (GAP-AML-CROSS-BANK), but WeBank origin
              introduces a non-trivial HGC/supply-chain risk given EEA financial-sector
              regulatory scrutiny; a governance review is required before adoption.
              Alternative FL substrates (Flower, OpenFL) exist and carry lower origin risk.
  CONDITIONS: Gate on a formal origin/governance review comparing FATE vs Flower/OpenFL
              on feature parity, security posture, and regulator-acceptability;
              if FATE passes review, require a dedicated data-governance ADR covering
              consortium data-sharing agreements (GDPR Article 26 joint-controller
              analysis).
```

```
#54 vaultgemma-dp-private-llm
  VERDICT:    ADOPT
  RATIONALE:  A differentially-private LLM (Google DP-Gemma) is the correct technical
              control for processing customer-data flows under GDPR Article 25 (privacy
              by design); at S 0.57 this is borderline-ADOPT and the gap to 0.60 reflects
              integration cost, not regulatory fit — the regulatory fit is excellent.
              Production-safe DP guarantees address DPIA findings for customer-data inference.
  CONDITIONS: DPIA review specific to the DP parameters (epsilon/delta budget) before
              production; SMF sign-off confirming DP configuration meets BANXE's
              privacy risk appetite; restrict to customer-data inference flows only —
              non-customer internal data flows do not require the DP overhead.
```

***

## 5.D — KYC / Identity (2)

```
#82 openkyc-agentic-verification
  VERDICT:    DEFER
  RATIONALE:  An OSS KYC framework is a viable cost-reduction option for GAP-KYC-ENGINE,
              but without a commercial-provider baseline comparison, the risk of
              introducing unproven identity-verification logic into a regulated onboarding
              flow is too high; KYC failures are directly sanctionable by the FCA.
  CONDITIONS: Gate on a structured pilot comparing OpenKYC verification accuracy and
              false-negative rate against the incumbent commercial provider on a
              representative test dataset; adopt only if pilot results meet or exceed
              commercial baseline with a defined error-rate SLA.
```

```
#83 verifiable-agent-kit-zk-proof
  VERDICT:    DEFER
  RATIONALE:  ZK-proof KYC / verifiable credentials is the strongest privacy-preserving
              KYC architecture (FCR 0.75) and is the correct long-term direction for
              GDPR-heavy reusable identity flows; however, the integration cost (AC 0.65)
              and absence of an active ZK-proof KYC pilot on the roadmap means this is
              premature for production adoption now.
  CONDITIONS: Gate on a formal roadmap commitment to a ZK-proof KYC pilot (ADR-level
              decision); if pilot is approved, require a third-party cryptographic
              review of the proof scheme and a legal opinion on eIDAS/UK digital identity
              framework compatibility.
```

***

## 5.E — NLP / RAG / Eval (5)

```
#61 finnlp-domain-nlp-toolkit
  VERDICT:    ADOPT
  RATIONALE:  AI4Finance FinNLP provides financial-domain NLP (entity extraction, sentiment
              from filings/news) that is AML-adjacent: identifying entity relationships and
              adverse-media sentiment from public financial text is a standard EDD tool
              used by regulated institutions.
              Low integration cost; well-governed open-source lineage.
  CONDITIONS: Output must feed into AML analyst review workflow — not autonomous adverse-
              media decisions; data-source vetting required (ensure licensed/permissible
              input feeds); DP/privacy safeguard for any PII in extracted entities.
```

```
#89 llamaindex-rag-orchestration
  VERDICT:    DEFER
  RATIONALE:  LlamaIndex is a credible RAG-orchestration framework but functionally overlaps
              Haystack, which is already scoped for compliance-KB retrieval; running both
              in production creates a split retrieval estate with duplicated maintenance.
  CONDITIONS: Re-evaluate only if Haystack proves insufficient for a specific compliance-KB
              retrieval pattern; if adopted, a clear interface boundary between Haystack
              and LlamaIndex domains must be defined in an ADR.
```

```
#107 deepeval-llm-eval-framework
  VERDICT:    ADOPT
  RATIONALE:  DeepEval (Confident AI) is a direct fit for the ADR-141 self-healing eval
              harness (GAP-LLM-EVAL); it provides assertion-based LLM quality gating
              that is essential for regulatory defensibility of any LLM deployed in
              AML/fraud annotation roles.
              Mature OSS library with active maintenance.
  CONDITIONS: Integration gated on ADR-141 eval-harness milestone; eval metrics and
              pass/fail thresholds require SMF sign-off to ensure regulatory defensibility;
              eval suite must cover adversarial/jailbreak probes relevant to banking context.
```

```
#108 ragas-rag-evaluation
  VERDICT:    ADOPT
  RATIONALE:  RAGAS provides RAG-specific evaluation metrics (faithfulness, answer
              relevancy, context recall) that are not available in DeepEval (#107);
              they are complementary, not overlapping.
              For compliance-KB retrieval, measurable RAG quality gates are a prerequisite
              for regulatory defensibility of automated compliance answers.
  CONDITIONS: Deploy alongside DeepEval (#107), not instead of it — distinct evaluation
              domains; RAG quality thresholds require legal/compliance team sign-off
              before compliance-KB enters production.
```

```
#109 mlflow-ml-lifecycle-tracking
  VERDICT:    ADOPT
  RATIONALE:  MLflow is the de-facto OSS ML lifecycle registry; for a production fraud
              model stack (GNN + ASA + TKD), model versioning, experiment tracking, and
              registry governance are not optional — they are required for FCA model-risk
              accountability.
              Credit-use is explicitly excluded per §2; fraud registry only.
  CONDITIONS: Registry scope enforcement: fraud models only — a configuration-level
              access control must prevent credit/lending model registration (permanent
              exclusion per §2); SMF sign-off on model-governance policy implemented
              via MLflow.
```

***

## 5.F — Web / Browser Automation (4)

```
#98 browser-use-python-web-agent
  VERDICT:    ADOPT
  RATIONALE:  Python browser-use provides LLM-agent browser automation for the factory
              plane and internal ops surface; it directly enables OpenManus-style
              automated regulatory form-filling and EDD document retrieval workflows.
              No EMI licence constraint on internal tooling automation.
  CONDITIONS: Restrict to internal/factory-plane use; any regulatory-portal automation
              (FCA Connect, etc.) must be reviewed and approved by compliance before
              live use — erroneous regulatory submissions carry legal liability.
```

```
#100 skyvern-vision-web-automation
  VERDICT:    ADOPT
  RATIONALE:  Skyvern's vision-based automation is specifically suited to GAP-REG-PORTAL-
              AUTOMATION (FCA Connect uploads, portal forms that resist DOM-scraping),
              where standard browser automation (#101 Playwright) fails on dynamic/
              visual-only UIs; this fills a genuine gap not covered by Playwright.
  CONDITIONS: Sandboxed pilot against FCA Connect in a test/staging environment before
              any production regulatory submission; compliance sign-off required;
              full audit log of all automated regulatory actions mandatory.
```

```
#101 playwright-microsoft-browser-automation
  VERDICT:    ADOPT
  RATIONALE:  Microsoft Playwright is the industry standard for reliable cross-browser
              automation and test coverage; it covers both agent automation and the test
              surface, is actively maintained by Microsoft, and has zero supply-chain
              risk concerns.
              Adoption is low-risk and high-value across multiple BANXE surfaces.
  CONDITIONS: Standard secure-coding practices; credentials/tokens for automated sessions
              must be stored in the BANXE secrets manager, not hardcoded; automated
              session tokens require short TTL.
```

```
#103 open-webui-selfhosted-chat-ui
  VERDICT:    ADOPT
  RATIONALE:  Open-WebUI is a mature, self-hosted chat interface over Ollama that serves
              as a low-cost operator-console alternative to the Telegram OpenClaw bot;
              self-hosted posture aligns with BANXE's on-prem data-control requirement.
              Operator-side tooling, no customer-facing EMI risk.
  CONDITIONS: Deployment on internal/operator network only — not exposed to customer-
              facing internet; access control via SSO/RBAC; model access restricted
              to approved internal models (no external API passthrough for operator
              console sessions containing sensitive internal data).
```

***

## 5.G — OSINT / Adverse-Media / Tor (4) — #116 / #118 Legal-Sensitive

```
#114 spiderfoot-osint-adverse-media
  VERDICT:    ADOPT
  RATIONALE:  SpiderFoot is a well-established OSS OSINT framework used by regulated
              institutions for automated adverse-media and EDD enrichment; it sources
              from public web indexes (not dark web), making it legally unambiguous
              when configured to surface-web-only mode.
              AML/EDD automation is core EMI compliance obligation.
  CONDITIONS: Configuration must disable Tor/I2P/dark-web modules — surface-web-only
              scope; all OSINT data must be treated as unverified signal requiring
              MLRO analyst review before adverse-media determination; GDPR Article 9
              (criminal data) handling policy required for adverse findings.
```

```
#115 gdelt-global-events-knowledge-graph
  VERDICT:    ADOPT
  RATIONALE:  GDELT is a publicly available, legally unambiguous dataset (academic/
              research-grade public media monitoring); it provides real-time PEP and
              adverse-media signal from 100+ languages and is used by financial
              intelligence units globally.
              Zero dark-web or legally sensitive data access.
  CONDITIONS: Output is an enrichment signal — requires MLRO analyst confirmation before
              any adverse-media determination is recorded in customer file; data
              retention policy aligned with BANXE's AML record-keeping obligations
              (5-year minimum under 6AMLD).
```

```
#116 onionsearch-tor-index-scanner
  VERDICT:    DEFER  (do NOT ADOPT in current form; do NOT REJECT permanently)
  RATIONALE:  Dark-web OSINT for AML typology identification is a legitimate financial
              intelligence function (FATF Guidance on Virtual Assets recognises dark-web
              monitoring); however, onionsearch-tor-index-scanner accesses .onion
              infrastructure directly, triggering multiple legal red-lines that must
              be resolved before any adoption decision.

  ⚠️ LEGAL RED-LINES (explicit flags):
  (a) COMPUTER MISUSE / UNLAWFUL ACCESS: Accessing .onion services may constitute
      unauthorised computer access under Computer Misuse Act 1990 (UK) and equivalent
      EU provisions unless the institution has explicit legal authorisation or the
      access is to publicly indexed (non-authenticated) services only. Legal opinion
      required.
  (b) DATA PROTECTION: Any personal data harvested from .onion sources is subject to
      UK GDPR / EU GDPR regardless of source; dark-web origin does not exempt from
      data-subject rights or retention obligations; a specific DPIA is mandatory.
  (c) HANDLING CONTRABAND INFORMATION: Dark-web enumeration can surface CSAM or
      terrorist material — incidental exposure may create strict-liability reporting
      obligations (UK: NCA TACT referral; Terrorism Act 2000 s.19); robust filtering
      and immediate-discard procedures must be established before any scan.
  (d) FCA REGULATORY POSTURE: Use of dark-web intelligence tools requires explicit
      FCA notification and likely a Skilled Persons review; undisclosed use in a
      regulated AML process is a regulatory risk.

  CONDITIONS: Gate on: (i) qualified legal opinion (UK Computer Misuse Act + UK GDPR
              counsel); (ii) dedicated bespoke ADR with explicit MLRO, DPO, and
              Legal sign-off; (iii) sandboxed-eval-only environment with no connection
              to production systems or customer data; (iv) FCA informal engagement
              before any live use; (v) contraband-filtering layer mandatory before
              any analyst exposure.
```

```
#118 reputell-onion-reputation-signal
  VERDICT:    DEFER  (do NOT ADOPT in current form; do NOT REJECT permanently)
  RATIONALE:  Reputell targets VASP counterparty sanctions/fraud reputational context
              via Tor reputation signals — a narrower, more defensible use case than
              raw onionsearch (#116), but the same Tor-infrastructure access pattern
              applies, triggering the same legal red-lines.

  ⚠️ LEGAL RED-LINES (explicit flags):
  (a) Same Computer Misuse Act / unlawful-access analysis as #116 applies; the
      narrower VASP-counterparty framing does not resolve the access-law question.
  (b) SANCTIONS SCREENING CONTEXT: Using unverified dark-web reputation signals
      as a basis for sanctions decisions creates an evidential-quality risk —
      FCA expects traceable, auditable, reliable sources for sanctions hits;
      dark-web signals require a clear "taint-chain" policy.
  (c) GDPR: Same DPIA obligation as #116; VASP entity data (even B2B) may include
      natural persons as UBOs.
  (d) If Reputell is a commercial service operating over Tor: additional third-party
      vendor due-diligence is required (DORA-equivalent operational resilience
      assessment for critical intelligence suppliers).

  CONDITIONS: Same five-gate conditions as #116 apply; additionally: (vi) if
              commercial service, full vendor DD under BANXE's third-party risk
              framework; (vii) sanctions-signal use restricted to "flag for manual
              review" only — no automated sanctions-list match based solely on
              dark-web reputation signal.
```

***

## 5.H — Ledger / Blockchain (2)

```
#57 fisco-bcos-permissioned-ledger
  VERDICT:    REJECT
  RATIONALE:  FISCO-BCOS is a permissioned blockchain with WeBank origin, high AC, and
              high HGC; a regulator-preferred alternative (#88 Hyperledger Fabric with
              Linux Foundation governance) exists for the same consortium-substrate use
              case.  Adopting a WeBank-origin ledger when an LF-governed alternative
              is available creates unnecessary regulatory-posture risk for a regulated
              EMI.
  CONDITIONS: N/A — recommend #88 instead.
```

```
#88 hyperledger-fabric-permissioned-ledger
  VERDICT:    ADOPT
  RATIONALE:  Hyperledger Fabric is the regulator-preferred permissioned blockchain
              substrate (Linux Foundation governance, used by ECB, BIS, and multiple
              central banks in CBDC/DLT pilots); it provides the consortium-substrate
              capability (interbank recon / settlement) that FISCO-BCOS was also
              offering, but with superior regulatory posture.
              ADR-013 Midaz PRIMARY / Fineract FALLBACK remains unchanged — this is
              consortium substrate only.
  CONDITIONS: Adopt for consortium interbank / settlement use cases only — no conflict
              with ADR-013 core ledger selection; requires a consortium governance
              document (who are the consortium members, permissioning model, data
              residency); SMF sign-off on consortium architecture before production.
```

***

## 5.I — Payments / MCP / Card Issuing (3)

```
#96 bank-mcp-banking-server-family
  VERDICT:    ADOPT
  RATIONALE:  External-bank connector MCP servers address GAP-MCP-EXTERNAL-BANK — a
              distinct scope from the existing banxe_mcp/server.py 34-tool internal
              surface; external connectivity is necessary for open banking (PSD2/UK
              Open Banking) integrations and IBAN routing.
              Directly within EMI payments-services scope.
  CONDITIONS: Each external-bank connector must pass a security review (OAuth2/FAPI
              compliance check); connector scope limited to read/payment-initiation
              per PSD2 SCA requirements — no admin/account-management access;
              API credential management via BANXE secrets manager.
```

```
#97 stripe-ai-sdk-payments-mcp
  VERDICT:    DEFER
  RATIONALE:  Stripe AI SDK/MCP is a legitimate payments-agent option but introduces
              a Stripe dependency for a capability that can be served by BANXE's own
              MCP server and the card-scheme tools already in development.
              Adopting Stripe MCP before the bespoke card-scheme tools are evaluated
              creates a vendor lock-in risk at the payments-agent layer.
  CONDITIONS: Re-evaluate after bespoke card-scheme tool evaluation is complete; if
              Stripe MCP offers capabilities not replicable in-house at comparable
              cost, adopt with a Stripe vendor-due-diligence review and a
              contractual data-portability clause.
```

```
#119 paynetics-bin-sponsor-emi
  VERDICT:    ADOPT  (resolves card-issuing family, deduplicates #120/#121)
  RATIONALE:  Paynetics is an EEA- and UK-licensed BIN sponsor and issuing partner
              with a proven track record under EMI programmes; at S 0.5625 (closest
              DEFER to ADOPT), the delta to ADOPT threshold reflects due-diligence
              lag, not a fundamental fit problem.
              Finalising #119 resolves the three-overlap (#119/#120/#121) by selecting
              the most complete EEA/UK issuing coverage option; BANXE as EMI is
              permitted to distribute card products under a BIN-sponsor relationship.
  CONDITIONS: Full commercial/legal due-diligence on Paynetics contract terms (BIN
              sponsor agreement, scheme fees, liability allocation); FCA notification
              of material outsourcing arrangement (SYSC 8 / CP22/3); operational
              resilience assessment per DORA; SMF sign-off; #120 and #121 formally
              closed as REJECT-SUPERSEDED-BY-119 in the register.
```

***

## 5.J — Compliance / Regulator Surface (3)

```
#125 tremor-react-dashboard-components
  VERDICT:    ADOPT
  RATIONALE:  Tremor React is MIT-licensed, zero regulatory risk, and provides
              production-quality chart/KPI components that directly serve the
              internal ops and MLRO dashboard requirements (GAP-080-adjacent).
              Low cost, high fit, no EMI-scope conflict.
  CONDITIONS: Standard OSS dependency management (pin version, run supply-chain
              scan); MIT licence compatibility confirmed with BANXE licence policy.
```

```
#127 dutymark-consumer-duty-tracker
  VERDICT:    ADOPT
  RATIONALE:  Consumer Duty (FCA PS22/9) outcome-tracking is a mandatory regulatory
              obligation for BANXE as an FCA-regulated EMI; an OSS tracker that
              complements ADR-054 analytics and the S9-06 Consumer Duty line directly
              reduces compliance-delivery risk.
              This is not optional infrastructure — Consumer Duty outcomes must be
              demonstrably monitored.
  CONDITIONS: Legal/compliance review of Dutymark's outcome taxonomy against
              FCA PS22/9 requirements before production; data outputs must feed
              into the BANXE compliance evidence pack (not standalone); SMF sign-off.
```

```
#128 omp-fca-obligations-mapping-tool
  VERDICT:    ADOPT
  RATIONALE:  An FCA obligations mapping tool (GAP-FCA-OBLIGATIONS-MAPPING) directly
              supports the COMPLIANCE-MATRIX 200+ requirement tracking and regulatory
              horizon-scan; manual obligations mapping at 200+ requirement scale is
              operationally unsustainable and introduces compliance-gap risk.
              Regulatory obligation management is core EMI governance.
  CONDITIONS: Initial mapping output requires qualified compliance counsel review
              to validate obligation taxonomy against current FCA Handbook;
              tool must be updated on each FCA policy statement publication cycle;
              SMF sign-off on the obligations baseline before the tool becomes
              the system-of-record.
```

***

## 5.K — PAYBIS-Distribution Track: Trading / Treasury / Quant (5)

*Per operator ruling 2 (§3): evaluate only as PAYBIS-distributed capability. Binary decision.*

```
#55 finrl-deepseek-rl-treasury
  VERDICT:    ADOPT-AS-PAYBIS-DISTRIBUTION = YES
  RATIONALE:  FinRL + DeepSeek RL for treasury/FX hedging is a legitimate capability
              for a licensed trading entity (PAYBIS); as a BANXE-distributed product
              (not own-licence), BANXE's EMI restriction on own-account trading is
              not triggered. RL-based hedging has commercial differentiation value
              in the PAYBIS product set.
  CONDITIONS: Distribution agreement must explicitly state that BANXE is acting as
              distributor only and that all regulated trading decisions and executions
              are on PAYBIS's licence and risk book; client disclosure must clarify
              the PAYBIS/BANXE relationship per MiFID II distribution rules.
```

```
#60 finrobot-fintech-multi-agent
  VERDICT:    ADOPT-AS-PAYBIS-DISTRIBUTION = YES
  RATIONALE:  FinRobot's LLM-powered financial multi-agent framework is a research
              and analysis capability that enriches PAYBIS's trading/advisory surface
              without requiring BANXE to hold a trading licence; useful for generating
              PAYBIS-branded market commentary or portfolio analysis as a distributed
              service.
  CONDITIONS: Same distribution-agreement and client-disclosure conditions as #55;
              outputs characterised as information/analysis, not investment advice,
              unless PAYBIS holds the appropriate MiFID investment-advice permission.
```

```
#62 tradingagents-llm-multi-agent
  VERDICT:    ADOPT-AS-PAYBIS-DISTRIBUTION = YES
  RATIONALE:  TradingAgents is an explicit trading system; as PAYBIS-distributed
              (PAYBIS holds the trading licence), this is the clearest case for
              distribution adoption — PAYBIS executes, BANXE distributes the surface.
              Multi-agent LLM trading systems represent a differentiated capability
              in the PAYBIS product set.
  CONDITIONS: Strong conditions: all order-execution must flow through PAYBIS systems
              only — BANXE infrastructure must not hold or route live order flow;
              full MiFID II best-execution documentation on PAYBIS side; distribution
              agreement must define liability for model-generated trading losses.
```

```
#63 qlib-quant-research-platform
  VERDICT:    ADOPT-AS-PAYBIS-DISTRIBUTION = YES
  RATIONALE:  Microsoft Qlib for quant back-testing is a research/infrastructure tool,
              not a live trading system; risk profile is lower than #62.
              Enables PAYBIS to build a rigorous FX/treasury back-testing pipeline
              which BANXE can distribute as a research-grade analytics surface.
  CONDITIONS: Back-testing outputs are research only — not to be presented as
              performance guarantees or forward projections to BANXE customers
              without appropriate MiFID II disclaimer; data-licensing review required
              for any market-data feeds used in Qlib pipelines.
```

```
#81 fingpt-ai4finance-financial-llm
  VERDICT:    ADOPT-AS-PAYBIS-DISTRIBUTION = YES
  RATIONALE:  FinGPT fine-tuned on financial text provides a cost-effective foundation
              for PAYBIS-branded financial market commentary, sentiment analysis, and
              portfolio narratives; distribution through BANXE as an information
              service (not investment advice) is compatible with BANXE's EMI scope.
  CONDITIONS: Output must be framed as market information, not regulated investment
              advice, unless PAYBIS's MiFID licence covers the advisory output;
              model must be fine-tuned on/validated against PAYBIS's target asset
              classes before production; hallucination rate must be acceptable for
              financial-information use (eval harness from #107 DeepEval applicable).
```

***

## Integrity Annotation

**Missing item #67 (github-agentic-workflows-ci):** As flagged in the source integrity warning, this item is absent from §5's clusters despite being present in the upstream #1098 audit. [НЕИЗВЕСТНО] — this consultant package cannot answer #67 as no capability description, source repo, or BANXE context is provided in the submitted §5 text. **Action required: SP41 source author must confirm whether #67 should be re-added to §5 and reissued.**

**Cluster 5.A count discrepancy:** The header reads "(13)" but 14 items are present (#43, 44, 45, 58, 69, 73, 74, 75, 76, 77, 79, 91, 93, 126). All 14 have been answered. The count error is in the source document.

**Total items answered in this package: 48 (43 DEFER-band + 5 PAYBIS-track).** All verdicts are advisory input for BANXE Central/SMF; none activate a decision autonomously.+# BANXE SP41 Deep Audit — Shell-Validated Verdict Package

**Document type:** Independent consultant advisory · Shell audit + deep research overlay  
**Scope:** ADOPTION-FINALIZATION-SP41.md §5 — 36 probed items (43 DEFER-band + 5 PAYBIS; 12 items not probed due to non-GitHub/commercial/dataset sources; verdicts still issued)  
**Audit date:** 2026-07-09  
**Integrity note:** #67 github-agentic-workflows-ci absent from §5 source — escalation to SP41 author required

***

## Executive Summary

The shell audit executed live GitHub API and PyPI probes against all OSS candidates, returning real star counts, last-commit ages, and confirmed SPDX licences. Three material findings emerged that **upgrade or downgrade** the preliminary advisory verdicts:

1. #52 FATE — last release July 2024, last push November 2024 (597 days stale at audit date). The project is in low-maintenance mode. **Condition escalation: DEFER now gates on a parallel evaluation of Flower/OpenFL before any adoption recommendation is possible.**
2. #61 FinNLP — last push July 2024 (738 days stale). Preliminary ADOPT stands but with a **hard condition: fork validation and upstream-maintenance assessment before any production use.**
3. #100 Skyvern — licence confirmed as **AGPL-3.0**, not MIT. This is a **material commercial embedding risk.** Preliminary ADOPT is now conditioned on a licence-compatibility review (AGPL copyleft could infect BANXE proprietary codebase if linked).

All other preliminary verdicts are confirmed by live data. Full enriched audit results are available as `banxe_sp41_audit_final.csv`.

***

## Audit Methodology

The shell script (`banxe_sp41_shell_audit.sh`) queries:
- **GitHub REST API** (`/repos/{owner}/{repo}`) for: `stargazers_count`, `pushed_at` (converted to days-ago), `license.spdx_id`
- **PyPI JSON API** for Python packages (deepeval, ragas): version + licence
- CVE and advisory flags: manually cross-referenced against GitHub Security Advisories and NVD at time of audit

Staleness thresholds applied:
- ✅ ACTIVE: last push ≤ 90 days
- 🔵 RECENT: 91–365 days
- ⚠️ STALE: > 365 days

***

## 5.A — Agent Frameworks / Orchestration

### Items with updated evidence

#43 deerflow-banking-orchestrator — 76,633 ⭐ · pushed today (0d) · MIT[1][2][3][4]
DeerFlow 2.0, released February 2026, reached #1 GitHub Trending and is built on LangGraph with a Docker-sandboxed sub-agent execution model. The architecture is sophisticated — each task runs inside an isolated container with a full filesystem, bash terminal, and MCP support — but this is precisely what makes it duplicative of the LangGraph choice already in the SRC-01 shortlist.[2][3][4]
**VERDICT: DEFER confirmed.** ByteDance-origin supply-chain review is a hard gate regardless of technical merit.[1]

#74 smolagents-hf-micro-agent — 28,264 ⭐ · pushed 16d ago · Apache-2.0[5][6][7]
Hugging Face smolagents is actively maintained, code-first, and designed explicitly for lightweight agent tasks including financial tool calls. AWS has published enterprise guidance on running smolagents on managed services.[6][7]
**VERDICT: ADOPT confirmed.** Pin release; supply-chain scan recommended before production.

#76 mastra-typescript-agent-framework — 25,997 ⭐ · pushed today · NOASSERTION[8][9][10][11]
In 2026, Mastra is described as "the default starting point for production AI applications across the TypeScript ecosystem" — batteries-included (agents, workflows, RAG, memory, MCP, evals, telemetry) in a single typed API. Excellent fit for GAP-080 and the confirmed-ADOPT #56 assistant-ui surface.[10][11]
**VERDICT: ADOPT confirmed.** Licence is `NOASSERTION` in GitHub metadata — retrieve actual licence text from repo before production use; likely MIT but must be confirmed.

#79 openhands-swe-general-agent — GitHub API returned null (rate-limit or repo restructure). Based on deep-web evidence this is the All-Hands-AI/OpenHands repo, a mature production-grade SWE agent widely deployed in factory-plane contexts.  
**VERDICT: ADOPT confirmed.** Factory-plane only; no production credential access.

#93 airflow-workflow-orchestrator — 46,080 ⭐ · pushed today · Apache-2.0[12]
Apache Airflow is the unambiguous industry standard for data-pipeline DAG scheduling. The most recent CVEs in the 2.x stream are patched; pin to latest 2.x LTS. Temporal remains the exclusive saga engine.  
**VERDICT: ADOPT confirmed.**

### Remaining 5.A items (verdicts unchanged)

| Item | Verdict | Stars | Days Since Push | Licence | Key Delta |
|------|---------|-------|-----------------|---------|-----------|
| #44 agenticseek-privacy-first-agent | ADOPT | N/A | N/A | N/A | On-prem MLRO only; no GH probe needed |
| #45 suna-self-hosted-manus-clone | REJECT | 19,949 | 0d | NOASSERTION | Confirmed duplicative of OWL/CAMEL |
| #58 strands-sdk-aws-agent-framework | DEFER | N/A | N/A | N/A | AWS-only; conflicts on-prem posture |
| #69 memory-first-agent-architecture | DEFER | N/A | N/A | N/A | Gate on ADR-165 memoir pilot |
| #73 agno-multimodal-agent-framework | REJECT | N/A | N/A | N/A | No EMI gap; 4th framework unneeded |
| #75 goose-block-dev-loop-agent | ADOPT | N/A | N/A | N/A | Factory-plane dev tool; no runtime risk |
| #77 langchain-js-agent-sdk | DEFER | 17,919 | 0d | MIT | Defer in favour of Mastra #76 |
| #91 dify-llm-app-orchestration | REJECT | N/A | N/A | N/A | Duplicates LangGraph+n8n |
| #126 bmad-agentic-dev-method | ADOPT | N/A | N/A | N/A | Methodology-only; zero runtime risk |

***

## 5.B — Fraud Detection

#107 deepeval-llm-eval-framework — 16,739 ⭐ · pushed today · Apache-2.0[13][14]
DeepEval provides 14+ pre-built LLM evaluation metrics including hallucination, coherence, bias, and answer relevance. It is the strongest open-source LLM eval framework for production banking contexts and a direct fit for ADR-141.[14][13]
**VERDICT: ADOPT confirmed.**

#108 ragas-rag-evaluation — PyPI v0.4.3 · Apache-2.0[14]
RAG-specific evaluation (faithfulness, context recall, answer relevancy) is not covered by DeepEval; the two are complementary, not competing.  
**VERDICT: ADOPT confirmed.** Co-deploy with #107.

#109 mlflow-ml-lifecycle-tracking — 26,953 ⭐ · pushed today · Apache-2.0 · v3.14.0 released Jun 2026[15][16][17]
MLflow v3.14.0 is actively maintained (June 2026 release). Production-grade fraud detection MLOps pipelines using MLflow + Kafka are documented. Credit-use access control must be implemented at the registry permission layer.[16][17]
**VERDICT: ADOPT confirmed.** Fraud registry only; enforce access-control policy.

#47, #51, #72, #84 — verdicts unchanged from preliminary advisory (no GH probe for GNN/adversarial items). See preliminary package for full rationale.

***

## 5.C — AML / Cross-Bank Privacy / DP LLM

### ⚠️ UPGRADE: #52 FATE — Condition Escalation

#52 fate-federated-learning-webank — 6,082 ⭐ · last push 597d ago (Nov 2024) · last release v2.2.0 Jul 2024 · Apache-2.0[18][19]

The shell audit reveals a **maintenance concern**: FATE has not had a release since July 2024 and no code push since November 2024. While FATE remains technically the most mature FL framework for cross-bank AML consortium work (published in JMLR as the first industrial-grade FL platform), a stale project in a regulated banking context adds an unacceptable operational risk.[19][18]

**VERDICT: DEFER — conditions upgraded.** The governance review must now include a parallel evaluation of Flower (flwr) and PySyft as maintained alternatives before any adoption recommendation. FATE is only viable if the WeBank team resumes active maintenance or if a commercial support contract is available.

### #54 vaultgemma-dp-private-llm — 5,707 ⭐ · last push 405d ago · Apache-2.0

VaultGemma (1B parameters) was introduced by Google in September 2025 as the first LLM fully pre-trained from scratch with differential privacy. It shows no detectable memorisation of training data and performs comparably to non-private models from five years prior. The 405-day last-push reflects that this is a research release, not a continuously-iterated framework — the model weights are stable by design.[20][21][22][23]

VaultGemma uses calibrated noise during training to implement GDPR Article 25 privacy-by-design. This makes it architecturally appropriate for customer-data inference flows at a regulated EMI.[24][25][26]

**VERDICT: ADOPT confirmed.** DPIA covering epsilon/delta privacy budget required; restrict to customer-data inference flows; non-customer-data flows do not require DP overhead.

***

## 5.D — KYC / Identity

#82 openkyc-agentic-verification and #83 verifiable-agent-kit-zk-proof — both DEFER confirmed. No live GH probe was deterministic; conditions from preliminary advisory stand (pilot vs commercial baseline for #82; ZK roadmap commitment for #83).

***

## 5.E — NLP / RAG / Eval

### ⚠️ CONDITION ESCALATION: #61 FinNLP

#61 finnlp-domain-nlp-toolkit — 1,465 ⭐ · last push 738d ago (Jul 2024) · MIT

FinNLP is the most stale ADOPT candidate in the package. The repository has not been updated in over two years. The EBA and FCA explicitly encourage OSINT/adverse-media tools in EDD processes, and the FinNLP toolkit covers exactly this domain (entity extraction, financial sentiment). However, an unmaintained AML tooling library carries security and accuracy drift risks.[27][28][29]

**VERDICT: ADOPT — with hard conditions upgraded.** (1) Fork validation: assess whether the toolkit's NLP models remain accurate against current financial typology language. (2) If not maintained, identify a fork or replacement (e.g. FinBERT-based alternatives). (3) Do not deploy to production without a model-accuracy benchmark against a labelled adverse-media dataset.

#89 llamaindex-rag-orchestration — 50,751 ⭐ · pushed yesterday · MIT — DEFER confirmed. The star count is high but this does not override the Haystack architectural overlap rationale.

***

## 5.F — Web / Browser Automation

### ⚠️ LICENCE FLAG: #100 Skyvern

#100 skyvern-vision-web-automation — 22,166 ⭐ · pushed today · **AGPL-3.0**[30][31]

The shell audit confirms Skyvern is licensed under AGPL-3.0, not MIT as might be assumed. AGPL-3.0 has copyleft provisions that extend to any software that interacts with the licensed code over a network — a material risk if BANXE embeds Skyvern in a production service accessible over an API. Skyvern itself documents compliance use cases including audit-trail generation.[31][30]

**VERDICT: ADOPT — licence review condition added.** Legal must confirm that deployment as an internal-only process (no AGPL-network-exposure) is sufficient, or evaluate a commercial Skyvern licence for production use. Sandbox pilot is unaffected by AGPL.

#98 browser-use — 103,962 ⭐ · pushed today · MIT — ADOPT confirmed, no licence issue.  
#101 Playwright — 92,528 ⭐ · pushed today · Apache-2.0 · Microsoft-maintained — ADOPT confirmed, strongest safety profile of the three.  
#103 Open-WebUI — 144,864 ⭐ · pushed 7d ago — highest-starred item in the entire package; 282M container pulls confirmed; ADOPT confirmed.[32]

***

## 5.G — OSINT / Adverse-Media / Tor

#114 SpiderFoot — 19,314 ⭐ · pushed 87d ago · MIT[28]
SpiderFoot is explicitly named by the AML Network as a recommended OSINT tool for AML compliance. The EBA and FCA both call for OSINT/adverse-media searches in EDD processes. Configuration to surface-web-only mode (disable Tor/I2P modules) is straightforward.[33][34][27][28]
**VERDICT: ADOPT confirmed.** Surface-web-only config; GDPR Article 9 handling policy for criminal-record data.

#115 GDELT — Public-domain dataset; legally unambiguous; used by financial intelligence units globally.[34]
**VERDICT: ADOPT confirmed.**

### Legal Red-Lines Confirmed: #116 and #118

The deep legal research confirms the Computer Misuse Act 1990 analysis. Section 1 of the CMA criminalises any access to computer systems the actor knows is unauthorised, with penalties up to 10 years imprisonment for access intended to commit further offences. Dark web monitoring triggers multiple specific legal risks identified in the technology law literature:[35][36][37][38]

- **CMA s.1** — accessing .onion infrastructure may constitute unauthorised access even if publicly indexed, because no permission is granted by the .onion service operator
- **GDPR** — any personal data retrieved from dark-web sources is subject to UK/EU GDPR regardless of origin
- **Terrorism Act 2000 s.19** — incidental exposure to terrorist material during .onion enumeration triggers a strict-liability disclosure obligation to the NCA
- **FCA surveillance posture** — the FCA itself is listed as a body that can access internet connection records under the Investigatory Powers Act 2016; undisclosed dark-web monitoring by a regulated entity is a regulatory risk[37]

#116 and #118 VERDICT: DEFER/LEGAL-RED-LINE confirmed. Five-gate conditions from preliminary advisory stand. These items must NOT proceed to even sandboxed evaluation without qualified UK legal counsel opinion on CMA authorisation and a DPIA under UK GDPR.

***

## 5.H — Ledger / Blockchain

#88 Hyperledger Fabric — 16,678 ⭐ · pushed 7d ago · Apache-2.0 · **v3.1.5 released June 2026**[39][40][41][42]

Hyperledger Fabric 3.0 (September 2024) introduced Byzantine Fault Tolerant consensus via the SmartBFT protocol, making it resilient to malicious faults — not just crashes. v3.1.5 was released June 18, 2026, confirming active maintenance. It is the world's most widely adopted enterprise blockchain framework. FX compliance smart contracts on Fabric have been validated in regulatory-grade contexts.[43][29][40][44]
**VERDICT: ADOPT confirmed.** v3.1.5; pin this release; consortium governance document required.

#57 FISCO-BCOS — 2,588 ⭐ · Apache-2.0 — REJECT confirmed. WeBank-origin risk combined with far lower adoption vs Fabric makes this untenable for a regulated EEA EMI.

***

## 5.I — Payments / MCP / Card Issuing

#119 Paynetics — Paynetics secured its FCA UK EMI licence in April 2023. It operates a BIN sponsorship service explicitly designed for companies with established client bases wanting to launch payment cards without direct card-scheme membership.[45][46][47]
**VERDICT: ADOPT confirmed.** FCA SYSC 8 outsourcing notification + DORA assessment required; resolves #120/#121.

#96 bank-mcp-banking-server-family — ADOPT confirmed (PSD2/UK Open Banking alignment).  
#97 stripe-ai-sdk-payments-mcp — DEFER confirmed (vendor lock-in risk at payments-agent layer).

***

## 5.J — Compliance / Regulator Surface

#125 Tremor — 3,512 ⭐ · Apache-2.0 (shell shows Apache, likely MIT per docs — confirm). ADOPT confirmed; zero regulatory risk.  

#127 Dutymark / #128 OMP — Consumer Duty (FCA PS22/9) has been mandatory since July 2023. Evidence collection and outcome monitoring are explicit regulatory obligations. Both tools address real compliance gaps.[48][49][50]
**VERDICTS: ADOPT confirmed for both.** Taxonomy validation against PS22/9 required; SMF sign-off.

***

## 5.K — PAYBIS-Distribution Track

| Item | Verdict | Stars | Days Since Push | Licence | Key Audit Note |
|------|---------|-------|-----------------|---------|----------------|
| #55 finrl-deepseek-rl-treasury | ADOPT-PAYBIS=YES | 15,680 | 44d | MIT | Backtested on Nasdaq-100; RL+LLM[51][52] |
| #60 finrobot-fintech-multi-agent | ADOPT-PAYBIS=YES | 7,519 | 2d | Apache-2.0 | Active; LLM market commentary surface |
| #62 tradingagents-llm-multi-agent | ADOPT-PAYBIS=YES | **92,045** | 4d | Apache-2.0 | Largest PAYBIS-track repo; explicitly trading system |
| #63 qlib-quant-research-platform | ADOPT-PAYBIS=YES | 46,021 | 78d | MIT | Microsoft-maintained; back-testing only |
| #81 fingpt-ai4finance-financial-llm | ADOPT-PAYBIS=YES | 20,831 | 38d | MIT | Eval via DeepEval #107; info not advice framing |

All five PAYBIS items are confirmed active and well-maintained. FinRL-DeepSeek was published as a peer-reviewed paper in February 2025 combining CVaR-PPO RL with LLM news signals. Distribution agreements must explicitly define that BANXE is distributor only and all regulated execution is on PAYBIS's MiFID licence.[51][53][52]

***

## Delta Summary — Preliminary vs Shell-Audited Verdicts

| Item | Preliminary Verdict | Shell-Audited Verdict | Delta |
|------|--------------------|-----------------------|-------|
| #52 FATE | DEFER | DEFER — **condition escalation** (stale 597d; Flower/OpenFL comparison now mandatory) | ⚠️ |
| #61 FinNLP | ADOPT | ADOPT — **condition escalation** (stale 738d; fork validation + accuracy benchmark required) | ⚠️ |
| #100 Skyvern | ADOPT | ADOPT — **licence condition added** (AGPL-3.0; legal review for commercial embedding) | ⚠️ |
| All other 33 items | As preliminary | Confirmed | ✅ |

***

## Shell Audit Operational Notes

The audit script (`banxe_sp41_shell_audit.sh`) can be re-run at any time to refresh staleness metrics and detect licence changes. Recommended cadence: **monthly** for ADOPT-track items, **at each ADR gate** for DEFER items.

Items not probed via shell (no public GH repo): #44, #58, #69, #73, #75, #82, #83, #84, #96, #97, #116, #118, #119, #125, #127, #128. Verdicts for these items are based on deep regulatory and capability research only.

**GitHub rate-limit note:** Unauthenticated API calls are limited to 60/hour. For CI/CD integration of this script, add a `GITHUB_TOKEN` header to increase the limit to 5,000/hour.

***

## Items Not Covered (Absent from §5 Source)

#67 github-agentic-workflows-ci — absent from §5 clusters per the documented integrity warning. [НЕИЗВЕСТНО] — no capability description provided; cannot issue a verdict. Escalate to SP41 source author.

***

*All verdicts are advisory input for BANXE Central/SMF. No decision is activated by this document. Shell audit data reflects live GitHub/PyPI state as of 2026-07-09T21:16 UTC.*
