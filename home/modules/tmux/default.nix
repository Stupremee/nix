{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.tmux;
in
{
  options.my.tmux.enable = mkEnableOption "Enable TMUX";

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      prefix = "C-a";

      escapeTime = 0;

      terminal = "screen-256color";

      extraConfig = ''
        # split panes using - and |
        bind | split-window -h
        bind - split-window -v

        unbind '"'
        unbind %

        # switch panes using Alt + hjkl
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # enable mouse control
        set -g mouse on

        # disable esc key timeout
        set -s escape-time 0
      '';
    };
  };
}
