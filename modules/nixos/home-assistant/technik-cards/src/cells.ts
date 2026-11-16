// A row of key, value and subline cells, shared by the status rows.

import { escape } from "./hass";

export const CELLS_CSS = `
  :host { display: block; }
  ha-card { display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); overflow: hidden; }
  .cell { padding: 12px 14px; border-right: 1px solid var(--divider-color); cursor: pointer; min-width: 0; }
  .cell:last-child { border-right: 0; }
  .k { font-size: 12px; color: var(--secondary-text-color); }
  .v { font-size: 20px; font-weight: 600; font-variant-numeric: tabular-nums; margin: 2px 0 1px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .s { font-size: 11.5px; color: var(--secondary-text-color); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .alert .v, .alert .k { color: var(--error-color, #db4437); }
`;

export interface Cell {
  key: string;
  value: string;
  sub: string;
  /** Opened in more-info on click. */
  entity: string;
  alert?: boolean | undefined;
  /** Colour of a dot in front of the subline. */
  dot?: string | undefined;
}

export function cells(row: readonly Cell[]): string {
  return row
    .map(
      ({ key, value, sub, entity, alert, dot }) =>
        `<div class="cell${alert ? " alert" : ""}" data-more="${entity}"><div class="k">${escape(key)}</div>
        <div class="v">${escape(value)}</div><div class="s">${dot ? `<span style="color:${dot}">●</span> ` : ""}${escape(sub)}</div></div>`,
    )
    .join("");
}
