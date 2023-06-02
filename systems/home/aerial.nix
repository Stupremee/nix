{...}: {
  modules.hyprland = {
    enable = true;

    sensitivity = "-0.8";

    devices."elan-touchpad" = {
      sensitivity = "1.0";
    };

    devices."at-translated-set-2-keyboard" = {
      kbOptions = "caps:swapescape";
    };

    monitors = {
      "eDP-1" = {
        position = "0x0";
      };

      # "HDMI-A-1" = {
      #   position = "0x0";
      # };
    };
  };
}
