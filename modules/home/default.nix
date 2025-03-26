{ flake, lib, ... }:
with lib;
{
  imports =
    with flake.inputs;
    [
      catppuccin.homeManagerModules.catppuccin
      nvf.homeManagerModules.default
    ]
    ++ (attrValues (filterAttrs (name: _: name != "default") flake.inputs.self.homeModules));

  nixpkgs.overlays = [
    flake.inputs.self.overlays.default
  ];

  manual.manpages.enable = true;

  programs = {
    command-not-found.enable = true;
    home-manager.enable = true;
  };

  fonts.fontconfig.enable = true;

  catppuccin = {
    enable = true;
    flavor = lib.mkDefault "frappe";
  };

  home.stateVersion = "24.05";
}
