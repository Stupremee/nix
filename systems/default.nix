{ inputs, ... }:
let
  coreModules = [
    ../nixos/nix-daemon.nix
    ../nixos/users.nix
    ../nixos/network/sshd.nix
    ../nixos/network/networkmanager.nix
    ../nixos/network/tailscale.nix

    ../nixos/modules/erase-darlings.nix
    ../nixos/modules/deploy.nix

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
      ];
    };
  };
}
