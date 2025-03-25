{
  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixos-unified = {
      url = "github:srid/nixos-unified";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
    };

    catppuccin.url = "github:catppuccin/nix";

    impermanence.url = "github:nix-community/impermanence";

    flake-root.url = "github:srid/flake-root";

    mission-control.url = "github:Platonic-Systems/mission-control";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        ...
      }:
      {
        imports = [
          inputs.treefmt-nix.flakeModule
          inputs.nixos-unified.flakeModules.default
          ./modules
          ./machines
          ./devshell.nix
          ./packages
        ];

        systems = import inputs.systems;

        flake = {
          overlays.default = final: prev: {
            caddy = self.packages.${final.system}.caddy;
          };
        };

        perSystem =
          {
            pkgs,
            system,
            lib,
            ...
          }:
          {
            # Make our overlay available to the devShell
            # "Flake parts does not yet come with an endorsed module that initializes the pkgs argument.""
            # So we must do this manually; https://flake.parts/overlays#consuming-an-overlay
            _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
            };

            # Select all inputs as primary inputs, to make them update
            nixos-unified = {
              primary-inputs = builtins.attrNames inputs;
            };

            treefmt = {
              projectRootFile = "flake.nix";

              programs.nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rfc-style;
              };
              programs.shfmt.enable = true;

              settings.global.excludes = [
                ".envrc"
                ".editorconfig"
                "README.md"
                "LICENSE"
                "*.png"
                "packages/caddy/src/*"
                "secrets/*"
              ];
            };
          };
      }
    );
}
