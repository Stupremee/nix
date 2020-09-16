{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.gaming.multimc = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.gaming.multimc.enable {
    my.packages = with pkgs; [
      multimc
    ];
  };
}
