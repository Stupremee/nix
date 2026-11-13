"""What the heat pump measures and reports."""

from collections.abc import Callable, Mapping
from dataclasses import dataclass
from typing import override

from homeassistant.components.sensor import (
    SensorDeviceClass,
    SensorEntity,
    SensorEntityDescription,
    SensorStateClass,
)
from homeassistant.const import (
    PERCENTAGE,
    EntityCategory,
    UnitOfPower,
    UnitOfTemperature,
    UnitOfTime,
)
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddConfigEntryEntitiesCallback
from homeassistant.helpers.typing import StateType

from .coordinator import OvumConfigEntry, Snapshot
from .entity import OvumEntity
from .registers import (
    BUFFER_BOTTOM,
    BUFFER_OPTIONS,
    BUFFER_TARGET_ACTIVE,
    BUFFER_TOP,
    BUFFER_TYPE,
    CIRCUIT_1_ROOM_TEMPERATURE,
    CIRCUIT_TYPE_OPTIONS,
    CIRCUITS,
    COMPRESSOR_RUNTIME,
    CONDENSER_INLET,
    CONDENSER_OUTLET,
    DEMAND,
    HEAT_OUTPUT,
    HOT_WATER_BOTTOM,
    HOT_WATER_FUNCTION,
    HOT_WATER_TARGET_ACTIVE,
    HOT_WATER_TOP,
    OUTDOOR_TEMPERATURE,
    POWER_INPUT,
    PRESENT_OPTIONS,
    STATUS,
    STATUS_OPTIONS,
    SYSTEM_NAME,
    Register,
)

PARALLEL_UPDATES = 0

# Below this electrical input the compressor is off and a ratio means nothing.
COP_MIN_POWER_INPUT = 0.1


@dataclass(frozen=True, kw_only=True)
class OvumSensorDescription(SensorEntityDescription):
    """A sensor, and how to read its value off a poll."""

    value_fn: Callable[[Snapshot], StateType]


def _temperature(
    key: str,
    register: Register,
    *,
    translation_key: str | None = None,
    circuit: int | None = None,
) -> OvumSensorDescription:
    return OvumSensorDescription(
        key=key,
        translation_key=translation_key or key,
        translation_placeholders=None if circuit is None else {"circuit": str(circuit)},
        device_class=SensorDeviceClass.TEMPERATURE,
        native_unit_of_measurement=UnitOfTemperature.CELSIUS,
        state_class=SensorStateClass.MEASUREMENT,
        suggested_display_precision=1,
        value_fn=lambda data: data[register],
    )


def _power(key: str, register: Register) -> OvumSensorDescription:
    return OvumSensorDescription(
        key=key,
        translation_key=key,
        device_class=SensorDeviceClass.POWER,
        native_unit_of_measurement=UnitOfPower.KILO_WATT,
        state_class=SensorStateClass.MEASUREMENT,
        suggested_display_precision=2,
        value_fn=lambda data: data[register],
    )


def _enum(
    key: str,
    register: Register,
    options: Mapping[int, str],
    *,
    translation_key: str | None = None,
    circuit: int | None = None,
    entity_category: EntityCategory | None = None,
) -> OvumSensorDescription:
    def value(data: Snapshot) -> str | None:
        raw = data[register]
        return options.get(raw) if isinstance(raw, int) else None

    return OvumSensorDescription(
        key=key,
        translation_key=translation_key or key,
        translation_placeholders=None if circuit is None else {"circuit": str(circuit)},
        device_class=SensorDeviceClass.ENUM,
        options=list(options.values()),
        entity_category=entity_category,
        value_fn=value,
    )


def _cop(data: Snapshot) -> float | None:
    power_input, heat_output = data[POWER_INPUT], data[HEAT_OUTPUT]
    if not isinstance(power_input, float) or not isinstance(heat_output, float):
        return None
    if power_input < COP_MIN_POWER_INPUT:
        return None
    return round(heat_output / power_input, 2)


