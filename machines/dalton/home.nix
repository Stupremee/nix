{...}: {
  my = {
    alacritty.enable = true;
    zsh.enable = true;

    mako.enable = true;
    hyprland = {
      enable = true;

      sensitivity = "0.0";

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
