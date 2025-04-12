{ flake, ... }:
let
  inherit (flake.inputs) self;
in
{
  imports = [ self.homeModules.default ];

  catppuccin.flavor = "latte";

  home = {
    username = "jkliem";
  };

  my = {
    zsh.enable = true;
    neovim.enable = true;
    git.enable = true;
  };
}
