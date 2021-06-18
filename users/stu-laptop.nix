{ pkgs, ... }: {
  home-manager.users.stu = {
    imports = [
      ./profiles/graphical/sway
      ./profiles/graphical/alacritty
      ./profiles/graphical/browsers/firefox.nix
      ./profiles/graphical/gtk.nix

      ./profiles/shell/zsh
      ./profiles/shell/git.nix
      ./profiles/shell/pgp.nix

      ./profiles/editors/nvim
    ];

    home.packages = with pkgs; [ spotify libreoffice ];
  };

  users.users.stu = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "sway" "networkmanager" "input" ];
    openssh.authorizedKeys.keys = pkgs.lib.flk.keysFromGithub {
      inherit pkgs;
      username = "Stupremee";
      sha256 = "sha256-QXJfmJjokI1rTHD7xK5Q+vQ6IeWZ9SrjM7uTnMoe/Iw=";
    };
  };
}
