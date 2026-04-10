"""Virtual grid export simulation for heat-pump-facing meter values."""

from __future__ import annotations

from dataclasses import dataclass
import logging

from .value_definitions import normalize_values


LOGGER = logging.getLogger(__name__)


@dataclass(frozen=True)
class GridExportSimulationConfig:
    """Configuration for virtual export simulation."""

    enable: bool = False
    activate_soc_pct: float = 90.0
    deactivate_soc_pct: float = 88.0
    grid_import_tolerance_w: float = 50.0
    battery_idle_tolerance_w: float = 100.0
    pv_cover_margin_w: float = 100.0


class GridExportSimulator:
    """Stateful heuristic that fakes export for a downstream heat pump."""

    def __init__(self, config: GridExportSimulationConfig) -> None:
        self._config = config
        self._full_battery_active = False
        self._active = False

    @property
    def active(self) -> bool:
        """Return whether virtual export is currently active."""
        return self._active

    def apply(self, raw_values: dict[str, float]) -> dict[str, float]:
        """Return effective values with optional virtual export applied."""
        values = normalize_values(raw_values)
        if not self._config.enable:
            return values

        house_load_w = max(
            0.0,
            values["active_power_w"] + values["grid_power_w"] + values["battery_power_w"],
        )
        pv_can_cover_house_load = (
            values["grid_power_w"] <= self._config.grid_import_tolerance_w
            and values["active_power_w"] >= house_load_w - self._config.pv_cover_margin_w
        )
        battery_is_idle = (
            abs(values["battery_power_w"]) <= self._config.battery_idle_tolerance_w
        )
        battery_is_charging = (
            values["battery_power_w"] < -self._config.battery_idle_tolerance_w
        )
        charging_export_w = (
            abs(values["battery_power_w"])
            if battery_is_charging and pv_can_cover_house_load
            else 0.0
        )

        previous_active = self.active
        if self._full_battery_active:
            self._full_battery_active = (
                values["battery_soc_pct"] >= self._config.deactivate_soc_pct
                and battery_is_idle
                and pv_can_cover_house_load
            )
        else:
            self._full_battery_active = (
                values["battery_soc_pct"] >= self._config.activate_soc_pct
                and battery_is_idle
                and pv_can_cover_house_load
            )

        self._active = charging_export_w > 0.0 or self._full_battery_active

        if previous_active != self._active:
            LOGGER.info(
                "Virtual grid export simulation %s",
                "activated" if self._active else "deactivated",
            )

        if not self._active:
            return values

        simulated_export_w = (
            charging_export_w
            if charging_export_w > 0.0
            else max(0.0, values["active_power_w"])
        )
        effective_values = dict(values)
        effective_values["grid_power_w"] = min(
            values["grid_power_w"],
            -simulated_export_w,
        )
        return effective_values
