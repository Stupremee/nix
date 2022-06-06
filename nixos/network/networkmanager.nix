{ lib, ... }: {
  networking.networkmanager = {
    enable = true;
    dns = lib.mkForce "none";
    extraConfig = ''
      [main]
      systemd-resolved=false
    '';
  };

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

  #services.resolved = {
    #enable = true;
    #dnssec = "true";
    #extraConfig = ''
      #DNSOverTLS=yes
    #'';
  #};
}
