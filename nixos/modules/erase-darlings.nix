{ config, lib, ... }:
with lib;
let
  cfg = config.modules.eraseDarlings;
in
{
  options = {
    modules = {
      eraseDarlings = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };

        rootSnapshot = mkOption {
          type = types.str;
          default = "rpool/local/root@blank";
        };

        persistDir = mkOption {
          type = types.path;
          default = "/persist";
        };

        machineId = mkOption {
          type = types.str;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Wipe / on boot
    boot.initrd.postDeviceCommands = mkAfter ''
      zfs rollback -r ${cfg.rootSnapshot}
    '';

    # Set /etc/machine-id, so that journalctl can access logs from
    # previous boots.
    environment.etc.machine-id = {
      text = "${cfg.machineId}\n";
      mode = "0444";
    };

    # Persist state in `cfg.persistDir`
    services.openssh.hostKeys = [
      {
        path = "${toString cfg.persistDir}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "${toString cfg.persistDir}/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];

    systemd.tmpfiles.rules = [
      "L+ /etc/nixos - - - - ${toString cfg.persistDir}/etc/nixos"
    ] ++ (lib.lists.optionals config.services.tailscale.enable [
      "L+ /var/lib/tailscale - - - - ${toString cfg.persistDir}/var/lib/tailscale"
    ]);

    services.paperless.dataDir = "${toString cfg.persistDir}/var/lib/paperless";
  };
}
