{ config, pkgs, ... }: {
  age.secrets.tailscaleKey.file = ../../secrets/tailscale.key;

  # Enable tailscale VPN
  my.services.tailscale = {
    enable = true;

    autoprovision.enable = true;
    autoprovision.keyFile = config.age.secrets.tailscaleKey.path;
  };

  # Trust the tailscale0 interface
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

  # Persist tailscale configuration
  environment.persist.directories = [
    "/var/lib/tailscale"
  ];
}
