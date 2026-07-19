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

  environment = {
    shellInit = lib.mkAfter ''
      if [ -f "$HOME/.vite-plus/env" ]; then
        . "$HOME/.vite-plus/env"
      fi
    '';

    systemPackages = with pkgs; [
      gnupg
    ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  homebrew = {
    enable = true;
    brews = [
      "libpq"
      "psqlodbc"
    ];
  };

  nix.settings.builders = lib.mkForce "ssh://root@rome x86_64-linux";

  system.stateVersion = lib.mkForce 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
