{ pkgs, ... }:
{
  home.packages = with pkgs; [
    firefox-devedition
  ];

  my = {
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
