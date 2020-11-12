{
  description = "My NixOS system configurations";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Probably I will need it some time
  # inputs.nur.url = "github:nix-community/NUR/master";

  outputs = { self, nixpkgs, home-manager, nur }:
    let
      systemModule = { hostName, hardwareConfig, config }:
        ({ pkgs, ... }: {
          # Set the hostname
          networking.hostName = hostName;

          # Redirect global nixpkgs to nixpkgs flage defined here
          nix.registry.nixpkgs.flake = nixpkgs;

          # Import the modules
          imports =
            [ hardwareConfig config home-manager.nixosModules.home-manager ];
        });
    in {

      nixosConfigurations.nixius = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # hardware.enableRedistributableFirmware = true
          nixpkgs.nixosModules.notDetected
        ];
      };
    };
}
