{
  inputs = {
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

    catppuccin.url = "github:catppuccin/nix";

    impermanence.url = "github:nix-community/impermanence";

    flake-root.url = "github:srid/flake-root";

    mission-control.url = "github:Platonic-Systems/mission-control";
  };

  outputs =
    inputs@{
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
        ];

        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];

        flake = {
          overlays.default = final: prev: { };
        };

        perSystem =
          {
            inputs,
            pkgs,
            system,
            self',
            ...
          }:
          {
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

              settings.global.excludes = [
                ".envrc"
                ".editorconfig"
                "README.md"
                "LICENSE"
                "*.png"
              ];
            };
          };
      }
    );
}
