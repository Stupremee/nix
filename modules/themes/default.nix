{ config, options, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./nord
  ];

  options.modules.theme = {
    name    = mkOption { type = with types; nullOr str; default = null; };
    path = mkOption {
      type = with types; nullOr path;
      default = null;
    };

    wallpaper = {
      path = mkOption {
        type = with types; nullOr str;
        default = if config.modules.theme.path != null
                  then "${config.modules.theme.path}/wallpaper.png"
                  else null;
      };
    };
  };

  config = mkIf (config.modules.theme.wallpaper.path != null &&
                 builtins.pathExists config.modules.theme.wallpaper.path) {
    my.home.home.file.".background-image".source =
      config.modules.theme.wallpaper.path;
  };
}
