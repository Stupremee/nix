"""The MIRA START-level register map, and how its words become values."""

from collections.abc import Mapping
from dataclasses import dataclass
from enum import IntEnum
import math
from typing import Literal

from modbus_connection.decode import (
    decode_float32,
    decode_int16,
    decode_int32,
    decode_string,
)
from modbus_connection.encode import encode_float32, encode_int16, encode_int32


class Module(IntEnum):
    """The unit ids the MIRA controller answers on."""

    HSM = 110
    """Hydraulics: hot water, heating buffer, heating circuits, EMS inputs."""
    WPM = 111
    """The heat pump itself: power, status, condenser, compressor."""


type Kind = Literal["s16", "s32", "float", "p_int", "p_float", "p_wahl", "p_text"]
type Value = int | float | str

_WIDTH: Mapping[Kind, int] = {"s32": 2, "float": 2, "p_float": 2, "p_text": 10}


@dataclass(frozen=True, slots=True)
class Register:
    """One value in the register map."""

    module: Module
    address: int
    kind: Kind

    @property
    def count(self) -> int:
        """How many 16-bit registers the value spans."""
        return _WIDTH.get(self.kind, 1)

    @property
    def persistent(self) -> bool:
        """Whether every write lands in the controller's flash."""
        return self.kind.startswith("p_")

    def decode(self, words: list[int]) -> Value | None:
        """Turn the registers read off the device into a value."""
        match self.kind:
            case "s16" | "p_int":
                return decode_int16(words)
            case "p_wahl":
                return words[0]
            case "s32":
                return decode_int32(words)
            case "float" | "p_float":
                value = decode_float32(words)
                # The controller keeps one decimal; float32 adds noise below it.
                return round(value, 2) if math.isfinite(value) else None
            case "p_text":
                return decode_string(words).strip() or None

    def encode(self, value: float) -> list[int]:
        """Turn a value into the registers to write in one request."""
        match self.kind:
            case "s16" | "p_int" | "p_wahl":
                return encode_int16(int(value))
            case "s32":
                return encode_int32(int(value))
            case "float" | "p_float":
                return encode_float32(value)
            case "p_text":
                raise ValueError("Text registers are read-only here")


@dataclass(frozen=True, slots=True)
class HeatingCircuit:
    """A heating circuit, whose registers repeat from its base address."""

    number: int
    base: int

    @property
    def type(self) -> Register:
        return Register(Module.HSM, self.base, "p_wahl")

    @property
    def pv_raise(self) -> Register:
        return Register(Module.HSM, self.base + 1, "p_int")

    @property
    def pv_lower(self) -> Register:
        return Register(Module.HSM, self.base + 2, "p_int")

    @property
    def flow_target(self) -> Register:
        return Register(Module.HSM, self.base + 3, "float")

    @property
    def flow_temperature(self) -> Register:
        return Register(Module.HSM, self.base + 5, "float")

    @property
    def mode(self) -> Register:
        return Register(Module.HSM, self.base + 7, "p_wahl")

    @property
    def room_target(self) -> Register:
        return Register(Module.HSM, self.base + 8, "p_float")


HOT_WATER = Register(Module.HSM, 55000, "p_wahl")
HOT_WATER_TARGET = Register(Module.HSM, 55001, "p_int")
HOT_WATER_TARGET_PV = Register(Module.HSM, 55002, "p_int")
HOT_WATER_FUNCTION = Register(Module.HSM, 55003, "p_wahl")
HOT_WATER_TARGET_ACTIVE = Register(Module.HSM, 55004, "float")
HOT_WATER_TOP = Register(Module.HSM, 55007, "float")
HOT_WATER_BOTTOM = Register(Module.HSM, 55009, "float")

BUFFER_TYPE = Register(Module.HSM, 55020, "p_wahl")
BUFFER_TARGET_PV = Register(Module.HSM, 55021, "p_int")
BUFFER_TARGET_ACTIVE = Register(Module.HSM, 55023, "float")
BUFFER_TOP = Register(Module.HSM, 55026, "float")
BUFFER_BOTTOM = Register(Module.HSM, 55028, "float")

EMS_PV_STATUS = Register(Module.HSM, 55070, "s16")
EMS_BATTERY_SOC = Register(Module.HSM, 55071, "s16")
EMS_GRID_POWER = Register(Module.HSM, 55072, "s32")
EMS_INVERTER_POWER = Register(Module.HSM, 55074, "s32")
EMS_TARGET_POWER = Register(Module.HSM, 55076, "s32")

# Empty on the HSM, so read off the heat pump.
SYSTEM_NAME = Register(Module.WPM, 56000, "p_text")
DEMAND = Register(Module.WPM, 56020, "s16")
POWER_INPUT = Register(Module.WPM, 56021, "float")
HEAT_OUTPUT = Register(Module.WPM, 56023, "float")
STATUS = Register(Module.WPM, 56025, "s16")
CONDENSER_INLET = Register(Module.WPM, 56026, "float")
CONDENSER_OUTLET = Register(Module.WPM, 56028, "float")
COMPRESSOR_RUNTIME = Register(Module.WPM, 56030, "s32")

OUTDOOR_TEMPERATURE = Register(Module.HSM, 56048, "float")
CIRCUITS = (HeatingCircuit(1, 56050), HeatingCircuit(2, 56060))
CIRCUIT_1_ROOM_TEMPERATURE = Register(Module.HSM, 56152, "float")

# The widest spans the controller serves in one read; wider ones fail with
# exception 2. Gaps inside them read as 0xFFFF and are never decoded.
BLOCKS: tuple[tuple[Module, int, int], ...] = (
    (Module.HSM, 55000, 30),
    (Module.HSM, 55070, 8),
    (Module.HSM, 56048, 22),
    (Module.HSM, 56152, 2),
    (Module.WPM, 56000, 32),
)

LOGIN_STATUS = 100
LOGIN_CODE = 101

STATUS_OPTIONS: Mapping[int, str] = {
    0: "fault",
    1: "inverter_offline",
    3: "blocked",
    4: "oil_preheating",
    5: "ready",
    6: "starting",
    7: "hot_water",
    8: "heating",
    9: "cooling",
    10: "defrosting",
    11: "manual_deicing",
    12: "stopping",
    13: "below_operating_limit",
    14: "inverter_reset",
}
ON_OFF_OPTIONS: Mapping[int, str] = {0: "off", 1: "on"}
PRESENT_OPTIONS: Mapping[int, str] = {0: "not_present", 1: "present"}
BUFFER_OPTIONS: Mapping[int, str] = {0: "none", 1: "buffer", 2: "cube_storage"}
CIRCUIT_TYPE_OPTIONS: Mapping[int, str] = {
    0: "none",
    1: "unmixed",
    2: "return",
    3: "mixed",
    4: "cube_direct",
}
CIRCUIT_MODE_OPTIONS: Mapping[int, str] = {
    0: "off",
    1: "automatic",
    2: "winter",
    3: "summer",
}
PV_STATUS_OPTIONS: Mapping[int, str] = {0: "neutral", 1: "raise", 2: "lower"}
