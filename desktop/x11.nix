{ ... }: {
  services.xserver = {
    enable = true;
    xrandrHeads = [
      {
        output = "DP-3";
        monitorConfig = ''Option "LeftOf" "HDMI-0" '';
      }
      {
        output = "HDMI-0";
        primary = true;
      }
    ];

    xkbOptions = "caps:swapescape";
    layout = "eu";
  };
}
