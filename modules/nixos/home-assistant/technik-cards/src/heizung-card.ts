// Schematic of the heating system: circuits, buffer tank, heating rod and heat pump.

import { CIRCUITS, type Circuit, HEAT_PUMP, OUTDOOR, ROD, TANK } from "./entities";
import {
  escape,
  formatDuration,
  formatNumber,
  type HistoryRows,
  type HomeAssistant,
  type LovelaceCard,
  moreInfo,
  numeric,
} from "./hass";
import { SHEET_CSS, Sheet, type SheetContent } from "./sheet";
import { DEFROST_STATES, iconSvg, statusLook, TONE_COLOR } from "./status";

const NARROW_BELOW = 620;
const LONG_PRESS_MS = 500;
const DEFROST_REFRESH_MS = 10 * 60 * 1000;
// Rod power stages are relay bitmasks: 1 = 3 kW, 3 = 6 kW, 7 = 9 kW.
const ROD_STAGES = [1, 3, 7] as const;

const WATCHED = [
  OUTDOOR,
  ...Object.values(HEAT_PUMP),
  ...Object.values(TANK),
  ...Object.values(ROD),
  ...CIRCUITS.flatMap((c) => [c.flow, c.flowTarget, c.room, c.roomTarget, c.mode]),
].filter((id): id is string => id !== undefined);

interface DefrostStats {
  count: number;
  hours: number;
  last: Date | undefined;
}

const CSS = `
  :host { display: block; height: 100%; --line: color-mix(in srgb, var(--primary-text-color) 22%, transparent);
    --card-bg: var(--ha-card-background, var(--card-background-color, #1c1c1c));
    --hot: var(--warning-color, #ffa600); --ww: var(--error-color, #db4437); --cold: var(--info-color, #039be5); }
  ha-card { padding: 16px; overflow: hidden; height: 100%; box-sizing: border-box; display: flex; flex-direction: column; }
  #root { flex: 1; min-height: 0; display: flex; flex-direction: column; }
  #root > svg { flex: 1; min-height: 0; }
  #root > .stack { flex: 1; min-height: 0; overflow: auto; }
  .bar { display: flex; flex-wrap: wrap; align-items: baseline; gap: 4px 18px; font-size: 12px; color: var(--secondary-text-color); margin: 0 2px 10px; }
  .bar b { color: var(--primary-text-color); font-size: 15px; margin-right: auto; }
  .bar strong { color: var(--primary-text-color); font-variant-numeric: tabular-nums; }
  .bar .alert { font-weight: 600; }
  svg { display: block; width: 100%; height: auto; font-family: inherit; user-select: none; }
  .bar { flex: none; }
  .t { fill: var(--primary-text-color); } .m { fill: var(--secondary-text-color); }
  .num { font-variant-numeric: tabular-nums; font-weight: 600; }
  [data-sheet] { cursor: pointer; }
  [data-sheet]:hover .outline { stroke: var(--primary-color); }
  .stack { display: grid; gap: 8px; }
  .row { display: flex; align-items: center; gap: 10px; padding: 10px 2px; border-bottom: 1px solid var(--divider-color); cursor: pointer; }
  .row svg { width: 34px; flex: none; }
  .lbl { font-size: 13px; font-weight: 600; } .sub { font-size: 11px; color: var(--secondary-text-color); }
  .grow { flex: 1; min-width: 0; } .right { text-align: right; } .big { font-size: 22px; font-weight: 600; font-variant-numeric: tabular-nums; }
  .meter { height: 6px; border-radius: 3px; background: var(--line); margin-top: 6px; } .meter i { display: block; height: 100%; border-radius: 3px; }
  .tank { display: grid; grid-template-columns: 1fr 1fr; border-radius: 14px; overflow: hidden; cursor: pointer; }
  .tank div { padding: 9px 10px; }
  .hks { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; }
  .hk { border: 1px solid var(--divider-color); border-radius: 12px; padding: 9px 8px; cursor: pointer; }
  .hk.off { opacity: .45; border-style: dashed; cursor: default; }
  ${SHEET_CSS}
`;

