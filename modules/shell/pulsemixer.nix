{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.shell.pulsemixer = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.pulsemixer.enable {
    my.packages = with pkgs; [ pulsemixer ];

    my.alias.mixer = "pulsemixer";
  };
}
