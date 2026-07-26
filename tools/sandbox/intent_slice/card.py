"""Confirmation card builder (8-step flow step 5-6 artefact; governance visible).

The card shows max_cost and autonomy level to the client — governance as a
product feature (red line). Saved as json + human-readable markdown.
"""

from __future__ import annotations

import json
import uuid
from dataclasses import asdict

from .contracts import BudgetGateResult, ClientIntentRecord, ConfirmationCard
from .gates import effective_max_cost
from .lineage_log import SlicePaths


def build_confirmation_card(
    intent: ClientIntentRecord, budget_result: BudgetGateResult, autonomy_level: str
) -> ConfirmationCard:
    params = intent.parsed_params
    return ConfirmationCard(
        card_id=str(uuid.uuid4()),
        intent_id=intent.intent_id,
        correlation_id=intent.correlation_id,
        summary=(
            f"Перевод {params['amount']} {params['currency']} → {params['recipient']} "
            f"(sandbox, исполняется только после вашего подтверждения)"
        ),
        amount=params["amount"],
        currency=params["currency"],
        recipient=params["recipient"],
        fee="0.00",
        max_cost=str(effective_max_cost()),
        autonomy_level=autonomy_level,
        expires_at=intent.expires_at,
    )


def save_card(card: ConfirmationCard, paths: SlicePaths) -> tuple[str, str]:
    paths.cards_dir.mkdir(parents=True, exist_ok=True)
    json_path = paths.cards_dir / f"card-{card.card_id}.json"
    md_path = paths.cards_dir / f"card-{card.card_id}.md"
    json_path.write_text(
        json.dumps(asdict(card), ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    md_path.write_text(
        "\n".join(
            [
                "# Подтверждение операции",
                "",
                card.summary,
                "",
                f"- Сумма: **{card.amount} {card.currency}**",
                f"- Получатель: **{card.recipient}**",
                f"- Комиссия: {card.fee}",
                f"- Лимит стоимости агента (max_cost): {card.max_cost}",
                f"- Автономия агента: **{card.autonomy_level}** — только с вашим подтверждением",
                f"- Действует до: {card.expires_at}",
                "",
                f"Действия: {', '.join(card.actions)}",
                f"card_id: `{card.card_id}` · intent_id: `{card.intent_id}`",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return str(json_path), str(md_path)