class HeizungCard extends HTMLElement implements LovelaceCard {
  private _hass?: HomeAssistant;
  private signature = "";
  private narrow = false;
  private defrost?: DefrostStats;
  private defrostTimer?: number;
  private pressTimer?: number;
  private longPressed = false;
  private readonly root: HTMLElement;
  private readonly sheet: Sheet;

  constructor() {
    super();
    const shadow = this.attachShadow({ mode: "open" });
    shadow.innerHTML = `<style>${CSS}</style><ha-card><div id="root"></div></ha-card><dialog></dialog>`;
    this.root = shadow.getElementById("root")!;
    this.sheet = new Sheet(shadow.querySelector("dialog")!, this);
    new ResizeObserver(([entry]) => {
      const narrow = (entry?.contentRect.width ?? 0) < NARROW_BELOW;
      if (narrow !== this.narrow) {
        this.narrow = narrow;
        this.render();
      }
    }).observe(this);
    this.root.addEventListener("pointerdown", (event) => this.onPointerDown(event));
    this.root.addEventListener("pointerup", () => window.clearTimeout(this.pressTimer));
    this.root.addEventListener("pointerleave", () => window.clearTimeout(this.pressTimer));
    this.root.addEventListener("click", (event) => this.onClick(event));
  }

  setConfig(): void {}

  getCardSize(): number {
    return 8;
  }

  getGridOptions(): { columns: string | number; rows: number } {
    // Same height as Helios next to it; the schematic scales to fit.
    return { columns: "full", rows: 9 };
  }

  set hass(hass: HomeAssistant) {
    const statusChanged = this._hass?.states[HEAT_PUMP.status]?.state !== hass.states[HEAT_PUMP.status]?.state;
    this._hass = hass;
    this.sheet.update(hass);
    if (statusChanged) void this.loadDefrosts();
    const signature = WATCHED.map((id) => hass.states[id]?.state).join("|");
    if (signature !== this.signature) {
      this.signature = signature;
      this.render();
    }
  }

  connectedCallback(): void {
    this.defrostTimer = window.setInterval(() => void this.loadDefrosts(), DEFROST_REFRESH_MS);
  }

  disconnectedCallback(): void {
    window.clearInterval(this.defrostTimer);
  }

  private async loadDefrosts(): Promise<void> {
    const hass = this._hass;
    if (!hass) return;
    const end = new Date();
    const start = new Date(end.getTime() - 24 * 3600 * 1000);
    const rows = await hass.callWS<HistoryRows>({
      type: "history/history_during_period",
      start_time: start.toISOString(),
      end_time: end.toISOString(),
      entity_ids: [HEAT_PUMP.status],
      minimal_response: true,
      no_attributes: true,
    });
    const states = rows[HEAT_PUMP.status] ?? [];
    let count = 0;
    let seconds = 0;
    let last: Date | undefined;
    states.forEach((row, index) => {
      if (!DEFROST_STATES.has(row.s)) return;
      const begin = Math.max(row.lu, start.getTime() / 1000);
      const until = states[index + 1]?.lu ?? end.getTime() / 1000;
      if (index > 0 || row.lu * 1000 > start.getTime()) count += 1;
      seconds += until - begin;
      last = new Date(row.lu * 1000);
    });
    this.defrost = { count, hours: seconds / 3600, last };
    this.render();
  }

  private onPointerDown(event: PointerEvent): void {
    const more = (event.target as Element).closest<HTMLElement>("[data-more]")?.dataset.more;
    this.longPressed = false;
    if (!more) return;
    this.pressTimer = window.setTimeout(() => {
      this.longPressed = true;
      moreInfo(this, more);
    }, LONG_PRESS_MS);
  }

  private onClick(event: Event): void {
    if (this.longPressed || !this._hass) return;
    const key = (event.target as Element).closest<HTMLElement>("[data-sheet]")?.dataset.sheet;
    const content = key ? this.sheetFor(key) : undefined;
    if (content) this.sheet.open(content, this._hass);
  }

