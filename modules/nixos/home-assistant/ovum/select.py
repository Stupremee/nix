"""Choices a user can make on the controller."""

from collections.abc import Mapping
from dataclasses import dataclass
from typing import override

from homeassistant.components.select import SelectEntity, SelectEntityDescription
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddConfigEntryEntitiesCallback

from .coordinator import OvumConfigEntry
from .entity import OvumEntity
from .registers import (
    CIRCUIT_MODE_OPTIONS,
    CIRCUITS,
    EMS_PV_STATUS,
    HOT_WATER,
    ON_OFF_OPTIONS,
    PV_STATUS_OPTIONS,
    Register,
)

PARALLEL_UPDATES = 1


@dataclass(frozen=True, kw_only=True)
class OvumSelectDescription(SelectEntityDescription):
    """A choice, the register it is written to, and what each value means."""

    register: Register
    choices: Mapping[int, str]


SELECTS: tuple[OvumSelectDescription, ...] = (
    OvumSelectDescription(
        key="hot_water",
        translation_key="hot_water",
        register=HOT_WATER,
        choices=ON_OFF_OPTIONS,
    ),
    *(
        OvumSelectDescription(
            key=f"circuit_{circuit.number}_mode",
            translation_key="circuit_mode",
            translation_placeholders={"circuit": str(circuit.number)},
            register=circuit.mode,
            choices=CIRCUIT_MODE_OPTIONS,
        )
        for circuit in CIRCUITS
    ),
    OvumSelectDescription(
        key="ems_pv_status",
        translation_key="ems_pv_status",
        register=EMS_PV_STATUS,
        choices=PV_STATUS_OPTIONS,
    ),
)


async def async_setup_entry(
    hass: HomeAssistant,
    entry: OvumConfigEntry,
    async_add_entities: AddConfigEntryEntitiesCallback,
) -> None:
    """Set up the Ovum selects."""
    async_add_entities(
        OvumSelect(entry.runtime_data, description) for description in SELECTS
    )


class OvumSelect(OvumEntity, SelectEntity):
    """A choice written only when a user changes it."""

    entity_description: OvumSelectDescription

    @property
    @override
    def options(self) -> list[str]:
        """Return every choice the register accepts."""
        return list(self.entity_description.choices.values())

    @property
    @override
    def current_option(self) -> str | None:
        """Return the choice from the last poll."""
        raw = self.coordinator.data[self.entity_description.register]
        return (
            self.entity_description.choices.get(raw) if isinstance(raw, int) else None
        )

    @override
    async def async_select_option(self, option: str) -> None:
        """Write the chosen value."""
        value = next(
            raw
            for raw, choice in self.entity_description.choices.items()
            if choice == option
        )
        await self.coordinator.async_write(self.entity_description.register, value)
