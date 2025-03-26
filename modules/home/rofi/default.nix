{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  inherit (builtins) readFile;

  cfg = config.my.rofi;

  mkScript =
    name: path:
    (pkgs.writeScriptBin name (readFile path)).overrideAttrs (old: {
      buildCommand = ''
        ${old.buildCommand}

        patchShebangs $out
      '';
    });

  scripts = pkgs.symlinkJoin {
    name = "rofi-scripts";
    paths = [
      (mkScript "rofi-launcher" ./launcher.sh)
      (mkScript "rofi-runner" ./runner.sh)
      (mkScript "rofi-powermenu" ./powermenu.sh)
      (mkScript "rofi-screenshot" ./screenshot.sh)
    ];
  };
in
{
  options.my.rofi.enable = mkEnableOption "Enable rofi application launcher";

  config = mkIf cfg.enable {
    home.packages = [ scripts ];

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
    };
  };
}
