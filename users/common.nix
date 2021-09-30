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
    extraGroups = [
      "wheel"
      "sway"
      "networkmanager"
      "input"
      "libvirtd"
      "wireshark"
      "podman"
      "docker"
    ];
    openssh.authorizedKeys.keys = pkgs.lib.flk.myKeys pkgs;
  };
}
