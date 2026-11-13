import "./heizung-card";
import "./status-card";
import "./verdichter-card";

declare global {
  interface Window {
    customCards?: { type: string; name: string; description: string }[];
  }
}

window.customCards = [
  ...(window.customCards ?? []),
  { type: "heizung-card", name: "Heizung", description: "Schema von Heizkreisen, Speicher, Heizstab und Wärmepumpe" },
  { type: "technik-status-card", name: "Technik-Status", description: "Netz, Batterie, Autarkie und Wärmepumpe in einer Zeile" },
  { type: "verdichter-card", name: "Verdichter", description: "Laufzeit, Anteile und Starts des Verdichters" },
];
