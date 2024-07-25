{
  pkgs,
  unstable-pkgs,
  theme,
  lib,
  ...
}: let
  len = builtins.stringLength theme.name;
  first = lib.toUpper (lib.substring 0 1 theme.name);
  last = lib.substring 1 len theme.name;
  upperTheme = "${first}${last}";
in {
  imports = [
    ./eww
    ./media.nix
  ];

  home.packages = with unstable-pkgs; [
    (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override {pipewireSupport = true;}) {})
    ungoogled-chromium
  ];

  home.pointerCursor = {
    package = unstable-pkgs.catppuccin-cursors."${theme.name}Light";
    name = "Catppuccin-${upperTheme}-Light-Cursors";
    size = 24;
    gtk.enable = true;
    x11.enable = false;
  };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;

    font = {
      name = "Noto";
      package = pkgs.noto-fonts;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Catppuccin-${upperTheme}";
      package = pkgs.catppuccin-gtk.override {size = "compact";};
    };
  };
}
