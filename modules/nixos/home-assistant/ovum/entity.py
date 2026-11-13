"""What every Ovum entity shares."""

from homeassistant.helpers.entity import EntityDescription
from homeassistant.helpers.update_coordinator import CoordinatorEntity

from .const import DOMAIN
from .coordinator import OvumCoordinator


class OvumEntity(CoordinatorEntity[OvumCoordinator]):
    """An entity on the one Ovum device."""

    _attr_has_entity_name = True

    def __init__(
        self, coordinator: OvumCoordinator, description: EntityDescription
    ) -> None:
        """Initialize the entity."""
        super().__init__(coordinator)
        self.entity_description = description
        self._attr_unique_id = f"{DOMAIN}_{description.key}"
        self._attr_device_info = coordinator.device_info
