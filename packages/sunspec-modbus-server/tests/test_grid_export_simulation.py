"""Tests for virtual grid export simulation."""

from sunspec_modbus_server.grid_export_simulation import (
    GridExportSimulationConfig,
    GridExportSimulator,
)
from sunspec_modbus_server.register_store import SunSpecRegisterStore


def decode_i16(register: int) -> int:
    return register - 0x10000 if register > 0x7FFF else register


def decode_u32(registers: list[int]) -> int:
    return (registers[0] << 16) | registers[1]


def make_simulator() -> GridExportSimulator:
    return GridExportSimulator(
        GridExportSimulationConfig(
            enable=True,
            activate_soc_pct=90.0,
            deactivate_soc_pct=88.0,
            grid_import_tolerance_w=50.0,
            battery_idle_tolerance_w=100.0,
            pv_cover_margin_w=100.0,
        )
    )


def make_values(**overrides: float) -> dict[str, float]:
    values = {
        "active_power_w": 4000.0,
        "grid_power_w": 0.0,
        "battery_power_w": 0.0,
        "battery_soc_pct": 90.0,
        "total_energy_injected_wh": 1234.0,
        "total_energy_absorbed_wh": 5678.0,
    }
    values.update(overrides)
    return values


def test_simulation_activates_when_conditions_match() -> None:
    simulator = make_simulator()
    effective = simulator.apply(make_values())

    assert simulator.active is True
    assert effective["grid_power_w"] == -4000.0


def test_simulation_stays_active_between_deactivate_and_activate_thresholds() -> None:
    simulator = make_simulator()
    simulator.apply(make_values(battery_soc_pct=90.0))

    effective = simulator.apply(make_values(battery_soc_pct=89.0))

    assert simulator.active is True
    assert effective["grid_power_w"] == -4000.0


def test_simulation_deactivates_below_hysteresis_threshold() -> None:
    simulator = make_simulator()
    simulator.apply(make_values(battery_soc_pct=90.0))

    effective = simulator.apply(make_values(battery_soc_pct=87.0))

    assert simulator.active is False
    assert effective["grid_power_w"] == 0.0


def test_simulation_deactivates_on_real_grid_import() -> None:
    simulator = make_simulator()
    simulator.apply(make_values())

    effective = simulator.apply(make_values(grid_power_w=120.0))

    assert simulator.active is False
    assert effective["grid_power_w"] == 120.0


def test_simulation_uses_battery_charging_power_as_virtual_export() -> None:
    simulator = make_simulator()
    effective = simulator.apply(make_values(battery_power_w=-1500.0, battery_soc_pct=40.0))

    assert simulator.active is True
    assert effective["grid_power_w"] == -1500.0


def test_simulation_does_not_fake_export_for_battery_charging_during_grid_import() -> None:
    simulator = make_simulator()
    effective = simulator.apply(make_values(battery_power_w=-1500.0, grid_power_w=200.0, battery_soc_pct=40.0))

    assert simulator.active is False
    assert effective["grid_power_w"] == 200.0


def test_simulation_deactivates_when_battery_is_discharging() -> None:
    simulator = make_simulator()
    simulator.apply(make_values())

    effective = simulator.apply(make_values(battery_power_w=150.0))

    assert simulator.active is False
    assert effective["grid_power_w"] == 0.0


def test_simulation_deactivates_when_pv_no_longer_covers_house_load() -> None:
    simulator = make_simulator()
    simulator.apply(make_values())

    effective = simulator.apply(make_values(active_power_w=600.0, grid_power_w=0.0, battery_power_w=500.0))

    assert simulator.active is False
    assert effective["grid_power_w"] == 0.0


def test_only_meter_power_registers_are_affected_not_energy_counters() -> None:
    simulator = make_simulator()
    raw_values = make_values()
    effective_values = simulator.apply(raw_values)

    store = SunSpecRegisterStore(unit_id=1, base_address=40000, poll_interval_seconds=5)
    store.update_dynamic_values(effective_values)

    layout = store.layout
    meter_watts = store.get_registers(layout.field_address("meter", "W"), 1)
    total_wh_exp = store.get_registers(layout.field_address("meter", "TotWhExp"), 2)
    total_wh_imp = store.get_registers(layout.field_address("meter", "TotWhImp"), 2)

    assert decode_i16(meter_watts[0]) == -4000
    assert decode_u32(total_wh_exp) == 1234
    assert decode_u32(total_wh_imp) == 5678
