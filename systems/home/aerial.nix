{...}: {
  modules.hyprland = {
    enable = true;

    monitors = {
      "eDP-1" = {
        position = "1920x0";
      };

      "HDMI-A-1" = {
        position = "0x0";
      };
    };
  };
}
