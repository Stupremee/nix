{
  lib,
  pkgs,
  pkgsUnstable,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home-assistant;

  lldap-ha-auth = pkgs.callPackage ./lldap-ha-auth.nix { };
in
{
  options.my.home-assistant = {
    enable = mkEnableOption "Enables home-assistant";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."home.stu-dev.me".extraConfig = ''
      import cloudflare
      reverse_proxy :${toString config.services.home-assistant.config.http.server_port}
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

      extraPackages =
        python3Packages: with python3Packages; [
          aiogithubapi
        ];

      extraComponents = [
        # Components required to complete the onboarding
        "analytics"
        "google_translate"
        "met"
        "radio_browser"
        "shopping_list"

        # Recommended for fast zlib compression
        # https://www.home-assistant.io/integrations/isal
        "isal"

        # Custom devices
        "apple_tv"
        "ezviz"
        "ipp"
        "brother"
        "esphome"

        # Non-device integrations
        "co2signal"
        "tibber"
        "soundtouch"
        "spotify"
        "forecast_solar"

        "wiz"
        "homeassistant_hardware"
        "tessie"
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

        input_select = {
          hea_thor_power_mode = {
            name = "HEA THOR Power Mode";
            options = [
              "Disabled"
              "3 kW"
              "6 kW"
              "9 kW"
            ];
            initial = "Disabled";
          };
        };

        http = {
          use_x_forwarded_for = true;
          server_host = "127.0.0.1";
          trusted_proxies = [ "127.0.0.1" ];
        };
      };
    };

    services.sunspecModbusServer = {
      enable = true;
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

    services.esphome = {
      enable = true;
      package = pkgsUnstable.esphome;
    };

    systemd.services.esphome = {
      environment = {
        PYTHONPATH = "${pkgsUnstable.esphome}/lib/python3.13/site-packages:${pkgs.python3Packages.makePythonPath pkgs.esphome.dependencies}";
      };
    };

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
