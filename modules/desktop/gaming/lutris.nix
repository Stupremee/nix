{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.gaming.lutris = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.gaming.lutris.enable {
    my.packages = with pkgs; [
      unstable.lutris-unwrapped
      mesa
    ];
  };
}
