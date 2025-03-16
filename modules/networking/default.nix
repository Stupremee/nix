{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.networking;
in
{
  options.my.networking = {
    enable = mkEnableOption "Network configuration";

    tailscale = {
      enable = mkEnableOption "Enable tailscale";

      profile = mkOption {
        type = types.enum [
          "none"
          "client"
          "server"
          "both"
        ];
        default = "none";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    networking = {
      # Enable networkmanager
      networkmanager.enable = true;

      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    };

    users.extraUsers.${config.my.user.mainUser}.extraGroups = [ "networkmanager" ];

    services.tailscale = mkIf cfg.tailscale.enable {
      enable = true;
      useRoutingFeatures = cfg.tailscale.profile;

      inherit (cfg.tailscale) openFirewall;
    };

    my.persist.directories = ["/var/lib/tailscale"];

    networking.firewall.trustedInterfaces = optionals cfg.tailscale.openFirewall [
      config.services.tailscale.interfaceName
    ];
  };
}
