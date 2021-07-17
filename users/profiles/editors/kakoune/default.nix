{ pkgs, lib, config, ... }: {
  programs.kakoune = {
    enable = true;
  };

  home.sessionVariables.EDITOR = "kakoune";
  home.sessionVariables.MANPAGER = "nvim +Man!";
}
