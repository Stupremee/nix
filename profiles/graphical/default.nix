{ pkgs, ... }: {
  services.xserver = {
    enable = true;
    xkbOptions = "caps:swapescape";
    layout = "eu";
    libinput.enable = true;

    displayManager.sddm = {
      enable = true;
      theme = "chili";
    };
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.pulseaudio.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    tmpOnTmpfs = true;
    kernel.sysctl."kernel.sysrq" = 1;
  };

  services.xbanish.enable = true;

  environment.systemPackages = with pkgs; [ ssdm-chili ];
}
