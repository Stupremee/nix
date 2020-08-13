device: username:
{ pkgs, options, lib, config, ... }:
{
  networking.hostName = lib.mkDefault "nixius";
  my.username = username;

  imports = [
    ./modules
    "${./hosts}/${device}"
  ] ++ (if builtins.pathExists(./secrets.nix) then [
    ./secrets.nix
  ] else []);

  nix.autoOptimiseStore = true;
  nix.nixPath = options.nix.nixPath.default ++ [
    "bin=/etc/dotfiles/bin"
    "config=/etc/dotfiles/config"
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    coreutils
    git
    killall
    unzip
    vim
    wget
    sshfs

    gnumake
  ];

  environment.shellAliases = {
    nix-env = "NIXPKGS_ALLOW_UNFREE=1 nix-env";
    nsh = "nix-shell";
    nen = "nix-env";
    dots = "make -C ~/.dotfiles";
  };

  my.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "networkmanager" ];
    shell = pkgs.zsh;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
