"""What the inverter, battery and grid meter measure."""

from collections.abc import Callable, Mapping
from dataclasses import dataclass
from datetime import datetime
from typing import Literal, override

from homeassistant.components.sensor import (
    SensorDeviceClass,
    SensorEntity,
    SensorEntityDescription,
    SensorStateClass,
)
from homeassistant.const import (
    PERCENTAGE,
    UnitOfApparentPower,
    UnitOfElectricCurrent,
    UnitOfElectricPotential,
    UnitOfEnergy,
    UnitOfFrequency,
    UnitOfPower,
    UnitOfReactivePower,
    UnitOfTemperature,
    UnitOfTime,
)
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddConfigEntryEntitiesCallback
from homeassistant.helpers.typing import StateType
from homeassistant.util import dt as dt_util

from .coordinator import FoxConfigEntry, Snapshot
from .entity import FoxEntity, FoxEntityDescription, Part
from .outage import Outage
from .registers import (
    STATUS_1,
    STATUS_3,
    STATUS_3_OFF_GRID,
    STATUS_FAULT,
    STATUS_OPERATION,
    STATUS_STANDBY,
    Register,
)

PARALLEL_UPDATES = 0

PHASES = ("l1", "l2", "l3")

type Quantity = Literal[
    "power",
    "reactive_power",
    "reactive_power_k",
    "apparent_power",
    "power_factor",
    "voltage",
    "cell_voltage",
    "current",
    "frequency",
    "temperature",
    "energy_total",
    "energy_today",
    "energy_stored",
    "charge",
    "battery",
    "percentage",
]

# Units match the YAML entities these replace, so statistics carry on.
_QUANTITIES: Mapping[
    Quantity, tuple[SensorDeviceClass | None, str | None, SensorStateClass]
] = {
    "power": (SensorDeviceClass.POWER, UnitOfPower.WATT, SensorStateClass.MEASUREMENT),
    "reactive_power": (
        SensorDeviceClass.REACTIVE_POWER,
        UnitOfReactivePower.VOLT_AMPERE_REACTIVE,
        SensorStateClass.MEASUREMENT,
    ),
    "reactive_power_k": (
        SensorDeviceClass.REACTIVE_POWER,
        UnitOfReactivePower.KILO_VOLT_AMPERE_REACTIVE,
        SensorStateClass.MEASUREMENT,
    ),
    "apparent_power": (
        SensorDeviceClass.APPARENT_POWER,
        UnitOfApparentPower.VOLT_AMPERE,
        SensorStateClass.MEASUREMENT,
    ),
    "power_factor": (
        SensorDeviceClass.POWER_FACTOR,
        None,
        SensorStateClass.MEASUREMENT,
    ),
    "voltage": (
        SensorDeviceClass.VOLTAGE,
        UnitOfElectricPotential.VOLT,
        SensorStateClass.MEASUREMENT,
    ),
    "cell_voltage": (
        SensorDeviceClass.VOLTAGE,
        UnitOfElectricPotential.MILLIVOLT,
        SensorStateClass.MEASUREMENT,
    ),
    "current": (
        SensorDeviceClass.CURRENT,
        UnitOfElectricCurrent.AMPERE,
        SensorStateClass.MEASUREMENT,
    ),
    "frequency": (
        SensorDeviceClass.FREQUENCY,
        UnitOfFrequency.HERTZ,
        SensorStateClass.MEASUREMENT,
    ),
    "temperature": (
        SensorDeviceClass.TEMPERATURE,
        UnitOfTemperature.CELSIUS,
        SensorStateClass.MEASUREMENT,
    ),
    "energy_total": (
        SensorDeviceClass.ENERGY,
        UnitOfEnergy.KILO_WATT_HOUR,
        SensorStateClass.TOTAL_INCREASING,
    ),
    "energy_today": (
        SensorDeviceClass.ENERGY,
        UnitOfEnergy.KILO_WATT_HOUR,
        SensorStateClass.TOTAL,
    ),
    "energy_stored": (
        SensorDeviceClass.ENERGY_STORAGE,
        UnitOfEnergy.WATT_HOUR,
        SensorStateClass.MEASUREMENT,
    ),
    "charge": (None, "Ah", SensorStateClass.MEASUREMENT),
    "battery": (SensorDeviceClass.BATTERY, PERCENTAGE, SensorStateClass.MEASUREMENT),
    "percentage": (None, PERCENTAGE, SensorStateClass.MEASUREMENT),
}


