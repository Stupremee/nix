"""Grid outages, taken from the inverter switching to off-grid operation."""

from dataclasses import asdict, dataclass, replace
from datetime import datetime, timedelta

from homeassistant.core import HomeAssistant
from homeassistant.helpers.storage import Store
from homeassistant.util import dt as dt_util

from .const import DOMAIN

STORAGE_VERSION = 1


@dataclass(frozen=True, slots=True)
class Outage:
    """The most recent outage, and how many there have been."""

    count: int = 0
    started: datetime | None = None
    ended: datetime | None = None

    @property
    def ongoing(self) -> bool:
        return self.started is not None and self.ended is None

    def duration(self, now: datetime) -> timedelta | None:
        """How long the last outage lasted, or has lasted so far."""
        if self.started is None:
            return None
        return (self.ended or now) - self.started


class OutageTracker:
    """Follow the off-grid flag across polls and keep the result across restarts."""

    def __init__(self, hass: HomeAssistant, serial: str) -> None:
        self._store = Store[dict[str, str | int | None]](
            hass, STORAGE_VERSION, f"{DOMAIN}.{serial}.outage"
        )
        self.outage = Outage()

    async def async_load(self) -> None:
        """Restore the last known outage."""
        if not (data := await self._store.async_load()):
            return
        started, ended = data.get("started"), data.get("ended")
        self.outage = Outage(
            count=int(data.get("count") or 0),
            started=dt_util.parse_datetime(started)
            if isinstance(started, str)
            else None,
            ended=dt_util.parse_datetime(ended) if isinstance(ended, str) else None,
        )

    def update(self, off_grid: bool | None) -> None:
        """Record a transition into or out of off-grid operation."""
        if off_grid is None or off_grid == self.outage.ongoing:
            return
        now = dt_util.utcnow()
        if off_grid:
            self.outage = Outage(count=self.outage.count + 1, started=now)
        else:
            self.outage = replace(self.outage, ended=now)
        self._store.async_delay_save(self._serialize, 1)

    def _serialize(self) -> dict[str, str | int | None]:
        return {
            key: value.isoformat() if isinstance(value, datetime) else value
            for key, value in asdict(self.outage).items()
        }
