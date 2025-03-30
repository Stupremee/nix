{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  userOptions =
    with lib.types;
    submodule {
      options = {
        password = mkOption {
          type = uniq (nullOr str);
          default = null;
          description = ''
            Specifies the (clear text) password for the MQTT User.
          '';
        };

        passwordFile = mkOption {
          type = uniq (nullOr path);
          example = "/path/to/file";
          default = null;
          description = ''
            Specifies the path to a file containing the
            clear text password for the MQTT user.
            The file is securely passed to mosquitto by
            leveraging systemd credentials. No special
            permissions need to be set on this file.
          '';
        };

        hashedPassword = mkOption {
          type = uniq (nullOr str);
          default = null;
          description = ''
            Specifies the hashed password for the MQTT User.
            To generate hashed password install the `mosquitto`
            package and use `mosquitto_passwd`, then extract
            the second field (after the `:`) from the generated
            file.
          '';
        };

        hashedPasswordFile = mkOption {
          type = uniq (nullOr path);
          example = "/path/to/file";
          default = null;
          description = ''
            Specifies the path to a file containing the
            hashed password for the MQTT user.
            To generate hashed password install the `mosquitto`
            package and use `mosquitto_passwd`, then remove the
            `username:` prefix from the generated file.
            The file is securely passed to mosquitto by
            leveraging systemd credentials. No special
            permissions need to be set on this file.
          '';
        };

        acl = mkOption {
          type = listOf str;
          example = [
            "read A/B"
            "readwrite A/#"
          ];
          default = [ ];
          description = ''
            Control client access to topics on the broker.
          '';
        };
      };
    };

  cfg = config.my.mqtt;
in
{
  options.my.mqtt = {
    enable = mkEnableOption "Enable Mosquitto MQTT Broker";

    users = mkOption {
      type = types.attrsOf userOptions;
      example = {
        john = {
          password = "123456";
          acl = [ "readwrite john/#" ];
        };
      };
      description = ''
        A set of users and their passwords and ACLs.
      '';
      default = { };
    };

  };

  config = mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      dataDir = if config.my.persist.enable then "/persist/var/lib/mosquitto" else "/var/lib/mosquitto";

      listeners = [
        {
          address = "127.0.0.1";
          port = 1883;

          inherit (cfg) users;
        }
      ];
    };
  };
}
