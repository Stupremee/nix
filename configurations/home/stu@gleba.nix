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

      monitors = { };
    };
  };
}
