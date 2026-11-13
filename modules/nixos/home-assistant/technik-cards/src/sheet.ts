// A modal sheet with setpoint controls. Changes are held while it is open and
// written once on close, and only where they differ from the device: most of
// these are P_* registers on the Ovum, and every write lands in its flash.

import { escape, formatNumber, type HassEntity, type HomeAssistant, moreInfo } from "./hass";

export type Control =
  | { kind: "stepper"; entity: string; label: string; step: number; digits: number; unit: string }
  | { kind: "segments"; entity: string; label: string }
  | { kind: "press"; entity: string; label: string }
  | { kind: "facts"; rows: readonly (readonly [string, string])[] }
  | { kind: "history"; links: readonly (readonly [string, string])[] };

export interface SheetContent {
  title: string;
  subtitle: string;
  controls: (hass: HomeAssistant) => readonly Control[];
}

export const SHEET_CSS = `
  dialog { border: 1px solid var(--divider-color); border-radius: 20px; padding: 18px 18px 20px; width: min(420px, calc(100vw - 32px));
    background: var(--card-bg); color: var(--primary-text-color); box-shadow: 0 16px 48px rgb(0 0 0 / .35); }
  dialog::backdrop { background: rgb(0 0 0 / .45); }
  .sheet-head { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 6px; }
  .sheet-head b { font-size: 17px; }
  .sheet-head span, .ctl-label { font-size: 12px; color: var(--secondary-text-color); }
  .ctl { margin-top: 14px; }
  .stepper { display: flex; align-items: center; justify-content: space-between; margin-top: 4px; }
  .stepper button, .press { width: 46px; height: 46px; border-radius: 50%; border: 1px solid var(--divider-color);
    background: var(--secondary-background-color); color: var(--primary-text-color); font-size: 22px; cursor: pointer; }
  .stepper .value { font-size: 32px; font-weight: 600; font-variant-numeric: tabular-nums; }
  .stepper .value.changed { color: var(--primary-color); }
  .segments { display: grid; grid-auto-flow: column; grid-auto-columns: 1fr; border: 1px solid var(--divider-color); border-radius: 10px; overflow: hidden; margin-top: 4px; }
  .segments button { border: 0; background: none; color: var(--primary-text-color); font: inherit; font-size: 12.5px; padding: 9px 2px; cursor: pointer; }
  .segments button.on { background: var(--primary-color); color: var(--text-primary-color, #fff); font-weight: 600; }
  .press { width: auto; height: auto; border-radius: 10px; font-size: 13px; padding: 9px 14px; margin-top: 4px; }
  .facts { display: grid; grid-template-columns: 1fr auto; row-gap: 6px; font-size: 13px; }
  .facts span:nth-child(odd) { color: var(--secondary-text-color); }
  .facts span:nth-child(even) { font-variant-numeric: tabular-nums; font-weight: 600; }
  .links { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 4px; }
  .links button { border: 1px solid var(--divider-color); background: none; color: var(--primary-text-color); border-radius: 8px; padding: 6px 10px; font: inherit; font-size: 12px; cursor: pointer; }
  .sheet-foot { display: flex; justify-content: space-between; align-items: center; margin-top: 18px; font-size: 12px; color: var(--secondary-text-color); }
  .sheet-foot button { border: 0; background: var(--primary-color); color: var(--text-primary-color, #fff); border-radius: 10px; padding: 9px 18px; font: inherit; font-weight: 600; cursor: pointer; }
`;

export class Sheet {
  private readonly pending = new Map<string, string | number>();
  private content?: SheetContent;
  private hass?: HomeAssistant;

  constructor(
    private readonly dialog: HTMLDialogElement,
    private readonly host: HTMLElement,
  ) {
    dialog.addEventListener("click", (event) => this.onClick(event));
    dialog.addEventListener("close", () => void this.flush());
  }

  open(content: SheetContent, hass: HomeAssistant): void {
    this.content = content;
    this.hass = hass;
    this.pending.clear();
    this.render();
    this.dialog.showModal();
  }

  update(hass: HomeAssistant): void {
    this.hass = hass;
    if (this.dialog.open) this.render();
  }

  private current(entity: string): HassEntity | undefined {
    return this.hass?.states[entity];
  }

  private value(entity: string): string | number | undefined {
    return this.pending.get(entity) ?? this.current(entity)?.state;
  }

