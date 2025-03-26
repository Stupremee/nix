{ flake, ... }:
let
  inherit (flake.inputs) self;
in
{
  imports = [ self.homeModules.default ];

  home.username = "stu";

  my = {
    alacritty.enable = true;
    mako.enable = true;

    zsh.enable = true;
    tmux.enable = true;
    neovim.enable = true;
    git.enable = true;

    hyprland = {
      enable = true;

      sensitivity = "-0.5";

      monitors = {
        "DP-5" = {
          position = "0x0";
          resolution = "3840x2160@60";
          scale = "1.5";
        };

        "DP-3" = {
          position = "2560x0";
          resolution = "3840x2160@60";
          scale = "1.5";
        };

        "Unknown-1".disable = true;
      };
    };
  };
}
