{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.neovim;
in
{
  options.my.neovim.enable = mkEnableOption "Enable Neovim";

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      enableManpages = true;
      defaultEditor = true;
      settings = ./config;
    };

    home.sessionVariables = {
      MANPAGER = "nvim +Man!";
    };
  };
}
