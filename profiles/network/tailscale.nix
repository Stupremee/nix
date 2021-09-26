{ config, pkgs, ... }: {
  age.secrets.tailscaleKey.file = ../../secrets/tailscale.key;

  # Enable tailscale VPN
  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale.enable = true;

  # Trust the tailscale0 interface
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

  # Persist tailscale configuration
  environment.persist.directories = [
    "/var/lib/tailscale"
  ];

  # Create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";

    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up --authkey `cat ${config.age.secrets.tailscaleKey.path}`
    '';
  };
}
