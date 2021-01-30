{ pkgs, ... }: {

  sound.enable = true;
  hardware = {
    opengl.enable = true;
    opengl.driSupport = true;
    pulseaudio.enable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    tmpOnTmpfs = true;
    kernel.sysctl."kernel.sysrq" = 1;
  };
}
