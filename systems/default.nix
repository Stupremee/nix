{ lib, inputs, ... }:
let
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

    inputs.agenix.nixosModule
    inputs.home-manager.nixosModule
  ];

  mkHomeModule = modules: system: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit system inputs; };
    home-manager.users.stu = { pkgs, ... }: {
      # Default imports for the user
      imports = modules;
      home.stateVersion = "22.05";
    };
  };

  mkSystem =
    { system
    , modules
    , home ? false
    , homeModules ? [ ]
    }: inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        {
          _module.args.unstable-pkgs = inputs.unstable.legacyPackages."${system}";
        }
      ]
      ++ coreModules
      ++ modules
      ++ (optionals home [ (mkHomeModule homeModules system) ]);
    };
in
{
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
    };

    nixius = mkSystem {
      system = "x86_64-linux";
      modules = [
        ./nixius.nix
      ];
      home = true;
      homeModules = [
        ../home/git.nix
      ];
    };
  };
}