SENSORS: tuple[OvumSensorDescription, ...] = (
    _enum("status", STATUS, STATUS_OPTIONS),
    _power("power_input", POWER_INPUT),
    _power("heat_output", HEAT_OUTPUT),
    OvumSensorDescription(
        key="cop",
        translation_key="cop",
        state_class=SensorStateClass.MEASUREMENT,
        suggested_display_precision=2,
        value_fn=_cop,
    ),
    OvumSensorDescription(
        key="demand",
        translation_key="demand",
        native_unit_of_measurement=PERCENTAGE,
        state_class=SensorStateClass.MEASUREMENT,
        value_fn=lambda data: data[DEMAND],
    ),
    OvumSensorDescription(
        key="compressor_runtime",
        translation_key="compressor_runtime",
        device_class=SensorDeviceClass.DURATION,
        native_unit_of_measurement=UnitOfTime.MINUTES,
        suggested_unit_of_measurement=UnitOfTime.HOURS,
        suggested_display_precision=0,
        state_class=SensorStateClass.TOTAL_INCREASING,
        value_fn=lambda data: data[COMPRESSOR_RUNTIME],
    ),
    _temperature("condenser_inlet", CONDENSER_INLET),
    _temperature("condenser_outlet", CONDENSER_OUTLET),
    _temperature("outdoor_temperature", OUTDOOR_TEMPERATURE),
    _temperature("hot_water_top", HOT_WATER_TOP),
    _temperature("hot_water_bottom", HOT_WATER_BOTTOM),
    _temperature("hot_water_target_active", HOT_WATER_TARGET_ACTIVE),
    _temperature("buffer_top", BUFFER_TOP),
    _temperature("buffer_bottom", BUFFER_BOTTOM),
    _temperature("buffer_target_active", BUFFER_TARGET_ACTIVE),
    *(
        sensor
        for circuit in CIRCUITS
        for sensor in (
            _temperature(
                f"circuit_{circuit.number}_flow_temperature",
                circuit.flow_temperature,
                translation_key="circuit_flow_temperature",
                circuit=circuit.number,
            ),
            _temperature(
                f"circuit_{circuit.number}_flow_target",
                circuit.flow_target,
                translation_key="circuit_flow_target",
                circuit=circuit.number,
            ),
            _enum(
                f"circuit_{circuit.number}_type",
                circuit.type,
                CIRCUIT_TYPE_OPTIONS,
                translation_key="circuit_type",
                circuit=circuit.number,
                entity_category=EntityCategory.DIAGNOSTIC,
            ),
        )
    ),
    _temperature(
        "circuit_1_room_temperature",
        CIRCUIT_1_ROOM_TEMPERATURE,
        translation_key="circuit_room_temperature",
        circuit=1,
    ),
    _enum(
        "hot_water_function",
        HOT_WATER_FUNCTION,
        PRESENT_OPTIONS,
        entity_category=EntityCategory.DIAGNOSTIC,
    ),
    _enum(
        "buffer_type",
        BUFFER_TYPE,
        BUFFER_OPTIONS,
        entity_category=EntityCategory.DIAGNOSTIC,
    ),
    OvumSensorDescription(
        key="system_name",
        translation_key="system_name",
        entity_category=EntityCategory.DIAGNOSTIC,
        value_fn=lambda data: data[SYSTEM_NAME],
    ),
)


async def async_setup_entry(
    hass: HomeAssistant,
    entry: OvumConfigEntry,
    async_add_entities: AddConfigEntryEntitiesCallback,
) -> None:
    """Set up the Ovum sensors."""
    async_add_entities(
        OvumSensor(entry.runtime_data, description) for description in SENSORS
    )


class OvumSensor(OvumEntity, SensorEntity):
    """A value read off the controller."""

    entity_description: OvumSensorDescription

    @property
    @override
    def native_value(self) -> StateType:
        """Return the value from the last poll."""
        return self.entity_description.value_fn(self.coordinator.data)
