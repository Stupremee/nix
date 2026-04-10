"""SunSpec holding register store and dynamic value mapping."""

from __future__ import annotations

import math
import threading
from typing import Iterable

from pymodbus.constants import ExcCodes
from pymodbus.datastore.store import BaseModbusDataBlock

from .sunspec_models import (
    build_layout,
    encode_i16,
    encode_string,
    encode_u16,
    encode_u32,
    iter_model_headers,
    writable_addresses,
)
from .value_definitions import DEFAULT_VALUES, normalize_values


class SunSpecRegisterStore:
    """In-memory SunSpec register map backed by polled Home Assistant values."""

    PV_NOMINAL_VOLTAGE_V = 600.0

    def __init__(
        self,
        *,
        unit_id: int,
        base_address: int,
        poll_interval_seconds: int,
        initial_values: dict[str, float] | None = None,
    ) -> None:
        self.layout = build_layout(base_address)
        self._unit_id = unit_id
        self._poll_interval_seconds = poll_interval_seconds
        self._lock = threading.RLock()
        self._registers: list[int] = [0] * 65536
        self._writable_addresses = writable_addresses(self.layout)
        self._dynamic_values = normalize_values(initial_values or DEFAULT_VALUES)

        self._initialize_layout()
        self.update_dynamic_values(self._dynamic_values)

    @property
    def served_start(self) -> int:
        """First served raw Modbus address."""
        return self.layout.start_address

    @property
    def served_end(self) -> int:
        """Last served raw Modbus address."""
        return self.layout.end_address

    def get_dynamic_values(self) -> dict[str, float]:
        """Return a copy of the current dynamic value set."""
        with self._lock:
            return dict(self._dynamic_values)

    def update_dynamic_values(self, values: dict[str, float]) -> None:
        """Update dynamic values and rewrite affected registers."""
        with self._lock:
            self._dynamic_values = normalize_values(self._dynamic_values | values)
            self._apply_dynamic_values()

    def get_registers(self, address: int, count: int) -> list[int] | ExcCodes:
        """Read a contiguous register range from the served SunSpec block."""
        with self._lock:
            if address < self.served_start or address + count - 1 > self.served_end:
                return ExcCodes.ILLEGAL_ADDRESS
            return self._registers[address : address + count]

    def set_registers(self, address: int, values: Iterable[int]) -> None | ExcCodes:
        """Reject writes outside any explicitly writable address list."""
        registers = list(values)
        with self._lock:
            for offset, _ in enumerate(registers):
                absolute = address + offset
                if absolute not in self._writable_addresses:
                    return ExcCodes.ILLEGAL_ADDRESS
            for offset, value in enumerate(registers):
                self._registers[address + offset] = int(value) & 0xFFFF
            return None

    def _initialize_layout(self) -> None:
        self._write_many(self.layout.base_address, encode_string("SunS", 2))
        for address, value in iter_model_headers(self.layout):
            self._registers[address] = value & 0xFFFF
        self._registers[self.layout.end_marker_address] = 0xFFFF

        self._write_string("common", "Mn", "NixOS")
        self._write_string("common", "Md", "Virtual SunSpec Server")
        self._write_string("common", "Opt", "Inv+MPPT+Mtr")
        self._write_string("common", "Vr", "0.1.0")
        self._write_string("common", "SN", "virtual-0001")
        self._write_u16("common", "DA", self._unit_id)

        self._write_i16("inverter", "A_SF", -1)
        self._write_i16("inverter", "V_SF", -1)
        self._write_i16("inverter", "W_SF", 0)
        self._write_i16("inverter", "Hz_SF", -2)
        self._write_i16("inverter", "VA_SF", 0)
        self._write_i16("inverter", "VAr_SF", 0)
        self._write_i16("inverter", "PF_SF", -2)
        self._write_i16("inverter", "WH_SF", 0)
        self._write_i16("inverter", "DCA_SF", -1)
        self._write_i16("inverter", "DCV_SF", -1)
        self._write_i16("inverter", "DCW_SF", 0)
        self._write_i16("inverter", "Tmp_SF", 0)
        self._write_u16("inverter", "PPVphAB", 4000)
        self._write_u16("inverter", "PPVphBC", 4000)
        self._write_u16("inverter", "PPVphCA", 4000)
        self._write_u16("inverter", "PhVphA", 2300)
        self._write_u16("inverter", "PhVphB", 2300)
        self._write_u16("inverter", "PhVphC", 2300)
        self._write_u16("inverter", "StVnd", 0)
        self._write_u32("inverter", "Evt1", 0)
        self._write_u32("inverter", "Evt2", 0)
        self._write_u32("inverter", "EvtVnd1", 0)
        self._write_u32("inverter", "EvtVnd2", 0)
        self._write_u32("inverter", "EvtVnd3", 0)
        self._write_u32("inverter", "EvtVnd4", 0)

        self._write_i16("mppt", "DCA_SF", 0)
        self._write_i16("mppt", "DCV_SF", 0)
        self._write_i16("mppt", "DCW_SF", 0)
        self._write_i16("mppt", "DCWH_SF", 0)
        self._write_u32("mppt", "Evt", 0)
        self._write_u16("mppt", "N", 1)
        self._write_u16("mppt", "TmsPer", 0)
        self._write_u16("mppt", "M1_ID", 1)
        self._write_string("mppt", "M1_IDStr", "PV1")
        self._write_u32("mppt", "M1_Tms", 0)
        self._write_i16("mppt", "M1_Tmp", 25)
        self._write_u16("mppt", "M1_DCSt", 1)
        self._write_u32("mppt", "M1_DCEvt", 0)

        self._write_i16("meter", "A_SF", -1)
        self._write_i16("meter", "V_SF", -1)
        self._write_i16("meter", "Hz_SF", -2)
        self._write_i16("meter", "W_SF", 0)
        self._write_i16("meter", "VA_SF", 0)
        self._write_i16("meter", "VAR_SF", 0)
        self._write_i16("meter", "PF_SF", -2)
        self._write_i16("meter", "TotWh_SF", 0)
        self._write_i16("meter", "TotVAh_SF", 0)
        self._write_i16("meter", "TotVArh_SF", 0)
        self._write_u32("meter", "Evt", 0)

    def _apply_dynamic_values(self) -> None:
        values = normalize_values(self._dynamic_values)

        inverter_power = int(round(values["active_power_w"]))
        pv_power = int(round(values["pv_power_w"]))
        grid_power = int(round(values["grid_power_w"]))
        apparent_power = int(round(
            values["apparent_power_va"]
            if values["apparent_power_va"]
            else max(abs(inverter_power), abs(grid_power))
        ))
        reactive_power = int(round(values["reactive_power_var"]))
        power_factor = int(round(
            values["power_factor_pct"]
            if values["power_factor_pct"] != DEFAULT_VALUES["power_factor_pct"]
            else (100.0 if inverter_power >= 0 else -100.0)
        ))
        voltage_ln = max(0.0, values["voltage_ln_v"])
        voltage_ll = max(0.0, values["voltage_ll_v"])
        frequency_hz = max(0.0, values["frequency_hz"])

        current = values["current_a"]
        if current == DEFAULT_VALUES["current_a"]:
            current = self._derive_current(max(abs(inverter_power), abs(grid_power)), voltage_ln)
        total_current = max(0, int(round(abs(current))))

        phase_current = max(0, int(round(abs(current / 3.0))))
        inverter_phase_power = int(round(inverter_power / 3.0))
        grid_phase_power = int(round(grid_power / 3.0))
        phase_apparent = int(round(apparent_power / 3.0))
        phase_reactive = int(round(reactive_power / 3.0))
        phase_export_wh = int(round(values["total_energy_injected_wh"] / 3.0))
        phase_import_wh = int(round(values["total_energy_absorbed_wh"] / 3.0))
        pv_dc_power = max(0, pv_power)
        pv_dc_voltage = int(round(self.PV_NOMINAL_VOLTAGE_V))
        pv_dc_current = int(round(pv_dc_power / self.PV_NOMINAL_VOLTAGE_V)) if pv_dc_power > 0 else 0

        self._write_u16("inverter", "A", self._clamp_u16(total_current))
        self._write_u16("inverter", "AphA", self._clamp_u16(phase_current))
        self._write_u16("inverter", "AphB", self._clamp_u16(phase_current))
        self._write_u16("inverter", "AphC", self._clamp_u16(phase_current))
        self._write_i16("inverter", "W", self._clamp_i16(inverter_power))
        self._write_i16("inverter", "VA", self._clamp_i16(apparent_power))
        self._write_i16("inverter", "VAr", self._clamp_i16(reactive_power))
        self._write_i16("inverter", "PF", self._clamp_i16(power_factor))
        self._write_u16("inverter", "Hz", self._clamp_u16(int(round(frequency_hz * 100.0))))
        self._write_u32(
            "inverter",
            "WH",
            self._clamp_u32(int(round(values["total_energy_injected_wh"]))),
        )
        self._write_u16("inverter", "DCA", self._clamp_u16(pv_dc_current))
        self._write_u16("inverter", "DCV", self._clamp_u16(pv_dc_voltage))
        self._write_i16("inverter", "DCW", self._clamp_i16(pv_dc_power))
        self._write_i16("inverter", "TmpCab", self._clamp_i16(int(round(values["cabinet_temperature_c"]))))
        self._write_i16("inverter", "TmpSnk", self._clamp_i16(int(round(values["heat_sink_temperature_c"]))))
        self._write_i16("inverter", "TmpTrns", self._clamp_i16(int(round(values["transformer_temperature_c"]))))
        self._write_i16("inverter", "TmpOt", self._clamp_i16(int(round(values["other_temperature_c"]))))
        self._write_u16("inverter", "St", 4 if inverter_power != 0 else 1)

        self._write_u16("mppt", "M1_DCA", self._clamp_u16(pv_dc_current))
        self._write_u16("mppt", "M1_DCV", self._clamp_u16(pv_dc_voltage))
        self._write_u16("mppt", "M1_DCW", self._clamp_u16(pv_dc_power))
        self._write_u32(
            "mppt",
            "M1_DCWH",
            self._clamp_u32(int(round(values["total_energy_injected_wh"]))),
        )
        self._write_u16("mppt", "M1_DCSt", 4 if pv_dc_power > 0 else 1)

        self._write_u16("meter", "A", self._clamp_u16(total_current))
        self._write_u16("meter", "AphA", self._clamp_u16(phase_current))
        self._write_u16("meter", "AphB", self._clamp_u16(phase_current))
        self._write_u16("meter", "AphC", self._clamp_u16(phase_current))
        self._write_u16("meter", "PhV", self._clamp_u16(int(round(voltage_ln * 10.0))))
        self._write_u16("meter", "PhVphA", self._clamp_u16(int(round(voltage_ln * 10.0))))
        self._write_u16("meter", "PhVphB", self._clamp_u16(int(round(voltage_ln * 10.0))))
        self._write_u16("meter", "PhVphC", self._clamp_u16(int(round(voltage_ln * 10.0))))
        self._write_u16("meter", "PPV", self._clamp_u16(int(round(voltage_ll * 10.0))))
        self._write_u16("meter", "PhVphAB", self._clamp_u16(int(round(voltage_ll * 10.0))))
        self._write_u16("meter", "PhVphBC", self._clamp_u16(int(round(voltage_ll * 10.0))))
        self._write_u16("meter", "PhVphCA", self._clamp_u16(int(round(voltage_ll * 10.0))))
        self._write_u16("meter", "Hz", self._clamp_u16(int(round(frequency_hz * 100.0))))
        self._write_i16("meter", "W", self._clamp_i16(grid_power))
        self._write_i16("meter", "WphA", self._clamp_i16(grid_phase_power))
        self._write_i16("meter", "WphB", self._clamp_i16(grid_phase_power))
        self._write_i16("meter", "WphC", self._clamp_i16(grid_phase_power))
        self._write_i16("meter", "VA", self._clamp_i16(apparent_power))
        self._write_i16("meter", "VAphA", self._clamp_i16(phase_apparent))
        self._write_i16("meter", "VAphB", self._clamp_i16(phase_apparent))
        self._write_i16("meter", "VAphC", self._clamp_i16(phase_apparent))
        self._write_i16("meter", "VAR", self._clamp_i16(reactive_power))
        self._write_i16("meter", "VARphA", self._clamp_i16(phase_reactive))
        self._write_i16("meter", "VARphB", self._clamp_i16(phase_reactive))
        self._write_i16("meter", "VARphC", self._clamp_i16(phase_reactive))
        self._write_i16("meter", "PF", self._clamp_i16(power_factor))
        self._write_i16("meter", "PFphA", self._clamp_i16(power_factor))
        self._write_i16("meter", "PFphB", self._clamp_i16(power_factor))
        self._write_i16("meter", "PFphC", self._clamp_i16(power_factor))
        self._write_u32(
            "meter",
            "TotWhExp",
            self._clamp_u32(int(round(values["total_energy_injected_wh"]))),
        )
        self._write_u32("meter", "TotWhExpPhA", self._clamp_u32(phase_export_wh))
        self._write_u32("meter", "TotWhExpPhB", self._clamp_u32(phase_export_wh))
        self._write_u32("meter", "TotWhExpPhC", self._clamp_u32(phase_export_wh))
        self._write_u32(
            "meter",
            "TotWhImp",
            self._clamp_u32(int(round(values["total_energy_absorbed_wh"]))),
        )
        self._write_u32("meter", "TotWhImpPhA", self._clamp_u32(phase_import_wh))
        self._write_u32("meter", "TotWhImpPhB", self._clamp_u32(phase_import_wh))
        self._write_u32("meter", "TotWhImpPhC", self._clamp_u32(phase_import_wh))

    def _derive_current(self, active_power_w: float, voltage_ln_v: float) -> float:
        voltage = max(voltage_ln_v, 1.0)
        return abs(active_power_w) / (math.sqrt(3.0) * voltage)

    def _field_address(self, placement_name: str, field_name: str) -> int:
        return self.layout.field_address(placement_name, field_name)

    def _write_many(self, address: int, registers: Iterable[int]) -> None:
        for offset, value in enumerate(registers):
            self._registers[address + offset] = int(value) & 0xFFFF

    def _write_string(self, placement_name: str, field_name: str, value: str) -> None:
        field = self.layout.placements[placement_name].definition.fields[field_name]
        self._write_many(
            self._field_address(placement_name, field_name),
            encode_string(value, field.length),
        )

    def _write_u16(self, placement_name: str, field_name: str, value: int) -> None:
        self._write_many(self._field_address(placement_name, field_name), encode_u16(value))

    def _write_i16(self, placement_name: str, field_name: str, value: int) -> None:
        self._write_many(self._field_address(placement_name, field_name), encode_i16(value))

    def _write_u32(self, placement_name: str, field_name: str, value: int) -> None:
        self._write_many(self._field_address(placement_name, field_name), encode_u32(value))

    def _clamp_i16(self, value: int) -> int:
        return max(-32768, min(32767, value))

    def _clamp_u16(self, value: int) -> int:
        return max(0, min(0xFFFF, value))

    def _clamp_u32(self, value: int) -> int:
        return max(0, min(0xFFFFFFFF, value))


class SunSpecHoldingRegisterBlock(BaseModbusDataBlock[list[int]]):
    """PyModbus data block adapter for the SunSpec register store."""

    def __init__(self, store: SunSpecRegisterStore) -> None:
        self._store = store
        self.address = store.served_start
        self.values = []
        self.default_value = 0

    def getValues(self, address: int, count: int = 1) -> list[int] | ExcCodes:
        zero_based = address - 1
        return self._store.get_registers(zero_based, count)

    def setValues(self, address: int, values: list[int]) -> None | ExcCodes:
        zero_based = address - 1
        return self._store.set_registers(zero_based, values)
