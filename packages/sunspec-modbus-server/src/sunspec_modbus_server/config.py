"""Configuration loading for the SunSpec Modbus server."""

from __future__ import annotations

from dataclasses import dataclass
import json
from pathlib import Path
from typing import Any

from .ha_client import HomeAssistantConfig
from .value_definitions import normalize_entity_mappings, normalize_values


@dataclass(frozen=True)
class AppConfig:
    """Application runtime configuration."""

    host: str
    port: int
    unit_id: int
    base_address: int
    poll_interval_seconds: int
    log_level: str
    data_source: str
    home_assistant: HomeAssistantConfig
    dummy_values: dict[str, float]

    @classmethod
    def dummy_default(cls) -> "AppConfig":
        """Return a built-in dummy configuration for quick local runs."""
        return cls(
            host="0.0.0.0",
            port=1502,
            unit_id=1,
            base_address=40000,
            poll_interval_seconds=5,
            log_level="INFO",
            data_source="dummy",
            home_assistant=HomeAssistantConfig(
                url="http://127.0.0.1:8123",
                token_file=None,
                entity_mappings={},
            ),
            dummy_values=normalize_values(None),
        )

    @classmethod
    def from_json_file(
        cls,
        config_path: str | Path,
        *,
        home_assistant_token_file_override: str | None = None,
    ) -> "AppConfig":
        """Load configuration from JSON."""
        payload = json.loads(Path(config_path).read_text(encoding="utf-8"))

        home_assistant_payload = payload.get("homeAssistant", {})
        token_file = (
            home_assistant_token_file_override
            or home_assistant_payload.get("tokenFile")
        )

        app_config = cls(
            host=str(payload["host"]),
            port=int(payload["port"]),
            unit_id=int(payload["unitId"]),
            base_address=int(payload.get("baseAddress", 40000)),
            poll_interval_seconds=int(payload["pollIntervalSeconds"]),
            log_level=str(payload["logLevel"]).upper(),
            data_source=str(payload.get("dataSource", "homeAssistant")),
            home_assistant=HomeAssistantConfig(
                url=str(home_assistant_payload.get("url", "http://127.0.0.1:8123")),
                token_file=str(token_file) if token_file else None,
                entity_mappings=normalize_entity_mappings(
                    home_assistant_payload.get("entityIds")
                ),
            ),
            dummy_values=normalize_values(payload.get("dummyValues")),
        )

        if app_config.data_source not in {"homeAssistant", "dummy"}:
            raise ValueError(
                "dataSource must be either 'homeAssistant' or 'dummy'"
            )
        if (
            app_config.data_source == "homeAssistant"
            and not app_config.home_assistant.token_file
        ):
            raise ValueError(
                "homeAssistant.tokenFile must be set when dataSource is 'homeAssistant'"
            )

        return app_config

    def redacted_summary(self) -> dict[str, Any]:
        """Return a startup summary without secrets."""
        return {
            "host": self.host,
            "port": self.port,
            "unitId": self.unit_id,
            "baseAddress": self.base_address,
            "pollIntervalSeconds": self.poll_interval_seconds,
            "logLevel": self.log_level,
            "dataSource": self.data_source,
            "homeAssistantUrl": self.home_assistant.url,
            "mappedEntities": len(self.home_assistant.entity_mappings),
            "dummyValues": len(self.dummy_values),
        }
