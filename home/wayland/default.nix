{pkgs, ...}: {
  imports = [
    ./hyprland.nix
    ./rofi
    ./moka.nix
    ./swaylock.nix
    ./swayidle.nix
  ];
}
