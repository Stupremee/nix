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
    package = pkgs.mako.overrideAttrs (_: {
      src = pkgs.fetchFromGitHub {
        owner = "emersion";
        repo = "mako";
        rev = "5eca7d58bf9eb658ece1b32da586627118f00642";
        sha256 = "sha256-YRCS+6or/Z6KJ0wRfZDkvwbjAH2FwL5muQfVoFtq/lI=";
      };
    });

    borderRadius = 4;
    borderSize = 2;

    inherit iconPath;

    backgroundColor = theme.base;
    textColor = theme.text;
    borderColor = theme.blue;
    progressColor = theme.surface0;

    extraConfig = ''
      max-icon-size=32
      output=HDMI-A-1

      [urgency=low]
      border-color=${theme.lavender}

      [urgency=normal]
      border-color=${theme.blue}

      [urgency=critical]
      border-color=${theme.red}

      [mode=do-not-disturb]
      invisible=1
    '';
  };
}
