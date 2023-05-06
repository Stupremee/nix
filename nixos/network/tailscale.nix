{
  config,
  packages,
  ...
}: {
  # Enable tailscale VPN
  modules.tailscale = {
    enable = true;
    package = packages.tailscale;
  };

  # Trust the tailscale0 interface
  networking.firewall.trustedInterfaces = [config.modules.tailscale.interfaceName];
  networking.firewall.allowedUDPPorts = [config.modules.tailscale.port];
}
