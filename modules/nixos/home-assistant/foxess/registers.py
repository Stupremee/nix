"""The FoxESS H3 input register map, and how its words become values."""

from dataclasses import dataclass
from typing import Literal

from modbus_connection.decode import (
    decode_int16,
    decode_int32,
    decode_string,
    decode_uint32,
)

type Kind = Literal["u16", "i16", "u32", "i32", "str"]

_WIDTH: dict[Kind, int] = {"u32": 2, "i32": 2, "str": 16}


@dataclass(frozen=True, slots=True)
class Register:
    """One input register value, scaled and rounded the way it is shown."""

    address: int
    kind: Kind
    scale: float = 1
    precision: int = 0

    @property
    def count(self) -> int:
        """How many 16-bit registers the value spans."""
        return _WIDTH.get(self.kind, 1)

    def decode(self, words: list[int]) -> float | int | str | None:
        """Turn the registers read off the device into a value."""
        match self.kind:
            case "str":
                return decode_string(words).strip() or None
            case "u16":
                raw = words[0]
            case "i16":
                raw = decode_int16(words)
            case "u32":
                raw = decode_uint32(words)
            case "i32":
                raw = decode_int32(words)
        value = raw * self.scale
        return round(value, self.precision) if self.precision else round(value)


def u16(address: int) -> Register:
    return Register(address, "u16")


# Read once at setup: identity and firmware, which only change with an update.
MODEL = Register(30000, "str")
SERIAL = Register(30016, "str")
MANUFACTURER = Register(30032, "str")
FIRMWARE_MASTER = u16(36001)
FIRMWARE_SLAVE = u16(36002)
FIRMWARE_MANAGER = u16(36003)
BMS_FIRMWARE_MASTER = u16(37003)
BMS_FIRMWARE_SLAVE = u16(37004)
BATTERY_PACK_SERIALS = (Register(37097, "str"), Register(37113, "str"))

INFO_BLOCKS: tuple[tuple[int, int], ...] = (
    (30000, 48),
    (36001, 3),
    (37002, 3),
    (37097, 32),
)

# Polled together. Gaps inside read as zero and are never decoded; a request
# carries at most 125 registers.
BLOCKS: tuple[tuple[int, int], ...] = (
    (37002, 1),
    (37609, 28),
    (38801, 47),
    (39063, 90),
    (39162, 125),
    (39327, 16),
    (39601, 32),
)

BMS_ONLINE = u16(37002)
BMS_FAULTS = tuple(u16(address) for address in range(37626, 37632))
FORCE_CHARGE = u16(37636)
METER_CONNECTED = u16(38801)
STATUS_1 = u16(39063)
STATUS_3 = Register(39065, "u32")
ALARMS = (u16(39067), u16(39068), u16(39069))

STATUS_STANDBY = 1 << 0
STATUS_OPERATION = 1 << 2
STATUS_FAULT = 1 << 6
STATUS_3_OFF_GRID = 1 << 0


def firmware(version: int) -> str:
    """Format a firmware word the way FoxESS shows it, 0x0105 as 1.05."""
    return f"{version >> 8}.{version & 0xFF:02x}"
