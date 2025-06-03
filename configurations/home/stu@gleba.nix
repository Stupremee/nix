{ pkgs, ... }:
{
  imports = [ ./stu.nix ];

  home.packages = with pkgs.unstable; [
    firefox-devedition
    ungoogled-chromium
    spotify-player
    localsend
  ];

  my = {
    dev.k8s.enable = true;

    hyprland = {
      sensitivity = "0.0";

      extraSettings = {
        input.kb_options = "caps:swapescape";
        "input:touchpad".natural_scroll = true;
      };

      monitors = {
        "eDP-1" = {
          position = "auto";
          resolution = "1920x1200";
          scale = "1.0";
        };
      };
    };
  };
}
