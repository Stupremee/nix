{
  config,
  pkgs,
  lib,
  ...
}:
{
  manual.manpages.enable = true;

  programs.command-not-found.enable = true;

  programs.home-manager.enable = true;

  catppuccin = {
    enable = true;
    flavor = lib.mkDefault "frappe";
  };

  home.stateVersion = "24.05";
}
