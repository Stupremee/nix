"""Taking over the YAML Modbus entities, so history and dashboards carry on."""

import logging

from homeassistant.config_entries import ConfigEntry
from homeassistant.core import HomeAssistant, callback
from homeassistant.helpers import entity_registry as er

from .binary_sensor import BINARY_SENSORS
from .const import DOMAIN
from .entity import FoxEntityDescription
from .sensor import SENSORS
from .switch import SWITCHES

_LOGGER = logging.getLogger(__name__)

LEGACY_PLATFORM = "modbus"

# Raw codes that now read as text get entity IDs to match.
RENAMED: dict[str, str] = {
    "ess_1_status_1": "sensor.ess_1_status",
    "ess_1_status_3": "sensor.ess_1_grid_mode",
}

# Identity now lives on the devices, alarms in one problem sensor, and the EPS
# currents only ever read a placeholder.
REMOVED_SENSORS: tuple[str, ...] = tuple(
    f"ess_1_{key}"
    for key in (
        "device_model_name",
        "device_serial_number",
        "firmware_master_version",
        "firmware_slave_version",
        "firmware_manager_version",
        "bms1_firmware_master_version",
        "bms1_firmware_slave_version",
        "bms1_slave_serial_number",
        "bms1_slave1_serial_number",
        "bms1_slave2_serial_number",
        "bms1_slave2_firmware_version",
        "alarm_1",
        "alarm_2",
        "alarm_3",
        "eps_current_l1",
        "eps_current_l2",
        "eps_current_l3",
    )
)

DESCRIPTIONS: tuple[tuple[str, FoxEntityDescription], ...] = (
    *(("sensor", description) for description in SENSORS),
    *(("binary_sensor", description) for description in BINARY_SENSORS),
    *(("switch", description) for description in SWITCHES),
)


@callback
def async_migrate_legacy_entities(
    hass: HomeAssistant, entry: ConfigEntry, serial: str
) -> None:
    """Move YAML Modbus entities onto this entry, keeping their entity IDs.

    Runs before the platforms load, and only finds anything the first time.
    """
    registry = er.async_get(hass)

    for unique_id in REMOVED_SENSORS:
        if entity_id := registry.async_get_entity_id(
            "sensor", LEGACY_PLATFORM, unique_id
        ):
            _LOGGER.info("Removing %s, now covered by the FoxESS devices", entity_id)
            registry.async_remove(entity_id)

    for domain, description in DESCRIPTIONS:
        legacy = description.legacy_unique_id
        if legacy is None:
            continue
        entity_id = registry.async_get_entity_id(domain, LEGACY_PLATFORM, legacy)
        if entity_id is None:
            continue
        migrated = registry.async_update_entity_platform(
            entity_id,
            DOMAIN,
            new_config_entry_id=entry.entry_id,
            new_unique_id=f"{serial}_{description.key}",
        )
        _LOGGER.info("Took over %s from YAML Modbus", entity_id)
        if (
            not description.entity_registry_enabled_default
            and migrated.disabled_by is None
        ):
            registry.async_update_entity(
                entity_id, disabled_by=er.RegistryEntryDisabler.INTEGRATION
            )
        new_entity_id = RENAMED.get(legacy)
        if new_entity_id and not registry.async_is_registered(new_entity_id):
            registry.async_update_entity(entity_id, new_entity_id=new_entity_id)
