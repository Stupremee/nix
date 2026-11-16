"""The Ovum heat pump, read and set over the MIRA controller's Modbus TCP."""

from pathlib import Path

from modbus_connection import ModbusTcpParams
import probatio

from homeassistant.components.modbus import async_get_unit
from homeassistant.config_entries import SOURCE_IMPORT
from homeassistant.const import (
    CONF_HOST,
    CONF_PORT,
    EVENT_HOMEASSISTANT_STOP,
    Platform,
)
from homeassistant.core import Event, HomeAssistant
from homeassistant.exceptions import ConfigEntryError
from homeassistant.helpers import config_validation as cv
from homeassistant.helpers.typing import ConfigType

from .const import CONF_EMS, CONF_LOGIN_CODE_FILE, DEFAULT_PORT, DOMAIN
from .coordinator import OvumConfigEntry, OvumCoordinator
from .ems import EmsController, EmsInputs
from .registers import Module

PLATFORMS: list[Platform] = [
    Platform.NUMBER,
    Platform.SELECT,
    Platform.SENSOR,
    Platform.SWITCH,
]

CONFIG_SCHEMA = probatio.Schema(
    {
        probatio.Optional(DOMAIN): probatio.Schema(
            {
                probatio.Required(CONF_HOST): cv.string,
                probatio.Optional(CONF_PORT, default=DEFAULT_PORT): cv.port,
                probatio.Optional(CONF_LOGIN_CODE_FILE): cv.string,
                probatio.Optional(CONF_EMS): probatio.Schema(
                    {
                        probatio.Required("battery_level"): cv.entity_id,
                        probatio.Required("battery_power"): cv.entity_id,
                        probatio.Required("grid_power"): cv.entity_id,
                        probatio.Required("pv_power"): cv.entity_id,
                        probatio.Optional(
                            "grid_power_inverted", default=False
                        ): cv.boolean,
                        probatio.Optional("heating_rod"): cv.entity_id,
                    }
                ),
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


async def async_setup_entry(hass: HomeAssistant, entry: OvumConfigEntry) -> bool:
    """Set up the Ovum controller from a config entry."""
    params = ModbusTcpParams(host=entry.data[CONF_HOST], port=entry.data[CONF_PORT])
    units = {module: async_get_unit(hass, entry, params, module) for module in Module}
    login_code = await _async_read_login_code(
        hass, entry.data.get(CONF_LOGIN_CODE_FILE)
    )

    coordinator = OvumCoordinator(hass, entry, units, login_code)
    await coordinator.async_config_entry_first_refresh()
    if inputs := entry.data.get(CONF_EMS):
        ems = coordinator.ems = EmsController(hass, coordinator, EmsInputs(**inputs))

        # Hand the heat pump back to its own control while nothing feeds it.
        async def _async_release(_: Event | None = None) -> None:
            await ems.async_disable()

        entry.async_on_unload(_async_release)
        entry.async_on_unload(
            hass.bus.async_listen_once(EVENT_HOMEASSISTANT_STOP, _async_release)
        )

    entry.runtime_data = coordinator
    await hass.config_entries.async_forward_entry_setups(entry, PLATFORMS)
    return True


async def async_unload_entry(hass: HomeAssistant, entry: OvumConfigEntry) -> bool:
    """Unload a config entry."""
    return await hass.config_entries.async_unload_platforms(entry, PLATFORMS)


async def _async_read_login_code(hass: HomeAssistant, path: str | None) -> int | None:
    """Read the Modbus login code, which only writes need."""
    if path is None:
        return None
    try:
        return int(await hass.async_add_executor_job(Path(path).read_text))
    except (OSError, ValueError) as err:
        raise ConfigEntryError(
            translation_domain=DOMAIN,
            translation_key="login_code_unreadable",
            translation_placeholders={"path": path},
        ) from err
