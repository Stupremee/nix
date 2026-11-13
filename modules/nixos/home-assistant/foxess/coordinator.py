"""Polling the inverter, and the one path that writes to it."""

from collections.abc import Mapping
from dataclasses import dataclass
from datetime import timedelta
import logging
from typing import override

from modbus_connection import ModbusError, ModbusUnit

from homeassistant.config_entries import ConfigEntry
from homeassistant.core import HomeAssistant
from homeassistant.exceptions import HomeAssistantError
from homeassistant.helpers.update_coordinator import DataUpdateCoordinator, UpdateFailed

from .const import DOMAIN
from .registers import (
    BATTERY_PACK_SERIALS,
    BLOCKS,
    BMS_FIRMWARE_MASTER,
    BMS_FIRMWARE_SLAVE,
    FIRMWARE_MANAGER,
    FIRMWARE_MASTER,
    FIRMWARE_SLAVE,
    INFO_BLOCKS,
    MANUFACTURER,
    MODEL,
    SERIAL,
    Register,
    firmware,
)

_LOGGER = logging.getLogger(__name__)

SCAN_INTERVAL = timedelta(seconds=5)

type FoxConfigEntry = ConfigEntry[FoxCoordinator]


@dataclass(frozen=True, slots=True)
class Snapshot:
    """The raw words of one read, decoded on access."""

    words: Mapping[int, int]

    def __getitem__(self, register: Register) -> float | int | str | None:
        try:
            words = [
                self.words[register.address + offset]
                for offset in range(register.count)
            ]
        except KeyError:
            return None
        return register.decode(words)

    def raw(self, register: Register) -> int | None:
        """Return a register's unscaled integer, for bitfields."""
        value = self[Register(register.address, register.kind)]
        return value if isinstance(value, int) else None


@dataclass(frozen=True, slots=True)
class DeviceIdentity:
    """What the inverter says about itself, read once at setup."""

    model: str
    serial: str
    manufacturer: str
    firmware: str
    battery_firmware: str
    battery_packs: str


async def _async_read(
    unit: ModbusUnit, blocks: tuple[tuple[int, int], ...]
) -> Snapshot:
    words: dict[int, int] = {}
    for start, count in blocks:
        block = await unit.read_input_registers(start, count)
        words.update({start + offset: word for offset, word in enumerate(block)})
    return Snapshot(words)


async def async_read_identity(unit: ModbusUnit) -> DeviceIdentity:
    """Read model, serial and firmware off the inverter."""
    info = await _async_read(unit, INFO_BLOCKS)
    serial = info[SERIAL]
    if not isinstance(serial, str):
        raise ModbusError("The inverter reported no serial number")
    versions = (
        info.raw(FIRMWARE_MASTER),
        info.raw(FIRMWARE_SLAVE),
        info.raw(FIRMWARE_MANAGER),
    )
    return DeviceIdentity(
        model=str(info[MODEL] or "H3"),
        serial=serial,
        manufacturer=str(info[MANUFACTURER] or "FoxESS"),
        firmware=" / ".join(
            f"{part} {firmware(version)}"
            for part, version in zip(
                ("Master", "Slave", "Manager"), versions, strict=True
            )
            if version is not None
        ),
        battery_firmware=" / ".join(
            f"{part} {firmware(version)}"
            for part, version in zip(
                ("Master", "Slave"),
                (info.raw(BMS_FIRMWARE_MASTER), info.raw(BMS_FIRMWARE_SLAVE)),
                strict=True,
            )
            if version is not None
        ),
        battery_packs=", ".join(
            str(serial)
            for register in BATTERY_PACK_SERIALS
            if (serial := info[register])
        ),
    )


class FoxCoordinator(DataUpdateCoordinator[Snapshot]):
    """Read every polled register block every few seconds."""

    config_entry: FoxConfigEntry

    def __init__(
        self,
        hass: HomeAssistant,
        entry: FoxConfigEntry,
        unit: ModbusUnit,
        identity: DeviceIdentity,
        inverter_device_id: str,
    ) -> None:
        """Initialize the coordinator."""
        super().__init__(
            hass,
            _LOGGER,
            config_entry=entry,
            name=identity.model,
            update_interval=SCAN_INTERVAL,
        )
        self.unit = unit
        self.identity = identity
        self.inverter_device_id = inverter_device_id

    @override
    async def _async_update_data(self) -> Snapshot:
        try:
            return await _async_read(self.unit, BLOCKS)
        except ModbusError as err:
            raise UpdateFailed(
                translation_domain=DOMAIN,
                translation_key="cannot_connect",
                translation_placeholders={"error": str(err)},
            ) from err

    async def async_write(self, register: Register, value: int) -> None:
        """Write one holding register a user changed, then read it back."""
        try:
            await self.unit.write_register(register.address, value)
            [stored] = await self.unit.read_holding_registers(register.address, 1)
        except ModbusError as err:
            raise HomeAssistantError(
                translation_domain=DOMAIN,
                translation_key="write_failed",
                translation_placeholders={"error": str(err)},
            ) from err
        if stored != value:
            raise HomeAssistantError(
                translation_domain=DOMAIN,
                translation_key="write_rejected",
                translation_placeholders={"value": str(value), "stored": str(stored)},
            )
        await self.async_request_refresh()
