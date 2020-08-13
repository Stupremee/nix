{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.desktop.browsers.qutebrowser = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.browsers.qutebrowser.enable {
    my.packages = with pkgs; [
      qutebrowser
      (makeDesktopItem {
        name = "qutebrowser-private";
        desktopName = "Qutebrowser (Private)";
        genericName = "Open a private Qutebrowser window";
        icon = "qutebrowser";
        exec = "${qutebrowser}/bin/qutebrowser ':open -p'";
        categories = "Network";
      })
    ];

    my.home.xdg.configFile."qutebrowser" = {
      source = <config/qutebrowser>;
      recursive = true;
    };
  };
}
