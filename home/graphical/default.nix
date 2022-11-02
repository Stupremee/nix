{ pkgs, unstable-pkgs, theme, lib, ... }:
let
  len = builtins.stringLength theme.name;
  first = lib.toUpper (lib.substring 0 1 theme.name);
  last = lib.substring 1 len theme.name;
  upperTheme = "${first}${last}";
in
{
  home.packages = with pkgs; [
    firefox-wayland
  ];

  home.pointerCursor = {
    package = unstable-pkgs.catppuccin-cursors."${theme.name}Light";
    name = "Catppuccin-${upperTheme}-Light-Cursors";
    size = 24;
    gtk.enable = true;
    x11.enable = false;
  };

  gtk = {
    enable = true;

    font = {
      name = "Roboto";
      package = pkgs.roboto;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Catppuccin-${upperTheme}"; package = pkgs.catppuccin-gtk.override { size = "compact"; };
    };
  };
}
