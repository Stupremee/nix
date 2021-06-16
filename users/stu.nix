{ pkgs, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  home-manager.users.stu = {
    imports = [
      ./profiles/graphical/bspwm
      ./profiles/graphical/alacritty
      # ./profiles/graphical/gtk.nix

      ./profiles/shell/zsh
      ./profiles/shell/git.nix
      ./profiles/shell/pgp.nix
      ./profiles/shell/tmux.nix
      ./profiles/shell/zellij.nix

      ./profiles/editors/nvim
      ./profiles/editors/kakoune
    ];

    # TODO: Move these somewhere else
    home.packages = with pkgs; [ firefox spotify discord ];

    modules.graphical = {
      bspwm = {
        enable = true;
        theme = ./themes/nord;
      };

      alacritty = {
        enable = true;
        theme = ./themes/nord;
      };
    };

    modules.zsh.enable = true;
    modules.git.enable = true;
    modules.pgp.enable = true;

    modules.tmux = {
      enable = true;
      theme = ./themes/nord;
    };

    modules.zellij = {
      enable = false;
      theme = ./themes/nord;
    };

    modules.editors.nvim.enable = true;
    modules.editors.kakoune.enable = true;
  };

  users.users.stu = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" ];
    openssh.authorizedKeys.keys = pkgs.lib.flk.keysFromGithub {
      inherit pkgs;
      username = "Stupremee";
      sha256 = "sha256-QXJfmJjokI1rTHD7xK5Q+vQ6IeWZ9SrjM7uTnMoe/Iw=";
    };
  };
}
