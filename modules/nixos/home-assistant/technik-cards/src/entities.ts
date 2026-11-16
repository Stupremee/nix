// Entity IDs of the Ovum heat pump, the WP-Steuerung ESP and the FoxESS inverter.

const E = "sensor.ess_1_";

export const GRID = {
  mode: `${E}grid_mode`,
  /** Negative while importing. */
  power: `${E}meter1_active_power_total`,
  imported: `${E}energy_consumed_total`,
  exported: `${E}feeder_network_energy_total`,
  outageLast: `${E}grid_outage_last`,
  outageMinutes: `${E}grid_outage_duration`,
} as const;

export const BATTERY = {
  soc: `${E}bms1_state_of_charge`,
  /** Negative while charging. */
  power: `${E}battery_power_total`,
  remaining: `${E}battery_time_remaining`,
  toFull: `${E}battery_time_to_full`,
} as const;

export const HOUSE_ENERGY = `${E}load_energy_total`;

export const OUTDOOR = "sensor.ovum_outdoor_temperature";

export const HEAT_PUMP = {
  status: "sensor.ovum_status",
  demand: "sensor.ovum_demand",
  powerInput: "sensor.ovum_electrical_power",
  heatOutput: "sensor.ovum_heat_output",
  cop: "sensor.ovum_cop",
  condenserIn: "sensor.ovum_condenser_inlet",
  condenserOut: "sensor.ovum_condenser_outlet",
  runtime: "sensor.ovum_compressor_runtime",
  pvStatus: "select.ovum_ems_pv_status",
} as const;

export const EMS = {
  enabled: "switch.ovum_pv_surplus",
  state: "sensor.ovum_ems_state",
  /** Watts. */
  target: "number.ovum_ems_target_power",
} as const;

export const TANK = {
  hotWaterTop: "sensor.ovum_hot_water_top",
  hotWaterBottom: "sensor.ovum_hot_water_bottom",
  hotWaterTargetActive: "sensor.ovum_hot_water_active_target",
  bufferTop: "sensor.ovum_buffer_top",
  bufferBottom: "sensor.ovum_buffer_bottom",
  bufferTargetActive: "sensor.ovum_buffer_active_target",
  hotWater: "select.ovum_hot_water",
  hotWaterTarget: "number.ovum_hot_water_target",
  hotWaterTargetPv: "number.ovum_hot_water_target_with_pv",
  bufferTargetPv: "number.ovum_buffer_target_with_pv",
} as const;

export const ROD = {
  power: "sensor.wp_steuerung_heizstab_leistung",
  temperature: "sensor.wp_steuerung_heizstab_temperatur",
  level: "sensor.wp_steuerung_heizstab_leistungsstufe",
  mode: "select.wp_steuerung_heizstab_modus",
  demand: "binary_sensor.wp_steuerung_heizstab_anforderung",
  boost: "button.wp_steuerung_heizstab_boost",
  boostActive: "binary_sensor.wp_steuerung_heizstab_boost_aktiv",
  fault: "binary_sensor.wp_steuerung_heizstab_storung",
  energy: "sensor.wp_steuerung_heizstab_energie",
  /** kW the PV surplus regulation asks for, honoured in mode Auto. */
  pvPower: "number.wp_steuerung_heizstab_pv_leistung",
} as const;

export interface Circuit {
  key: "hk1" | "hk2";
  label: string;
  name: string;
  flow: string;
  flowTarget: string;
  room?: string;
  roomTarget: string;
  mode: string;
  pvRaise: string;
  pvLower: string;
}

export const CIRCUITS: readonly Circuit[] = [
  {
    key: "hk1",
    label: "HK1",
    name: "Löwenzahn",
    flow: "sensor.ovum_heating_circuit_1_flow_temperature",
    flowTarget: "sensor.ovum_heating_circuit_1_flow_target",
    room: "sensor.ovum_heating_circuit_1_room_temperature",
    roomTarget: "number.ovum_heating_circuit_1_room_target",
    mode: "select.ovum_heating_circuit_1_mode",
    pvRaise: "number.ovum_heating_circuit_1_pv_raise",
    pvLower: "number.ovum_heating_circuit_1_pv_reduction",
  },
  {
    key: "hk2",
    label: "HK2",
    name: "Rosenrot",
    flow: "sensor.ovum_heating_circuit_2_flow_temperature",
    flowTarget: "sensor.ovum_heating_circuit_2_flow_target",
    roomTarget: "number.ovum_heating_circuit_2_room_target",
    mode: "select.ovum_heating_circuit_2_mode",
    pvRaise: "number.ovum_heating_circuit_2_pv_raise",
    pvLower: "number.ovum_heating_circuit_2_pv_reduction",
  },
];