  private fmt(entity: string, digits = 1): string {
    return this._hass ? formatNumber(this._hass, numeric(this._hass, entity), digits) : "–";
  }

  private label(entity: string): string {
    const state = this._hass?.states[entity];
    return state && this._hass ? this._hass.formatEntityState(state) : "–";
  }

  private sheetFor(key: string): SheetContent | undefined {
    const circuit = CIRCUITS.find((c) => c.key === key);
    if (circuit) return this.circuitSheet(circuit);
    switch (key) {
      case "tank":
        return {
          title: "Powerlink 3",
          subtitle: "Warmwasser und Puffer",
          controls: () => [
            { kind: "segments", entity: TANK.hotWater, label: "Warmwasser" },
            { kind: "stepper", entity: TANK.hotWaterTarget, label: "WW Soll", step: 1, digits: 0, unit: "°C" },
            { kind: "stepper", entity: TANK.hotWaterTargetPv, label: "WW Soll bei PV", step: 1, digits: 0, unit: "°C" },
            { kind: "stepper", entity: TANK.bufferTargetPv, label: "Puffer Soll bei PV", step: 1, digits: 0, unit: "°C" },
            {
              kind: "facts",
              rows: [
                ["WW oben / unten", `${this.fmt(TANK.hotWaterTop)} / ${this.fmt(TANK.hotWaterBottom)} °C`],
                ["Puffer oben / unten", `${this.fmt(TANK.bufferTop)} / ${this.fmt(TANK.bufferBottom)} °C`],
                ["Puffer Soll aktiv", `${this.fmt(TANK.bufferTargetActive)} °C`],
              ],
            },
          ],
        };
      case "rod":
        return {
          title: "Heizstab",
          subtitle: "HEA THOR 9 kW",
          controls: () => [
            { kind: "segments", entity: ROD.mode, label: "Modus" },
            { kind: "press", entity: ROD.boost, label: "Boost starten" },
            {
              kind: "facts",
              rows: [
                ["Leistung", `${this.fmt(ROD.power, 0)} W`],
                ["Temperatur", `${this.fmt(ROD.temperature)} °C`],
                ["Anforderung", this.label(ROD.demand)],
                ["Zähler", `${this.fmt(ROD.energy)} kWh`],
              ],
            },
            { kind: "history", links: [["Leistung", ROD.power], ["Temperatur", ROD.temperature]] },
          ],
        };
      case "wp":
        return {
          title: "Wärmepumpe",
          subtitle: this.label(HEAT_PUMP.status),
          controls: () => [
            {
              kind: "facts",
              rows: [
                ["Anforderung", `${this.fmt(HEAT_PUMP.demand, 0)} %`],
                ["Strom / Wärme", `${this.fmt(HEAT_PUMP.powerInput, 2)} / ${this.fmt(HEAT_PUMP.heatOutput, 2)} kW`],
                ["COP", this.fmt(HEAT_PUMP.cop, 2)],
                ["Kondensator ein / aus", `${this.fmt(HEAT_PUMP.condenserIn)} / ${this.fmt(HEAT_PUMP.condenserOut)} °C`],
                ["Abtauungen 24 h", this.defrostText()],
                ["Letzte Abtauung", this.lastDefrostText()],
                ["Laufzeit gesamt", `${this.fmt(HEAT_PUMP.runtime, 0)} h`],
              ],
            },
            { kind: "segments", entity: HEAT_PUMP.pvStatus, label: "EMS PV-Status" },
            {
              kind: "history",
              links: [
                ["COP", HEAT_PUMP.cop],
                ["Leistung", HEAT_PUMP.powerInput],
                ["Status", HEAT_PUMP.status],
                ["Kondensator", HEAT_PUMP.condenserOut],
              ],
            },
          ],
        };
    }
    return undefined;
  }

