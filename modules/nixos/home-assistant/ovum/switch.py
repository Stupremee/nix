"""Switching the PV surplus regulation on and off."""

from typing import Any, override

from homeassistant.components.switch import SwitchEntity, SwitchEntityDescription
from homeassistant.const import STATE_ON
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddConfigEntryEntitiesCallback
from homeassistant.helpers.restore_state import RestoreEntity

from .coordinator import OvumConfigEntry, OvumCoordinator
from .ems import EmsController
from .entity import OvumEntity

PARALLEL_UPDATES = 1

PV_SURPLUS = SwitchEntityDescription(key="pv_surplus", translation_key="pv_surplus")


async def async_setup_entry(
    hass: HomeAssistant,
    entry: OvumConfigEntry,
    async_add_entities: AddConfigEntryEntitiesCallback,
) -> None:
    """Set up the switch, if the EMS inputs are configured."""
    coordinator = entry.runtime_data
    if coordinator.ems is not None:
        async_add_entities([OvumPvSurplusSwitch(coordinator, coordinator.ems)])


class OvumPvSurplusSwitch(OvumEntity, RestoreEntity, SwitchEntity):
    """Run the EMS regulator, off until someone turns it on."""

    _attr_is_on = False

    def __init__(self, coordinator: OvumCoordinator, ems: EmsController) -> None:
        """Initialize the switch."""
        super().__init__(coordinator, PV_SURPLUS)
        self._ems = ems

    @override
    async def async_added_to_hass(self) -> None:
        """Resume regulating if it was on before a restart."""
        await super().async_added_to_hass()
        if (last := await self.async_get_last_state()) and last.state == STATE_ON:
            await self.async_turn_on()

    @override
    async def async_turn_on(self, **kwargs: Any) -> None:
        """Start regulating."""
        self._attr_is_on = True
        self.async_write_ha_state()
        await self._ems.async_enable()

    @override
    async def async_turn_off(self, **kwargs: Any) -> None:
        """Stop regulating and reset the EMS registers."""
        self._attr_is_on = False
        self.async_write_ha_state()
        await self._ems.async_disable()
