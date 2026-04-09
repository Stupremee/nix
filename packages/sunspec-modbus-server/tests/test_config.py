"""Tests for top-level app configuration helpers."""

from sunspec_modbus_server.config import AppConfig


def test_dummy_default_ignores_external_configuration() -> None:
    config = AppConfig.dummy_default()
    assert config.data_source == "dummy"
    assert config.host == "0.0.0.0"
    assert config.port == 1502
    assert config.home_assistant.token_file is None
