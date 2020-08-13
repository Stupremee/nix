{ config, options, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./alacritty.nix
  ];

  options.modules.desktop.term = {
    default = mkOption {
      type = types.str;
      default = "alacritty";
    };
  };

  config = {
    services.xserver.desktopManager.xterm.enable = false;
    my.env.TERMINAL = config.modules.desktop.term.default;
  };
}
