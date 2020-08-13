{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.media.mpv = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.media.mpv.enable {
    my.packages = [ pkgs.mpv-with-scripts ];
  };
}