  private render(): void {
    const { content, hass } = this;
    if (!content || !hass) return;
    const controls = content.controls(hass).map((control) => this.renderControl(control, hass)).join("");
    const changes = this.pending.size;
    this.dialog.innerHTML = `
      <div class="sheet-head"><b>${escape(content.title)}</b><span>${escape(content.subtitle)}</span></div>
      ${controls}
      <div class="sheet-foot"><span>${changes ? `${changes} Änderung${changes > 1 ? "en" : ""} wird beim Schließen geschrieben` : ""}</span>
        <button data-close>Fertig</button></div>`;
  }

  private renderControl(control: Control, hass: HomeAssistant): string {
    switch (control.kind) {
      case "stepper": {
        const raw = Number(this.value(control.entity));
        const changed = this.pending.has(control.entity);
        return `<div class="ctl"><div class="ctl-label">${escape(control.label)}</div>
          <div class="stepper"><button data-step="${control.entity}" data-delta="-1">−</button>
          <span class="value ${changed ? "changed" : ""}">${Number.isFinite(raw) ? formatNumber(hass, raw, control.digits) : "–"} ${control.unit}</span>
          <button data-step="${control.entity}" data-delta="1">+</button></div></div>`;
      }
      case "segments": {
        const entity = this.current(control.entity);
        const options = entity?.attributes.options ?? [];
        const selected = this.value(control.entity);
        return `<div class="ctl"><div class="ctl-label">${escape(control.label)}</div><div class="segments">${options
          .map(
            (option) =>
              `<button class="${option === selected ? "on" : ""}" data-select="${control.entity}" data-option="${escape(option)}">${escape(
                entity ? hass.formatEntityState(entity, option) : option,
              )}</button>`,
          )
          .join("")}</div></div>`;
      }
      case "press":
        return `<div class="ctl"><button class="press" data-press="${control.entity}">${escape(control.label)}</button></div>`;
      case "facts":
        return `<div class="ctl facts">${control.rows.map(([k, v]) => `<span>${escape(k)}</span><span>${escape(v)}</span>`).join("")}</div>`;
      case "history":
        return `<div class="ctl"><div class="ctl-label">Verlauf</div><div class="links">${control.links
          .map(([label, entity]) => `<button data-more="${entity}">${escape(label)}</button>`)
          .join("")}</div></div>`;
    }
  }

  private onClick(event: Event): void {
    const target = (event.target as HTMLElement).closest<HTMLElement>("button");
    if (event.target === this.dialog) return this.dialog.close();
    if (!target || !this.hass) return;
    const { step, delta, select, option, press, more } = target.dataset;
    if (target.hasAttribute("data-close")) this.dialog.close();
    else if (step && delta) this.step(step, Number(delta));
    else if (select && option !== undefined) this.setPending(select, option);
    else if (press) void this.hass.callService("button", "press", { entity_id: press });
    else if (more) {
      this.dialog.close();
      moreInfo(this.host, more);
    }
  }

  private step(entityId: string, direction: number): void {
    const entity = this.current(entityId);
    const control = this.content?.controls(this.hass!).find((c) => c.kind === "stepper" && c.entity === entityId);
    if (!entity || control?.kind !== "stepper") return;
    const min = entity.attributes.min ?? -Infinity;
    const max = entity.attributes.max ?? Infinity;
    const next = Number(this.value(entityId)) + direction * control.step;
    // Snap to the step so float noise never turns into a second write.
    const snapped = Math.round(Math.min(max, Math.max(min, next)) / control.step) * control.step;
    this.setPending(entityId, Number(snapped.toFixed(2)));
  }

  private setPending(entityId: string, value: string | number): void {
    const current = this.current(entityId)?.state;
    if (current !== undefined && String(value) === String(typeof value === "number" ? Number(current) : current)) {
      this.pending.delete(entityId);
    } else {
      this.pending.set(entityId, value);
    }
    this.render();
  }

  private async flush(): Promise<void> {
    const { hass } = this;
    if (!hass) return;
    const changes = [...this.pending];
    this.pending.clear();
    for (const [entityId, value] of changes) {
      const current = hass.states[entityId]?.state;
      if (current === undefined || String(value) === String(typeof value === "number" ? Number(current) : current)) continue;
      const [domain] = entityId.split(".");
      if (domain === "number") await hass.callService("number", "set_value", { entity_id: entityId, value });
      else if (domain === "select") await hass.callService("select", "select_option", { entity_id: entityId, option: value });
    }
  }
}
