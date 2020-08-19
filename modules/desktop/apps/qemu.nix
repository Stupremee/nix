{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.apps.qemu = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.apps.qemu.enable {
    my = {
      packages = with pkgs; [
        qemu
        qemu-utils
      ];
    };
  };
}

