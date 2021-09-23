{ pkgs, ... }: {
  age.secrets.sshConfig = {
    file = ../secrets/ssh.config;
    owner = "stu";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  home-manager.users.stu = {
    imports = [
      ./profiles/shell/zsh
      ./profiles/shell/git.nix
      ./profiles/shell/pgp.nix
      ./profiles/shell/tmux.nix

      ./profiles/editors/nvim
      ./profiles/editors/kakoune

      ./profiles/udiskie.nix
    ];

    home.packages = with pkgs; [ personalScripts ];
  };

  users.users.stu = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "sway" "networkmanager" "input" "libvirtd" ];
    openssh.authorizedKeys.keys = pkgs.lib.flk.keysFromGithub {
      inherit pkgs;
      username = "Stupremee";
      sha256 = "sha256-QXJfmJjokI1rTHD7xK5Q+vQ6IeWZ9SrjM7uTnMoe/Iw=";
    };
  };
}
