{ pkgs, ... }: {
  services.xserver = {
    enable = true;
    layout = "us";
    libinput.enable = true;
  };

  services.xbanish.enable = true;

  # environment.systemPackages = with pkgs; [ ssdm-chili ];
}
