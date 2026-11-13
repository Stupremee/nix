{
  lib,
  pkgs,
  pkgsUnstable,
  config,
  flake,
  ...
}:
with lib;
let
  cfg = config.my.home-assistant;

  lldap-ha-auth = pkgs.callPackage ./lldap-ha-auth.nix { };

  hassModule = "services/home-automation/home-assistant.nix";
in
{
  # Module and package from unstable together: 2026.8 moved `http` into UI storage
  # and the unstable module dropped the matching options. Remove once on 26.11.
  disabledModules = [ hassModule ];
  imports = [ "${flake.inputs.nixpkgs-unstable}/nixos/modules/${hassModule}" ];

  options.my.home-assistant = {
    enable = mkEnableOption "Enables home-assistant";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."home.stu-dev.me".extraConfig = ''
      import cloudflare
      reverse_proxy :8123
    '';

    services.caddy.virtualHosts."esp.stu-dev.me".extraConfig = ''
      import cloudflare
      import authelia
      reverse_proxy :${toString config.services.esphome.port}
    '';

    services.caddy.virtualHosts."zigbee.stu-dev.me".extraConfig = ''
      import cloudflare
      import authelia
      reverse_proxy :18080
    '';

    age.secrets = {
      hass-mqtt-password = {
        generator.script = "alnum";
      };
      ovum-modbus-login-code = {
        rekeyFile = ../../../secrets/ovum-modbus-login-code.age;
        owner = "hass";
      };
      sunspec-home-assistant-token.rekeyFile = ../../../secrets/sunspec-home-assistant-token.age;
      zigbee2mqtt-mqtt-password.rekeyFile = ../../../secrets/zigbee2mqtt-mqtt-password.age;
      "zigbee2mqtt-secrets.yaml" = {
        rekeyFile = ../../../secrets/zigbee2mqtt-secrets.yaml.age;
        owner = "zigbee2mqtt";
        group = "zigbee2mqtt";
      };
    };

    services.home-assistant = {
      enable = true;
      package = pkgsUnstable.home-assistant;

      extraPackages =
        python3Packages: with python3Packages; [
          # HACS
          aiogithubapi
          # hcu_integration
          getmac
        ];

      customComponents = [
        (pkgsUnstable.buildHomeAssistantComponent {
          owner = "stu";
          domain = "ovum";
          version = "0.1.0";
          src = ./ovum;
        })
      ];

      extraComponents = [
        # Components required to complete the onboarding
        "analytics"
        "google_translate"
        "met"
        "shopping_list"

        # Recommended for fast zlib compression
        # https://www.home-assistant.io/integrations/isal
        "isal"

        # Custom devices
        "ipp"
        "brother"
        "esphome"

        # Non-device integrations
        "co2signal"
        "soundtouch"
        "mqtt"

        "homeassistant_hardware"
      ];

      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = { };

        homeassistant = {
          name = "Lana-Landhof";
          auth_providers = [
            {
              type = "command_line";
              command = "${lldap-ha-auth}/bin/lldap-ha-auth";
              args = [
                "https://ldap.stu-dev.me"
                "homeassistant_user"
                "homeassistant_admin"
                "homeassistant_local"
              ];
              meta = true;
            }
          ];
        };

        automation = "!include automations.yaml";
        modbus = "!include ${./modbus.yaml}";

        # Ovum heat pump (MIRA controller), see ./ovum
        ovum = {
          host = "192.168.188.96";
          port = 502;
          login_code_file = config.age.secrets.ovum-modbus-login-code.path;
        };
      };
    };

    services.sunspecModbusServer = {
      enable = false;
      host = "0.0.0.0";
      port = 1502;
      unitId = 1;
      baseAddress = 40000;
      pollIntervalSeconds = 5;
      logLevel = "INFO";
      dataSource = "homeAssistant";
      openFirewall = true;

      gridExportSimulation = {
        enable = true;
      };

      homeAssistant = {
        url = "https://home.stu-dev.me";
        tokenFile = config.age.secrets.sunspec-home-assistant-token.path;
        entityIds = {
          active_power_w = {
            entityId = "sensor.ess_1_pv_input_power_total";
          };
          pv_power_w = {
            entityId = "sensor.ess_1_pv_input_power_total";
          };
          total_energy_injected_wh = {
            entityId = "sensor.ess_1_pv_energy_total";
            scale = 1000;
          };
          total_energy_absorbed_wh = {
            entityId = "sensor.ess_1_energy_consumed_total";
            scale = 1000;
          };
          grid_power_w = {
            entityId = "sensor.ess_1_meter1_active_power_total";
            negate = true;
          };
          battery_power_w = {
            entityId = "sensor.ess_1_battery_power_total";
          };
          battery_soc_pct = {
            entityId = "sensor.ess_1_bms1_state_of_charge";
          };
        };
      };
    };

    # Stable on purpose: ESPHome 2026.8 removed the built-in dashboard this service runs.
    services.esphome.enable = true;

    services.zigbee2mqtt = {
      enable = true;
      package = pkgsUnstable.zigbee2mqtt_2;
      dataDir =
        if config.my.persist.enable then "/persist/var/lib/zigbee2mqtt" else "/var/lib/zigbee2mqtt";

      settings = {
        serial = {
          port = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_660d27acdd49ef11a096c98cff00cc63-if00-port0";
          adapter = "zstack";
        };

        homeassistant.enable = true;

        mqtt = {
          enable = true;
          user = "zigbee2mqtt";
          password = "!${config.age.secrets."zigbee2mqtt-secrets.yaml".path} mqtt_password";
        };

        frontend = {
          enable = true;
          host = "127.0.0.1";
          port = 18080;
        };

        availability.enabled = true;
        advanced = {
          transmit_power = 20;
          log_level = "warning";
        };
      };
    };
    systemd.services.zigbee2mqtt.serviceConfig.SystemCallFilter = [
      "@system-service @pkey"
      "~@privileged @resources"
      "@chown"
    ];

    my.persist.directories = [
      {
        directory = "/var/lib/hass";
        user = "hass";
        group = "hass";
      }
      {
        directory = "/var/lib/esphome";
        user = "esphome";
        group = "esphome";
      }
    ];

    my.mqtt = {
      enable = true;

      users = {
        hass = {
          acl = [ "readwrite #" ];
          passwordFile = config.age.secrets.hass-mqtt-password.path;
        };
        zigbee2mqtt = {
          acl = [ "readwrite #" ];
          passwordFile = config.age.secrets.zigbee2mqtt-mqtt-password.path;
        };
      };
    };
  };
}