@dataclass(frozen=True, kw_only=True)
class FoxSensorDescription(SensorEntityDescription, FoxEntityDescription):
    """A sensor, and how to read its value off a poll."""

    value_fn: Callable[[Snapshot], StateType]


def _sensor(
    key: str,
    part: Part,
    quantity: Quantity,
    register: Register,
    *,
    legacy: str | None = None,
    translation_key: str | None = None,
    placeholders: Mapping[str, str] | None = None,
    enabled: bool = True,
) -> FoxSensorDescription:
    device_class, unit, state_class = _QUANTITIES[quantity]
    return FoxSensorDescription(
        key=key,
        part=part,
        legacy_unique_id=f"ess_1_{legacy or key}",
        translation_key=translation_key or key,
        translation_placeholders=placeholders,
        device_class=device_class,
        native_unit_of_measurement=unit,
        state_class=state_class,
        suggested_display_precision=register.precision,
        entity_registry_enabled_default=enabled,
        value_fn=lambda data: data[register],
    )


def _per_phase(
    key: str,
    part: Part,
    quantity: Quantity,
    registers: tuple[Register, Register, Register],
    *,
    legacy: str | None = None,
    enabled: bool = True,
) -> tuple[FoxSensorDescription, ...]:
    return tuple(
        _sensor(
            f"{key}_{phase}",
            part,
            quantity,
            register,
            legacy=f"{legacy or key}_{phase}",
            translation_key=f"{key}_phase",
            placeholders={"phase": phase.upper()},
            enabled=enabled,
        )
        for phase, register in zip(PHASES, registers, strict=True)
    )


def _numbered(
    key: str,
    quantity: Quantity,
    registers: tuple[Register, ...],
    *,
    enabled: bool = True,
) -> tuple[FoxSensorDescription, ...]:
    """Per PV string or MPPT, keyed like pv1_voltage."""
    prefix, _, suffix = key.partition("_")
    return tuple(
        _sensor(
            f"{prefix}{number}_{suffix}",
            Part.INVERTER,
            quantity,
            register,
            translation_key=key,
            placeholders={"number": str(number)},
            enabled=enabled,
        )
        for number, register in enumerate(registers, start=1)
    )


def _i32(address: int, scale: float = 1, precision: int = 0) -> Register:
    return Register(address, "i32", scale, precision)


def _i16(address: int, scale: float = 1, precision: int = 0) -> Register:
    return Register(address, "i16", scale, precision)


def _u16(address: int, scale: float = 1, precision: int = 0) -> Register:
    return Register(address, "u16", scale, precision)


def _energy(address: int) -> Register:
    return Register(address, "u32", 0.01, 1)


def _phases(
    first: int, step: int, make: Callable[[int], Register]
) -> tuple[Register, Register, Register]:
    return (make(first), make(first + step), make(first + 2 * step))


def _status(data: Snapshot) -> str | None:
    if (status := data.raw(STATUS_1)) is None:
        return None
    if status & STATUS_FAULT:
        return "fault"
    if status & STATUS_OPERATION:
        return "operation"
    if status & STATUS_STANDBY:
        return "standby"
    return None


def _grid_mode(data: Snapshot) -> str | None:
    if (status := data.raw(STATUS_3)) is None:
        return None
    return "off_grid" if status & STATUS_3_OFF_GRID else "on_grid"


INVERTER = Part.INVERTER
BATTERY = Part.BATTERY
GRID = Part.GRID

