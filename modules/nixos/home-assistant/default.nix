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
      reverse_proxy :${toString config.services.esphome.port}
    '';

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
  };
}
