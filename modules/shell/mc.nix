{ config, options, pkgs, lib, ... }:
with lib;
{
  options.modules.shell.mc = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.mc.enable {
    my = {
      packages = with pkgs; [
        unstable.minio-client
      ];
    };
  };
}
