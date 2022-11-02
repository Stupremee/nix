{
  pkgs,
  lib,
  theme,
  ...
}: let
  inherit (lib) concatMapStringsSep;

  themes = [
    {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Light";
    }
    {
      package = pkgs.hicolor-icon-theme;
      name = "hicolor";
    }
  ];

  mkPath = {
    package,
    name,
  }: "${package}/share/icons/${name}";

  iconPath = concatMapStringsSep ":" mkPath themes;
in {
  home.packages = [pkgs.libnotify];

  programs.mako = {
    enable = true;

    borderRadius = 4;
    borderSize = 2;

    inherit iconPath;

    backgroundColor = theme.base;
    textColor = theme.text;
    borderColor = theme.blue;
    progressColor = theme.surface0;

    extraConfig = ''
      max-icon-size=32

      [urgency=low]
      border-color=${theme.lavender}

      [urgency=normal]
      border-color=${theme.blue}

      [urgency=critical]
      border-color=${theme.red}
    '';
  };
}
