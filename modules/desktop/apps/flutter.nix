{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.apps.flutter = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.apps.flutter.enable {
    my = {
      packages = [ pkgs.unstable.flutterPackages.beta ];
    };
  };
}

