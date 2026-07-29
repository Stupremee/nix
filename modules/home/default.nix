{
  flake,
  lib,
  pkgs,
  ...
}:
with lib;
let
  pkgsUnstable = import flake.inputs.nixpkgs-unstable {
    localSystem = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  imports =
    with flake.inputs;
    [
      catppuccin.homeModules.catppuccin
      nvf.homeManagerModules.default
      nix-index-database.homeModules.nix-index
    ]
    ++ (attrValues (filterAttrs (name: _: name != "default") flake.inputs.self.homeModules));

  _module.args.pkgsUnstable = pkgsUnstable;

  home.packages = [ pkgsUnstable.devenv ];

  my.xdg.enable = lib.mkDefault true;

  manual.manpages.enable = true;

  programs = {
    home-manager.enable = true;
  };

  fonts.fontconfig.enable = true;

  catppuccin = {
    autoEnable = true;
    enable = true;
    flavor = lib.mkDefault "frappe";
  };

  home.stateVersion = "24.05";
}
