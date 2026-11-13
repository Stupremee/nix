// How each heat pump status looks, keyed by the Ovum status sensor's options.

export type Tone = "run" | "cold" | "warn" | "idle" | "fault";
export type Icon = "fan" | "flake" | "lock" | "warn" | "plug" | "cycle";
/** Where the heat pump moves heat: into the buffer, into hot water, or back out of the buffer. */
export type Target = "buffer" | "hot_water" | "from_buffer";

export interface StatusLook {
  tone: Tone;
  icon: Icon;
  hint: string;
  target?: Target;
  alert?: boolean;
  running?: boolean;
}

const LOOKS = {
  heating: { tone: "run", icon: "fan", hint: "Verdichter läuft", target: "buffer", running: true },
  hot_water: { tone: "run", icon: "fan", hint: "Verdichter läuft", target: "hot_water", running: true },
  cooling: { tone: "cold", icon: "fan", hint: "Verdichter läuft", running: true },
  defrosting: { tone: "cold", icon: "flake", hint: "Wärme aus dem Puffer", target: "from_buffer", alert: true, running: true },
  manual_deicing: { tone: "cold", icon: "flake", hint: "am Gerät ausgelöst", target: "from_buffer", alert: true, running: true },
  ready: { tone: "idle", icon: "fan", hint: "keine Anforderung" },
  starting: { tone: "warn", icon: "fan", hint: "Verdichter fährt hoch", target: "buffer", running: true },
  stopping: { tone: "warn", icon: "fan", hint: "Verdichter fährt herunter", running: true },
  oil_preheating: { tone: "warn", icon: "fan", hint: "Verdichter wird vorgewärmt" },
  blocked: { tone: "idle", icon: "lock", hint: "Netzbetreiber-Sperre" },
  below_operating_limit: { tone: "warn", icon: "warn", hint: "Außentemperatur zu niedrig", alert: true },
  inverter_reset: { tone: "warn", icon: "cycle", hint: "Inverter startet neu", alert: true },
  inverter_offline: { tone: "fault", icon: "plug", hint: "keine Verbindung zum Inverter", alert: true },
  fault: { tone: "fault", icon: "warn", hint: "Fehlercode am Display ablesen", alert: true },
} as const satisfies Record<string, StatusLook>;

const UNKNOWN: StatusLook = { tone: "idle", icon: "fan", hint: "kein Status" };

export function statusLook(state: string | undefined): StatusLook {
  return state !== undefined && state in LOOKS ? LOOKS[state as keyof typeof LOOKS] : UNKNOWN;
}

export const DEFROST_STATES: ReadonlySet<string> = new Set(["defrosting", "manual_deicing"]);
export const RUNNING_STATES: ReadonlySet<string> = new Set(
  Object.entries(LOOKS)
    .filter(([, look]) => "running" in look && look.running)
    .map(([state]) => state),
);

export const TONE_COLOR: Record<Tone, string> = {
  run: "var(--success-color, #43a047)",
  cold: "var(--info-color, #039be5)",
  warn: "var(--warning-color, #ffa600)",
  idle: "var(--secondary-text-color)",
  fault: "var(--error-color, #db4437)",
};

export function iconSvg(icon: Icon, color: string): string {
  const ring = `<circle r="18" fill="none" stroke="var(--line)" stroke-width="1.5"/>`;
  const shapes: Record<Icon, string> = {
    fan: [0, 120, 240]
      .map((r) => `<path d="M0 -14 C8 -10 6 -2 0 0 C-6 -2 -8 -10 0 -14Z" fill="${color}" transform="rotate(${r})"/>`)
      .join("") + `<circle r="2.5" fill="var(--card-bg)"/>`,
    flake: `<g stroke="${color}" stroke-width="2.2" stroke-linecap="round">${[0, 60, 120]
      .map((r) => `<g transform="rotate(${r})"><path d="M0 -12 V12"/><path d="M-4 -9 L0 -6 L4 -9 M-4 9 L0 6 L4 9"/></g>`)
      .join("")}</g>`,
    lock: `<rect x="-7" y="-2" width="14" height="11" rx="2" fill="${color}"/><path d="M-4.5 -2 V-6 A4.5 4.5 0 0 1 4.5 -6 V-2" fill="none" stroke="${color}" stroke-width="2"/>`,
    warn: `<path d="M0 -11 L11 8 H-11 Z" fill="${color}"/><path d="M0 -4 V2" stroke="var(--card-bg)" stroke-width="2.4" stroke-linecap="round"/><circle cy="5.2" r="1.3" fill="var(--card-bg)"/>`,
    plug: `<path d="M-5 -9 V-3 M5 -9 V-3 M-8 -3 H8 V2 A8 8 0 0 1 -8 2 Z M0 10 V6" stroke="${color}" stroke-width="2.2" fill="none" stroke-linecap="round"/><path d="M-11 11 L11 -11" stroke="${color}" stroke-width="2.2" stroke-linecap="round"/>`,
    cycle: `<path d="M8 -6 A9 9 0 1 0 9 3" fill="none" stroke="${color}" stroke-width="2.4" stroke-linecap="round"/><path d="M9 -12 V-5 H2" fill="none" stroke="${color}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>`,
  };
  return ring + shapes[icon];
}
