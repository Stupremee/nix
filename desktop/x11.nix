{ ... }: {

  services.xserver = {
    enable = true;
    xkbOptions = "caps:swapescape";
    layout = "eu";
    displayManager.lightdm = {
      enable = true;
      greeters.mini.enable = true;
    };
  };
}
