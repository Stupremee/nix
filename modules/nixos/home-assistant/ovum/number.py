"""Setpoints a user can change on the controller."""

from dataclasses import dataclass
from typing import override

from homeassistant.components.number import (
    NumberDeviceClass,
    NumberEntity,
    NumberEntityDescription,
    NumberMode,
)
from homeassistant.const import (
    PERCENTAGE,
    EntityCategory,
    UnitOfPower,
    UnitOfTemperature,
)
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddConfigEntryEntitiesCallback

from .coordinator import OvumConfigEntry
from .entity import OvumEntity
from .registers import (
    BUFFER_TARGET_PV,
    CIRCUITS,
    EMS_BATTERY_SOC,
    EMS_GRID_POWER,
    EMS_INVERTER_POWER,
    EMS_TARGET_POWER,
    HOT_WATER_TARGET,
    HOT_WATER_TARGET_PV,
    Register,
)

PARALLEL_UPDATES = 1

KELVIN_DIFFERENCE = "K"


@dataclass(frozen=True, kw_only=True)
class OvumNumberDescription(NumberEntityDescription):
    """A setpoint, and the register it is written to."""

    register: Register


def _temperature(
    key: str,
    register: Register,
    *,
    minimum: float,
    maximum: float,
    step: float,
    translation_key: str | None = None,
    circuit: int | None = None,
    entity_category: EntityCategory | None = None,
    enabled: bool = True,
) -> OvumNumberDescription:
    return OvumNumberDescription(
        key=key,
        translation_key=translation_key or key,
        translation_placeholders=None if circuit is None else {"circuit": str(circuit)},
        register=register,
        device_class=NumberDeviceClass.TEMPERATURE,
        native_unit_of_measurement=UnitOfTemperature.CELSIUS,
        native_min_value=minimum,
        native_max_value=maximum,
        native_step=step,
        entity_category=entity_category,
        entity_registry_enabled_default=enabled,
    )


def _ems_power(key: str, register: Register, minimum: int) -> OvumNumberDescription:
    return OvumNumberDescription(
        key=key,
        translation_key=key,
        register=register,
        device_class=NumberDeviceClass.POWER,
        native_unit_of_measurement=UnitOfPower.WATT,
        native_min_value=minimum,
        native_max_value=30000,
        native_step=1,
        entity_category=EntityCategory.CONFIG,
    )


NUMBERS: tuple[OvumNumberDescription, ...] = (
    _temperature("hot_water_target", HOT_WATER_TARGET, minimum=0, maximum=62, step=1),
    _temperature(
        "hot_water_target_pv",
        HOT_WATER_TARGET_PV,
        minimum=0,
        maximum=67,
        step=1,
        entity_category=EntityCategory.CONFIG,
    ),
    _temperature(
        "buffer_target_pv",
        BUFFER_TARGET_PV,
        minimum=0,
        maximum=70,
        step=1,
        entity_category=EntityCategory.CONFIG,
    ),
    *(
        number
        for circuit in CIRCUITS
        for number in (
            _temperature(
                f"circuit_{circuit.number}_room_target",
                circuit.room_target,
                minimum=0,
                maximum=50,
                step=0.5,
                translation_key="circuit_room_target",
                circuit=circuit.number,
            ),
            OvumNumberDescription(
                key=f"circuit_{circuit.number}_pv_raise",
                translation_key="circuit_pv_raise",
                translation_placeholders={"circuit": str(circuit.number)},
                register=circuit.pv_raise,
                native_unit_of_measurement=KELVIN_DIFFERENCE,
                native_min_value=0,
                native_max_value=25,
                native_step=1,
                entity_category=EntityCategory.CONFIG,
            ),
            OvumNumberDescription(
                key=f"circuit_{circuit.number}_pv_lower",
                translation_key="circuit_pv_lower",
                translation_placeholders={"circuit": str(circuit.number)},
                register=circuit.pv_lower,
                native_unit_of_measurement=KELVIN_DIFFERENCE,
                native_min_value=-25,
                native_max_value=0,
                native_step=1,
                entity_category=EntityCategory.CONFIG,
            ),
            # Process values the controller computes itself. Writable for
            # overrides, so off until someone means to.
            _temperature(
                f"circuit_{circuit.number}_flow_target",
                circuit.flow_target,
                minimum=0,
                maximum=80,
                step=0.1,
                translation_key="circuit_flow_target",
                circuit=circuit.number,
                entity_category=EntityCategory.CONFIG,
                enabled=False,
            ),
            _temperature(
                f"circuit_{circuit.number}_flow_temperature",
                circuit.flow_temperature,
                minimum=0,
                maximum=80,
                step=0.1,
                translation_key="circuit_flow_temperature",
                circuit=circuit.number,
                entity_category=EntityCategory.CONFIG,
                enabled=False,
            ),
        )
    ),
    OvumNumberDescription(
        key="ems_battery_soc",
        translation_key="ems_battery_soc",
        register=EMS_BATTERY_SOC,
        device_class=NumberDeviceClass.BATTERY,
        native_unit_of_measurement=PERCENTAGE,
        native_min_value=0,
        native_max_value=100,
        native_step=1,
        entity_category=EntityCategory.CONFIG,
    ),
    _ems_power("ems_grid_power", EMS_GRID_POWER, minimum=-30000),
    _ems_power("ems_inverter_power", EMS_INVERTER_POWER, minimum=0),
    _ems_power("ems_target_power", EMS_TARGET_POWER, minimum=0),
)


async def async_setup_entry(
    hass: HomeAssistant,
    entry: OvumConfigEntry,
    async_add_entities: AddConfigEntryEntitiesCallback,
) -> None:
    """Set up the Ovum setpoints."""
    async_add_entities(
        OvumNumber(entry.runtime_data, description) for description in NUMBERS
    )


class OvumNumber(OvumEntity, NumberEntity):
    """A setpoint written only when a user changes it."""

    entity_description: OvumNumberDescription
    _attr_mode = NumberMode.BOX

    @property
    @override
    def native_value(self) -> float | None:
        """Return the value from the last poll."""
        value = self.coordinator.data[self.entity_description.register]
        return value if isinstance(value, int | float) else None

    @override
    async def async_set_native_value(self, value: float) -> None:
        """Write the value, snapped to the step so it cannot drift."""
        step = self.entity_description.native_step or 1
        await self.coordinator.async_write(
            self.entity_description.register, round(round(value / step) * step, 2)
        )
