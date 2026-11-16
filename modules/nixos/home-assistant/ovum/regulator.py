"""When to raise the heat pump on PV surplus behind a zero-export inverter.

With zero export a full battery makes the inverter curtail PV, and surplus
never shows as a number. So the regulator keeps the battery just below full,
at 95 %: there the battery's own charging and discharging is the surplus, and
the consumers follow it. The heat pump's power target takes what the battery
would otherwise charge beyond the little it needs to stay at 95 %.

Once the heat pump draws all it can, the heating rod in its flow takes the
rest in 3 kW steps. It runs only while the compressor does, since only then
does the condenser pump move water past it. It switches fast and gives way
first, while the heat pump follows minute means so the battery rides out
clouds.
"""

from collections import deque
from collections.abc import Callable
from dataclasses import dataclass
from datetime import datetime, timedelta
from enum import IntEnum, StrEnum


class PvStatus(IntEnum):
    """What the controller's EMS PV status register accepts."""

    NEUTRAL = 0
    RAISE = 1


class EmsState(StrEnum):
    """What the regulator is doing, for the state sensor."""

    OFF = "off"
    NO_INPUT = "no_input"
    IDLE = "idle"
    PENDING = "pending"
    RAISING = "raising"


# The battery level held while raising, and how hard it pulls back to it: at
# 93 % the battery still takes 1 kW, at 97 % the consumers may draw 1 kW from it.
HOLD_LEVEL = 95
PULL_PER_PERCENT = 500
MAX_PULL = 2000

# Start once the battery is near the held level and the surplus over the start
# window is worth it.
START_LEVEL = 93
START_SURPLUS = 500
MIN_PV = 1000
START_WINDOW = timedelta(minutes=5)

# Stop once the battery sinks well below the held level or PV fades in the
# evening, after the compressor has run long enough not to cycle, and at once
# below the floor.
STOP_LEVEL = 90
STOP_WINDOW = timedelta(minutes=10)
FLOOR_LEVEL = 85
MIN_RUN = timedelta(minutes=20)

# The heat pump follows the surplus averaged over this window.
TRACK_WINDOW = timedelta(minutes=5)

# The AC417P draws 0.6 to 1.0 kW at its lowest compressor speed and up to
# 5.0 kW at its highest for 55 °C flow (datasheet ACP 2026-06).
MIN_TARGET = 800
MAX_TARGET = 5000
TARGET_RESOLUTION = 100

# The HEA THOR switches three 3 kW elements. It steps up after a minute with
# a surplus that covers most of a step, the battery taking the rest, and steps
# down after a minute of this much deficit.
ROD_STEP = 3000
ROD_MAX = 9000
ROD_WINDOW = timedelta(minutes=1)
ROD_STEP_SURPLUS = 2500
ROD_CUT_DEFICIT = 1000
ROD_STEP_AFTER = timedelta(minutes=2)
# Above this level the inverter may be curtailing, which hides the surplus, so
# the rod steps up as long as the battery is not discharging. If PV cannot
# follow, the battery drains towards the held level, which is the point.
ROD_PROBE_LEVEL = HOLD_LEVEL + 3
# A probe that found no surplus is not repeated for a while.
ROD_PROBE_HOLD = timedelta(minutes=15)
# The heat pump counts as saturated while its draw stays this far below the
# target without rising.
SATURATION_GAP = 400
SATURATION_RISE = 200
ROD_AFTER_SATURATED = timedelta(minutes=3)

HISTORY = max(START_WINDOW, STOP_WINDOW, TRACK_WINDOW, ROD_WINDOW)


@dataclass(frozen=True, slots=True)
class Reading:
    """One look at the house, in watts and percent."""

    battery_level: float
    battery_power: float
    """Positive while discharging."""
    grid_power: float
    """Positive while importing."""
    pv_power: float
    heat_pump_power: float
    heat_pump_running: bool
    """Whether the compressor, and with it the condenser pump, runs."""

    @property
    def surplus(self) -> float:
        """Power the consumers could take on top, keeping the battery at its level."""
        pull = (HOLD_LEVEL - self.battery_level) * PULL_PER_PERCENT
        wanted = min(max(pull, -MAX_PULL), MAX_PULL)
        return -self.battery_power - max(0.0, self.grid_power) - wanted


@dataclass(frozen=True, slots=True)
class Plan:
    """What to write to the controller."""

    state: EmsState
    status: PvStatus
    target: int
    rod: int = 0
    """Heating rod power in watts."""


IDLE = Plan(EmsState.IDLE, PvStatus.NEUTRAL, 0)


class History:
    """The readings of the last minutes."""

    def __init__(self) -> None:
        """Start empty."""
        self._readings: deque[tuple[datetime, Reading]] = deque()

    def add(self, now: datetime, reading: Reading) -> None:
        """Remember a reading and forget those too old to matter."""
        self._readings.append((now, reading))
        while self._readings[0][0] < now - HISTORY:
            self._readings.popleft()

    def clear(self) -> None:
        """Forget every reading."""
        self._readings.clear()

    def covers(self, now: datetime, window: timedelta) -> bool:
        """Whether the readings reach back over the whole window."""
        return bool(self._readings) and self._readings[0][0] <= now - window

    def mean(
        self, now: datetime, window: timedelta, value: Callable[[Reading], float]
    ) -> float:
        """Average a value over the readings inside the window."""
        values = [value(r) for at, r in self._readings if at >= now - window]
        return sum(values) / len(values) if values else 0.0


