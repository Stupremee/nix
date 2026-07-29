{
  lib,
  config,
  pkgsUnstable,
  ...
}:
with lib;
let
  cfg = config.my.unifi;
in
{
  options.my.unifi = {
    enable = mkEnableOption "Enable the Unifi controller software";
  };

  config = mkIf cfg.enable {
    services.unifi = {
      enable = true;
      openFirewall = true;
      unifiPackage = pkgsUnstable.unifi;
    };

    my.persist.directories = [
      {
        directory = "/var/lib/unifi";
        user = "unifi";
        group = "unifi";
      }
    ];

    networking.firewall = {
      allowedTCPPorts = [
        38080
        38443
      ];
    };
  };
}