SENSORS: tuple[FoxSensorDescription, ...] = (
    # Inverter
    FoxSensorDescription(
        key="status",
        part=INVERTER,
        legacy_unique_id="ess_1_status_1",
        translation_key="status",
        device_class=SensorDeviceClass.ENUM,
        options=["standby", "operation", "fault"],
        value_fn=_status,
    ),
    FoxSensorDescription(
        key="grid_mode",
        part=INVERTER,
        legacy_unique_id="ess_1_status_3",
        translation_key="grid_mode",
        device_class=SensorDeviceClass.ENUM,
        options=["on_grid", "off_grid"],
        value_fn=_grid_mode,
    ),
    _sensor("pv_input_power_total", INVERTER, "power", _i32(39118, precision=3)),
    _sensor("active_power", INVERTER, "power", _i32(39134, precision=3)),
    _sensor("reactive_power", INVERTER, "reactive_power_k", _i32(39136, 0.001, 3)),
    _sensor("inv_apparent_power_total", INVERTER, "apparent_power", _i32(39270)),
    _sensor("power_factor", INVERTER, "power_factor", _i16(39138, 0.001, 3)),
    _sensor("grid_frequency", INVERTER, "frequency", _i16(39139, 0.01, 2)),
    _sensor("internal_temperature", INVERTER, "temperature", _i16(39141, 0.1, 1)),
    _sensor("available_import_power", INVERTER, "power", _i32(39275)),
    _sensor("available_export_power", INVERTER, "power", _i32(39277)),
    *_per_phase(
        "grid_voltage",
        INVERTER,
        "voltage",
        _phases(39123, 1, lambda a: _i16(a, 0.1, 1)),
    ),
    *_per_phase(
        "inverter_current",
        INVERTER,
        "current",
        _phases(39126, 2, lambda a: _i32(a, 0.001, 3)),
    ),
    *_per_phase("inv_active_power", INVERTER, "power", _phases(39248, 2, _i32)),
    *_per_phase(
        "inv_reactive_power",
        INVERTER,
        "reactive_power",
        _phases(39256, 2, _i32),
        enabled=False,
    ),
    *_per_phase(
        "inv_apparent_power",
        INVERTER,
        "apparent_power",
        _phases(39264, 2, _i32),
        enabled=False,
    ),
    *_per_phase(
        "inv_frequency",
        INVERTER,
        "frequency",
        _phases(39272, 1, lambda a: _i16(a, 0.01, 2)),
        enabled=False,
    ),
    *_per_phase("load_power", INVERTER, "power", _phases(39219, 2, _i32)),
    _sensor(
        "load_power", INVERTER, "power", _i32(39225), legacy="load_power_total_39225"
    ),
    # One string per MPPT, so the per-string values repeat the MPPT ones.
    *_numbered(
        "mppt_voltage",
        "voltage",
        tuple(_i16(a, 0.1, 1) for a in (39327, 39331, 39335, 39339)),
    ),
    *_numbered(
        "mppt_current",
        "current",
        tuple(_i16(a, 0.01, 2) for a in (39328, 39332, 39336, 39340)),
    ),
    *_numbered(
        "mppt_power", "power", tuple(_i32(a) for a in (39329, 39333, 39337, 39341))
    ),
    *_numbered(
        "pv_voltage",
        "voltage",
        tuple(_i16(a, 0.1, 1) for a in (39070, 39072, 39074, 39076)),
        enabled=False,
    ),
    *_numbered(
        "pv_current",
        "current",
        tuple(_i16(a, 0.01, 2) for a in (39071, 39073, 39075, 39077)),
        enabled=False,
    ),
    *_numbered(
        "pv_power",
        "power",
        tuple(_i32(a) for a in (39279, 39281, 39283, 39285)),
        enabled=False,
    ),
    _sensor("eps_power", INVERTER, "power", _i32(39216), legacy="eps_power_total"),
    *_per_phase("eps_power", INVERTER, "power", _phases(39210, 2, _i32), enabled=False),
    *_per_phase(
        "eps_voltage",
        INVERTER,
        "voltage",
        _phases(39201, 1, lambda a: _u16(a, 0.1, 1)),
        enabled=False,
    ),
    _sensor(
        "eps_frequency", INVERTER, "frequency", _i16(39218, 0.01, 2), enabled=False
    ),
    _sensor(
        "pv_energy_total",
        INVERTER,
        "energy_total",
        _energy(39601),
        legacy="pv_power_total",
    ),
    _sensor("pv_energy_today", INVERTER, "energy_today", _energy(39603), enabled=False),
    _sensor(
        "energy_generated_total",
        INVERTER,
        "energy_total",
        Register(39149, "u32", 0.01, 2),
    ),
    _sensor(
        "energy_generated_today",
        INVERTER,
        "energy_today",
        Register(39151, "u32", 0.01, 2),
        enabled=False,
    ),
    _sensor(
        "output_energy_total",
        INVERTER,
        "energy_total",
        _energy(39621),
        legacy="output_power_total",
        enabled=False,
    ),
    _sensor(
        "output_energy_today",
        INVERTER,
        "energy_today",
        _energy(39623),
        legacy="output_power_today",
        enabled=False,
    ),
    _sensor(
        "input_energy_total",
        INVERTER,
        "energy_total",
        _energy(39625),
        legacy="input_power_total",
    ),
    _sensor(
        "input_energy_today",
        INVERTER,
        "energy_today",
        _energy(39627),
        legacy="input_power_today",
        enabled=False,
    ),
    _sensor(
        "load_energy_total",
        INVERTER,
        "energy_total",
        _energy(39629),
        legacy="load_power_total_39629",
    ),
    _sensor(
        "load_energy_today",
        INVERTER,
        "energy_today",
        _energy(39631),
        legacy="load_power_today",
        enabled=False,
    ),
    # Battery
    _sensor("bms1_state_of_charge", BATTERY, "battery", _u16(37612)),
    _sensor("bms1_state_of_health", BATTERY, "percentage", _u16(37624)),
    _sensor("battery_power_total", BATTERY, "power", _i32(39237)),
    _sensor("bms1_voltage", BATTERY, "voltage", _u16(37609, 0.1, 1)),
    _sensor("bms1_current", BATTERY, "current", _i16(37610, 0.1, 1)),
    _sensor("bms1_ambient_temperature", BATTERY, "temperature", _i16(37611, 0.1, 1)),
    _sensor("bms1_temperature_max", BATTERY, "temperature", _i16(37617, 0.1, 1)),
    _sensor("bms1_temperature_min", BATTERY, "temperature", _i16(37618, 0.1, 1)),
    _sensor("bms1_cell_voltage_max", BATTERY, "cell_voltage", _u16(37619)),
    _sensor("bms1_cell_voltage_min", BATTERY, "cell_voltage", _u16(37620)),
    _sensor("bms1_remaining_energy", BATTERY, "energy_stored", _u16(37632, 10)),
    _sensor("bms1_design_energy", BATTERY, "energy_stored", _u16(37635, 10)),
    _sensor("bms1_full_charge_capacity", BATTERY, "charge", _u16(37633, 0.1, 1)),
    _sensor("charge_energy_total", BATTERY, "energy_total", _energy(39605)),
    _sensor(
        "charge_energy_today", BATTERY, "energy_today", _energy(39607), enabled=False
    ),
    _sensor(
        "discharge_energy_total",
        BATTERY,
        "energy_total",
        _energy(39609),
        legacy="discharge_power_total",
    ),
    _sensor(
        "discharge_energy_today",
        BATTERY,
        "energy_today",
        _energy(39611),
        legacy="discharge_power_today",
        enabled=False,
    ),
    # The single battery repeats the BMS and battery totals.
    _sensor("battery1_voltage", BATTERY, "voltage", _i16(39227, 0.1, 1), enabled=False),
    _sensor("battery1_current", BATTERY, "current", _i32(39228, 0.1, 1), enabled=False),
    _sensor("battery1_power", BATTERY, "power", _i32(39230), enabled=False),
    # Grid meter
    _sensor("meter1_active_power_total", GRID, "power", _i32(38814, 0.1, 1)),
    *_per_phase(
        "meter1_active_power",
        GRID,
        "power",
        _phases(38816, 2, lambda a: _i32(a, 0.1, 1)),
    ),
    *_per_phase(
        "meter1_voltage", GRID, "voltage", _phases(38802, 2, lambda a: _i32(a, 0.1, 1))
    ),
    *_per_phase(
        "meter1_current",
        GRID,
        "current",
        _phases(38808, 2, lambda a: _i32(a, 0.001, 3)),
    ),
    _sensor("meter1_frequency", GRID, "frequency", _i32(38846, 0.01, 2)),
    _sensor("meter1_power_factor_total", GRID, "power_factor", _i32(38838, 0.001, 3)),
    *_per_phase(
        "meter1_power_factor",
        GRID,
        "power_factor",
        _phases(38840, 2, lambda a: _i32(a, 0.001, 3)),
        enabled=False,
    ),
    _sensor("meter1_reactive_power_total", GRID, "reactive_power", _i32(38822, 0.1, 1)),
    *_per_phase(
        "meter1_reactive_power",
        GRID,
        "reactive_power",
        _phases(38824, 2, lambda a: _i32(a, 0.1, 1)),
        enabled=False,
    ),
    _sensor("meter1_apparent_power_total", GRID, "apparent_power", _i32(38830, 0.1, 1)),
    *_per_phase(
        "meter1_apparent_power",
        GRID,
        "apparent_power",
        _phases(38832, 2, lambda a: _i32(a, 0.1, 1)),
        enabled=False,
    ),
    # The meter's power seen from the inverter, with the sign flipped.
    _sensor("meter_collection_active_power", GRID, "power", _i32(39168), enabled=False),
    _sensor("energy_consumed_total", GRID, "energy_total", _energy(39617)),
    _sensor(
        "energy_consumed_today", GRID, "energy_today", _energy(39619), enabled=False
    ),
    _sensor(
        "feeder_network_energy_total",
        GRID,
        "energy_total",
        _energy(39613),
        legacy="feeder_network_power_total",
    ),
    _sensor(
        "feeder_network_energy_today",
        GRID,
        "energy_today",
        _energy(39615),
        legacy="feeder_network_power_today",
        enabled=False,
    ),
)