  private circuitSheet(circuit: Circuit): SheetContent {
    return {
      title: circuit.name,
      subtitle: `${circuit.label} · gemischt`,
      controls: () => [
        { kind: "stepper", entity: circuit.roomTarget, label: "Raumsoll", step: 0.5, digits: 1, unit: "°C" },
        { kind: "segments", entity: circuit.mode, label: "Betriebsart" },
        { kind: "stepper", entity: circuit.pvRaise, label: "PV-Anhebung", step: 1, digits: 0, unit: "K" },
        { kind: "stepper", entity: circuit.pvLower, label: "PV-Absenkung", step: 1, digits: 0, unit: "K" },
        {
          kind: "facts",
          rows: [
            ["Vorlauf ist / soll", `${this.fmt(circuit.flow)} / ${this.fmt(circuit.flowTarget)} °C`],
            ...(circuit.room ? [["Raumtemperatur", `${this.fmt(circuit.room)} °C`] as const] : []),
          ],
        },
        { kind: "history", links: [["Vorlauf", circuit.flow], ...(circuit.room ? [["Raum", circuit.room] as const] : [])] },
      ],
    };
  }

  private defrostText(): string {
    const stats = this.defrost;
    if (!stats || !this._hass) return "–";
    if (!stats.count) return "keine";
    return `${stats.count} · ${formatDuration(stats.hours)}`;
  }

  private lastDefrostText(): string {
    const last = this.defrost?.last;
    if (!last || !this._hass) return "keine in 24 h";
    return last.toLocaleTimeString(this._hass.locale.language, { hour: "2-digit", minute: "2-digit" });
  }

  private rodStage(): number {
    const level = this._hass ? numeric(this._hass, ROD.level) : undefined;
    return level === undefined ? 0 : ROD_STAGES.filter((stage) => level >= stage).length;
  }

  private render(): void {
    const hass = this._hass;
    if (!hass) return;
    const status = hass.states[HEAT_PUMP.status]?.state;
    const look = statusLook(status);
    const tone = TONE_COLOR[look.tone];
    const alert = look.alert
      ? `<span class="alert" style="color:${tone}">${escape(this.label(HEAT_PUMP.status))}</span>`
      : "";
    const bar = `<div class="bar"><b>Heizung</b>${alert}
      <span>Außen <strong>${this.fmt(OUTDOOR)} °C</strong></span>
      <span>Strom <strong>${this.fmt(HEAT_PUMP.powerInput, 2)} kW</strong></span>
      <span>Wärme <strong>${this.fmt(HEAT_PUMP.heatOutput, 2)} kW</strong></span>
      <span>COP <strong>${this.fmt(HEAT_PUMP.cop, 2)}</strong></span></div>`;
    this.root.innerHTML = bar + (this.narrow ? this.renderStack(look, tone) : this.renderSchema(look, tone));
  }

  private circuitBox(circuit: Circuit, x: number): string {
    const mode = this.label(circuit.mode);
    const off = this._hass?.states[circuit.mode]?.state === "off";
    const pump = off ? "var(--line)" : "var(--hot)";
    const room = circuit.room
      ? `<text x="${x + 45}" y="310" text-anchor="middle" class="m" font-size="11">Raum <tspan class="t num">${this.fmt(circuit.room)}°</tspan></text>`
      : "";
    return `<g data-sheet="${circuit.key}" data-more="${circuit.flow}">
      <rect class="outline" x="${x}" y="140" width="90" height="200" rx="10" fill="var(--card-bg)" stroke="var(--divider-color)"/>
      <text x="${x + 45}" y="164" text-anchor="middle" class="t" font-size="13" font-weight="600">${escape(circuit.name)}</text>
      <text x="${x + 45}" y="180" text-anchor="middle" class="m" font-size="11">${circuit.label} · ${escape(mode)}</text>
      <circle cx="${x + 45}" cy="216" r="17" fill="none" stroke="${pump}" stroke-width="2.5"/>
      <path d="M${x + 38} 207 L${x + 55} 216 L${x + 38} 225 Z" fill="${pump}"/>
      <text x="${x + 45}" y="262" text-anchor="middle" class="t num" font-size="19">${this.fmt(circuit.flow)}°</text>
      <text x="${x + 45}" y="278" text-anchor="middle" class="m" font-size="11">Soll ${this.fmt(circuit.flowTarget)}°</text>
      ${room}
      <text x="${x + 45}" y="326" text-anchor="middle" class="m" font-size="11">Ziel ${this.fmt(circuit.roomTarget)}°</text>
    </g>`;
  }

