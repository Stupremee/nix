{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  inherit (builtins) readFile;

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
      reverse_proxy :8080
    '';

    age.secrets = {
      hass-mqtt-password = {
        generator.script = "alnum";
      };
      zigbee2mqtt-mqtt-password.rekeyFile = ../../../secrets/zigbee2mqtt-mqtt-password.age;
      "zigbee2mqtt-secrets.yaml" = {
        rekeyFile = ../../../secrets/zigbee2mqtt-secrets.yaml.age;
        owner = "zigbee2mqtt";
        group = "zigbee2mqtt";
      };
    };

    services.home-assistant = {
      enable = true;

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

        http = {
          use_x_forwarded_for = true;
          server_host = "127.0.0.1";
          trusted_proxies = [ "127.0.0.1" ];
        };
      };
    };

    services.esphome = {
      enable = true;
    };

    services.zigbee2mqtt = {
      enable = true;
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
        };
      };
    };

    my.persist.directories = [
      {
        directory = "/var/lib/hass";
        user = "hass";
        group = "hass";
      }
      {
        directory = "/var/lib/private/esphome";
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
