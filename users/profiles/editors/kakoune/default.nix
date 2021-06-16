{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.editors.kakoune;
in
{
  options.modules.editors.kakoune = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.kakoune = {
      enable = true;
    };

    home.sessionVariables.EDITOR = "kakoune";
    home.sessionVariables.MANPAGER = "nvim +Man!";
  };
}
