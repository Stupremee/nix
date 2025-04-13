{ pkgs, ... }:
{
  imports = [ ./stu.nix ];

  home.packages = with pkgs; [
    firefox-devedition
    spotify-player
  ];

  my = {
    dev.k8s.enable = true;

    hyprland = {
      sensitivity = "0.0";

      monitors = {
        "DP-1" = {
          position = "0x0";
          resolution = "2560x1440";
        };
      };
    };
  };
}
