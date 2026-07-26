# BANXE-ENGINE-MATH.md — Canonical Math & Rules for the AI Engine

> **STATUS: ACTIVE in SANDBOX (TRAINING data) per operator Promotion Gate 2026-07-26 — prod activation remains gated.**
> Source: consolidated engine reference rebuilt v2 (blocks C, C-bench), analytics #1/#4, session 2026-07-26 (ENGREF01).
> Formulas are reproduced VERBATIM from the analytics ground truth. Any change requires a new ADR.
> Companion docs: `BANXE-AI-ENGINE-REFERENCE.md` (architecture), `BANXE-SECURITY-OWASP.md` (security map),
> `../../roadmap/BANXE-E0-E6.md` (phases).

## 1. GNN fraud detection (E4 phase)

Graph attention:

```
e_ij = LeakyReLU( a^T [ W h_i || W h_j ] )
alpha_ij = softmax_j(e_ij)
```

Aggregation:

```
h_i' = sigma( sum_k( sum_{j in N_i} alpha_ij^k · W^k h_j ) )
```

Temporal decay:

```
h_i(t) = sum_{j in N_i} alpha_ij · e^{ -(t - t_ij) } · W h_j
```

## 2. FraudGNN-RL — DQN for feature importance

```
Q(s,a) ← Q(s,a) + alpha [ r + gamma·max_a' Q(s',a') − Q(s,a) ]
```

Reported results (source benchmark, not a BANXE commitment): **F1 = 97.3%, false positives −31%**.
Calibration of BANXE targets against our own data volume = open point (OP-M3), operator/eval decision.

## 3. Federated Learning (E6 phase)

FedAvg:

```
w_{t+1} = sum_{k=1..K} (n_k / n) · w_k^{t+1}      (n = sum n_k)
```

- FedKT = Federated Knowledge Transfer (fine-tuning + KD, Non-IID).
- FATE PSI cross-bank credit scoring: **+15–30% PR-AUC**, GDPR-preserving (training moves to data, not data to training).

## 4. Differential Privacy

Gaussian mechanism:

```
M(x) = f(x) + N(0, sigma^2 · I)
```

Rényi DP accounting; reported operating point **epsilon ≈ 8.65 at ~87–90% privacy-utility**.
Acceptability of this ε for GDPR/CNIL context = counsel question (OP-M5), not an engineering default.

## 5. Temporal Knowledge Distillation (teacher 1B → student 10M)

```
L_KD = (1−alpha)·L_CE(y, y_s) + alpha·T^2·L_KL( z_t/T , z_s/T )
```

- `z_t` = teacher logits (1B), `z_s` = student logits (10M).
- Inference split: **10M ≈ 1ms real-time fraud path; 1B batch path**.

## 6. EU AI Act explainability — SHAP

```
phi_i = sum_{S ⊆ F\{i}} [ |S|!(|F|−|S|−1)! / |F|! ] · ( f(S∪{i}) − f(S) )
```

Blend ≈ 40/35/25 (per source). Cross-ref: ADR-169 (LIME/SHAP HITL explainability) — this section extends, does not replace.

## 7. FinRL state (Treasury/analytics track)

```
s_t = [ p_t , f_t , LLM_signal_t ]
```

`p` = prices, `f` = features, `LLM_signal` = LLM sentiment signal.

## 8. Proactive alert rule (Temporal Cron)

```
if balance < bill_due.amount × 1.2 → send_proactive_alert
```

First-wave advisory candidate (read-only, no funds movement).

## 9. Quantum GNN — RESEARCH-TRACK ONLY (parked)

- QGNN (VQC) fraud: reported **AUC 0.85**; IBM Qiskit; horizon **2027–2028**.
- **NOT in E0–E6.** Parked by decision embedded in the engine reference.

## 10. Foundation-model benchmarks (evidence, C-bench)

| Model | Key facts |
|---|---|
| Revolut PRAGMA | ~24–40B banking events; +13% PR-AUC; fraud recall +65%; recommendation mAP +40.5%; encoders Profile/Event/History; BPE tokenization; buckets(amount/merchant/time); temporal feats hour-of-day/day-of-week/day-of-month; masked LM 15% masking; datasets 10M/100M/1B |
| Nubank nuFormer | GPT-style decoder, causal next-token + joint fusion DCNv2 tabular; +1.25% test AUC (~+4.4% cited) |
| TransactionGPT | 3D-Transformer (3 axes); beats fine-tuned-LLM baseline |
| WeChat Pay GPT | autoregressive; token-explosion; differential-convolution anomaly detection; online |
| ASA-GNN | sampling: cosine-sim filtering + entropy diversity + multi-hop |
| OpenManus | GAIA 86.5% (vs Manus 74.3); 3-part = (PlanningAgent/ToolCallAgent) + Tool + Memory |
| VaultGemma | 1B params, Gemma-2 base, differentially private (HuggingFace/Kaggle) |

External benchmarks used as eval anchors: Finance Agent Benchmark (LLM ≈ 57% → HITL mandatory), McKinsey agentic KYC/AML resolution ≈ 80% (target metric class).

---
*ENGREF01 | 2026-07-26 | PROPOSED, no activation. Sources = session analytics versions (no source files on disk — OP-A).*
