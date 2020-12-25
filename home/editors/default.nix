{ pkgs, ... }: {
  imports = [ ./neovim ];

  home.sessionVariables = { EDITOR = "nvim"; };
}
