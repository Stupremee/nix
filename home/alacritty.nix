{ config, ... }: {
  home.sessionVariables.TERMINAL = "${config.programs.alacritty.package}/bin/alacritty";
  programs.alacritty = {
    enable = true;

    settings = {
      font = {
        size = 9;
        normal.family = "FiraCode Nerd Font";
        bold = {
          family = "monospace";
          style = "Bold";
        };
        italic = {
          family = "monospace";
          style = "Italic";
        };
      };
    };
  };
}
