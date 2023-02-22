{pkgs}: let
  nodePackages = import ./composition.nix {inherit pkgs;};
in
  nodePackages
