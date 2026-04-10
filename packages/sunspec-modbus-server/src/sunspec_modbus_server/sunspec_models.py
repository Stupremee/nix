"""SunSpec model definitions and encoding helpers."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


def encode_u16(value: int) -> list[int]:
    """Encode an unsigned 16-bit register."""
    return [int(value) & 0xFFFF]


def encode_i16(value: int) -> list[int]:
    """Encode a signed 16-bit register."""
    if not -32768 <= int(value) <= 32767:
        raise ValueError(f"int16 out of range: {value}")
    return [int(value) & 0xFFFF]


def encode_u32(value: int) -> list[int]:
    """Encode an unsigned 32-bit value into two holding registers."""
    encoded = int(value) & 0xFFFFFFFF
    return [(encoded >> 16) & 0xFFFF, encoded & 0xFFFF]


def encode_u64(value: int) -> list[int]:
    """Encode an unsigned 64-bit value into four holding registers."""
    encoded = int(value) & 0xFFFFFFFFFFFFFFFF
    return [
        (encoded >> 48) & 0xFFFF,
        (encoded >> 32) & 0xFFFF,
        (encoded >> 16) & 0xFFFF,
        encoded & 0xFFFF,
    ]


def encode_string(text: str, registers: int) -> list[int]:
    """Encode a SunSpec string field."""
    width = registers * 2
    encoded = text.encode("ascii", errors="ignore")[:width]
    padded = encoded.ljust(width, b"\x00")
    return [
        (padded[index] << 8) | padded[index + 1]
        for index in range(0, len(padded), 2)
    ]


@dataclass(frozen=True)
class FieldDefinition:
    """One field inside a SunSpec model."""

    offset: int
    kind: str
    length: int = 1


@dataclass(frozen=True)
class ModelDefinition:
    """One SunSpec model definition."""

    model_id: int
    length: int
    fields: dict[str, FieldDefinition]


@dataclass(frozen=True)
class ModelPlacement:
    """One concrete model instance in the register map."""

    name: str
    definition: ModelDefinition
    header_offset: int

    @property
    def data_offset(self) -> int:
        """Return the start of the model data block relative to SunSpec base."""
        return self.header_offset + 2


@dataclass(frozen=True)
class RegisterLayout:
    """Complete SunSpec register layout."""

    base_address: int
    placements: dict[str, ModelPlacement]
    end_marker_address: int

    def field_address(self, placement_name: str, field_name: str) -> int:
        """Return the absolute raw Modbus address of a field."""
        placement = self.placements[placement_name]
        field = placement.definition.fields[field_name]
        return self.base_address + placement.data_offset + field.offset

    @property
    def start_address(self) -> int:
        """Return the first served address."""
        return self.base_address

    @property
    def end_address(self) -> int:
        """Return the last served address, including the end marker."""
        return self.end_marker_address


def _build_model_definition(
    *,
    model_id: int,
    length: int,
    points: list[tuple[str, str, int]],
) -> ModelDefinition:
    offset = 0
    fields: dict[str, FieldDefinition] = {}
    for name, kind, point_length in points:
        fields[name] = FieldDefinition(offset=offset, kind=kind, length=point_length)
        offset += point_length
    if offset != length:
        raise ValueError(
            f"Model {model_id} point lengths add up to {offset}, expected {length}"
        )
    return ModelDefinition(model_id=model_id, length=length, fields=fields)


COMMON_MODEL = ModelDefinition(
    model_id=1,
    length=66,
    fields={
        "Mn": FieldDefinition(0, "string", length=16),
        "Md": FieldDefinition(16, "string", length=16),
        "Opt": FieldDefinition(32, "string", length=8),
        "Vr": FieldDefinition(40, "string", length=8),
        "SN": FieldDefinition(48, "string", length=16),
        "DA": FieldDefinition(64, "u16"),
    },
)

INVERTER_MODEL = ModelDefinition(
    model_id=103,
    length=50,
    fields={
        "A": FieldDefinition(0, "u16"),
        "AphA": FieldDefinition(1, "u16"),
        "AphB": FieldDefinition(2, "u16"),
        "AphC": FieldDefinition(3, "u16"),
        "A_SF": FieldDefinition(4, "i16"),
        "PPVphAB": FieldDefinition(5, "u16"),
        "PPVphBC": FieldDefinition(6, "u16"),
        "PPVphCA": FieldDefinition(7, "u16"),
        "PhVphA": FieldDefinition(8, "u16"),
        "PhVphB": FieldDefinition(9, "u16"),
        "PhVphC": FieldDefinition(10, "u16"),
        "V_SF": FieldDefinition(11, "i16"),
        "W": FieldDefinition(12, "i16"),
        "W_SF": FieldDefinition(13, "i16"),
        "Hz": FieldDefinition(14, "u16"),
        "Hz_SF": FieldDefinition(15, "i16"),
        "VA": FieldDefinition(16, "i16"),
        "VA_SF": FieldDefinition(17, "i16"),
        "VAr": FieldDefinition(18, "i16"),
        "VAr_SF": FieldDefinition(19, "i16"),
        "PF": FieldDefinition(20, "i16"),
        "PF_SF": FieldDefinition(21, "i16"),
        "WH": FieldDefinition(22, "u32", length=2),
        "WH_SF": FieldDefinition(24, "i16"),
        "DCA": FieldDefinition(25, "u16"),
        "DCA_SF": FieldDefinition(26, "i16"),
        "DCV": FieldDefinition(27, "u16"),
        "DCV_SF": FieldDefinition(28, "i16"),
        "DCW": FieldDefinition(29, "i16"),
        "DCW_SF": FieldDefinition(30, "i16"),
        "TmpCab": FieldDefinition(31, "i16"),
        "TmpSnk": FieldDefinition(32, "i16"),
        "TmpTrns": FieldDefinition(33, "i16"),
        "TmpOt": FieldDefinition(34, "i16"),
        "Tmp_SF": FieldDefinition(35, "i16"),
        "St": FieldDefinition(36, "u16"),
        "StVnd": FieldDefinition(37, "u16"),
        "Evt1": FieldDefinition(38, "u32", length=2),
        "Evt2": FieldDefinition(40, "u32", length=2),
        "EvtVnd1": FieldDefinition(42, "u32", length=2),
        "EvtVnd2": FieldDefinition(44, "u32", length=2),
        "EvtVnd3": FieldDefinition(46, "u32", length=2),
        "EvtVnd4": FieldDefinition(48, "u32", length=2),
    },
)

METER_MODEL = _build_model_definition(
    model_id=203,
    length=105,
    points=[
        # SunSpec model 203: wye-connect three phase (abcn) meter.
        ("A", "u16", 1),
        ("AphA", "u16", 1),
        ("AphB", "u16", 1),
        ("AphC", "u16", 1),
        ("A_SF", "i16", 1),
        ("PhV", "u16", 1),
        ("PhVphA", "u16", 1),
        ("PhVphB", "u16", 1),
        ("PhVphC", "u16", 1),
        ("V_SF", "i16", 1),
        ("PPV", "u16", 1),
        ("PhVphAB", "u16", 1),
        ("PhVphBC", "u16", 1),
        ("PhVphCA", "u16", 1),
        ("Hz", "u16", 1),
        ("Hz_SF", "i16", 1),
        ("W", "i16", 1),
        ("WphA", "i16", 1),
        ("WphB", "i16", 1),
        ("WphC", "i16", 1),
        ("W_SF", "i16", 1),
        ("VA", "i16", 1),
        ("VAphA", "i16", 1),
        ("VAphB", "i16", 1),
        ("VAphC", "i16", 1),
        ("VA_SF", "i16", 1),
        ("VAR", "i16", 1),
        ("VARphA", "i16", 1),
        ("VARphB", "i16", 1),
        ("VARphC", "i16", 1),
        ("VAR_SF", "i16", 1),
        ("PF", "i16", 1),
        ("PFphA", "i16", 1),
        ("PFphB", "i16", 1),
        ("PFphC", "i16", 1),
        ("PF_SF", "i16", 1),
        ("TotWhExp", "u32", 2),
        ("TotWhExpPhA", "u32", 2),
        ("TotWhExpPhB", "u32", 2),
        ("TotWhExpPhC", "u32", 2),
        ("TotWhImp", "u32", 2),
        ("TotWhImpPhA", "u32", 2),
        ("TotWhImpPhB", "u32", 2),
        ("TotWhImpPhC", "u32", 2),
        ("TotWh_SF", "i16", 1),
        ("TotVAhExp", "u32", 2),
        ("TotVAhExpPhA", "u32", 2),
        ("TotVAhExpPhB", "u32", 2),
        ("TotVAhExpPhC", "u32", 2),
        ("TotVAhImp", "u32", 2),
        ("TotVAhImpPhA", "u32", 2),
        ("TotVAhImpPhB", "u32", 2),
        ("TotVAhImpPhC", "u32", 2),
        ("TotVAh_SF", "i16", 1),
        ("TotVArhImpQ1", "u32", 2),
        ("TotVArhImpQ1PhA", "u32", 2),
        ("TotVArhImpQ1PhB", "u32", 2),
        ("TotVArhImpQ1PhC", "u32", 2),
        ("TotVArhImpQ2", "u32", 2),
        ("TotVArhImpQ2PhA", "u32", 2),
        ("TotVArhImpQ2PhB", "u32", 2),
        ("TotVArhImpQ2PhC", "u32", 2),
        ("TotVArhExpQ3", "u32", 2),
        ("TotVArhExpQ3PhA", "u32", 2),
        ("TotVArhExpQ3PhB", "u32", 2),
        ("TotVArhExpQ3PhC", "u32", 2),
        ("TotVArhExpQ4", "u32", 2),
        ("TotVArhExpQ4PhA", "u32", 2),
        ("TotVArhExpQ4PhB", "u32", 2),
        ("TotVArhExpQ4PhC", "u32", 2),
        ("TotVArh_SF", "i16", 1),
        ("Evt", "u32", 2),
    ],
)

MPPT_MODEL = _build_model_definition(
    model_id=160,
    length=28,
    points=[
        ("DCA_SF", "i16", 1),
        ("DCV_SF", "i16", 1),
        ("DCW_SF", "i16", 1),
        ("DCWH_SF", "i16", 1),
        ("Evt", "u32", 2),
        ("N", "u16", 1),
        ("TmsPer", "u16", 1),
        ("M1_ID", "u16", 1),
        ("M1_IDStr", "string", 8),
        ("M1_DCA", "u16", 1),
        ("M1_DCV", "u16", 1),
        ("M1_DCW", "u16", 1),
        ("M1_DCWH", "u32", 2),
        ("M1_Tms", "u32", 2),
        ("M1_Tmp", "i16", 1),
        ("M1_DCSt", "u16", 1),
        ("M1_DCEvt", "u32", 2),
    ],
)

BATTERY_MODEL = _build_model_definition(
    model_id=124,
    length=25,
    points=[
        ("WChaMax", "u16", 1),
        ("WChaGra", "u16", 1),
        ("WDisChaGra", "u16", 1),
        ("StorCtl_Mod", "u16", 1),
        ("VAChaMax", "u16", 1),
        ("MinRsvPct", "u16", 1),
        ("ChaState", "u16", 1),
        ("StorAval", "u16", 1),
        ("InBatV", "u16", 1),
        ("ChaSt", "u16", 1),
        ("OutWRte", "i16", 1),
        ("InWRte", "i16", 1),
        ("InOutWRte_WinTms", "u16", 1),
        ("InOutWRte_RvrtTms", "u16", 1),
        ("InOutWRte_RmpTms", "u16", 1),
        ("ChaGriSet", "u16", 1),
        ("WChaMax_SF", "i16", 1),
        ("WChaDisChaGra_SF", "i16", 1),
        ("VAChaMax_SF", "i16", 1),
        ("MinRsvPct_SF", "i16", 1),
        ("ChaState_SF", "i16", 1),
        ("StorAval_SF", "i16", 1),
        ("InBatV_SF", "i16", 1),
        ("SoC_SF", "i16", 1),
        ("InOutWRte_SF", "i16", 1),
    ],
)

BATTERY_BASE_MODEL = _build_model_definition(
    model_id=802,
    length=62,
    points=[
        ("AHRtg", "u16", 1),
        ("WHRtg", "u16", 1),
        ("WChaRteMax", "u16", 1),
        ("WDisChaRteMax", "u16", 1),
        ("DisChaRte", "u16", 1),
        ("SoCMax", "u16", 1),
        ("SoCMin", "u16", 1),
        ("SocRsvMax", "u16", 1),
        ("SoCRsvMin", "u16", 1),
        ("SoC", "u16", 1),
        ("DoD", "u16", 1),
        ("SoH", "u16", 1),
        ("NCyc", "u32", 2),
        ("ChaSt", "u16", 1),
        ("LocRemCtl", "u16", 1),
        ("Hb", "u16", 1),
        ("CtrlHb", "u16", 1),
        ("AlmRst", "u16", 1),
        ("Typ", "u16", 1),
        ("State", "u16", 1),
        ("StateVnd", "u16", 1),
        ("WarrDt", "u32", 2),
        ("Evt1", "u32", 2),
        ("Evt2", "u32", 2),
        ("EvtVnd1", "u32", 2),
        ("EvtVnd2", "u32", 2),
        ("V", "u16", 1),
        ("VMax", "u16", 1),
        ("VMin", "u16", 1),
        ("CellVMax", "u16", 1),
        ("CellVMaxStr", "u16", 1),
        ("CellVMaxMod", "u16", 1),
        ("CellVMin", "u16", 1),
        ("CellVMinStr", "u16", 1),
        ("CellVMinMod", "u16", 1),
        ("CellVAvg", "u16", 1),
        ("A", "i16", 1),
        ("AChaMax", "u16", 1),
        ("ADisChaMax", "u16", 1),
        ("W", "i16", 1),
        ("ReqInvState", "u16", 1),
        ("ReqW", "i16", 1),
        ("SetOp", "u16", 1),
        ("SetInvState", "u16", 1),
        ("AHRtg_SF", "i16", 1),
        ("WHRtg_SF", "i16", 1),
        ("WChaDisChaMax_SF", "i16", 1),
        ("DisChaRte_SF", "i16", 1),
        ("SoC_SF", "i16", 1),
        ("DoD_SF", "i16", 1),
        ("SoH_SF", "i16", 1),
        ("V_SF", "i16", 1),
        ("CellV_SF", "i16", 1),
        ("A_SF", "i16", 1),
        ("AMax_SF", "i16", 1),
        ("W_SF", "i16", 1),
    ],
)


MODEL_SEQUENCE: tuple[tuple[str, ModelDefinition], ...] = (
    ("common", COMMON_MODEL),
    ("inverter", INVERTER_MODEL),
    ("mppt", MPPT_MODEL),
    ("meter", METER_MODEL),
    ("battery", BATTERY_MODEL),
    ("battery_base", BATTERY_BASE_MODEL),
)


def build_layout(base_address: int) -> RegisterLayout:
    """Build the SunSpec register layout for the configured base address."""
    relative = 2
    placements: dict[str, ModelPlacement] = {}
    for name, definition in MODEL_SEQUENCE:
        placements[name] = ModelPlacement(
            name=name,
            definition=definition,
            header_offset=relative,
        )
        relative += 2 + definition.length

    return RegisterLayout(
        base_address=base_address,
        placements=placements,
        end_marker_address=base_address + relative,
    )


def writable_addresses(_: RegisterLayout) -> set[int]:
    """Return writable register addresses.

    The refactored server exposes read-only SunSpec holding registers.
    """
    return set()


def iter_model_headers(layout: RegisterLayout) -> Iterable[tuple[int, int]]:
    """Yield absolute addresses and register values for all model headers."""
    for placement in layout.placements.values():
        yield layout.base_address + placement.header_offset, placement.definition.model_id
        yield layout.base_address + placement.header_offset + 1, placement.definition.length
