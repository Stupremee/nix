"""Feeding the controller's EMS registers from the house's inverter."""

from collections.abc import Callable
from dataclasses import dataclass
from datetime import datetime, timedelta
import logging

from homeassistant.components.number import (
    ATTR_VALUE,
    DOMAIN as NUMBER_DOMAIN,
    SERVICE_SET_VALUE,
)
from homeassistant.const import (
    ATTR_ENTITY_ID,
    STATE_UNAVAILABLE,
    STATE_UNKNOWN,
    UnitOfPower,
)
from homeassistant.core import HomeAssistant
from homeassistant.exceptions import HomeAssistantError
from homeassistant.helpers.event import async_track_time_interval
from homeassistant.util.unit_conversion import PowerConverter

from .coordinator import OvumCoordinator
from .registers import (
    EMS_BATTERY_SOC,
    EMS_GRID_POWER,
    EMS_INVERTER_POWER,
    EMS_PV_STATUS,
    EMS_TARGET_POWER,
    POWER_INPUT,
    STATUS,
    STATUS_OPTIONS,
    Register,
)
from .regulator import EmsState, Plan, PvStatus, Reading, Regulator

_LOGGER = logging.getLogger(__name__)

INTERVAL = timedelta(seconds=30)
# Mirrored powers are rounded so noise does not cost a write every cycle.
POWER_RESOLUTION = 50
# Statuses in which the compressor, and so the condenser pump, runs.
RUNNING = frozenset(
    raw for raw, status in STATUS_OPTIONS.items() if status in ("heating", "hot_water")
)

OFF = Plan(EmsState.OFF, PvStatus.NEUTRAL, 0)


@dataclass(frozen=True, slots=True)
class EmsInputs:
    """The entities the house's power flows are read from."""

    battery_level: str
    battery_power: str
    """Positive while discharging."""
    grid_power: str
    """Positive while importing, unless inverted."""
    pv_power: str
    grid_power_inverted: bool = False
    heating_rod: str | None = None
    """A number in kW the heating rod follows, which falls back to off unless
    it is written again within two minutes."""


class EmsController:
    """Run the regulator and write its plan, while switched on.

    Writes only the EMS process registers, which the controller keeps in RAM
    and expects an external EMS to write continuously.
    """

    def __init__(
        self,
        hass: HomeAssistant,
        coordinator: OvumCoordinator,
        inputs: EmsInputs,
    ) -> None:
        """Initialize the controller, switched off."""
        self.hass = hass
        self.coordinator = coordinator
        self.inputs = inputs
        self.regulator = Regulator()
        self.state = EmsState.OFF
        self._cancel: Callable[[], None] | None = None

    @property
    def enabled(self) -> bool:
        """Whether the regulator is running."""
        return self._cancel is not None

    async def async_enable(self) -> None:
        """Start regulating."""
        if self.enabled:
            return
        self.regulator = Regulator()
        self._cancel = async_track_time_interval(self.hass, self._async_tick, INTERVAL)
        await self._async_tick()

    async def async_disable(self) -> None:
        """Stop regulating and hand the heat pump back to its own control."""
        if self._cancel is not None:
            self._cancel()
            self._cancel = None
        self.state = EmsState.OFF
        try:
            await self._async_apply(OFF, None)
        except HomeAssistantError as err:
            _LOGGER.warning("Could not reset the EMS registers: %s", err)

    async def _async_tick(self, now: datetime | None = None) -> None:
        reading = self._read()
        plan = self.regulator.step(now or datetime.now().astimezone(), reading)
        self.state = plan.state
        try:
            await self._async_apply(plan, reading)
        except HomeAssistantError as err:
            _LOGGER.warning("Could not write the EMS registers: %s", err)
        self.coordinator.async_update_listeners()

    async def _async_apply(self, plan: Plan, reading: Reading | None) -> None:
        # Lower the status before the target, and raise the target before the
        # status, so the heat pump never runs raised on a stale target.
        if plan.status is PvStatus.RAISE:
            await self._async_write(EMS_TARGET_POWER, plan.target)
            await self._async_write(EMS_PV_STATUS, plan.status)
        else:
            await self._async_write(EMS_PV_STATUS, plan.status)
            await self._async_write(EMS_TARGET_POWER, plan.target)
        await self._async_set_rod(plan.rod)
        if reading is None:
            return
        await self._async_write(EMS_BATTERY_SOC, round(reading.battery_level))
        await self._async_write(EMS_GRID_POWER, _rounded(reading.grid_power))
        await self._async_write(EMS_INVERTER_POWER, _rounded(reading.pv_power))

    async def _async_set_rod(self, watts: int) -> None:
        # Written every cycle, even unchanged, to keep the rod's watchdog fed.
        if self.inputs.heating_rod is None:
            return
        try:
            await self.hass.services.async_call(
                NUMBER_DOMAIN,
                SERVICE_SET_VALUE,
                {ATTR_ENTITY_ID: self.inputs.heating_rod, ATTR_VALUE: watts / 1000},
                blocking=True,
            )
        except HomeAssistantError as err:
            # The rod's watchdog switches it off when this keeps failing.
            _LOGGER.warning("Could not set the heating rod: %s", err)

    async def _async_write(self, register: Register, value: int) -> None:
        if register.persistent:
            raise ValueError(f"{register} goes to flash and must not be written in a loop")
        await self.coordinator.async_write(register, value)

    def _read(self) -> Reading | None:
        heat_pump = self.coordinator.data[POWER_INPUT]
        status = self.coordinator.data[STATUS]
        level = self._number(self.inputs.battery_level, None)
        battery = self._number(self.inputs.battery_power, UnitOfPower.WATT)
        grid = self._number(self.inputs.grid_power, UnitOfPower.WATT)
        pv = self._number(self.inputs.pv_power, UnitOfPower.WATT)
        if (
            not isinstance(heat_pump, float)
            or level is None
            or battery is None
            or grid is None
            or pv is None
        ):
            return None
        return Reading(
            battery_level=level,
            battery_power=battery,
            grid_power=-grid if self.inputs.grid_power_inverted else grid,
            pv_power=pv,
            heat_pump_power=heat_pump * 1000,
            heat_pump_running=status in RUNNING,
        )

    def _number(self, entity_id: str, unit: UnitOfPower | None) -> float | None:
        state = self.hass.states.get(entity_id)
        if state is None or state.state in (STATE_UNAVAILABLE, STATE_UNKNOWN):
            return None
        try:
            value = float(state.state)
        except ValueError:
            return None
        if unit is None:
            return value
        return PowerConverter.convert(
            value, state.attributes.get("unit_of_measurement"), unit
        )


def _rounded(power: float) -> int:
    return round(power / POWER_RESOLUTION) * POWER_RESOLUTION
