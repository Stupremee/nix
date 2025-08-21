{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.xdg;
in
{
  options.my.xdg = {
    enable = mkEnableOption "Enable XDG user dirs and mime types";
  };

  config = mkIf cfg.enable {
    xdg = {
      enable = true;
      cacheHome = config.home.homeDirectory + "/.local/cache";

      mimeApps = {
        enable = true;
      };

      userDirs = {
        enable = true;
        createDirectories = true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
        };
      };
    };

    home.packages = [
      pkgs.xdg-utils
    ];
  };
}
