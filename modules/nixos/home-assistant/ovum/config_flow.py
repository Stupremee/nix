"""Adding the Ovum controller by address, or from YAML."""

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

from .const import DEFAULT_PORT, DOMAIN, NAME
from .registers import SYSTEM_NAME

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
    }
)


class OvumConfigFlow(ConfigFlow, domain=DOMAIN):
    """Handle a config flow for Ovum."""

    VERSION = 1

    @override
    async def async_step_user(
        self, user_input: dict[str, Any] | None = None
    ) -> ConfigFlowResult:
        """Ask for an address and check the controller answers there."""
        errors: dict[str, str] = {}

        if user_input is not None:
            # One controller per house, and it carries no serial to key on.
            await self.async_set_unique_id(DOMAIN)
            self._abort_if_unique_id_configured()
            params = ModbusTcpParams(
                host=user_input[CONF_HOST], port=user_input[CONF_PORT]
            )
            try:
                async with async_get_temporary_unit(
                    self.hass, params, SYSTEM_NAME.module
                ) as unit:
                    await unit.read_holding_registers(
                        SYSTEM_NAME.address, SYSTEM_NAME.count
                    )
            except ModbusError, HomeAssistantError:
                errors["base"] = "cannot_connect"
            except Exception:
                _LOGGER.exception("Unexpected exception")
                errors["base"] = "unknown"
            else:
                return self.async_create_entry(title=NAME, data=user_input)

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
        return self.async_create_entry(title=NAME, data=import_data)
