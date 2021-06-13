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

      ./profiles/zsh
      ./profiles/git.nix
      ./profiles/pgp.nix

      ./profiles/editors/nvim
    ];

    home.packages = with pkgs; [ firefox ];

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
