"""Tests for top-level app configuration helpers."""

import json
from pathlib import Path

from sunspec_modbus_server.config import AppConfig


def test_dummy_default_ignores_external_configuration() -> None:
    config = AppConfig.dummy_default()
    assert config.data_source == "dummy"
    assert config.host == "0.0.0.0"
    assert config.port == 1502
    assert config.home_assistant.token_file is None


def test_json_config_parses_grid_export_simulation(tmp_path: Path) -> None:
    config_path = tmp_path / "config.json"
    config_path.write_text(
        json.dumps(
            {
                "host": "0.0.0.0",
                "port": 1502,
                "unitId": 1,
                "pollIntervalSeconds": 5,
                "logLevel": "INFO",
                "dataSource": "dummy",
                "gridExportSimulation": {
                    "enable": True,
                    "activateSocPct": 90,
                    "deactivateSocPct": 88,
                    "gridImportToleranceW": 50,
                    "batteryIdleToleranceW": 100,
                    "pvCoverMarginW": 100,
                },
            }
        ),
        encoding="utf-8",
    )

    config = AppConfig.from_json_file(config_path)

    assert config.grid_export_simulation.enable is True
    assert config.grid_export_simulation.activate_soc_pct == 90
    assert config.grid_export_simulation.deactivate_soc_pct == 88
