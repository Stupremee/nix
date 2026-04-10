{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.sunspecModbusServer;
  positiveIntType = types.addCheck types.int (value: value > 0);
  entityMappingType = types.oneOf [
    types.str
    (types.submodule {
      options = {
        entityId = mkOption {
          type = types.str;
          description = "Home Assistant entity id to poll.";
        };
        scale = mkOption {
          type = types.number;
          default = 1;
          description = "Multiplier applied to the fetched numeric state.";
        };
        negate = mkOption {
          type = types.bool;
          default = false;
          description = "Whether to negate the fetched numeric state after scaling.";
        };
      };
    })
  ];

  jsonFormat = pkgs.formats.json { };

  package =
    pkgs.sunspecModbusServer or (pkgs.callPackage ../../../packages/sunspec-modbus-server { });

  configFile = jsonFormat.generate "sunspec-modbus-server.json" {
    inherit (cfg)
      host
      port
      baseAddress
      pollIntervalSeconds
      logLevel
      dataSource
      dummyValues
      ;
    unitId = cfg.unitId;
    gridExportSimulation = {
      inherit (cfg.gridExportSimulation)
        enable
        activateSocPct
        deactivateSocPct
        gridImportToleranceW
        batteryIdleToleranceW
        pvCoverMarginW
        ;
    };
    homeAssistant = {
      inherit (cfg.homeAssistant)
        url
        tokenFile
        entityIds
        ;
    };
  };
in
{
  options.services.sunspecModbusServer = {
    enable = mkEnableOption "a virtual SunSpec-compatible Modbus TCP server";

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Address to bind the Modbus TCP server to.";
    };

    port = mkOption {
      type = types.port;
      default = 1502;
      description = "TCP port to expose the Modbus server on.";
    };

    unitId = mkOption {
      type = types.ints.between 1 247;
      default = 1;
      description = "Modbus unit id exposed by the virtual SunSpec device.";
    };

    baseAddress = mkOption {
      type = types.ints.between 0 65535;
      default = 40000;
      description = "Raw Modbus holding register address where the SunSpec discovery block starts.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the configured Modbus TCP port in the firewall.";
    };

    pollIntervalSeconds = mkOption {
      type = positiveIntType;
      default = 5;
      description = "How often to poll Home Assistant in `homeAssistant` mode.";
    };

    logLevel = mkOption {
      type = types.enum [
        "DEBUG"
        "INFO"
        "WARNING"
        "ERROR"
        "CRITICAL"
      ];
      default = "INFO";
      description = "Application log level.";
    };

    dataSource = mkOption {
      type = types.enum [
        "homeAssistant"
        "dummy"
      ];
      default = "homeAssistant";
      description = ''
        Source for dynamic SunSpec values.
        `homeAssistant` polls existing Home Assistant entities via the REST API.
        `dummy` serves only the configured `dummyValues`.
      '';
    };

    homeAssistant = {
      url = mkOption {
        type = types.str;
        default = "http://127.0.0.1:8123";
        description = "Base URL of the Home Assistant instance.";
      };

      tokenFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/run/secrets/homeassistant-token";
        description = ''
          Absolute path to a file containing a Home Assistant long-lived access token.
          Required when `dataSource = "homeAssistant"`.
        '';
      };

      entityIds = mkOption {
        type = types.attrsOf entityMappingType;
        default = { };
        example = {
          active_power_w = {
            entityId = "sensor.inverter_power_kw";
            scale = 1000;
          };
          grid_power_w = {
            entityId = "sensor.grid_import_kw";
            scale = 1000;
            negate = true;
          };
          total_energy_injected_wh = "sensor.inverter_energy_total";
          voltage_ln_v = "sensor.grid_voltage";
          frequency_hz = "sensor.grid_frequency";
        };
        description = ''
          Mapping from logical SunSpec values to existing Home Assistant sensor entity ids.
          Each entry can either be a plain entity id string or an attrset with
          `entityId`, `scale`, and optional `negate`. The `scale` is multiplied
          onto the fetched state before it is written into SunSpec registers.
          When `negate = true`, the scaled value is multiplied by `-1`.
          Supported keys include `active_power_w`, `grid_power_w`, `apparent_power_va`,
          `reactive_power_var`, `power_factor_pct`, `current_a`, `voltage_ln_v`,
          `voltage_ll_v`, `frequency_hz`, `total_energy_injected_wh`,
          `total_energy_absorbed_wh`, `total_reactive_energy_injected_varh`,
          `total_reactive_energy_absorbed_varh`, `ambient_temperature_c`,
          `cabinet_temperature_c`, `heat_sink_temperature_c`,
          `transformer_temperature_c`, `switch_temperature_c`, `other_temperature_c`,
          `battery_power_w`, and `battery_soc_pct`.
        '';
      };
    };

    dummyValues = mkOption {
      type = types.attrsOf types.number;
      default = { };
      example = {
        active_power_w = 2500;
        grid_power_w = 1200;
        total_energy_injected_wh = 123456;
        voltage_ln_v = 230.0;
        frequency_hz = 50.0;
        battery_power_w = 1200;
        battery_soc_pct = 63;
      };
      description = ''
        Optional overrides for the built-in dummy values.
        Used directly when `dataSource = "dummy"` and also as startup defaults.
      '';
    };

    gridExportSimulation = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to simulate grid export for a downstream heat pump by
          overriding only the instantaneous grid power registers.
        '';
      };

      activateSocPct = mkOption {
        type = types.number;
        default = 90;
        description = "Battery state-of-charge threshold that activates virtual export.";
      };

      deactivateSocPct = mkOption {
        type = types.number;
        default = 88;
        description = "Battery state-of-charge threshold below which virtual export deactivates.";
      };

      gridImportToleranceW = mkOption {
        type = types.number;
        default = 50;
        description = "Maximum real grid import still treated as effectively zero for simulation.";
      };

      batteryIdleToleranceW = mkOption {
        type = types.number;
        default = 100;
        description = ''
          Maximum absolute battery power still treated as idle.
          Charging below `-batteryIdleToleranceW` is interpreted as virtual export.
        '';
      };

      pvCoverMarginW = mkOption {
        type = types.number;
        default = 100;
        description = "Margin used when deciding whether PV still fully covers the estimated house load.";
      };
    };
  };

  config = mkIf cfg.enable {
    users.groups.sunspec-modbus-server = { };
    users.users.sunspec-modbus-server = {
      isSystemUser = true;
      group = "sunspec-modbus-server";
      description = "SunSpec Modbus server service account";
    };

    systemd.services.sunspec-modbus-server = {
      description = "SunSpec-compatible Modbus TCP server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        User = "sunspec-modbus-server";
        Group = "sunspec-modbus-server";
        ExecStart =
          "${package}/bin/sunspec-modbus-server --config ${configFile}"
          + optionalString (
            cfg.homeAssistant.tokenFile != null
          ) " --home-assistant-token-file=%d/home-assistant-token";
        LoadCredential = optional (
          cfg.homeAssistant.tokenFile != null
        ) "home-assistant-token:${cfg.homeAssistant.tokenFile}";
        Restart = "on-failure";
        RestartSec = "5s";

        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        UMask = "0077";
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";
        SystemCallArchitectures = "native";
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = optional cfg.openFirewall cfg.port;

    assertions = [
      {
        assertion = cfg.pollIntervalSeconds >= 1;
        message = "services.sunspecModbusServer.pollIntervalSeconds must be >= 1";
      }
      {
        assertion = cfg.dataSource != "homeAssistant" || cfg.homeAssistant.tokenFile != null;
        message = "services.sunspecModbusServer.homeAssistant.tokenFile must be set when dataSource = \"homeAssistant\"";
      }
      {
        assertion = cfg.gridExportSimulation.deactivateSocPct <= cfg.gridExportSimulation.activateSocPct;
        message = "services.sunspecModbusServer.gridExportSimulation.deactivateSocPct must be <= activateSocPct";
      }
    ];
  };
}
