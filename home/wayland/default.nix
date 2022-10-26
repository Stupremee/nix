{ pkgs, ... }: {
  imports = [
    ./hyprland.nix
    ./rofi
    ./moka.nix
  ];
}
