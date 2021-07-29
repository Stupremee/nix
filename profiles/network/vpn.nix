{ config, pkgs, ... }: {
  # Enable tailscale VPN
  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale.enable = true;

  # Enable OpenVPN and add configurations to it
  age.secrets.tryHackMe.file = ../../secrets/tryHackMe.ovpn;
  services.openvpn.servers = {
    tryHackMeVPN = { config = "config ${config.age.secrets.tryHackMe.path}"; };
  };
}
