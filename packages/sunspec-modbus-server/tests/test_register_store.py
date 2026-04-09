"""Tests for SunSpec layout and dynamic register mapping."""

from sunspec_modbus_server.register_store import SunSpecRegisterStore
from sunspec_modbus_server.sunspec_models import build_layout


def decode_i16(register: int) -> int:
    return register - 0x10000 if register > 0x7FFF else register


def decode_u32(registers: list[int]) -> int:
    return (registers[0] << 16) | registers[1]


def test_layout_contains_common_103_and_203() -> None:
    layout = build_layout(40000)
    assert layout.start_address == 40000
    assert set(layout.placements) == {"common", "inverter", "meter", "battery", "battery_base"}
    assert layout.placements["meter"].definition.model_id == 203
    assert layout.placements["battery"].definition.model_id == 124
    assert layout.placements["battery_base"].definition.model_id == 802
    assert layout.field_address("common", "DA") > 40000
    assert layout.field_address("inverter", "W") > layout.field_address("common", "DA")
    assert layout.field_address("meter", "W") > layout.field_address("inverter", "W")
    assert layout.field_address("battery", "ChaState") > layout.field_address("meter", "W")
    assert layout.field_address("meter", "PhV") < layout.field_address("meter", "PPV")


def test_dynamic_values_are_written_into_103_and_203_registers() -> None:
    store = SunSpecRegisterStore(unit_id=1, base_address=40000, poll_interval_seconds=5)
    store.update_dynamic_values(
        {
            "active_power_w": 2345,
            "grid_power_w": 987,
            "frequency_hz": 49.98,
            "voltage_ln_v": 229.6,
            "voltage_ll_v": 398.0,
            "total_energy_injected_wh": 333,
            "total_energy_absorbed_wh": 444,
            "cabinet_temperature_c": 31,
            "battery_power_w": 1200,
            "battery_soc_pct": 63,
        }
    )

    layout = store.layout
    inverter_watts = store.get_registers(layout.field_address("inverter", "W"), 1)
    meter_watts = store.get_registers(layout.field_address("meter", "W"), 1)
    frequency = store.get_registers(layout.field_address("meter", "Hz"), 1)
    total_wh_exp = store.get_registers(layout.field_address("meter", "TotWhExp"), 2)
    total_wh_imp = store.get_registers(layout.field_address("meter", "TotWhImp"), 2)
    cabinet_temp = store.get_registers(layout.field_address("inverter", "TmpCab"), 1)
    battery_discharge_power = store.get_registers(layout.field_address("battery", "WDisChaGra"), 1)
    battery_discharge_rate = store.get_registers(layout.field_address("battery", "OutWRte"), 1)
    battery_soc = store.get_registers(layout.field_address("battery", "ChaState"), 1)
    battery_state = store.get_registers(layout.field_address("battery", "ChaSt"), 1)
    battery_base_power = store.get_registers(layout.field_address("battery_base", "W"), 1)
    battery_base_soc = store.get_registers(layout.field_address("battery_base", "SoC"), 1)

    assert decode_i16(inverter_watts[0]) == 2345
    assert decode_i16(meter_watts[0]) == 987
    assert frequency[0] == 4998
    assert decode_u32(total_wh_exp) == 333
    assert decode_u32(total_wh_imp) == 444
    assert decode_i16(cabinet_temp[0]) == 31
    assert battery_discharge_power[0] == 100
    assert decode_i16(battery_discharge_rate[0]) == 100
    assert battery_soc[0] == 63
    assert battery_state[0] == 3
    assert decode_i16(battery_base_power[0]) == 1200
    assert battery_base_soc[0] == 63


def test_negative_battery_power_writes_charging_state() -> None:
    store = SunSpecRegisterStore(unit_id=1, base_address=40000, poll_interval_seconds=5)
    store.update_dynamic_values(
        {
            "battery_power_w": -800,
            "battery_soc_pct": 40,
        }
    )

    layout = store.layout
    battery_charge_power = store.get_registers(layout.field_address("battery", "WChaGra"), 1)
    battery_charge_rate = store.get_registers(layout.field_address("battery", "InWRte"), 1)
    battery_state = store.get_registers(layout.field_address("battery", "ChaSt"), 1)
    battery_base_power = store.get_registers(layout.field_address("battery_base", "W"), 1)
    battery_base_state = store.get_registers(layout.field_address("battery_base", "ChaSt"), 1)

    assert battery_charge_power[0] == 100
    assert decode_i16(battery_charge_rate[0]) == 100
    assert battery_state[0] == 4
    assert decode_i16(battery_base_power[0]) == -800
    assert battery_base_state[0] == 4
