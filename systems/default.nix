{ inputs, ... }:
let
  coreModules = [
    ../nixos/nix-daemon.nix
    ../nixos/users.nix
    ../nixos/network/sshd.nix
    ../nixos/network/networkmanager.nix

    ../nixos/erase-darlings.nix
  ];

  mkSystem = { system, modules }: inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = coreModules ++ modules;
  };
in
{
  flake.nixosConfigurations = {
    nether = mkSystem {
      system = "x86_64-linux";
      modules = [
        ./nether.nix
      ];
    };
  };
}
