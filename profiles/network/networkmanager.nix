{ config, lib, ... }: {
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  networking.wireless.iwd.enable = true;

  # Configure nameservers and search for tailscale magic dns hostnames
  networking.nameservers =
    (if config.services.tailscale.enable then [ "100.100.100.100" ] else [ ]) ++ [ "1.1.1.1" "1.0.0.1" ];
  networking.search =
    if config.services.tailscale.enable then [
      "stupremee.github.beta.tailscale.net"
    ] else [ ];

  services.resolved = {
    enable = true;
    dnssec = "true";
    fallbackDns = config.networking.nameservers;
  };

  environment.persist.directories = [
    "/etc/NetworkManager/system-connections"
  ];
}