class Regulator:
    """Decide the PV status, power target and heating rod, reading by reading."""

    def __init__(self) -> None:
        """Start idle."""
        self.plan = IDLE
        self.history = History()
        self._started = datetime.min
        self._saturated_since: datetime | None = None
        self._saturated_power = 0.0
        self._rod_changed: datetime | None = None
        self._rod_cut: datetime | None = None

    def step(self, now: datetime, reading: Reading | None) -> Plan:
        """Return the plan for this reading."""
        if reading is None:
            self.history.clear()
            self.plan = Plan(EmsState.NO_INPUT, PvStatus.NEUTRAL, 0)
            return self.plan
        self.history.add(now, reading)
        if self.plan.state is EmsState.RAISING:
            self.plan = self._raising(now, reading)
        else:
            self.plan = self._waiting(now, reading)
        return self.plan

    def _mean(
        self, now: datetime, window: timedelta, value: Callable[[Reading], float]
    ) -> float:
        return self.history.mean(now, window, value)

    def _waiting(self, now: datetime, reading: Reading) -> Plan:
        surplus = (
            self._mean(now, START_WINDOW, lambda r: r.battery_level) >= START_LEVEL
            and self._mean(now, START_WINDOW, lambda r: r.pv_power) >= MIN_PV
            and self._mean(now, START_WINDOW, lambda r: r.surplus) >= START_SURPLUS
        )
        if not surplus:
            return IDLE
        if not self.history.covers(now, START_WINDOW):
            return Plan(EmsState.PENDING, PvStatus.NEUTRAL, 0)
        self._started = now
        self._saturated_since = None
        self._rod_changed = None
        self._rod_cut = None
        return self._raise(now, reading, previous=IDLE)

    def _raising(self, now: datetime, reading: Reading) -> Plan:
        ran = now - self._started >= MIN_RUN
        sinking = self._mean(now, STOP_WINDOW, lambda r: r.battery_level) < STOP_LEVEL
        fading = self._mean(now, STOP_WINDOW, lambda r: r.pv_power) < MIN_PV
        if reading.battery_level < FLOOR_LEVEL or (ran and (sinking or fading)):
            return IDLE
        return self._raise(now, reading, previous=self.plan)

    def _raise(self, now: datetime, reading: Reading, previous: Plan) -> Plan:
        if reading.heat_pump_running:
            surplus = self._mean(now, TRACK_WINDOW, lambda r: r.surplus)
            # The rod gives way first, and the battery rides out clouds while
            # above the held level, so a deficit only cuts the heat pump once
            # neither is left.
            if previous.rod or reading.battery_level >= HOLD_LEVEL - 1:
                surplus = max(surplus, 0.0)
            wanted = reading.heat_pump_power + surplus
        else:
            # Defrosting or idle: keep the target until the compressor is back.
            wanted = previous.target or MIN_TARGET
        clamped = min(max(wanted, MIN_TARGET), MAX_TARGET)
        target = round(clamped / TARGET_RESOLUTION) * TARGET_RESOLUTION
        rod = self._rod(now, reading, target, previous.rod)
        return Plan(EmsState.RAISING, PvStatus.RAISE, target, rod)

    def _rod(self, now: datetime, reading: Reading, target: int, rod: int) -> int:
        """Step the heating rod up once the heat pump is saturated, down first."""
        if not reading.heat_pump_running:
            self._saturated_since = None
            return 0
        surplus = self._mean(now, ROD_WINDOW, lambda r: r.surplus)
        # One step down per window, so the mean shows the last step's effect.
        followed = self._rod_changed is None or now - self._rod_changed >= ROD_WINDOW
        if rod and followed and surplus < -ROD_CUT_DEFICIT and reading.surplus < 0:
            self._rod_changed = now
            self._rod_cut = now
            return rod - ROD_STEP

        power = reading.heat_pump_power
        if target - power < SATURATION_GAP and target < MAX_TARGET:
            self._saturated_since = None
        elif (
            self._saturated_since is None
            or power > self._saturated_power + SATURATION_RISE
        ):
            self._saturated_since = now
            self._saturated_power = power
        saturated = (
            self._saturated_since is not None
            and now - self._saturated_since >= ROD_AFTER_SATURATED
        )
        settled = (
            self._rod_changed is None or now - self._rod_changed >= ROD_STEP_AFTER
        )
        visible = surplus >= ROD_STEP_SURPLUS and reading.surplus > 0
        hidden = (
            reading.battery_level >= ROD_PROBE_LEVEL
            and reading.battery_power < ROD_CUT_DEFICIT / 4
            and (self._rod_cut is None or now - self._rod_cut >= ROD_PROBE_HOLD)
        )
        if rod < ROD_MAX and saturated and settled and (visible or hidden):
            self._rod_changed = now
            return rod + ROD_STEP
        return rod
