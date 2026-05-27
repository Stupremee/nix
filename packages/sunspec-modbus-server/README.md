# SunSpec Modbus Server

This package provides a virtual SunSpec-compatible Modbus TCP server that runs under systemd on NixOS.

## Data sources

The server supports two runtime modes:

- `homeAssistant`: poll existing Home Assistant entities through the REST API using a long-lived access token.
- `dummy`: serve only configured dummy values without any Home Assistant dependency.

It can also simulate virtual grid export for a downstream heat pump by
overriding only the instantaneous grid power while leaving the energy counters
untouched.

## SunSpec layout

The server exposes holding registers starting at raw Modbus address `40000` with this model stack:

- Discovery block (`SunS`)
- Model 1: Common
- Model 103: Inverter
- Model 160: Multiple MPPT Inverter Extension
- Model 203: Meter (three-phase wye / ABCN)
- End marker (`0xFFFF`)

## Home Assistant mapping

In `homeAssistant` mode the service polls Home Assistant state values and maps them to SunSpec measurements. The mapping is explicit and configurable through `services.sunspecModbusServer.homeAssistant.entityIds`.

Supported mapping keys:

- `active_power_w`
- `pv_power_w`
- `grid_power_w`
- `apparent_power_va`
- `reactive_power_var`
- `power_factor_pct`
- `current_a`
- `voltage_ln_v`
- `voltage_ll_v`
- `frequency_hz`
- `total_energy_injected_wh`
- `total_energy_absorbed_wh`
- `total_reactive_energy_injected_varh`
- `total_reactive_energy_absorbed_varh`
- `ambient_temperature_c`
- `cabinet_temperature_c`
- `heat_sink_temperature_c`
- `transformer_temperature_c`
- `switch_temperature_c`
- `other_temperature_c`
- `battery_power_w`
- `battery_soc_pct`

Values without a mapping keep their current or configured dummy/default value.
Each mapping entry can either be a plain entity id string or an object with
`entityId`, `scale`, and optional `negate`. Use `scale: 1000` for sensors that
report kW but need to feed SunSpec watt registers. Set `negate: true` to invert
the value before it is written into SunSpec registers.

`active_power_w` feeds inverter AC power in `103.W`.
`pv_power_w` feeds inverter DC power in `103.DCW` and PV input power in `160.M1_DCW`.
`grid_power_w` feeds instantaneous grid import/export in Model `203.W`, which is the usual place for `Netzbezug`.
`total_energy_absorbed_wh` feeds `203.TotWhImp`, and `total_energy_injected_wh` feeds `203.TotWhExp`.
`battery_power_w` and `battery_soc_pct` are only used by the simulation layer and are not exposed through SunSpec registers.

When `gridExportSimulation.enable = true`, the service computes a virtual
effective `grid_power_w` from these live values only:

- `active_power_w`
- `pv_power_w`
- `grid_power_w`
- `battery_power_w`
- `battery_soc_pct`
- `total_energy_injected_wh`
- `total_energy_absorbed_wh`

Only the instantaneous meter power fields are modified by that heuristic.
The import/export energy counters remain real.
If the battery is actively charging, the reported inverter power is rewritten to the current PV input power.
If the battery is discharging, the reported PV power is forced to `0`.
If the battery state of charge reaches `activateSocPct` (default `99`), the meter model reports
`real_grid_power_w - (2 * pv_power_w)`.
The same simulated amount is also added to the reported PV value.
As soon as the battery starts discharging, that export emulation is disabled again and the real meter power is reported.

## NixOS module usage

Example with Home Assistant polling:

```nix
{
  services.sunspecModbusServer = {
    enable = true;
    host = "0.0.0.0";
    port = 1502;
    unitId = 1;
    openFirewall = true;
    pollIntervalSeconds = 5;
    dataSource = "homeAssistant";

    gridExportSimulation = {
      enable = true;
      activateSocPct = 99;
      deactivateSocPct = 99;
      gridImportToleranceW = 50;
      batteryIdleToleranceW = 100;
      pvCoverMarginW = 100;
    };

    homeAssistant = {
      url = "http://127.0.0.1:8123";
      tokenFile = "/run/secrets/homeassistant-token";
      entityIds = {
        active_power_w = {
          entityId = "sensor.wechselrichter_leistung_kw";
          scale = 1000;
        };
        pv_power_w = {
          entityId = "sensor.pv_input_power_kw";
          scale = 1000;
        };
        grid_power_w = {
          entityId = "sensor.netzbezug_kw";
          scale = 1000;
          negate = true;
        };
        total_energy_injected_wh = "sensor.zaehlerstand_einspeisung_wh";
        total_energy_absorbed_wh = "sensor.zaehlerstand_netzbezug_wh";
        battery_power_w = "sensor.battery_power_w";
        battery_soc_pct = "sensor.battery_soc";
        voltage_ln_v = "sensor.netzspannung_ln";
        voltage_ll_v = "sensor.netzspannung_ll";
        frequency_hz = "sensor.netzfrequenz";
      };
    };
  };
}
```

Raw JSON example with exactly the six values used by the virtual export heuristic:

```json
{
  "host": "0.0.0.0",
  "port": 1502,
  "unitId": 1,
  "baseAddress": 40000,
  "pollIntervalSeconds": 5,
  "logLevel": "INFO",
  "dataSource": "homeAssistant",
  "gridExportSimulation": {
    "enable": true,
    "activateSocPct": 99,
    "deactivateSocPct": 99,
    "gridImportToleranceW": 50,
    "batteryIdleToleranceW": 100,
    "pvCoverMarginW": 100
  },
  "homeAssistant": {
    "url": "https://home.stu-dev.me",
    "tokenFile": "/run/secrets/homeassistant-token",
    "entityIds": {
      "active_power_w": {
        "entityId": "sensor.ess_1_active_power"
      },
      "pv_power_w": {
        "entityId": "sensor.ess_1_pv_input_power_total"
      },
      "total_energy_injected_wh": {
        "entityId": "sensor.ess_1_pv_energy_total",
        "scale": 1000
      },
      "total_energy_absorbed_wh": {
        "entityId": "sensor.ess_1_energy_consumed_total",
        "scale": 1000
      },
      "grid_power_w": {
        "entityId": "sensor.ess_1_meter1_active_power_total",
        "negate": true
      },
      "battery_power_w": {
        "entityId": "sensor.ess_1_battery_power_total"
      },
      "battery_soc_pct": {
        "entityId": "sensor.ess_1_bms1_state_of_charge"
      }
    }
  }
}
```

Example with dummy values:

```nix
{
  services.sunspecModbusServer = {
    enable = true;
    dataSource = "dummy";
    dummyValues = {
      active_power_w = 2500;
      pv_power_w = 3200;
      grid_power_w = 1200;
      total_energy_injected_wh = 123456;
      total_energy_absorbed_wh = 987654;
      battery_power_w = 1200;
      battery_soc_pct = 63;
      voltage_ln_v = 230.0;
      voltage_ll_v = 400.0;
      frequency_hz = 50.0;
    };
  };
}
```

For a quick smoke test outside NixOS module config, you can also start the server directly with:

```sh
sunspec-modbus-server --dummy
```

That flag ignores any config file and starts the server with built-in defaults on `0.0.0.0:1502`.

## Limitations

- The refactored server is read-only.
- Only Model 1, Model 103, Model 160, and Model 203 are implemented.
- Home Assistant polling expects sensor states to be directly parseable as numbers.
- The virtual export simulation uses a fixed `2 * pv_power_w` offset once the battery is full,
  so it remains intentionally approximate.
