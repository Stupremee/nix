"""Forcing the battery to charge."""

from dataclasses import dataclass
from typing import Any, override

from homeassistant.components.switch import SwitchEntity, SwitchEntityDescription
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddConfigEntryEntitiesCallback

from .coordinator import FoxConfigEntry
from .entity import FoxEntity, FoxEntityDescription, Part
from .registers import FORCE_CHARGE, Register

PARALLEL_UPDATES = 1


@dataclass(frozen=True, kw_only=True)
class FoxSwitchDescription(SwitchEntityDescription, FoxEntityDescription):
    """A switch over one holding register, 1 for on."""

    register: Register


SWITCHES: tuple[FoxSwitchDescription, ...] = (
    FoxSwitchDescription(
        key="bms1_force_charge_enable",
        part=Part.BATTERY,
        legacy_unique_id="ess_1_bms1_force_charge_enable",
        translation_key="force_charge",
        register=FORCE_CHARGE,
    ),
)


async def async_setup_entry(
    hass: HomeAssistant,
    entry: FoxConfigEntry,
    async_add_entities: AddConfigEntryEntitiesCallback,
) -> None:
    """Set up the FoxESS switches."""
    async_add_entities(
        FoxSwitch(entry.runtime_data, description) for description in SWITCHES
    )


class FoxSwitch(FoxEntity, SwitchEntity):
    """A switch written only when a user flips it."""

    entity_description: FoxSwitchDescription
    platform_domain = "switch"

    @property
    @override
    def is_on(self) -> bool | None:
        """Return the state from the last poll."""
        value = self.coordinator.data.raw(self.entity_description.register)
        return None if value is None else value == 1

    @override
    async def async_turn_on(self, **kwargs: Any) -> None:
        """Turn the switch on."""
        await self.coordinator.async_write(self.entity_description.register, 1)

    @override
    async def async_turn_off(self, **kwargs: Any) -> None:
        """Turn the switch off."""
        await self.coordinator.async_write(self.entity_description.register, 0)
