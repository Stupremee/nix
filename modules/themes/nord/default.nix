{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules; in
{
  options.modules.themes.nord = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.themes.nord.enable {
    modules.theme = {
      name = "nord";
      path = ./.;
    };

    services.picom = {
      fade = true;
      fadeDelta = 1;
      fadeSteps = [ "0.01" "0.012" ];
      shadow = true;
      shadowOffsets = [ (-10) (-10) ];
      shadowOpacity = "0.22";
      settings = {
        shadow-radius = 12;
        blur-background = true;
      };
    };

    services.xserver.displayManager.lightdm = {
      greeters.mini.extraConfig = ''
        text-color = "#a3be8c"
        password-background-color = "#2e3440"
        window-color = "#4c566a"
        border-color = "#4c566a"
      '';
    };

    fonts.fonts = [ pkgs.nerdfonts ];
    my.packages = with pkgs; [
      nordic
      paper-icon-theme
    ];

    my.zsh = mkIf cfg.shell.zsh.enable {
      rc = lib.readFile ./fzf.zsh;
    };

    my.home = {
      home.file = mkMerge [
        (mkIf cfg.desktop.browsers.firefox.enable {
          ".mozilla/firefox/${cfg.desktop.browsers.firefox.profileName}.default/chrome/" = {
            source = ./firefox;
            recursive = true;
          };
        })
      ];

      xdg.configFile = mkMerge [
        (mkIf config.services.xserver.enable {
          "xtheme/90-theme".source    = ./Xresources;
          # GTK
          "gtk-3.0/settings.ini".text = ''
            [Settings]
            gtk-theme-name=Nordic
            gtk-icon-theme-name=Paper
            gtk-fallback-icon-theme=gnome
            gtk-application-prefer-dark-theme=true
            gtk-cursor-theme-name=Paper
            gtk-xft-hinting=1
            gtk-xft-hintstyle=hintfull
            gtk-xft-rgba=none
          '';
          # GTK2 global theme (widget and icon theme)
          "gtk-2.0/gtkrc".text = ''
            gtk-theme-name="Nordic"
            gtk-icon-theme-name="Paper-Mono-Dark"
            gtk-font-name="Hack 10"
          '';
          # QT4/5 global theme
          "Trolltech.conf".text = ''
            [Qt]
            style=nordic
          '';
        })
        (mkIf cfg.desktop.bspwm.enable {
          "bspwm/rc.d/polybar".source = ./polybar/run.sh;
          "bspwm/rc.d/theme".source   = ./bspwmrc;
        })
        (mkIf cfg.desktop.apps.rofi.enable {
          "rofi/config.rasi".source = ./rofi.rasi;
        })
        (mkIf (cfg.desktop.bspwm.enable) {
          "polybar" = { source = ./polybar; recursive = true; };
          "dunst/dunstrc".source = ./dunstrc;
        })
      ];
    };
  };
}
