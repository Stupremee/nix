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

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
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
      inputs.darwin.follows = "nix-darwin";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
    };

    catppuccin.url = "github:catppuccin/nix";

    impermanence.url = "github:nix-community/impermanence";

    just-flake.url = "github:juspay/just-flake";
  };

  outputs =
    inputs:
    inputs.nixos-unified.lib.mkFlake {
      inherit inputs;
      systems = import inputs.systems;
      root = ./.;
    };
}
