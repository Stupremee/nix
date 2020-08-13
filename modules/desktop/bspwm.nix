{ config, options, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./common.nix
  ];

  options.modules.desktop.bspwm = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.desktop.bspwm.enable {
    environment.systemPackages = with pkgs; [
      bspwm
      sxhkd
      lightdm
      dunst
      libnotify
      maim
      (polybar.override {
        pulseSupport = true;
        nlSupport = true;
      })
    ];

    services = {
      picom.enable = true;
      xserver = {
        enable = true;
        displayManager.defaultSession = "none+bspwm";
        displayManager.lightdm.enable = true;
        displayManager.lightdm.greeters.mini.enable = true;
        windowManager.bspwm.enable = true;
        xrandrHeads = [ { output = "DP-3"; monitorConfig = '' Option "LeftOf" "HDMI-0" ''; }
              { output = "HDMI-0"; primary = true; } ];
      };
    };

    my.home.xdg.configFile = {
      "bspwm" = {
        source = <config/bspwm>;
        recursive = true;
      };
    };
  };
}
