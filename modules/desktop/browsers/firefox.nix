{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.desktop.browsers.firefox = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    profileName = mkOption {
      type = types.str;
      default = config.my.username;
    };
  };

  config = mkIf config.modules.desktop.browsers.firefox.enable {
    my.packages = with pkgs; [
      firefox-devedition-bin
      (makeDesktopItem {
        name = "firefox-private";
        desktopName = "Firefox (Private)";
        genericName = "Open a private Firefox window";
        icon = "firefox";
        exec = "${firefox-bin}/bin/firefox --private-window";
        categories = "Network";
      })
    ];

    my.env.XDG_DESKTOP_DIR = "$HOME";
  };
}
