import "./heizung-card";
import "./pv-card";
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
  { type: "pv-card", name: "PV-Überschuss", description: "Was die PV-Überschussregelung entscheidet und ob die Ovum folgt" },
  { type: "technik-status-card", name: "Technik-Status", description: "Netz, Batterie, Autarkie und Wärmepumpe in einer Zeile" },
  { type: "verdichter-card", name: "Verdichter", description: "Laufzeit, Anteile und Starts des Verdichters" },
];
