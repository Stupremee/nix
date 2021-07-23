{ pkgs, ... }: {
  home.sessionVariables = { TERMINAL = "wezterm"; };

  home.packages = with pkgs; [ wezterm ];

  xdg.configFile."wezterm/wezterm.lua".source = ./config.lua;
}