  private renderSchema(look: ReturnType<typeof statusLook>, tone: string): string {
    const defrosting = look.target === "from_buffer";
    const supply = defrosting ? "var(--cold)" : look.running ? "var(--hot)" : "var(--line)";
    const back = look.running ? "var(--cold)" : "var(--line)";
    // The supply pipe meets the tank where the heat pump is charging.
    const supplyY = look.target === "hot_water" ? 112 : 262;
    const wwOutline = look.target === "hot_water" ? `stroke="var(--ww)" stroke-width="2"` : `stroke="none"`;
    const puOutline = look.target === "buffer" ? `stroke="var(--hot)" stroke-width="2"` : `stroke="none"`;
    const stage = this.rodStage();
    const stages = [0, 1, 2]
      .map((i) => `<rect x="${i * 42}" width="38" height="10" rx="3" fill="${i < stage ? "var(--hot)" : "var(--line)"}"/>`)
      .join("");
    const demand = Math.max(0, Math.min(100, this._hass ? (numeric(this._hass, HEAT_PUMP.demand) ?? 0) : 0));
    return `<svg viewBox="0 0 880 450">
      <defs><linearGradient id="tank" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="var(--hot)" stop-opacity=".55"/><stop offset=".48" stop-color="var(--hot)" stop-opacity=".32"/>
        <stop offset="1" stop-color="var(--cold)" stop-opacity=".35"/></linearGradient></defs>
      <g fill="none" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">
        <path d="M380 92 H70 M80 92 V140 M180 92 V140" stroke="var(--hot)"/>
        <path d="M280 92 V140" stroke="var(--line)" stroke-dasharray="2 9"/>
        <path d="M380 398 H70 M100 398 V340 M200 398 V340" stroke="var(--cold)"/>
        <path d="M300 398 V340" stroke="var(--line)" stroke-dasharray="2 9"/>
        <path d="M520 ${supplyY} H545 V60 H740" stroke="${supply}"/>
        <path d="M520 360 H545 V412 H740" stroke="${back}"/>
      </g>
      ${CIRCUITS.map((c, i) => this.circuitBox(c, 40 + i * 100)).join("")}
      <g opacity=".45"><rect x="240" y="140" width="90" height="200" rx="10" fill="none" stroke="var(--divider-color)" stroke-dasharray="4 5"/>
        <text x="285" y="164" text-anchor="middle" class="m" font-size="13" font-weight="600">HK3</text>
        <circle cx="285" cy="216" r="17" fill="none" stroke="var(--line)" stroke-width="2.5"/>
        <text x="285" y="262" text-anchor="middle" class="m" font-size="12">nicht</text>
        <text x="285" y="278" text-anchor="middle" class="m" font-size="12">auslesbar</text></g>
      <g data-sheet="tank" data-more="${TANK.hotWaterTop}">
        <rect class="outline" x="380" y="44" width="140" height="390" rx="62" fill="url(#tank)" stroke="var(--divider-color)" stroke-width="1.5"/>
        <rect x="384" y="70" width="132" height="166" rx="10" fill="none" ${wwOutline}/>
        <rect x="384" y="242" width="132" height="150" rx="10" fill="none" ${puOutline}/>
        <text x="450" y="30" text-anchor="middle" class="t" font-size="13" font-weight="600">Powerlink 3</text>
        <line x1="392" y1="238" x2="508" y2="238" stroke="var(--line)" stroke-dasharray="3 4"/>
        <text x="450" y="104" text-anchor="middle" class="m" font-size="10" letter-spacing=".08em">WARMWASSER</text>
        <text x="450" y="268" text-anchor="middle" class="m" font-size="10" letter-spacing=".08em">PUFFER</text>
        <text x="400" y="138" class="m" font-size="11">oben</text><text x="500" y="138" text-anchor="end" class="t num" font-size="18">${this.fmt(TANK.hotWaterTop)}°</text>
        <text x="400" y="186" class="m" font-size="11">unten</text><text x="500" y="186" text-anchor="end" class="t num" font-size="18">${this.fmt(TANK.hotWaterBottom)}°</text>
        <text x="400" y="216" class="m" font-size="11">Soll ${this.fmt(TANK.hotWaterTargetActive, 0)}° · PV ${this.fmt(TANK.hotWaterTargetPv, 0)}°</text>
        <text x="400" y="302" class="m" font-size="11">oben</text><text x="500" y="302" text-anchor="end" class="t num" font-size="18">${this.fmt(TANK.bufferTop)}°</text>
        <text x="400" y="350" class="m" font-size="11">unten</text><text x="500" y="350" text-anchor="end" class="t num" font-size="18">${this.fmt(TANK.bufferBottom)}°</text>
        <text x="400" y="380" class="m" font-size="11">Soll ${this.fmt(TANK.bufferTargetActive)}° · PV ${this.fmt(TANK.bufferTargetPv, 0)}°</text>
      </g>
      <g data-sheet="rod" data-more="${ROD.power}">
        <path d="M520 290 H560" stroke="var(--primary-text-color)" stroke-opacity=".35" stroke-width="8" stroke-linecap="round"/>
        <rect class="outline" x="560" y="214" width="150" height="152" rx="10" fill="var(--card-bg)" stroke="var(--divider-color)"/>
        <text x="572" y="236" class="t" font-size="13" font-weight="600">Heizstab</text>
        <text x="698" y="236" text-anchor="end" class="m" font-size="11">${escape(this.label(ROD.mode))}</text>
        <g transform="translate(572 250)">${stages}</g>
        <text x="572" y="278" class="m" font-size="10">3 · 6 · 9 kW</text>
        <text x="572" y="310" class="t num" font-size="19">${this.fmt(ROD.power, 0)} W</text>
        <text x="698" y="310" text-anchor="end" class="t num" font-size="19">${this.fmt(ROD.temperature)}°</text>
        <text x="572" y="336" class="m" font-size="11">Anforderung ${escape(this.label(ROD.demand).toLowerCase())}</text>
        <text x="572" y="352" class="m" font-size="11">Zähler ${this.fmt(ROD.energy)} kWh</text>
      </g>
      <g data-sheet="wp" data-more="${HEAT_PUMP.status}">
        <rect class="outline" x="740" y="40" width="130" height="398" rx="12" fill="var(--card-bg)"
          stroke="${look.alert ? tone : "var(--divider-color)"}" stroke-width="${look.alert ? 2 : 1}"/>
        <text x="752" y="62" class="t" font-size="13" font-weight="600">Wärmepumpe</text>
        <g transform="translate(805 110) scale(1.7)">${iconSvg(look.icon, tone)}</g>
        <text x="805" y="168" text-anchor="middle" class="t" font-size="13" font-weight="600">${escape(this.label(HEAT_PUMP.status))}</text>
        <text x="805" y="184" text-anchor="middle" class="m" font-size="11">${escape(look.hint)}</text>
        <text x="752" y="210" class="m" font-size="11">Anforderung</text>
        <text x="858" y="210" text-anchor="end" class="t num" font-size="12">${this.fmt(HEAT_PUMP.demand, 0)} %</text>
        <rect x="752" y="216" width="106" height="6" rx="3" fill="var(--line)"/>
        <rect x="752" y="216" width="${(106 * demand) / 100}" height="6" rx="3" fill="${tone}"/>
        <text x="805" y="258" text-anchor="middle" class="t num" font-size="30">${look.target === "from_buffer" ? "–" : this.fmt(HEAT_PUMP.cop, 2)}</text>
        <text x="805" y="274" text-anchor="middle" class="m" font-size="11">COP</text>
        <g font-size="11">
          <text x="752" y="298" class="m">Strom</text><text x="858" y="298" text-anchor="end" class="t num">${this.fmt(HEAT_PUMP.powerInput, 2)} kW</text>
          <text x="752" y="314" class="m">Wärme</text><text x="858" y="314" text-anchor="end" class="t num">${this.fmt(HEAT_PUMP.heatOutput, 2)} kW</text>
          <text x="752" y="338" class="m" font-size="10" letter-spacing=".06em">KONDENSATOR</text>
          <text x="752" y="354" class="m">Eintritt</text><text x="858" y="354" text-anchor="end" class="t num">${this.fmt(HEAT_PUMP.condenserIn)}°</text>
          <text x="752" y="370" class="m">Austritt</text><text x="858" y="370" text-anchor="end" class="t num">${this.fmt(HEAT_PUMP.condenserOut)}°</text>
          <text x="752" y="394" class="m">Abtauungen 24 h</text>
          <text x="858" y="410" text-anchor="end" class="t num">${escape(this.defrostText())}</text>
          <text x="752" y="428" class="m">Laufzeit</text><text x="858" y="428" text-anchor="end" class="t num">${this.fmt(HEAT_PUMP.runtime, 0)} h</text>
        </g>
      </g>
    </svg>`;
  }

