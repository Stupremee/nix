{ config, pkgs, ... }: {
  # Enable tailscale VPN
  services.tailscale.enable = true;

  # Trust the tailscale0 interface
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
}
