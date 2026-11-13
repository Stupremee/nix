// Compressor runtime: share of time running over rolling windows, per-day bars, starts.

import { HEAT_PUMP } from "./entities";
import {
  escape,
  formatDuration,
  formatNumber,
  type HistoryRows,
  type HomeAssistant,
  type LovelaceCard,
  type StatisticRow,
} from "./hass";
import { RUNNING_STATES } from "./status";

const HOUR = 3600 * 1000;
const DAY = 24 * HOUR;
const REFRESH_MS = 10 * 60 * 1000;
const WINDOWS = [
  ["24 Stunden", 1],
  ["3 Tage", 3],
  ["7 Tage", 7],
  ["30 Tage", 30],
] as const;
const BAR_DAYS = 30;
const START_DAYS = 7;

interface Runtime {
  hourly: readonly StatisticRow[];
  status: readonly { s: string; lu: number }[];
  loadedAt: number;
}

const CSS = `
  :host { display: block; --line: color-mix(in srgb, var(--primary-text-color) 16%, transparent); --run: var(--success-color, #43a047); }
  ha-card { padding: 16px; }
  .head { display: flex; flex-wrap: wrap; align-items: baseline; gap: 4px 16px; margin-bottom: 12px; font-size: 12px; color: var(--secondary-text-color); }
  .head b { color: var(--primary-text-color); font-size: 15px; margin-right: auto; }
  .head strong { color: var(--primary-text-color); font-variant-numeric: tabular-nums; }
  .rows { display: grid; grid-template-columns: 74px 1fr 52px 64px; align-items: center; row-gap: 10px; column-gap: 12px; font-size: 12px; }
  .k { color: var(--secondary-text-color); }
  .track { height: 14px; border-radius: 4px; background: var(--line); overflow: hidden; }
  .track i { display: block; height: 100%; background: var(--run); border-radius: 4px; }
  .pct { font-size: 15px; font-weight: 600; font-variant-numeric: tabular-nums; text-align: right; }
  .hrs { color: var(--secondary-text-color); font-variant-numeric: tabular-nums; text-align: right; }
  .note { font-size: 11px; color: var(--secondary-text-color); margin-top: 8px; }
  .sep { height: 1px; background: var(--divider-color); margin: 16px 0 12px; }
  .chart { display: grid; grid-template-columns: repeat(${BAR_DAYS}, 1fr); gap: 3px; align-items: end; height: 110px; }
  .chart i { display: block; min-height: 1px; background: color-mix(in srgb, var(--run) 72%, transparent); border-radius: 2px 2px 0 0; }
  .chart i:last-child { background: var(--run); }
  .axis { display: flex; justify-content: space-between; font-size: 10.5px; color: var(--secondary-text-color); margin-top: 5px; }
  .meta { display: grid; grid-template-columns: repeat(auto-fit, minmax(110px, 1fr)); gap: 10px; margin-top: 14px; font-size: 11px; color: var(--secondary-text-color); }
  .meta strong { display: block; color: var(--primary-text-color); font-size: 16px; font-weight: 600; font-variant-numeric: tabular-nums; }
`;

function startOfDay(time: number): number {
  const date = new Date(time);
  date.setHours(0, 0, 0, 0);
  return date.getTime();
}

class VerdichterCard extends HTMLElement implements LovelaceCard {
  private _hass?: HomeAssistant;
  private data?: Runtime;
  private timer?: number;
  private readonly root: HTMLElement;

  constructor() {
    super();
    const shadow = this.attachShadow({ mode: "open" });
    shadow.innerHTML = `<style>${CSS}</style><ha-card><div id="root"></div></ha-card>`;
    this.root = shadow.getElementById("root")!;
  }

  setConfig(): void {}

  getCardSize(): number {
    return 6;
  }

  set hass(hass: HomeAssistant) {
    const statusChanged = this._hass?.states[HEAT_PUMP.status]?.state !== hass.states[HEAT_PUMP.status]?.state;
    this._hass = hass;
    if (!this.data || statusChanged) void this.load();
  }

  connectedCallback(): void {
    this.timer = window.setInterval(() => void this.load(), REFRESH_MS);
  }

  disconnectedCallback(): void {
    window.clearInterval(this.timer);
  }

  private async load(): Promise<void> {
    const hass = this._hass;
    if (!hass) return;
    const now = Date.now();
    const [statistics, history] = await Promise.all([
      hass.callWS<Record<string, StatisticRow[]>>({
        type: "recorder/statistics_during_period",
        start_time: new Date(startOfDay(now - (BAR_DAYS - 1) * DAY)).toISOString(),
        statistic_ids: [HEAT_PUMP.runtime],
        period: "hour",
        types: ["change"],
        units: { duration: "h" },
      }),
      hass.callWS<HistoryRows>({
        type: "history/history_during_period",
        start_time: new Date(now - START_DAYS * DAY).toISOString(),
        entity_ids: [HEAT_PUMP.status],
        minimal_response: true,
        no_attributes: true,
      }),
    ]);
    this.data = {
      hourly: statistics[HEAT_PUMP.runtime] ?? [],
      status: history[HEAT_PUMP.status] ?? [],
      loadedAt: now,
    };
    this.render();
  }

