{ ... }: {
  services.xserver = {
    windowManager.bspwm.enable = true;
    displayManager.defaultSession = "none+bspwm";
    displayManager.lightdm.enable = true;
  };
}
