"""Shared value definitions for the virtual SunSpec server."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Mapping


@dataclass(frozen=True)
class ValueDefinition:
    """Metadata for one logical measurement used by the server."""

    key: str
    description: str
    unit: str | None
    default: float
    minimum: float
    maximum: float


@dataclass(frozen=True)
class EntityMapping:
    """Mapping from one logical SunSpec value to a Home Assistant entity."""

    entity_id: str
    scale: float = 1.0
    negate: bool = False


VALUE_DEFINITIONS: dict[str, ValueDefinition] = {
    "active_power_w": ValueDefinition(
        key="active_power_w",
        description="Inverter active power",
        unit="W",
        default=0.0,
        minimum=-30000.0,
        maximum=30000.0,
    ),
    "grid_power_w": ValueDefinition(
        key="grid_power_w",
        description="Grid import or export active power",
        unit="W",
        default=0.0,
        minimum=-30000.0,
        maximum=30000.0,
    ),
    "apparent_power_va": ValueDefinition(
        key="apparent_power_va",
        description="Total apparent power",
        unit="VA",
        default=0.0,
        minimum=0.0,
        maximum=30000.0,
    ),
    "reactive_power_var": ValueDefinition(
        key="reactive_power_var",
        description="Total reactive power",
        unit="Var",
        default=0.0,
        minimum=-30000.0,
        maximum=30000.0,
    ),
    "power_factor_pct": ValueDefinition(
        key="power_factor_pct",
        description="Power factor as a decimal scaled by 100",
        unit="pct",
        default=100.0,
        minimum=-100.0,
        maximum=100.0,
    ),
    "current_a": ValueDefinition(
        key="current_a",
        description="Total AC current",
        unit="A",
        default=0.0,
        minimum=-200.0,
        maximum=200.0,
    ),
    "voltage_ln_v": ValueDefinition(
        key="voltage_ln_v",
        description="Line-to-neutral voltage",
        unit="V",
        default=230.0,
        minimum=0.0,
        maximum=400.0,
    ),
    "voltage_ll_v": ValueDefinition(
        key="voltage_ll_v",
        description="Line-to-line voltage",
        unit="V",
        default=400.0,
        minimum=0.0,
        maximum=800.0,
    ),
    "frequency_hz": ValueDefinition(
        key="frequency_hz",
        description="Grid frequency",
        unit="Hz",
        default=50.0,
        minimum=0.0,
        maximum=100.0,
    ),
    "total_energy_injected_wh": ValueDefinition(
        key="total_energy_injected_wh",
        description="Total active energy injected",
        unit="Wh",
        default=0.0,
        minimum=0.0,
        maximum=18446744073709551615.0,
    ),
    "total_energy_absorbed_wh": ValueDefinition(
        key="total_energy_absorbed_wh",
        description="Total active energy absorbed",
        unit="Wh",
        default=0.0,
        minimum=0.0,
        maximum=18446744073709551615.0,
    ),
    "total_reactive_energy_injected_varh": ValueDefinition(
        key="total_reactive_energy_injected_varh",
        description="Total reactive energy injected",
        unit="Varh",
        default=0.0,
        minimum=0.0,
        maximum=18446744073709551615.0,
    ),
    "total_reactive_energy_absorbed_varh": ValueDefinition(
        key="total_reactive_energy_absorbed_varh",
        description="Total reactive energy absorbed",
        unit="Varh",
        default=0.0,
        minimum=0.0,
        maximum=18446744073709551615.0,
    ),
    "ambient_temperature_c": ValueDefinition(
        key="ambient_temperature_c",
        description="Ambient temperature",
        unit="C",
        default=20.0,
        minimum=-100.0,
        maximum=200.0,
    ),
    "cabinet_temperature_c": ValueDefinition(
        key="cabinet_temperature_c",
        description="Cabinet temperature",
        unit="C",
        default=25.0,
        minimum=-100.0,
        maximum=200.0,
    ),
    "heat_sink_temperature_c": ValueDefinition(
        key="heat_sink_temperature_c",
        description="Heat sink temperature",
        unit="C",
        default=25.0,
        minimum=-100.0,
        maximum=200.0,
    ),
    "transformer_temperature_c": ValueDefinition(
        key="transformer_temperature_c",
        description="Transformer temperature",
        unit="C",
        default=25.0,
        minimum=-100.0,
        maximum=200.0,
    ),
    "switch_temperature_c": ValueDefinition(
        key="switch_temperature_c",
        description="IGBT/MOSFET temperature",
        unit="C",
        default=25.0,
        minimum=-100.0,
        maximum=200.0,
    ),
    "other_temperature_c": ValueDefinition(
        key="other_temperature_c",
        description="Other temperature",
        unit="C",
        default=25.0,
        minimum=-100.0,
        maximum=200.0,
    ),
    "battery_power_w": ValueDefinition(
        key="battery_power_w",
        description="Battery power, positive for discharge and negative for charge",
        unit="W",
        default=0.0,
        minimum=-30000.0,
        maximum=30000.0,
    ),
    "battery_soc_pct": ValueDefinition(
        key="battery_soc_pct",
        description="Battery state of charge",
        unit="pct",
        default=50.0,
        minimum=0.0,
        maximum=100.0,
    ),
}

VALUE_KEYS = tuple(VALUE_DEFINITIONS.keys())
DEFAULT_VALUES = {key: definition.default for key, definition in VALUE_DEFINITIONS.items()}


def normalize_values(values: Mapping[str, object] | None) -> dict[str, float]:
    """Merge a partial value mapping with defaults and clamp types to floats."""
    normalized = dict(DEFAULT_VALUES)
    if values is None:
        return normalized

    unknown = sorted(set(values) - set(VALUE_DEFINITIONS))
    if unknown:
        joined = ", ".join(unknown)
        raise ValueError(f"Unknown SunSpec value keys: {joined}")

    for key, raw_value in values.items():
        definition = VALUE_DEFINITIONS[key]
        value = float(raw_value)
        normalized[key] = max(definition.minimum, min(definition.maximum, value))
    return normalized


def normalize_entity_mappings(
    entity_ids: Mapping[str, object] | None,
) -> dict[str, EntityMapping]:
    """Validate and normalize Home Assistant entity mappings."""
    if entity_ids is None:
        return {}

    unknown = sorted(set(entity_ids) - set(VALUE_DEFINITIONS))
    if unknown:
        joined = ", ".join(unknown)
        raise ValueError(f"Unknown Home Assistant entity mapping keys: {joined}")

    normalized: dict[str, EntityMapping] = {}
    for key, raw_value in entity_ids.items():
        if isinstance(raw_value, Mapping):
            allowed_keys = {"entityId", "scale", "negate"}
            unknown_mapping_keys = sorted(set(raw_value) - allowed_keys)
            if unknown_mapping_keys:
                joined = ", ".join(unknown_mapping_keys)
                raise ValueError(
                    f"Unknown Home Assistant entity mapping options for {key}: {joined}"
                )
            entity_id = str(raw_value.get("entityId", "")).strip()
            scale = float(raw_value.get("scale", 1.0))
            negate = bool(raw_value.get("negate", False))
        else:
            entity_id = str(raw_value).strip()
            scale = 1.0
            negate = False
        if not entity_id:
            continue
        normalized[key] = EntityMapping(
            entity_id=entity_id,
            scale=scale,
            negate=negate,
        )
    return normalized
