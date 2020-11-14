# System independent Nvidia settings.

{ config, pkgs, ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    driSupport32Bit = true;
    extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
  };
}

