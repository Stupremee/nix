{
  description = "Configuration for my NixOS systems.";

  inputs = {
    unstablePkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos.url = "github:NixOS/nixpkgs/release-20.09";

    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";

    home = {
      url = "github:nix-community/home-manager/release-20.09";
      inputs.nixpkgs.follows = "unstablePkgs";
    };

    neovim.url = "github:neovim/neovim/nightly?dir=contrib";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "unstablePkgs";
    };

    rust-analyzer-overlay = {
      url = "github:Stupremee/rust-analyzer-overlay";
      inputs.nixpkgs.follows = "unstablePkgs";
    };
  };

  outputs = inputs@{ self, home, nixos, unstablePkgs, flake-utils, ... }:
    let
      inherit (nixos) lib;
      inherit (lib) recursiveUpdate attrValues;
      inherit (utils) importPkgs overlayPaths importPaths modules;

      system = "x86_64-linux";

      utils = import ./lib/utils.nix { inherit lib; };

      extraModules = [ home.nixosModules.home-manager ];
      extraOverlays = with inputs; [
        devshell.overlay
        rust-overlay.overlay
        rust-analyzer-overlay.overlay
      ];

      outputs = let
        overlays = (attrValues self.overlays) ++ extraOverlays
          ++ [ self.overlay ];

        osPkgs = importPkgs nixos overlays system;
        unstablePkgs = importPkgs unstablePkgs [ ] system;
      in {
        nixosConfigurations = import ./hosts (recursiveUpdate inputs {
          inherit lib utils extraModules system osPkgs unstablePkgs;
        });

        overlay = import ./pkgs;

        overlays = importPaths overlayPaths;

        nixosModules = modules;
      };

    in outputs;
}
