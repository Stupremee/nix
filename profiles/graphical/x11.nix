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

  services.xbanish.enable = true;

  environment.systemPackages = with pkgs; [ ssdm-chili ];
}
