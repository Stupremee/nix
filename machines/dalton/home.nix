{...}: {
  my = {
    alacritty.enable = true;

    hyprland = {
      enable = true;

      monitors = {
        "DP-5" = {
          position = "0x0";
          resolution = "3840x2160@60";
          scale = "1.5";
        };

        "DP-6" = {
          position = "2560x0";
          resolution = "3840x2160@60";
          scale = "1.5";
        };

        "Unknown-1".disable = true;
      };
    };
  };
}
