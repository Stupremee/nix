{...}: {
  modules.hyprland = {
    enable = true;

    sensitivity = "-0.5";

    monitors = {
      "DP-2" = {
        position = "0x0";
        resolution = "2560x1440@144";
      };

      "HDMI-A-1" = {
        position = "2560x0";
        resolution = "1920x1080@60";
      };
    };
  };
}
