"""Tests for Home Assistant REST value parsing and mapping."""

from sunspec_modbus_server.ha_client import apply_mapping, parse_numeric_state
from sunspec_modbus_server.value_definitions import EntityMapping


def test_parse_numeric_state_accepts_numbers() -> None:
    assert parse_numeric_state("12.5") == 12.5
    assert parse_numeric_state(42) == 42.0


def test_parse_numeric_state_preserves_previous_on_unavailable() -> None:
    assert parse_numeric_state("unavailable", previous_value=7.0) == 7.0
    assert parse_numeric_state("unknown", previous_value=7.0) == 7.0


def test_parse_numeric_state_preserves_previous_on_bad_input() -> None:
    assert parse_numeric_state("not-a-number", previous_value=11.0) == 11.0


def test_apply_mapping_scales_and_negates() -> None:
    mapping = EntityMapping(entity_id="sensor.grid_power_kw", scale=1000, negate=True)
    assert apply_mapping(1.234, mapping) == -1234.0
