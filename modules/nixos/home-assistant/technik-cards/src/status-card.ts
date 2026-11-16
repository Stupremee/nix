// One compact row of live values that need more than one entity each.

import { type Cell, cells, CELLS_CSS } from "./cells";
import { BATTERY, GRID, HEAT_PUMP, HOUSE_ENERGY } from "./entities";
import { formatNumber, type HomeAssistant, type LovelaceCard, moreInfo, numeric, type StatisticRow } from "./hass";
import { statusLook, TONE_COLOR } from "./status";


const REFRESH_MS = 5 * 60 * 1000;
const DAY_MS = 24 * 3600 * 1000;

interface Totals {
  imported: number | undefined;
  exported: number | undefined;
  house: number | undefined;
  cop24h: number | undefined;
}

class TechnikStatusCard extends HTMLElement implements LovelaceCard {
  private _hass?: HomeAssistant;
  private totals: Totals = { imported: undefined, exported: undefined, house: undefined, cop24h: undefined };
  private timer?: number;
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
    const first = !this._hass;
    this._hass = hass;
    if (first) void this.load();
    const watched = [...Object.values(GRID), BATTERY.soc, BATTERY.remaining, BATTERY.toFull, HEAT_PUMP.status, HEAT_PUMP.cop];
    const signature = watched.map((id) => hass.states[id]?.state).join("|");
    if (signature !== this.signature) {
      this.signature = signature;
      this.render();
    }
  }

  connectedCallback(): void {
    this.timer = window.setInterval(() => void this.load(), REFRESH_MS);
  }

  disconnectedCallback(): void {
    window.clearInterval(this.timer);
  }

  private async today(hass: HomeAssistant, statisticId: string): Promise<number | undefined> {
    const result = await hass.callWS<{ change?: number | null }>({
      type: "recorder/statistic_during_period",
      statistic_id: statisticId,
      calendar: { period: "day" },
      types: ["change"],
    });
    return result.change ?? undefined;
  }

  private async load(): Promise<void> {
    const hass = this._hass;
    if (!hass) return;
    const [imported, exported, house, power] = await Promise.all([
      this.today(hass, GRID.imported),
      this.today(hass, GRID.exported),
      this.today(hass, HOUSE_ENERGY),
      hass.callWS<Record<string, StatisticRow[]>>({
        type: "recorder/statistics_during_period",
        start_time: new Date(Date.now() - DAY_MS).toISOString(),
        statistic_ids: [HEAT_PUMP.heatOutput, HEAT_PUMP.powerInput],
        period: "5minute",
        types: ["mean"],
      }),
    ]);
    // Equal 5 minute slots, so the ratio of summed means is heat over electricity.
    const sum = (id: string) => (power[id] ?? []).reduce((total, row) => total + (row.mean ?? 0), 0);
    const electricity = sum(HEAT_PUMP.powerInput);
    this.totals = { imported, exported, house, cop24h: electricity > 0 ? sum(HEAT_PUMP.heatOutput) / electricity : undefined };
    this.render();
  }

  private relative(time: Date): string {
    const hass = this._hass!;
    const minutes = (time.getTime() - Date.now()) / 60000;
    const format = new Intl.RelativeTimeFormat(hass.locale.language, { numeric: "auto" });
    if (Math.abs(minutes) < 60) return format.format(Math.round(minutes), "minute");
    if (Math.abs(minutes) < 48 * 60) return format.format(Math.round(minutes / 60), "hour");
    return format.format(Math.round(minutes / 1440), "day");
  }

  private gridCell(hass: HomeAssistant): Cell {
    const offGrid = hass.states[GRID.mode]?.state === "off_grid";
    const lastState = hass.states[GRID.outageLast]?.state;
    const last = lastState && !Number.isNaN(Date.parse(lastState)) ? new Date(lastState) : undefined;
    const minutes = numeric(hass, GRID.outageMinutes);
    if (offGrid && last) {
      const since = last.toLocaleTimeString(hass.locale.language, { hour: "2-digit", minute: "2-digit" });
      return { key: "Netzausfall", value: `seit ${since}`, sub: `${formatNumber(hass, minutes, 0)} min, Notbetrieb`, entity: GRID.mode, alert: true };
    }
    const power = numeric(hass, GRID.power);
    const value =
      power === undefined
        ? "–"
        : Math.abs(power) < 50
          ? "ausgeglichen"
          : `${power < 0 ? "Bezug" : "Einspeisung"} ${Math.abs(power) < 1000 ? `${formatNumber(hass, Math.abs(power), 0)} W` : `${formatNumber(hass, Math.abs(power) / 1000, 2)} kW`}`;
    const sub = last ? `Ausfall ${this.relative(last)} · ${formatNumber(hass, minutes, 0)} min` : "kein Ausfall erfasst";
    return { key: "Netz", value, sub, entity: GRID.power };
  }

  private batteryCell(hass: HomeAssistant): Cell {
    const soc = numeric(hass, BATTERY.soc);
    const remaining = numeric(hass, BATTERY.remaining);
    const toFull = numeric(hass, BATTERY.toFull);
    const sub =
      remaining !== undefined
        ? `noch ${formatNumber(hass, remaining, 1)} h`
        : toFull !== undefined
          ? `voll in ${formatNumber(hass, toFull, 1)} h`
          : soc !== undefined && soc >= 99
            ? "voll"
            : "ruht";
    return { key: "Batterie", value: `${formatNumber(hass, soc, 0)} %`, sub, entity: BATTERY.soc };
  }

  private render(): void {
    const hass = this._hass;
    if (!hass) return;
    const { imported, exported, house, cop24h } = this.totals;
    const autarky = imported !== undefined && house ? Math.max(0, Math.min(100, (1 - imported / house) * 100)) : undefined;
    const status = hass.states[HEAT_PUMP.status];
    const look = statusLook(status?.state);
    this.root.innerHTML = cells([
      this.gridCell(hass),
      this.batteryCell(hass),
      { key: "Autarkie heute", value: `${formatNumber(hass, autarky, 0)} %`, sub: `Verbrauch ${formatNumber(hass, house, 1)} kWh`, entity: HOUSE_ENERGY },
      { key: "Heute vom Netz", value: `${formatNumber(hass, imported, 1)} kWh`, sub: `eingespeist ${formatNumber(hass, exported, 1)} kWh`, entity: GRID.imported },
      {
        key: "Wärmepumpe Ø COP 24 h",
        value: formatNumber(hass, cop24h, 2),
        sub: `${status ? hass.formatEntityState(status) : "–"} · jetzt ${formatNumber(hass, numeric(hass, HEAT_PUMP.cop), 2)}`,
        entity: HEAT_PUMP.cop,
        dot: TONE_COLOR[look.tone],
      },
    ]);
  }
}

customElements.define("technik-status-card", TechnikStatusCard);
