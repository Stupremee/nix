{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.apps.rofi = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.apps.rofi.enable {
    my = {
      home.xdg.configFile."rofi" = {
        source = <config/rofi>;
        recursive = true;
      };

      packages = [ pkgs.rofi ];
    };
  };
}

