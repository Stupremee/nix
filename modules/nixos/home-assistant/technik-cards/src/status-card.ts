// One compact row of live values that need more than one entity each.

import { HEAT_PUMP } from "./entities";
import { escape, formatNumber, type HomeAssistant, type LovelaceCard, moreInfo, numeric, type StatisticRow } from "./hass";
import { statusLook, TONE_COLOR } from "./status";

const E = "sensor.ess_1_";
const GRID = {
  mode: `${E}grid_mode`,
  // Negative while importing.
  power: `${E}meter1_active_power_total`,
  imported: `${E}energy_consumed_total`,
  exported: `${E}feeder_network_energy_total`,
  outageLast: `${E}grid_outage_last`,
  outageMinutes: `${E}grid_outage_duration`,
} as const;
const BATTERY = {
  soc: `${E}bms1_state_of_charge`,
  remaining: `${E}battery_time_remaining`,
  toFull: `${E}battery_time_to_full`,
} as const;
const HOUSE_ENERGY = `${E}load_energy_total`;

const REFRESH_MS = 5 * 60 * 1000;
const DAY_MS = 24 * 3600 * 1000;

interface Totals {
  imported: number | undefined;
  exported: number | undefined;
  house: number | undefined;
  cop24h: number | undefined;
}

const CSS = `
  :host { display: block; }
  ha-card { display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); overflow: hidden; }
  .cell { padding: 12px 14px; border-right: 1px solid var(--divider-color); cursor: pointer; min-width: 0; }
  .cell:last-child { border-right: 0; }
  .k { font-size: 12px; color: var(--secondary-text-color); }
  .v { font-size: 20px; font-weight: 600; font-variant-numeric: tabular-nums; margin: 2px 0 1px; white-space: nowrap; }
  .s { font-size: 11.5px; color: var(--secondary-text-color); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .alert .v, .alert .k { color: var(--error-color, #db4437); }
`;

class TechnikStatusCard extends HTMLElement implements LovelaceCard {
  private _hass?: HomeAssistant;
  private totals: Totals = { imported: undefined, exported: undefined, house: undefined, cop24h: undefined };
  private timer?: number;
  private signature = "";
  private readonly root: HTMLElement;

  constructor() {
    super();
    const shadow = this.attachShadow({ mode: "open" });
    shadow.innerHTML = `<style>${CSS}</style><ha-card id="root"></ha-card>`;
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
    const watched = [...Object.values(GRID), ...Object.values(BATTERY), HEAT_PUMP.status, HEAT_PUMP.cop];
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

  private cell(key: string, value: string, sub: string, entity: string, alert = false): string {
    return `<div class="cell${alert ? " alert" : ""}" data-more="${entity}"><div class="k">${escape(key)}</div>
      <div class="v">${escape(value)}</div><div class="s">${escape(sub)}</div></div>`;
  }

  private gridCell(hass: HomeAssistant): string {
    const offGrid = hass.states[GRID.mode]?.state === "off_grid";
    const lastState = hass.states[GRID.outageLast]?.state;
    const last = lastState && !Number.isNaN(Date.parse(lastState)) ? new Date(lastState) : undefined;
    const minutes = numeric(hass, GRID.outageMinutes);
    if (offGrid && last) {
      const since = last.toLocaleTimeString(hass.locale.language, { hour: "2-digit", minute: "2-digit" });
      return this.cell("Netzausfall", `seit ${since}`, `${formatNumber(hass, minutes, 0)} min, Notbetrieb`, GRID.mode, true);
    }
    const power = numeric(hass, GRID.power);
    const value =
      power === undefined
        ? "–"
        : Math.abs(power) < 50
          ? "ausgeglichen"
          : `${power < 0 ? "Bezug" : "Einspeisung"} ${Math.abs(power) < 1000 ? `${formatNumber(hass, Math.abs(power), 0)} W` : `${formatNumber(hass, Math.abs(power) / 1000, 2)} kW`}`;
    const sub = last ? `Ausfall ${this.relative(last)} · ${formatNumber(hass, minutes, 0)} min` : "kein Ausfall erfasst";
    return this.cell("Netz", value, sub, GRID.power);
  }

  private batteryCell(hass: HomeAssistant): string {
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
    return this.cell("Batterie", `${formatNumber(hass, soc, 0)} %`, sub, BATTERY.soc);
  }

  private render(): void {
    const hass = this._hass;
    if (!hass) return;
    const { imported, exported, house, cop24h } = this.totals;
    const autarky = imported !== undefined && house ? Math.max(0, Math.min(100, (1 - imported / house) * 100)) : undefined;
    const status = hass.states[HEAT_PUMP.status];
    const look = statusLook(status?.state);
    this.root.innerHTML = [
      this.gridCell(hass),
      this.batteryCell(hass),
      this.cell("Autarkie heute", `${formatNumber(hass, autarky, 0)} %`, `Verbrauch ${formatNumber(hass, house, 1)} kWh`, HOUSE_ENERGY),
      this.cell("Heute vom Netz", `${formatNumber(hass, imported, 1)} kWh`, `eingespeist ${formatNumber(hass, exported, 1)} kWh`, GRID.imported),
      `<div class="cell" data-more="${HEAT_PUMP.cop}"><div class="k">Wärmepumpe Ø COP 24 h</div>
        <div class="v">${formatNumber(hass, cop24h, 2)}</div>
        <div class="s"><span style="color:${TONE_COLOR[look.tone]}">●</span> ${escape(status ? hass.formatEntityState(status) : "–")} · jetzt ${formatNumber(hass, numeric(hass, HEAT_PUMP.cop), 2)}</div></div>`,
    ].join("");
  }
}

customElements.define("technik-status-card", TechnikStatusCard);
