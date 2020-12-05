{
  description = "My NixOS system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/20.09";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/NUR/master";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url =
        "github:Myhlamaeus/pre-commit-hooks.nix/8d48a4cd434a6a6cc8f2603b50d2c0b2981a7c55";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mozpkgs = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, flake-utils
    , pre-commit-hooks, mozpkgs, nur }:
    let
      system = "x86_64-linux";

      systemModule = hostName:
        ({ pkgs, ... }: {
          # Set the hostname
          networking.hostName = hostName;

          # Set system revision to flake's revision
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

          # Redirect global nixpkgs to nixpkgs flage defined here
          nix.registry.nixpkgs.flake = nixpkgs;

          # Import the modules
          imports = [
            (./hosts + "/${hostName}")
            home-manager.nixosModules.home-manager
          ];
        });
    in {
      overlays = {
        mozila = final: prev: { mozilla = mozpkgs; };
        nur = nur.overlay;
        unstable = final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };

      # My workstation at home.
      nixosConfigurations.nixius = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (systemModule "nixius")
          { nixpkgs.overlays = (builtins.attrValues self.overlays); }
        ];
      };

      templates = import ./templates { };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pre-commit-check = pre-commit-hooks.defaultPackage.${system} {
          src = ./.;
          hooks = { nixfmt.enable = true; };
        };
      in {
        devShell = pkgs.mkShell {
          inherit (pre-commit-check) shellHook;
          buildInputs = [ pkgs.nixfmt ];
          runScript = "zsh";
        };
      });
}
