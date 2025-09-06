{ pkgs, ... }:
{
  imports = [ ./stu.nix ];

  home.packages = with pkgs.unstable; [
    firefox-devedition
    ungoogled-chromium
    pkgs.spotify-player
  ];

  my = {
    dev = {
      k8s.enable = true;
      azure.enable = true;
    };

    hyprland = {
      sensitivity = "0.0";

      monitors = {
        "DP-1" = {
          position = "0x0";
          resolution = "2560x1440";
        };
      };

      hyprpanel.settings.layout = {
        "bar.layouts" = {
          "0" = {
            left = [
              "dashboard"
              "workspaces"
              "windowtitle"
            ];
            middle = [ "media" ];
            right = [
              "volume"
              "systray"
              "clock"
              "notifications"
            ];
          };
        };
      };
    };
  };
}
