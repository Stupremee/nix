{ inputs, ... }:
let
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
  ];

  mkSystem = { system, modules }: inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      {
        _module.args.unstable-pkgs = inputs.unstable.legacyPackages."${system}";
      }
    ] ++ coreModules ++ modules;
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
    };
  };
}
