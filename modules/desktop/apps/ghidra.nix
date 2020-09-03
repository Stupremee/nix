{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.apps.ghidra = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.apps.ghidra.enable {
    my = {
      packages = [ pkgs.ghidra-bin];
    };
  };
}

