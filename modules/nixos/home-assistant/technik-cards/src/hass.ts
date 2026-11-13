// The slice of Home Assistant's frontend API these cards use.

export interface HassEntity {
  entity_id: string;
  state: string;
  attributes: Record<string, unknown> & {
    options?: readonly string[];
    min?: number;
    max?: number;
    step?: number;
    unit_of_measurement?: string;
  };
  last_changed: string;
}

export interface HomeAssistant {
  states: Record<string, HassEntity | undefined>;
  locale: { language: string };
  callService(domain: string, service: string, data: Record<string, unknown>): Promise<unknown>;
  callWS<T>(message: Record<string, unknown>): Promise<T>;
  formatEntityState(entity: HassEntity, state?: string): string;
}

export interface LovelaceCard extends HTMLElement {
  hass?: HomeAssistant;
  setConfig(config: Record<string, unknown>): void;
  getCardSize?(): number;
}

/** Compressed rows of `history/history_during_period` with `minimal_response`. */
export type HistoryRows = Record<string, readonly { s: string; lu: number }[]>;

export interface StatisticRow {
  start: number;
  end: number;
  change?: number | null;
}

export function moreInfo(from: HTMLElement, entityId: string): void {
  from.dispatchEvent(new CustomEvent("hass-more-info", { detail: { entityId }, bubbles: true, composed: true }));
}

export function numeric(hass: HomeAssistant, entityId: string): number | undefined {
  const value = Number.parseFloat(hass.states[entityId]?.state ?? "");
  return Number.isFinite(value) ? value : undefined;
}

export function formatNumber(hass: HomeAssistant, value: number | undefined, digits = 1): string {
  if (value === undefined) return "–";
  return value.toLocaleString(hass.locale.language, { minimumFractionDigits: digits, maximumFractionDigits: digits });
}

export function escape(text: string): string {
  return text.replace(/[&<>"']/g, (char) => `&#${char.charCodeAt(0)};`);
}

export function formatDuration(hours: number): string {
  const total = Math.round(hours * 60);
  return `${Math.floor(total / 60)}:${String(total % 60).padStart(2, "0")} h`;
}
