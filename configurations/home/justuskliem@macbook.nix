{ pkgs, flake, ... }:
let
  inherit (flake.inputs) self;
in
{
  imports = [ self.homeModules.default ];

  catppuccin.flavor = "latte";

  home = {
    username = "justuskliem";
    packages = with pkgs; [
      tailscale
      httpie
      fh
    ];
  };

  my = {
    xdg.enable = false;
    zsh.enable = true;
    neovim.enable = true;
    git.enable = true;
    dev = {
      enable = true;
      k8s.enable = true;
      azure.enable = true;
    };
  };
}
