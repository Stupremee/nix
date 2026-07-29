{ flake, pkgs, ... }:
let
  inherit (flake.inputs) self;
in
{
  imports = [ self.homeModules.default ];

  home = {
    username = "stu";
    packages = with pkgs; [
      fh
    ];
  };

  my = {
    zsh.enable = true;
    tmux.enable = true;
    neovim.enable = true;
    git.enable = true;
  };
}
