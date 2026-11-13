"""What every FoxESS entity shares, and the devices they sit on."""

from dataclasses import dataclass
from enum import StrEnum
from typing import ClassVar

from homeassistant.helpers.device_registry import DeviceInfo
from homeassistant.helpers.entity import EntityDescription
from homeassistant.helpers.update_coordinator import CoordinatorEntity

from .const import DOMAIN
from .coordinator import DeviceIdentity, FoxCoordinator


class Part(StrEnum):
    """Which part of the system an entity describes."""

    INVERTER = "inverter"
    BATTERY = "battery"
    GRID = "grid"


def device_info(
    identity: DeviceIdentity, part: Part, inverter_device_id: str | None = None
) -> DeviceInfo:
    """The device for one part, with battery and grid meter behind the inverter."""
    match part:
        case Part.INVERTER:
            return DeviceInfo(
                identifiers={(DOMAIN, identity.serial)},
                name="FoxESS",
                manufacturer=identity.manufacturer,
                model=identity.model,
                serial_number=identity.serial,
                sw_version=identity.firmware,
            )
        case Part.BATTERY:
            return DeviceInfo(
                identifiers={(DOMAIN, f"{identity.serial}_battery")},
                name="FoxESS Batterie",
                manufacturer=identity.manufacturer,
                model="BMS",
                serial_number=identity.battery_packs or None,
                sw_version=identity.battery_firmware,
                via_device_id=inverter_device_id,
            )
        case Part.GRID:
            return DeviceInfo(
                identifiers={(DOMAIN, f"{identity.serial}_grid")},
                name="FoxESS Netz",
                manufacturer=identity.manufacturer,
                model="Meter 1",
                via_device_id=inverter_device_id,
            )


@dataclass(frozen=True, kw_only=True)
class FoxEntityDescription(EntityDescription):
    """Where an entity sits, and the YAML Modbus entity it replaces."""

    part: Part
    legacy_unique_id: str | None = None


class FoxEntity(CoordinatorEntity[FoxCoordinator]):
    """An entity on one of the FoxESS devices."""

    _attr_has_entity_name = True
    entity_description: FoxEntityDescription
    platform_domain: ClassVar[str]

    def __init__(
        self, coordinator: FoxCoordinator, description: FoxEntityDescription
    ) -> None:
        """Initialize the entity."""
        super().__init__(coordinator)
        self.entity_description = description
        serial = coordinator.identity.serial
        self._attr_unique_id = f"{serial}_{description.key}"
        self._attr_device_info = device_info(
            coordinator.identity, description.part, coordinator.inverter_device_id
        )
        # Entities that never existed as YAML keep the ess_1_ prefix too.
        self.entity_id = f"{self.platform_domain}.ess_1_{description.key}"
