{ pkgs, ... }:
let
  closeLid = pkgs.writeShellScript "close-lid" ''
    if [ ! -z "$(hyprctl monitors | grep ' DP')" ]; then
      hyprctl keyword monitor "eDP-1, disable"
    else
      hyprlock
    fi
  '';

  openLid = pkgs.writeShellScript "open-lid" ''
    if [ ! -z "$(hyprctl monitors | grep ' DP')" ]; then
      hyprctl keyword monitor "eDP-1, 1920x1200, auto, 1"
    else
      hyprlock
    fi
  '';
in
{
  imports = [ ./stu.nix ];

  home.packages = with pkgs.unstable; [
    firefox-devedition
    ungoogled-chromium
    spotify-player
    libreoffice-still
    dbeaver-bin
  ];

  my = {
    dev = {
      enable = true;
      k8s.enable = true;
      azure.enable = true;
    };

    hyprland = {
      sensitivity = "0.0";

      extraSettings = {
        # input.kb_options = "caps:swapescape";
        "input:touchpad".natural_scroll = true;
      };

      monitors =
        let
          curvedMon = {
            position = "0x0";
            resolution = "5120x2160@75";
            scale = "1.6";
          };
        in
        {
          "eDP-1" = {
            position = "auto";
            resolution = "1920x1200";
            scale = "1.0";
          };

          "DP-4" = curvedMon;
          "DP-6" = curvedMon;
          "DP-7" = curvedMon;
        };

      extraSettings = {
        bindl = [
          ", switch:off:Lid Switch, exec, ${openLid}"
          ", switch:on:Lid Switch, exec, ${closeLid}"
        ];

        general = {
          layout = "master";
        };

        master = {
          mfact = 0.5;
          orientation = "center";
        };
      };

      hyprpanel.settings = {
        bar.layouts."*" = {
          left = [
            "dashboard"
            "workspaces"
            "windowtitle"
          ];
          middle = [ "media" ];
          right = [
            "volume"
            "network"
            "bluetooth"
            "battery"
            "systray"
            "clock"
            "notifications"
          ];
        };
      };
    };
  };
}
