{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.term.alacritty = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.term.alacritty.enable {
    my = {
      zsh.env = ''[ "$TERM" = xst-256color ] && export TERM=xterm-256color'';

      packages = with pkgs; [
        unstable.alacritty
      ];

      home.xdg.configFile."alacritty/alacritty.yml".source = <config/alacritty/alacritty.yml>;
    };

  };
}