# Inputs of the values derived below.
CELL_VOLTAGE_MAX = _u16(37619)
CELL_VOLTAGE_MIN = _u16(37620)
STATE_OF_CHARGE = _u16(37612)
REMAINING_ENERGY = _u16(37632, 10)
DESIGN_ENERGY = _u16(37635, 10)
BATTERY_POWER = _i32(39237)
DISCHARGED = _energy(39609)

# Below this the battery idles and a time estimate only jumps around.
IDLE_POWER = 50


def _numbers(data: Snapshot, *registers: Register) -> list[float] | None:
    values = [data[register] for register in registers]
    if any(not isinstance(value, int | float) for value in values):
        return None
    return [float(value) for value in values if isinstance(value, int | float)]


def _cell_spread(data: Snapshot) -> float | None:
    if (values := _numbers(data, CELL_VOLTAGE_MAX, CELL_VOLTAGE_MIN)) is None:
        return None
    high, low = values
    return high - low


def _cycles(data: Snapshot) -> float | None:
    if (values := _numbers(data, DISCHARGED, DESIGN_ENERGY)) is None:
        return None
    discharged_kwh, design_wh = values
    return round(discharged_kwh / (design_wh / 1000), 1) if design_wh else None


def _time_remaining(data: Snapshot) -> float | None:
    """Hours until empty at the current discharge power."""
    if (values := _numbers(data, REMAINING_ENERGY, BATTERY_POWER)) is None:
        return None
    remaining_wh, power = values
    return round(remaining_wh / power, 1) if power > IDLE_POWER else None


