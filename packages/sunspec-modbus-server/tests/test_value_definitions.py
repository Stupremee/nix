"""Tests for sensor mapping normalization."""

import pytest

from sunspec_modbus_server.value_definitions import (
    normalize_entity_mappings,
    normalize_values,
)


def test_normalize_values_fills_defaults() -> None:
    values = normalize_values({"active_power_w": 1234})
    assert values["active_power_w"] == 1234.0
    assert values["pv_power_w"] == 0.0
    assert values["grid_power_w"] == 0.0
    assert values["frequency_hz"] == 50.0
    assert values["battery_soc_pct"] == 50.0


def test_normalize_entity_mappings_rejects_unknown_keys() -> None:
    with pytest.raises(ValueError, match="Unknown Home Assistant entity mapping keys"):
        normalize_entity_mappings({"unknown_value": "sensor.foo"})


def test_normalize_entity_mappings_supports_scale() -> None:
    mappings = normalize_entity_mappings(
        {
          "active_power_w": {
            "entityId": "sensor.inverter_power_kw",
            "scale": 1000,
          }
        }
    )
    assert mappings["active_power_w"].entity_id == "sensor.inverter_power_kw"
    assert mappings["active_power_w"].scale == 1000
    assert mappings["active_power_w"].negate is False


def test_normalize_entity_mappings_supports_negate() -> None:
    mappings = normalize_entity_mappings(
        {
            "grid_power_w": {
                "entityId": "sensor.grid_import_kw",
                "scale": 1000,
                "negate": True,
            }
        }
    )

    assert mappings["grid_power_w"].entity_id == "sensor.grid_import_kw"
    assert mappings["grid_power_w"].scale == 1000
    assert mappings["grid_power_w"].negate is True


def test_normalize_entity_mappings_rejects_unknown_mapping_options() -> None:
    with pytest.raises(
        ValueError,
        match="Unknown Home Assistant entity mapping options for active_power_w",
    ):
        normalize_entity_mappings(
            {
                "active_power_w": {
                    "entityId": "sensor.inverter_power_kw",
                    "offset": 1,
                }
            }
        )
