{
  lib,
  inputs,
  ...
}: let
  inherit (lib) optionals;

  coreModules = [
    ../nixos/nix-daemon.nix
    ../nixos/users.nix
    ../nixos/network/sshd.nix
    ../nixos/network/network.nix
    ../nixos/network/tailscale.nix
    ../nixos/shell.nix

    ../nixos/modules/erase-darlings.nix
    ../nixos/modules/deploy.nix
    ../nixos/modules/tailscale.nix
    ../nixos/modules/vaultwarden.nix
    ../nixos/modules/backup.nix
    ../nixos/modules/age.nix

    inputs.agenix.nixosModule
    inputs.home-manager.nixosModule
    inputs.hyprland.nixosModules.default
  ];

  mkHomeModule = modules: system: theme: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inherit inputs system;
      theme = (import ../themes {inherit lib;})."${theme}";
      unstable-pkgs = inputs.unstable.legacyPackages."${system}";
    };
    home-manager.users.stu = {...}: {
      # Default imports for the user
      imports =
        [
          inputs.hyprland.homeManagerModules.default
        ]
        ++ modules;
      home.stateVersion = "22.05";
    };
  };

  mkSystem = {
    system,
    modules,
    home ? false,
    theme ? "",
    homeModules ? [],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules =
        [
          {
            _module.args.unstable-pkgs = inputs.unstable.legacyPackages."${system}";
          }
        ]
        ++ coreModules
        ++ modules
        ++ (optionals home [(mkHomeModule homeModules system theme)]);
    };
in {
  flake.nixosConfigurations = {
    nether = mkSystem {
      system = "x86_64-linux";
      modules = [
        ./nether.nix
        ../nixos/paperless.nix
        ../nixos/nginx.nix
        ../nixos/containers.nix
        ../nixos/postgres.nix
        ../nixos/vaultwarden.nix
      ];
      home = true;
      homeModules = [
        ../home/git.nix
      ];
    };

    nixius = mkSystem {
      system = "x86_64-linux";
      modules = [
        ./nixius.nix
        ../nixos/fonts.nix
        ../nixos/yubikey.nix
        ../nixos/graphical.nix
      ];
      home = true;
      theme = "frappe";
      homeModules = [
        ../home/git.nix
        ../home/wayland
        ../home/alacritty.nix
        ../home/pgp.nix
        ../home/xdg.nix
        ../home/zsh.nix
        ../home/tmux.nix
        ../home/nix-index.nix
        ../home/editors/nvim
        ../home/graphical
      ];
    };
  };
}
