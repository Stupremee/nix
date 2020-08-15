{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.shell.git = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.git.enable {
    my = {
      packages = with pkgs; [
        gitAndTools.hub
        gitAndTools.diff-so-fancy
        gitAndTools.gh
      ];
      home.xdg.configFile = {
        "git/config".source = <config/git/config>;
      };
      alias.g = "git";
    };
  };
}
