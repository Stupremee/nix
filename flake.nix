{
  description = "Configuration for my NixOS systems.";

  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    stable.url = "github:NixOS/nixpkgs/release-20.09";

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
  };

  outputs = inputs@{ self, home, stable, unstable, flake-utils, ... }:
    let
      inherit (stable) lib;
      inherit (utils) pkgSet overlayPaths;

      system = "x86_64-linux";

      utils = import ./lib/utils.nix { inherit lib; };

      extraModules = [ home.nixosModules.home-manager ];
      extraOverlays = with inputs; [
        devshell.overlay
        nur.overlay
        rust-overlay.overlay
        rust-analyzer-overlay.overlay
      ];

      pkgset = pkgSet { inherit stable unstable system; };
    in { };
}
