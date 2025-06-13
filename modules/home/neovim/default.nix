{
  lib,
  config,
  flake,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.neovim;

  customNeovim = flake.inputs.nvf.lib.neovimConfiguration {
    pkgs = pkgs.unstable;

    modules = [
      {
        _module.args.theme = config.catppuccin.flavor;
      }
      ./config
    ];
  };
in
{
  options.my.neovim.enable = mkEnableOption "Enable Neovim";

  config = mkIf cfg.enable {
    home.packages = [
      customNeovim.neovim
    ];

    home.sessionVariables = {
      MANPAGER = "nvim +Man!";
      EDITOR = "nvim";
    };
  };
}
