{
  description = "Configuration for my NixOS systems.";

  inputs = {
    unstable.url = "github:NixOS/nixpkgs/master";
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";

    home = {
      url = "github:nix-community/home-manager/release-20.09";
      inputs.nixpkgs.follows = "unstable";
    };

    neovim.url = "github:neovim/neovim/nightly?dir=contrib";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "unstable";
    };

    rust-analyzer-overlay = {
      url = "github:Stupremee/rust-analyzer-overlay";
      inputs.nixpkgs.follows = "unstable";
    };

    nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
  };

  outputs = inputs@{ self, home, nixos, unstable, flake-utils, ... }:
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
        inputs.nixpkgs-wayland.overlay
      ];

      pkgs' = unstable:
        let
          override = import ./pkgs/override.nix;
          overlays = (attrValues self.overlays) ++ extraOverlays
            ++ [ self.overlay (override unstable) ];
        in importPkgs nixos overlays system;

      unstablePkgs = importPkgs unstablePkgs [ ] system;

      outputs = let
        unstablePkgs = importPkgs unstable [ ] system;
        osPkgs = pkgs' unstablePkgs;
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