def _time_to_full(data: Snapshot) -> float | None:
    """Hours until full at the current charge power."""
    if (
        values := _numbers(data, REMAINING_ENERGY, STATE_OF_CHARGE, BATTERY_POWER)
    ) is None:
        return None
    remaining_wh, soc, power = values
    if power > -IDLE_POWER or soc <= 0:
        return None
    return round((remaining_wh / (soc / 100) - remaining_wh) / -power, 1)


def _derived(
    key: str,
    value_fn: Callable[[Snapshot], StateType],
    *,
    device_class: SensorDeviceClass | None = None,
    unit: str | None = None,
    state_class: SensorStateClass | None = SensorStateClass.MEASUREMENT,
    precision: int = 1,
) -> FoxSensorDescription:
    return FoxSensorDescription(
        key=key,
        part=Part.BATTERY,
        translation_key=key,
        device_class=device_class,
        native_unit_of_measurement=unit,
        state_class=state_class,
        suggested_display_precision=precision,
        value_fn=value_fn,
    )


DERIVED: tuple[FoxSensorDescription, ...] = (
    _derived(
        "cell_voltage_spread",
        _cell_spread,
        device_class=SensorDeviceClass.VOLTAGE,
        unit=UnitOfElectricPotential.MILLIVOLT,
        precision=0,
    ),
    _derived("battery_cycles", _cycles, state_class=SensorStateClass.TOTAL_INCREASING),
    _derived(
        "battery_time_remaining",
        _time_remaining,
        device_class=SensorDeviceClass.DURATION,
        unit=UnitOfTime.HOURS,
        state_class=None,
    ),
    _derived(
        "battery_time_to_full",
        _time_to_full,
        device_class=SensorDeviceClass.DURATION,
        unit=UnitOfTime.HOURS,
        state_class=None,
    ),
)


