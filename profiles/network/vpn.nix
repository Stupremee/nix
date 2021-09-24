{ config, pkgs, ... }: {
  # Enable tailscale VPN
  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale.enable = true;
}
