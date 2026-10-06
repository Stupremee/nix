{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.secure-boot;
in
{
  options.my.secure-boot = {
    enable = mkEnableOption "UEFI Secure Boot via lanzaboote with self-provisioned keys";
  };

  # Trust on first use: the first boot runs unsigned, generates keys and stages them on the
  # ESP, then reboots so systemd-boot enrolls them. The firmware must be in Setup Mode (keys
  # cleared) for that. Microsoft keys stay enrolled so Windows and GPU option ROMs still load.
  # Check with `sbctl status` / `bootctl status`.
  config = mkIf cfg.enable {
    boot = {
      loader.systemd-boot.enable = mkForce false;

      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        configurationLimit = mkDefault 10;

        autoGenerateKeys.enable = true;
        autoEnrollKeys = {
          enable = true;
          autoReboot = true;
        };
      };
    };

    environment.systemPackages = [ pkgs.sbctl ];

    my.persist.directories = [ "/var/lib/sbctl" ];
  };
}