@dataclass(frozen=True, kw_only=True)
class FoxOutageDescription(SensorEntityDescription, FoxEntityDescription):
    """A sensor over the last grid outage."""

    value_fn: Callable[[Outage, datetime], StateType | datetime]


def _outage_minutes(outage: Outage, now: datetime) -> float | None:
    duration = outage.duration(now)
    return None if duration is None else round(duration.total_seconds() / 60, 1)


OUTAGES: tuple[FoxOutageDescription, ...] = (
    FoxOutageDescription(
        key="grid_outage_last",
        part=Part.GRID,
        translation_key="grid_outage_last",
        device_class=SensorDeviceClass.TIMESTAMP,
        value_fn=lambda outage, _now: outage.started,
    ),
    FoxOutageDescription(
        key="grid_outage_duration",
        part=Part.GRID,
        translation_key="grid_outage_duration",
        device_class=SensorDeviceClass.DURATION,
        native_unit_of_measurement=UnitOfTime.MINUTES,
        suggested_display_precision=0,
        value_fn=_outage_minutes,
    ),
    FoxOutageDescription(
        key="grid_outages",
        part=Part.GRID,
        translation_key="grid_outages",
        state_class=SensorStateClass.TOTAL_INCREASING,
        value_fn=lambda outage, _now: outage.count,
    ),
)


async def async_setup_entry(
    hass: HomeAssistant,
    entry: FoxConfigEntry,
    async_add_entities: AddConfigEntryEntitiesCallback,
) -> None:
    """Set up the FoxESS sensors."""
    coordinator = entry.runtime_data
    async_add_entities(
        [
            *(
                FoxSensor(coordinator, description)
                for description in (*SENSORS, *DERIVED)
            ),
            *(FoxOutageSensor(coordinator, description) for description in OUTAGES),
        ]
    )


class FoxSensor(FoxEntity, SensorEntity):
    """A value read off the inverter."""

    entity_description: FoxSensorDescription
    platform_domain = "sensor"

    @property
    @override
    def native_value(self) -> StateType:
        """Return the value from the last poll."""
        return self.entity_description.value_fn(self.coordinator.data)


class FoxOutageSensor(FoxEntity, SensorEntity):
    """The last grid outage, as the inverter saw it."""

    entity_description: FoxOutageDescription
    platform_domain = "sensor"

    @property
    @override
    def native_value(self) -> StateType | datetime:
        """Return the value for the last recorded outage."""
        return self.entity_description.value_fn(
            self.coordinator.outages.outage, dt_util.utcnow()
        )
