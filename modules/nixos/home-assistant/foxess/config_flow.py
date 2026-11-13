"""Adding the FoxESS inverter by address, or from YAML."""

import logging
from typing import Any, override

from modbus_connection import ModbusError, ModbusTcpParams
import probatio

from homeassistant.components.modbus import async_get_temporary_unit
from homeassistant.config_entries import ConfigFlow, ConfigFlowResult
from homeassistant.const import CONF_HOST, CONF_PORT
from homeassistant.exceptions import HomeAssistantError
from homeassistant.helpers.selector import (
    NumberSelector,
    NumberSelectorConfig,
    NumberSelectorMode,
    TextSelector,
)

from .const import CONF_UNIT_ID, DEFAULT_PORT, DEFAULT_UNIT_ID, DOMAIN
from .coordinator import async_read_identity

_LOGGER = logging.getLogger(__name__)

STEP_USER_DATA_SCHEMA = probatio.Schema(
    {
        probatio.Required(CONF_HOST): TextSelector(),
        probatio.Required(CONF_PORT, default=DEFAULT_PORT): probatio.All(
            NumberSelector(
                NumberSelectorConfig(mode=NumberSelectorMode.BOX, min=1, max=65535)
            ),
            probatio.Coerce(int),
        ),
        probatio.Required(CONF_UNIT_ID, default=DEFAULT_UNIT_ID): probatio.All(
            NumberSelector(
                NumberSelectorConfig(mode=NumberSelectorMode.BOX, min=1, max=247)
            ),
            probatio.Coerce(int),
        ),
    }
)


class FoxConfigFlow(ConfigFlow, domain=DOMAIN):
    """Handle a config flow for FoxESS."""

    VERSION = 1

    @override
    async def async_step_user(
        self, user_input: dict[str, Any] | None = None
    ) -> ConfigFlowResult:
        """Ask for an address and check an inverter answers there."""
        errors: dict[str, str] = {}

        if user_input is not None:
            # One inverter per house; the entities still key on its serial.
            await self.async_set_unique_id(DOMAIN)
            self._abort_if_unique_id_configured()
            params = ModbusTcpParams(
                host=user_input[CONF_HOST], port=user_input[CONF_PORT]
            )
            try:
                async with async_get_temporary_unit(
                    self.hass, params, user_input[CONF_UNIT_ID]
                ) as unit:
                    identity = await async_read_identity(unit)
            except ModbusError, HomeAssistantError:
                errors["base"] = "cannot_connect"
            except Exception:
                _LOGGER.exception("Unexpected exception")
                errors["base"] = "unknown"
            else:
                return self.async_create_entry(title=identity.model, data=user_input)

        return self.async_show_form(
            step_id="user",
            data_schema=self.add_suggested_values_to_schema(
                STEP_USER_DATA_SCHEMA, user_input
            ),
            errors=errors,
        )

    async def async_step_import(self, import_data: dict[str, Any]) -> ConfigFlowResult:
        """Create or update the entry from YAML, without probing the device."""
        await self.async_set_unique_id(DOMAIN)
        self._abort_if_unique_id_configured(updates=import_data)
        return self.async_create_entry(title="FoxESS", data=import_data)
