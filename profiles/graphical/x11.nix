{ pkgs, ... }: {
  services.xserver = {
    enable = true;
    layout = "eu";
    libinput.enable = true;
  };

  services.xbanish.enable = true;

  # environment.systemPackages = with pkgs; [ ssdm-chili ];
}