  private renderStack(look: ReturnType<typeof statusLook>, tone: string): string {
    const demand = this._hass ? (numeric(this._hass, HEAT_PUMP.demand) ?? 0) : 0;
    const hk = CIRCUITS.map(
      (c) => `<div class="hk" data-sheet="${c.key}" data-more="${c.flow}"><div class="lbl">${escape(c.name)}</div>
        <div class="sub">${c.label} · ${escape(this.label(c.mode))}</div>
        <div class="big" style="margin-top:6px">${this.fmt(c.flow)}°</div>
        <div class="sub">${c.room ? `Raum ${this.fmt(c.room)}°` : `Ziel ${this.fmt(c.roomTarget)}°`}</div></div>`,
    ).join("");
    const ww = "color-mix(in srgb, var(--hot) 38%, transparent)";
    return `<div class="stack">
      <div class="row" data-sheet="wp" data-more="${HEAT_PUMP.status}">
        <svg viewBox="-20 -20 40 40">${iconSvg(look.icon, tone)}</svg>
        <div class="grow"><div class="lbl">Wärmepumpe · ${escape(this.label(HEAT_PUMP.status))}</div>
          <div class="sub">Kond. ${this.fmt(HEAT_PUMP.condenserIn)} / ${this.fmt(HEAT_PUMP.condenserOut)}° · Abtauungen ${escape(this.defrostText())}</div>
          <div class="meter"><i style="width:${Math.max(0, Math.min(100, demand))}%; background:${tone}"></i></div></div>
        <div class="right"><div class="big">${this.fmt(HEAT_PUMP.cop, 2)}</div><div class="sub">COP</div></div>
      </div>
      <div class="row" data-sheet="rod" data-more="${ROD.power}">
        <div class="grow"><div class="lbl">Heizstab</div><div class="sub">${escape(this.label(ROD.mode))} · Anforderung ${escape(this.label(ROD.demand).toLowerCase())}</div></div>
        <div class="right"><div class="lbl">${this.fmt(ROD.power, 0)} W</div><div class="sub">${this.fmt(ROD.temperature)} °C</div></div>
      </div>
      <div class="tank" data-sheet="tank" data-more="${TANK.hotWaterTop}">
        <div style="background:${ww}"><div class="sub">WW oben</div><div class="big">${this.fmt(TANK.hotWaterTop)}°</div></div>
        <div style="background:${ww}"><div class="sub">WW unten</div><div class="big">${this.fmt(TANK.hotWaterBottom)}°</div></div>
        <div style="background:color-mix(in srgb, var(--hot) 18%, transparent)"><div class="sub">Puffer oben</div><div class="big">${this.fmt(TANK.bufferTop)}°</div></div>
        <div style="background:color-mix(in srgb, var(--cold) 22%, transparent)"><div class="sub">Puffer unten</div><div class="big">${this.fmt(TANK.bufferBottom)}°</div></div>
      </div>
      <div class="hks">${hk}<div class="hk off"><div class="lbl">HK3</div><div class="sub">nicht auslesbar</div></div></div>
    </div>`;
  }
}

customElements.define("heizung-card", HeizungCard);
