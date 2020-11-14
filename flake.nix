{
  description = "My NixOS system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url =
        "github:Myhlamaeus/pre-commit-hooks.nix/8d48a4cd434a6a6cc8f2603b50d2c0b2981a7c55";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Probably I will need it some time
  # inputs.nur.url = "github:nix-community/NUR/master";

  outputs = { self, nixpkgs, home-manager, flake-utils, pre-commit-hooks }:
    let
      systemModule = { hostName, path }:
        ({ pkgs, ... }: {
          # Set the hostname
          networking.hostName = hostName;

          # Redirect global nixpkgs to nixpkgs flage defined here
          nix.registry.nixpkgs.flake = nixpkgs;

          # Import the modules
          imports = [ path home-manager.nixosModules.home-manager ];
        });
    in {

      # My workstation at home.
      nixosConfigurations.nixius = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixpkgs.nixosModules.notDetected
          (systemModule {
            hostName = "nixius";
            path = ./hosts/nixius;
          })
        ];
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pre-commit-check = pre-commit-hooks.defaultPackage.${system} {
          src = ./.;
          hooks = { nixfmt.enable = true; };
        };
      in {
        devShell = pkgs.mkShell { inherit (pre-commit-check) shellHook; };
      });
}
