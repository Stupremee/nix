{
  config,
  theme,
  pkgs,
  ...
}: let
  inherit (pkgs.tmuxPlugins) mkTmuxPlugin;
  inherit (pkgs) fetchFromGitHub;
in {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    prefix = "C-a";
    plugins = [
      {
        plugin = mkTmuxPlugin {
          pluginName = "catppuccin";
          version = "d9e5c6d";
          src = fetchFromGitHub {
            owner = "catppuccin";
            repo = "tmux";
            rev = "d9e5c6d1e3b2c6f6f344f7663691c4c8e7ebeb4c";
            sha256 = "sha256-k0nYjGjiTS0TOnYXoZg7w9UksBMLT+Bq/fJI3f9qqBg=";
          };
        };
        extraConfig = "set -g @catppuccin_flavour '${theme.name}'";
      }
    ];

    escapeTime = 0;

    extraConfig = let
      terminalSpecific =
        if config.programs.rio.enable
        then ''
          set -g default-terminal "rio"
          set-option -ga terminal-overrides ",rio:Tc"
        ''
        else ''
          # enable true color support
          set -g default-terminal 'screen-256color'
          set -ga terminal-overrides ',*256col*:Tc'
        '';
    in ''
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

      ${terminalSpecific}

      # disable esc key timeout
      set -s escape-time 0
    '';
  };
}
