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
            activate_soc_pct=99.0,
            deactivate_soc_pct=99.0,
            grid_import_tolerance_w=50.0,
            battery_idle_tolerance_w=100.0,
            pv_cover_margin_w=100.0,
        )
    )


def make_values(**overrides: float) -> dict[str, float]:
    values = {
        "active_power_w": 4000.0,
        "pv_power_w": 4000.0,
        "grid_power_w": 0.0,
        "battery_power_w": 0.0,
        "battery_soc_pct": 99.0,
        "total_energy_injected_wh": 1234.0,
        "total_energy_absorbed_wh": 5678.0,
    }
    values.update(overrides)
    return values


def test_simulation_activates_when_conditions_match() -> None:
    simulator = make_simulator()
    effective = simulator.apply(make_values())

    assert simulator.active is True
    assert effective["grid_power_w"] == -8000.0


def test_simulation_subtracts_virtual_export_from_real_meter_value() -> None:
    simulator = make_simulator()
    effective = simulator.apply(make_values(grid_power_w=750.0))

    assert simulator.active is True
    assert effective["grid_power_w"] == -7250.0
    assert effective["pv_power_w"] == 12000.0


def test_simulation_deactivates_below_full_battery_threshold() -> None:
    simulator = make_simulator()
    simulator.apply(make_values(battery_soc_pct=99.0))

    effective = simulator.apply(make_values(battery_soc_pct=98.0))

    assert simulator.active is False
    assert effective["grid_power_w"] == 0.0


def test_simulation_deactivates_immediately_when_battery_starts_discharging() -> None:
    simulator = make_simulator()
    simulator.apply(make_values(battery_soc_pct=99.0))

    effective = simulator.apply(
        make_values(
            battery_soc_pct=99.0,
            battery_power_w=150.0,
            grid_power_w=320.0,
            pv_power_w=4000.0,
        )
    )

    assert simulator.active is False
    assert effective["grid_power_w"] == 320.0


def test_simulation_uses_battery_charging_power_as_virtual_export() -> None:
    simulator = make_simulator()
    effective = simulator.apply(
        make_values(
            active_power_w=900.0,
            pv_power_w=4000.0,
            battery_power_w=-1500.0,
            battery_soc_pct=40.0,
        )
    )

    assert simulator.active is False
    assert effective["active_power_w"] == 4000.0
    assert effective["grid_power_w"] == 0.0


def test_simulation_does_not_fake_export_for_battery_charging_during_grid_import() -> None:
    simulator = make_simulator()
    effective = simulator.apply(
        make_values(
            active_power_w=900.0,
            pv_power_w=4000.0,
            battery_power_w=-1500.0,
            grid_power_w=200.0,
            battery_soc_pct=40.0,
        )
    )

    assert simulator.active is False
    assert effective["grid_power_w"] == 200.0
    assert effective["active_power_w"] == 4000.0


def test_simulation_sets_pv_power_to_zero_when_battery_is_discharging() -> None:
    simulator = make_simulator()
    simulator.apply(make_values())

    effective = simulator.apply(make_values(pv_power_w=2200.0, battery_power_w=150.0))

    assert simulator.active is False
    assert effective["pv_power_w"] == 0.0


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

    assert decode_i16(meter_watts[0]) == -8000
    assert decode_u32(total_wh_exp) == 1234
    assert decode_u32(total_wh_imp) == 5678
