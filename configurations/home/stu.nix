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
    alacritty.enable = true;
    mako.enable = true;
    zsh.enable = true;
    tmux.enable = true;
    neovim.enable = true;
    git.enable = true;
    rofi.enable = true;
    hyprland.enable = true;
  };
}
