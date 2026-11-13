"""Polling the controller, and the one path that writes to it."""

import asyncio
from collections.abc import Mapping
from dataclasses import dataclass
from datetime import timedelta
import logging
from typing import override

from modbus_connection import ModbusError, ModbusUnit
from modbus_connection.encode import encode_int32

from homeassistant.config_entries import ConfigEntry
from homeassistant.core import HomeAssistant
from homeassistant.exceptions import HomeAssistantError
from homeassistant.helpers.device_registry import DeviceInfo
from homeassistant.helpers.update_coordinator import DataUpdateCoordinator, UpdateFailed

from .const import DOMAIN, NAME
from .registers import BLOCKS, LOGIN_CODE, LOGIN_STATUS, Module, Register, Value

_LOGGER = logging.getLogger(__name__)

SCAN_INTERVAL = timedelta(seconds=30)
# The controller answers login attempts at most once a second.
LOGIN_SETTLE = 1.1

type OvumConfigEntry = ConfigEntry[OvumCoordinator]


@dataclass(frozen=True, slots=True)
class Snapshot:
    """The raw words of one poll, decoded on access."""

    words: Mapping[tuple[Module, int], int]

    def __getitem__(self, register: Register) -> Value | None:
        try:
            words = [
                self.words[register.module, register.address + offset]
                for offset in range(register.count)
            ]
        except KeyError:
            return None
        return register.decode(words)

    def updated(self, register: Register, words: list[int]) -> Snapshot:
        """Return a copy with one register's words replaced."""
        return Snapshot(
            {
                **self.words,
                **{
                    (register.module, register.address + offset): word
                    for offset, word in enumerate(words)
                },
            }
        )


class OvumCoordinator(DataUpdateCoordinator[Snapshot]):
    """Read every START-level register, and write the ones a user changes."""

    config_entry: OvumConfigEntry

    def __init__(
        self,
        hass: HomeAssistant,
        entry: OvumConfigEntry,
        units: Mapping[Module, ModbusUnit],
        login_code: int | None,
    ) -> None:
        """Initialize the coordinator."""
        super().__init__(
            hass,
            _LOGGER,
            config_entry=entry,
            name=NAME,
            update_interval=SCAN_INTERVAL,
        )
        self.units = units
        self._login_code = login_code
        self._write_lock = asyncio.Lock()
        self.device_info = DeviceInfo(
            identifiers={(DOMAIN, entry.unique_id or entry.entry_id)},
            name=NAME,
            manufacturer=NAME,
            model="MIRA",
        )

    @override
    async def _async_update_data(self) -> Snapshot:
        words: dict[tuple[Module, int], int] = {}
        try:
            for module, start, count in BLOCKS:
                block = await self.units[module].read_holding_registers(start, count)
                words.update(
                    {(module, start + offset): word for offset, word in enumerate(block)}
                )
        except ModbusError as err:
            raise UpdateFailed(
                translation_domain=DOMAIN,
                translation_key="cannot_connect",
                translation_placeholders={"error": str(err)},
            ) from err
        return Snapshot(words)

    async def async_write(self, register: Register, value: float) -> None:
        """Write a value a user set, then read it back.

        P_ registers go to flash on every write, so this runs only from a user
        action, and skips values the device already holds.
        """
        async with self._write_lock:
            if self.data[register] == value:
                return
            unit = self.units[register.module]
            words = register.encode(value)
            try:
                await self._async_ensure_login(unit)
                if len(words) == 1:
                    await unit.write_register(register.address, words[0])
                else:
                    await unit.write_registers(register.address, words)
                readback = await unit.read_holding_registers(
                    register.address, register.count
                )
            except ModbusError as err:
                raise HomeAssistantError(
                    translation_domain=DOMAIN,
                    translation_key="write_failed",
                    translation_placeholders={"error": str(err)},
                ) from err
            self.async_set_updated_data(self.data.updated(register, readback))

        if (stored := self.data[register]) != value:
            raise HomeAssistantError(
                translation_domain=DOMAIN,
                translation_key="write_rejected",
                translation_placeholders={"value": str(value), "stored": str(stored)},
            )

    async def _async_ensure_login(self, unit: ModbusUnit) -> None:
        """Log the unit in unless it still is from an earlier write."""
        [status] = await unit.read_holding_registers(LOGIN_STATUS, 1)
        if status == 1:
            return
        if self._login_code is None:
            raise HomeAssistantError(
                translation_domain=DOMAIN, translation_key="login_required"
            )
        await unit.write_registers(LOGIN_CODE, encode_int32(self._login_code))
        await asyncio.sleep(LOGIN_SETTLE)
        [status] = await unit.read_holding_registers(LOGIN_STATUS, 1)
        if status != 1:
            raise HomeAssistantError(
                translation_domain=DOMAIN, translation_key="login_rejected"
            )
