"""The FoxESS H3 inverter, battery and grid meter over Modbus TCP."""

from modbus_connection import ModbusError, ModbusTcpParams
import probatio

from homeassistant.components.modbus import async_get_unit
from homeassistant.config_entries import SOURCE_IMPORT
from homeassistant.const import CONF_HOST, CONF_PORT, Platform
from homeassistant.core import HomeAssistant
from homeassistant.exceptions import ConfigEntryNotReady
from homeassistant.helpers import config_validation as cv, device_registry as dr
from homeassistant.helpers.typing import ConfigType

from .const import CONF_UNIT_ID, DEFAULT_PORT, DEFAULT_UNIT_ID, DOMAIN
from .coordinator import FoxConfigEntry, FoxCoordinator, async_read_identity
from .entity import Part, device_info
from .migration import async_migrate_legacy_entities

PLATFORMS: list[Platform] = [Platform.BINARY_SENSOR, Platform.SENSOR, Platform.SWITCH]

CONFIG_SCHEMA = probatio.Schema(
    {
        probatio.Optional(DOMAIN): probatio.Schema(
            {
                probatio.Required(CONF_HOST): cv.string,
                probatio.Optional(CONF_PORT, default=DEFAULT_PORT): cv.port,
                probatio.Optional(
                    CONF_UNIT_ID, default=DEFAULT_UNIT_ID
                ): cv.positive_int,
            }
        )
    },
    extra=probatio.ALLOW_EXTRA,
)


async def async_setup(hass: HomeAssistant, config: ConfigType) -> bool:
    """Create the config entry from YAML, if it is configured there."""
    if DOMAIN in config:
        hass.async_create_task(
            hass.config_entries.flow.async_init(
                DOMAIN, context={"source": SOURCE_IMPORT}, data=config[DOMAIN]
            )
        )
    return True


async def async_setup_entry(hass: HomeAssistant, entry: FoxConfigEntry) -> bool:
    """Set up the FoxESS inverter from a config entry."""
    unit = async_get_unit(
        hass,
        entry,
        ModbusTcpParams(host=entry.data[CONF_HOST], port=entry.data[CONF_PORT]),
        entry.data[CONF_UNIT_ID],
    )
    try:
        identity = await async_read_identity(unit)
    except ModbusError as err:
        raise ConfigEntryNotReady(
            translation_domain=DOMAIN,
            translation_key="cannot_connect",
            translation_placeholders={"error": str(err)},
        ) from err

    async_migrate_legacy_entities(hass, entry, identity.serial)

    # Battery and grid meter hang off the inverter, so it has to exist first.
    inverter = dr.async_get(hass).async_get_or_create(
        config_entry_id=entry.entry_id, **device_info(identity, Part.INVERTER)
    )
    coordinator = FoxCoordinator(hass, entry, unit, identity, inverter.id)
    await coordinator.async_config_entry_first_refresh()

    entry.runtime_data = coordinator
    await hass.config_entries.async_forward_entry_setups(entry, PLATFORMS)
    return True


async def async_unload_entry(hass: HomeAssistant, entry: FoxConfigEntry) -> bool:
    """Unload a config entry."""
    return await hass.config_entries.async_unload_platforms(entry, PLATFORMS)
