{...}: {
  modules.hyprland = {
    enable = true;

    sensitivity = "-1.0";

    devices."elan-touchpad" = {
      sensitivity = "-0.2";
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

  programs.git = {
    userName = lib.mkForce "Justus Kliem";
    userEmail = lib.mkForce "justus.kliem@ekd-solar.de";

    signing.key = lib.mkForce "31AC6529";
  };
}
