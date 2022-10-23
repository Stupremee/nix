{ config, pkgs, ... }: {
  home.packages = [ pkgs.rofi-wayland ];
  xdg.configFile."rofi/config".source = ./config;
  xdg.configFile."rofi/bin".source = ./bin;
}
