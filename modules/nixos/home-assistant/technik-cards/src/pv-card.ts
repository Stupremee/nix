// What the PV surplus regulation decides, and whether the Ovum follows it.

import { type Cell, cells, CELLS_CSS } from "./cells";
import { BATTERY, EMS, GRID, HEAT_PUMP, ROD, TANK } from "./entities";
import { formatNumber, type HomeAssistant, type LovelaceCard, moreInfo, numeric } from "./hass";
import { TONE_COLOR, type Tone } from "./status";

const STATE_TONE: Record<string, Tone> = {
  raising: "run",
  pending: "warn",
  idle: "idle",
  off: "idle",
  no_input: "fault",
};

const PV_STATUS: Record<string, string> = { neutral: "Neutral", raise: "Anheben", lower: "Absenken" };

const WATCHED = [
  ...Object.values(EMS),
  HEAT_PUMP.pvStatus,
  HEAT_PUMP.powerInput,
  BATTERY.soc,
  BATTERY.power,
  GRID.power,
  TANK.hotWaterTargetActive,
  TANK.hotWaterTargetPv,
  TANK.bufferTargetActive,
  TANK.bufferTargetPv,
  ROD.pvPower,
  ROD.power,
  ROD.mode,
  ROD.demand,
];

/** Below this a power reads as zero. */
const NOISE_W = 50;

class PvCard extends HTMLElement implements LovelaceCard {
  private _hass?: HomeAssistant;
  private signature = "";
  private readonly root: HTMLElement;

  constructor() {
    super();
    const shadow = this.attachShadow({ mode: "open" });
    shadow.innerHTML = `<style>${CELLS_CSS}</style><ha-card id="root"></ha-card>`;
    this.root = shadow.getElementById("root")!;
    this.root.addEventListener("click", (event) => {
      const entity = (event.target as Element).closest<HTMLElement>("[data-more]")?.dataset.more;
      if (entity) moreInfo(this, entity);
    });
  }

  setConfig(): void {}

  getCardSize(): number {
    return 1;
  }

  getGridOptions(): { columns: string; rows: string } {
    return { columns: "full", rows: "auto" };
  }

  set hass(hass: HomeAssistant) {
    this._hass = hass;
    const signature = WATCHED.map((id) => `${hass.states[id]?.state}@${hass.states[id]?.last_changed}`).join("|");
    if (signature === this.signature) return;
    this.signature = signature;
    this.root.innerHTML = cells([
      this.regulationCell(hass),
      this.pvStatusCell(hass),
      this.powerCell(hass),
      this.rodCell(hass),
      this.batteryCell(hass),
      this.targetsCell(hass),
    ]);
  }

  private since(hass: HomeAssistant, entityId: string): string {
    const changed = hass.states[entityId]?.last_changed;
    if (!changed) return "";
    const time = new Date(changed);
    const today = time.toDateString() === new Date().toDateString();
    return ` seit ${time.toLocaleString(hass.locale.language, today ? { hour: "2-digit", minute: "2-digit" } : { day: "2-digit", month: "2-digit" })}`;
  }

  private watts(hass: HomeAssistant, watts: number): string {
    return Math.abs(watts) < 1000 ? `${formatNumber(hass, watts, 0)} W` : `${formatNumber(hass, watts / 1000, 1)} kW`;
  }

  private regulationCell(hass: HomeAssistant): Cell {
    const state = hass.states[EMS.state];
    const enabled = hass.states[EMS.enabled]?.state === "on";
    return {
      key: "PV-Überschuss",
      value: state ? hass.formatEntityState(state) : "–",
      sub: enabled ? `Regelung an ·${this.since(hass, EMS.state)}` : "Regelung aus",
      entity: EMS.enabled,
      dot: TONE_COLOR[STATE_TONE[state?.state ?? ""] ?? "idle"],
      alert: state?.state === "no_input",
    };
  }

  private pvStatusCell(hass: HomeAssistant): Cell {
    const status = hass.states[HEAT_PUMP.pvStatus]?.state;
    return {
      key: "Ovum PV-Status",
      value: (status && PV_STATUS[status]) ?? "–",
      sub: `gelesen${this.since(hass, HEAT_PUMP.pvStatus)}`,
      entity: HEAT_PUMP.pvStatus,
    };
  }

  private powerCell(hass: HomeAssistant): Cell {
    const drawn = numeric(hass, HEAT_PUMP.powerInput);
    const target = numeric(hass, EMS.target);
    return {
      key: "WP-Leistung",
      value: drawn === undefined ? "–" : `${formatNumber(hass, drawn, 1)} kW`,
      sub: target ? `Soll ${this.watts(hass, target)}` : "kein Soll",
      entity: EMS.target,
    };
  }

  private rodCell(hass: HomeAssistant): Cell {
    const drawn = numeric(hass, ROD.power) ?? 0;
    const asked = numeric(hass, ROD.pvPower) ?? 0;
    const mode = hass.states[ROD.mode]?.state;
    const sub =
      mode !== "Auto"
        ? `Modus ${mode ?? "–"}, PV ohne Wirkung`
        : hass.states[ROD.demand]?.state === "on"
          ? "Ovum fordert an"
          : asked
            ? `PV-Vorgabe ${formatNumber(hass, asked, 0)} kW`
            : "keine PV-Vorgabe";
    return {
      key: "Heizstab",
      value: drawn > NOISE_W ? this.watts(hass, drawn) : "aus",
      sub,
      entity: ROD.pvPower,
      alert: mode !== "Auto",
      dot: drawn > NOISE_W ? TONE_COLOR.run : undefined,
    };
  }

  private batteryCell(hass: HomeAssistant): Cell {
    const power = numeric(hass, BATTERY.power);
    const imported = -(numeric(hass, GRID.power) ?? 0);
    const value =
      power === undefined
        ? "–"
        : power < -NOISE_W
          ? `lädt ${this.watts(hass, -power)}`
          : power > NOISE_W
            ? `entlädt ${this.watts(hass, power)}`
            : "ruht";
    const grid = imported > NOISE_W ? `Netzbezug ${this.watts(hass, imported)}` : "kein Netzbezug";
    return {
      key: "Akku",
      value,
      sub: `${formatNumber(hass, numeric(hass, BATTERY.soc), 0)} % (Ziel 95 %) · ${grid}`,
      entity: BATTERY.power,
    };
  }

  private targetsCell(hass: HomeAssistant): Cell {
    const hotWater = numeric(hass, TANK.hotWaterTargetActive);
    const hotWaterPv = numeric(hass, TANK.hotWaterTargetPv);
    const buffer = numeric(hass, TANK.bufferTargetActive);
    const bufferPv = numeric(hass, TANK.bufferTargetPv);
    const reached = (active?: number, pv?: number) => active !== undefined && pv !== undefined && active >= pv - 0.5;
    const raised = reached(hotWater, hotWaterPv) || reached(buffer, bufferPv);
    return {
      key: "Soll WW · Puffer",
      value: `${formatNumber(hass, hotWater, 0)}° · ${formatNumber(hass, buffer, 0)}°`,
      sub: raised ? "PV-Sollwerte aktiv" : `bei PV: ${formatNumber(hass, hotWaterPv, 0)}° · ${formatNumber(hass, bufferPv, 0)}°`,
      entity: TANK.hotWaterTargetActive,
      dot: raised ? TONE_COLOR.run : undefined,
    };
  }
}

customElements.define("pv-card", PvCard);
