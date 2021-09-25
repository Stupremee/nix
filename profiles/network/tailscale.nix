{ config, pkgs, ... }: {
  # Enable tailscale VPN
  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale.enable = true;

  # Trust the tailscale0 interface
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
