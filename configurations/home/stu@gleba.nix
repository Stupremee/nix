{ pkgs, ... }:
let
  closeLid = pkgs.writeShellScript "close-lid" ''
    if [ ! -z "$(hyprctl monitors | grep DP-7)" ]; then
      hyprctl keyword monitor "eDP-1, disable"
    else
      hyprlock
    fi
  '';

  openLid = pkgs.writeShellScript "open-lid" ''
    if [ ! -z "$(hyprctl monitors | grep DP-7)" ]; then
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
    localsend
  ];

  my = {
    dev = {
      k8s.enable = true;
      azure.enable = true;
    };

    hyprland = {
      sensitivity = "0.0";

      extraSettings = {
        # input.kb_options = "caps:swapescape";
        "input:touchpad".natural_scroll = true;
      };

      monitors = {
        "eDP-1" = {
          position = "auto";
          resolution = "1920x1200";
          scale = "1.0";
        };

        "DP-7" = {
          position = "auto";
          resolution = "5120x2160@75";
          scale = "1.6";
        };
      };

      extraSettings = {
        bindl = [
          ", switch:off:Lid Switch, exec, ${openLid}"
          ", switch:on:Lid Switch, exec, ${closeLid}"
        ];
      };
    };
  };
}
