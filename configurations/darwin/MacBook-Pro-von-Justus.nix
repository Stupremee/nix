{
  pkgs,
  lib,
  flake,
  ...
}:
{
  imports = with flake.inputs; [
    self.darwinModules.default
  ];

  system.primaryUser = "justuskliem";
  my = {
    user = {
      name = "justuskliem";
      import = ../. + "/home/justuskliem@macbook.nix";
    };

    zsh.enable = true;
    nix-common = {
      enable = true;
      maxJobs = 4;
    };
  };

  environment.systemPackages = with pkgs; [
    gnupg
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  nix.settings.builders = lib.mkForce "ssh://root@rome x86_64-linux";

  system.stateVersion = lib.mkForce 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
