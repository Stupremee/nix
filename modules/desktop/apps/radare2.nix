{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.apps.r2 = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.apps.r2.enable {
    my = {
      packages = [ pkgs.radare2 ];

      home.xdg.configFile."radare2/radare2rc".source = <config/radare2>;
    };
  };
}

