{ pkgs, ... }: {
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.pulseaudio.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    tmpOnTmpfs = true;
    kernel.sysctl."kernel.sysrq" = 1;
  };
}
