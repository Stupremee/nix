{ pkgs, ... }:
let
  nord-xresources = pkgs.fetchFromGitHub {
    owner = "arcticicestudio";
    repo = "nord-xresources";
    rev = "ad8d70435ee0abd49acc7562f6973462c74ee67d";
    sha256 = "sha256-bjLQwYYkIMKgC68EGLkfWJWqJbiTIvTZ6bboGJNhS9E=";
  } + "/src/nord";
in {
  imports = [ ./gtk.nix ./mimeapps.nix ./bspwm.nix ];

  home.file.".background-image".source = ../../background-image.png;

  xresources.extraConfig = builtins.readFile nord-xresources;
}
