"""Tests for SunSpec layout and dynamic register mapping."""

from sunspec_modbus_server.register_store import SunSpecRegisterStore
from sunspec_modbus_server.sunspec_models import build_layout


def decode_i16(register: int) -> int:
    return register - 0x10000 if register > 0x7FFF else register


def decode_u32(registers: list[int]) -> int:
    return (registers[0] << 16) | registers[1]


def test_layout_contains_common_103_160_and_203() -> None:
    layout = build_layout(40000)
    assert layout.start_address == 40000
    assert set(layout.placements) == {"common", "inverter", "mppt", "meter"}
    assert layout.placements["mppt"].definition.model_id == 160
    assert layout.placements["meter"].definition.model_id == 203
    assert layout.field_address("common", "DA") > 40000
    assert layout.field_address("inverter", "W") > layout.field_address("common", "DA")
    assert layout.field_address("mppt", "M1_DCW") > layout.field_address("inverter", "W")
    assert layout.field_address("meter", "W") > layout.field_address("mppt", "M1_DCW")
    assert layout.field_address("meter", "PhV") < layout.field_address("meter", "PPV")


def test_dynamic_values_are_written_into_103_160_and_203_registers() -> None:
    store = SunSpecRegisterStore(unit_id=1, base_address=40000, poll_interval_seconds=5)
    store.update_dynamic_values(
        {
            "active_power_w": 2345,
            "pv_power_w": 3210,
            "grid_power_w": 987,
            "frequency_hz": 49.98,
            "voltage_ln_v": 229.6,
            "voltage_ll_v": 398.0,
            "total_energy_injected_wh": 333,
            "total_energy_absorbed_wh": 444,
            "cabinet_temperature_c": 31,
        }
    )

    layout = store.layout
    inverter_watts = store.get_registers(layout.field_address("inverter", "W"), 1)
    inverter_dc_power = store.get_registers(layout.field_address("inverter", "DCW"), 1)
    mppt_dc_power = store.get_registers(layout.field_address("mppt", "M1_DCW"), 1)
    mppt_dc_energy = store.get_registers(layout.field_address("mppt", "M1_DCWH"), 2)
    meter_watts = store.get_registers(layout.field_address("meter", "W"), 1)
    frequency = store.get_registers(layout.field_address("meter", "Hz"), 1)
    total_wh_exp = store.get_registers(layout.field_address("meter", "TotWhExp"), 2)
    total_wh_imp = store.get_registers(layout.field_address("meter", "TotWhImp"), 2)
    cabinet_temp = store.get_registers(layout.field_address("inverter", "TmpCab"), 1)

    assert decode_i16(inverter_watts[0]) == 2345
    assert decode_i16(inverter_dc_power[0]) == 3210
    assert mppt_dc_power[0] == 3210
    assert decode_u32(mppt_dc_energy) == 333
    assert decode_i16(meter_watts[0]) == 987
    assert frequency[0] == 4998
    assert decode_u32(total_wh_exp) == 333
    assert decode_u32(total_wh_imp) == 444
    assert decode_i16(cabinet_temp[0]) == 31
