"""Connection states, and whether the inverter or battery reports a problem."""

from collections.abc import Mapping
from dataclasses import dataclass
from typing import Any, override

from homeassistant.components.binary_sensor import (
    BinarySensorDeviceClass,
    BinarySensorEntity,
    BinarySensorEntityDescription,
)
from homeassistant.const import EntityCategory
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddConfigEntryEntitiesCallback

from .coordinator import FoxConfigEntry, Snapshot
from .entity import FoxEntity, FoxEntityDescription, Part
from .registers import ALARMS, BMS_FAULTS, BMS_ONLINE, METER_CONNECTED, Register

PARALLEL_UPDATES = 0


@dataclass(frozen=True, kw_only=True)
class FoxBinarySensorDescription(BinarySensorEntityDescription, FoxEntityDescription):
    """A binary sensor that is on while any of its registers is non-zero."""

    registers: tuple[Register, ...]


BINARY_SENSORS: tuple[FoxBinarySensorDescription, ...] = (
    FoxBinarySensorDescription(
        key="bms1_online",
        part=Part.BATTERY,
        legacy_unique_id="ess_1_bms1_online",
        translation_key="bms_online",
        device_class=BinarySensorDeviceClass.CONNECTIVITY,
        entity_category=EntityCategory.DIAGNOSTIC,
        registers=(BMS_ONLINE,),
    ),
    FoxBinarySensorDescription(
        key="meter1_connected",
        part=Part.GRID,
        legacy_unique_id="ess_1_meter1_connected",
        translation_key="meter_connected",
        device_class=BinarySensorDeviceClass.CONNECTIVITY,
        entity_category=EntityCategory.DIAGNOSTIC,
        registers=(METER_CONNECTED,),
    ),
    FoxBinarySensorDescription(
        key="alarm",
        part=Part.INVERTER,
        translation_key="alarm",
        device_class=BinarySensorDeviceClass.PROBLEM,
        registers=ALARMS,
    ),
    FoxBinarySensorDescription(
        key="bms_fault",
        part=Part.BATTERY,
        translation_key="bms_fault",
        device_class=BinarySensorDeviceClass.PROBLEM,
        registers=BMS_FAULTS,
    ),
)


async def async_setup_entry(
    hass: HomeAssistant,
    entry: FoxConfigEntry,
    async_add_entities: AddConfigEntryEntitiesCallback,
) -> None:
    """Set up the FoxESS binary sensors."""
    async_add_entities(
        FoxBinarySensor(entry.runtime_data, description)
        for description in BINARY_SENSORS
    )


def _words(data: Snapshot, registers: tuple[Register, ...]) -> list[int] | None:
    words = [data.raw(register) for register in registers]
    return None if None in words else [word for word in words if word is not None]


class FoxBinarySensor(FoxEntity, BinarySensorEntity):
    """A flag read off the inverter."""

    entity_description: FoxBinarySensorDescription
    platform_domain = "binary_sensor"

    @property
    @override
    def is_on(self) -> bool | None:
        """Return whether any of the registers is set."""
        words = _words(self.coordinator.data, self.entity_description.registers)
        return None if words is None else any(words)

    @property
    @override
    def extra_state_attributes(self) -> Mapping[str, Any] | None:
        """Expose raw problem codes, since the alarm table is not documented here."""
        if self.entity_description.device_class != BinarySensorDeviceClass.PROBLEM:
            return None
        words = _words(self.coordinator.data, self.entity_description.registers)
        if words is None:
            return None
        return {
            f"code_{number}": f"0x{word:04X}"
            for number, word in enumerate(words, start=1)
        }
