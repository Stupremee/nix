{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.modules.tmux;
in
{
  options.modules.tmux = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    theme = mkOption {
      type = types.path;
    };
  };

  config =
    let
      theme = import cfg.theme { inherit pkgs; };
    in
    mkIf cfg.enable {
      programs.tmux = {
        enable = true;
        keyMode = "vi";
        prefix = "C-a";
        terminal = "alacritty";
        plugins = theme.tmux.plugins ++ [ ];

        extraConfig = ''
          # Split panes using | and -
          bind | split-window -h
          bind - split-window -v

          unbind '"'
          unbind %

          # Switch panes using Alt+HJKL
          bind -n M-h select-pane -L
          bind -n M-l select-pane -R
          bind -n M-k select-pane -U
          bind -n M-j select-pane -D

          # Enable mouse control
          set -g mouse on
        '';
      };
    };
}