  /** Transitions from standing into running, and the stopped stretches between them. */
  private cycles(since: number): { starts: number; longestPause: number } {
    const rows = this.data?.status ?? [];
    let starts = 0;
    let longestPause = 0;
    let stoppedAt: number | undefined;
    rows.forEach((row, index) => {
      const time = row.lu * 1000;
      const running = RUNNING_STATES.has(row.s);
      const wasRunning = index > 0 && RUNNING_STATES.has(rows[index - 1]!.s);
      if (running && !wasRunning && index > 0) {
        if (time >= since) starts += 1;
        if (stoppedAt !== undefined && time >= since) longestPause = Math.max(longestPause, time - Math.max(stoppedAt, since));
      }
      if (!running && (wasRunning || index === 0)) stoppedAt = time;
    });
    const last = rows.at(-1);
    if (last && !RUNNING_STATES.has(last.s) && stoppedAt !== undefined) {
      longestPause = Math.max(longestPause, Date.now() - Math.max(stoppedAt, since));
    }
    return { starts, longestPause: longestPause / HOUR };
  }

  private render(): void {
    const hass = this._hass;
    const data = this.data;
    if (!hass || !data) return;
    const now = data.loadedAt;
    const firstHour = data.hourly[0]?.start;

    const rows = WINDOWS.map(([label, days]) => {
      const from = now - days * DAY;
      const inWindow = data.hourly.filter((row) => row.start >= from);
      const hours = inWindow.reduce((sum, row) => sum + (row.change ?? 0), 0);
      const covered = inWindow.length;
      const share = covered ? Math.min(100, (hours / covered) * 100) : 0;
      return `<span class="k">${label}</span><div class="track"><i style="width:${share}%"></i></div>
        <span class="pct">${covered ? Math.round(share) : "–"} %</span><span class="hrs">${formatNumber(hass, hours, 1)} h</span>`;
    }).join("");

    const days = Array.from({ length: BAR_DAYS }, (_, i) => startOfDay(now - (BAR_DAYS - 1 - i) * DAY));
    const perDay = days.map((day) =>
      data.hourly.filter((row) => row.start >= day && row.start < day + DAY).reduce((sum, row) => sum + (row.change ?? 0), 0),
    );
    const bars = perDay
      .map((hours, i) => `<i style="height:${(hours / 24) * 100}%" title="${new Date(days[i]!).toLocaleDateString(hass.locale.language)}: ${formatNumber(hass, hours, 1)} h"></i>`)
      .join("");

    const status = hass.states[HEAT_PUMP.status];
    const running = status !== undefined && RUNNING_STATES.has(status.state);
    const since = status ? (now - Date.parse(status.last_changed)) / HOUR : undefined;
    const today = this.cycles(startOfDay(now));
    const week = this.cycles(now - START_DAYS * DAY);
    const runtimeWeek = data.hourly.filter((row) => row.start >= now - START_DAYS * DAY).reduce((s, r) => s + (r.change ?? 0), 0);
    const coverage =
      firstHour !== undefined && firstHour > now - 30 * DAY + HOUR
        ? `<div class="note">Daten seit ${escape(new Date(firstHour).toLocaleString(hass.locale.language, { day: "2-digit", month: "2-digit", hour: "2-digit", minute: "2-digit" }))}, Anteile beziehen sich auf die erfasste Zeit.</div>`
        : "";

    this.root.innerHTML = `
      <div class="head"><b>Verdichter</b>
        ${since !== undefined ? `<span>${running ? "läuft" : "steht"} seit <strong>${formatDuration(since)}</strong></span>` : ""}
        <span>gesamt <strong>${formatNumber(hass, Number.parseFloat(hass.states[HEAT_PUMP.runtime]?.state ?? ""), 0)} h</strong></span></div>
      <div class="rows">${rows}</div>${coverage}
      <div class="sep"></div>
      <div class="chart">${bars}</div>
      <div class="axis"><span>vor ${BAR_DAYS} Tagen</span><span>vor 2 Wochen</span><span>heute</span></div>
      <div class="meta">
        <div>Starts heute<strong>${today.starts}</strong></div>
        <div>Ø Laufzeit / Start<strong>${week.starts ? formatDuration(runtimeWeek / week.starts) : "–"}</strong></div>
        <div>Starts 7 Tage<strong>${week.starts}</strong></div>
        <div>längste Pause heute<strong>${today.longestPause ? formatDuration(today.longestPause) : "–"}</strong></div>
      </div>`;
  }
}

customElements.define("verdichter-card", VerdichterCard);
