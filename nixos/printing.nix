{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      foomatic-db
    ];
  };

  services.avahi = {
    enable = true;

    openFirewall = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;

    publish.enable = false;
  };

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      sane-airscan
      sane-backends
    ];
  };
}
