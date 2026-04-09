"""Home Assistant REST API polling helpers."""

from __future__ import annotations

from dataclasses import dataclass
import logging
from typing import Any

import aiohttp

from .value_definitions import EntityMapping, VALUE_DEFINITIONS


LOGGER = logging.getLogger(__name__)


def parse_numeric_state(
    raw_state: Any,
    *,
    previous_value: float | None = None,
) -> float | None:
    """Parse a Home Assistant state value into a float."""
    if raw_state is None:
        return previous_value

    text = str(raw_state).strip()
    if not text or text.lower() in {"unknown", "unavailable", "none", "null"}:
        return previous_value

    try:
        return float(text)
    except ValueError:
        return previous_value


def apply_mapping(parsed: float, mapping: EntityMapping) -> float:
    """Apply the configured Home Assistant mapping transforms."""
    value = parsed * mapping.scale
    return -value if mapping.negate else value


@dataclass(frozen=True)
class HomeAssistantConfig:
    """Home Assistant REST connectivity settings."""

    url: str
    token_file: str | None
    entity_mappings: dict[str, EntityMapping]


class HomeAssistantClient:
    """Small async client for polling Home Assistant entity states."""

    def __init__(self, config: HomeAssistantConfig, token: str) -> None:
        self._config = config
        self._session = aiohttp.ClientSession(
            base_url=config.url.rstrip("/"),
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
            },
        )

    async def close(self) -> None:
        """Close the underlying HTTP session."""
        await self._session.close()

    async def fetch_values(
        self,
        *,
        previous_values: dict[str, float],
    ) -> dict[str, float]:
        """Fetch all mapped entity values from Home Assistant."""
        async with self._session.get("/api/states") as response:
            response.raise_for_status()
            payload = await response.json()

        states_by_entity_id = {
            item.get("entity_id"): item
            for item in payload
            if isinstance(item, dict) and item.get("entity_id")
        }

        resolved: dict[str, float] = {}
        for key, definition in VALUE_DEFINITIONS.items():
            previous = previous_values.get(key, definition.default)
            mapping = self._config.entity_mappings.get(key)
            if mapping is None:
                resolved[key] = previous
                continue

            item = states_by_entity_id.get(mapping.entity_id)
            if item is None:
                LOGGER.warning(
                    "Home Assistant entity %s for %s was not found",
                    mapping.entity_id,
                    key,
                )
                resolved[key] = previous
                continue

            parsed = parse_numeric_state(item.get("state"), previous_value=previous)
            if parsed is None:
                LOGGER.warning(
                    "Home Assistant entity %s for %s had a non-numeric state %r",
                    mapping.entity_id,
                    key,
                    item.get("state"),
                )
                resolved[key] = previous
                continue

            scaled = apply_mapping(parsed, mapping)
            resolved[key] = max(definition.minimum, min(definition.maximum, scaled))

        return resolved
