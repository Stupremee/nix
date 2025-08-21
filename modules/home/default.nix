{
  flake,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports =
    with flake.inputs;
    [
      catppuccin.homeModules.catppuccin
      nvf.homeManagerModules.default
      nix-index-database.hmModules.nix-index
    ]
    ++ (attrValues (filterAttrs (name: _: name != "default") flake.inputs.self.homeModules));

  home.packages = with pkgs; [
    devenv
  ];

  my.xdg.enable = true;

  manual.manpages.enable = true;

  programs = {
    home-manager.enable = true;
  };

  fonts.fontconfig.enable = true;

  catppuccin = {
    enable = true;
    flavor = lib.mkDefault "frappe";
  };

  home.stateVersion = "24.05";
}
