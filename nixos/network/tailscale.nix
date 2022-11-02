{config, ...}: {
  # Enable tailscale VPN
  modules.tailscale.enable = true;

  # Trust the tailscale0 interface
  networking.firewall.trustedInterfaces = [config.modules.tailscale.interfaceName];
  networking.firewall.allowedUDPPorts = [config.modules.tailscale.port];

  # Required for exit node routing to work
  networking.firewall.checkReversePath = "loose";
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };
}
