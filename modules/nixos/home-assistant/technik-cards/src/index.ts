import "./heizung-card";
import "./verdichter-card";

declare global {
  interface Window {
    customCards?: { type: string; name: string; description: string }[];
  }
}

window.customCards = [
  ...(window.customCards ?? []),
  { type: "heizung-card", name: "Heizung", description: "Schema von Heizkreisen, Speicher, Heizstab und Wärmepumpe" },
  { type: "verdichter-card", name: "Verdichter", description: "Laufzeit, Anteile und Starts des Verdichters" },
];
