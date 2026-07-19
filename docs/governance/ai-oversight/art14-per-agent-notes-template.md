# Art.14 Per-Agent Oversight Notes — Template

Status: TEMPLATE / NOT FOR MERGE · Register: #8 (context only; свет не меняется) · Owner: CRO+CTO

Назначение: технические per-agent описания human-oversight (Art.14-стиль): stop/override/explainability/change-control — по фактическому коду. **Legal classification всегда `[counsel]`** — внутренним мнением не заполняется.

## Обязательные секции экземпляра
1. **Title** · 2. **Status** · 3. **Agent / code path** (репо-пути, verified) · 4. **Room / owner**
5. **Decision context** — какие решения агент готовит/исполняет
6. **Stop-function** — как останавливается (kill switch, HOLD, refuse-путь), fail-closed поведение
7. **Override / escalation path** — кто и как переопределяет (роль, гейт, SLA)
8. **Explainability output shape** — формат объяснимого вывода (поля score/factors/reasons)
9. **Threshold / tuning change-control** — как меняются пороги (I-27, H-012/H-014, никаких auto-updates)
10. **Logging / traceability** — lineage (ADR-046), audit trail (I-24)
11. **Register linkage** · 12. **Related sprint/docs links** · 13. **Legal classification: [counsel]** · 14. **Open questions**
