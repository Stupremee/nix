{ config, pkgs, ... }: {
  age.secrets.tailscaleKey.file = ../../secrets/tailscale.key;

  # Enable tailscale VPN
  services.tailscale.enable = true;

  # Trust the tailscale0 interface
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

  # Persist tailscale configuration
  environment.persist.directories = [
    "/var/lib/tailscale"
  ];

  # Auto connect to tailscale network
  systemd.services.tailscale-autoprovision = {
    description = "Automatic connection to Tailscale";

    after = [ "network-pre.target" "tailscaled.service" ];
    wants = [ "network-pre.target" "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";

    script = ''
      sleep 2
      ${pkgs.tailscale}/bin/tailscale down
      ${pkgs.tailscale}/bin/tailscale up --authkey=`cat ${config.age.secrets.tailscaleKey.path}`
    '';
  };
}
