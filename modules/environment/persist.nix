{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.environment.persist;
in
{
  options.environment.persist = {
    erase = mkOption {
      type = types.bool;
      default = false;
      description = "Enable erasing of `/` at startup.";
    };

    files = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [
        "/etc/machine-id"
        "/etc/nix/id_rsa"
      ];
      description = ''
        Files in /etc that should be stored in persistent storage.
      '';
    };

    directories = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
      ];
      description = ''
        Directories to bind mount to persistent storage.
      '';
    };
  };

  config = mkIf cfg.erase {
    # Restore old state
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';

    environment.persistence."/persist" = {
      inherit (cfg) directories files;
    };
  };
}
