{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.gaming.steam = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.gaming.steam.enable {
    my.packages = with pkgs; [
      (writeScriptBin "steam" ''
        #!${stdenv.shell}
        HOME="$XDG_DATA_HOME/steamlib" exec ${steam}/bin/steam "$@"
        '')
      (writeScriptBin "steam-run" ''
        #!${stdenv.shell}
        HOME="$XDG_DATA_HOME/steamlib" exec ${steam-run-native}/bin/steam-run "$@"
        '')
    ];

    hardware.opengl.driSupport32Bit = true;
    hardware.pulseaudio.support32Bit = true;
  };
}
