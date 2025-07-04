{
  lib,
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
      tmuxp.enable = true;
      keyMode = "vi";
      prefix = "C-a";

      escapeTime = 0;

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

        # Session shortcuts
        bind S command-prompt -p "New Session:" "new-session -A -s '%%'"
        bind K confirm kill-session

        # enable mouse control
        set -g mouse on

        # enable true color support
        set -g default-terminal 'screen-256color'
        set -ga terminal-overrides ',*256col*:Tc'

        # disable esc key timeout
        set -s escape-time 0
      '';
    };
  };
}
