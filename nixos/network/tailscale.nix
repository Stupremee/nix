{
  config,
  unstable-pkgs,
  lib,
  ...
}: {
  # Enable tailscale VPN
  services .tailscale = {
    enable = true;
    package = unstable-pkgs.tailscale;
    useRoutingFeatures = lib.mkDefault "client";
  };

  # Trust the tailscale0 interface
  networking.firewall.trustedInterfaces = [config.services.tailscale.interfaceName];
  networking.firewall.allowedUDPPorts = [config.services.tailscale.port];
}
