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
      inherit (lib) recursiveUpdate;
      inherit (utils) pkgSet overlayPaths importPaths modules;

      system = "x86_64-linux";

      utils = import ./lib/utils.nix { inherit lib; };

      extraModules = [ home.nixosModules.home-manager ];
      extraOverlays = with inputs; [
        devshell.overlay
        nur.overlay
        rust-overlay.overlay
        rust-analyzer-overlay.overlay
      ];

      outputs = let
        overlays = extraOverlays ++ self.overlays ++ [ self.overlay ];
        pkgset = pkgSet { inherit stable unstable system overlays; };
      in {
        nixosConfigurations = import ./hosts
          (recursiveUpdate inputs { inherit lib utils extraModules system; });

        overlay = import ./pkgs;

        overlays = importPaths overlayPaths;

        nixosModules = modules;
      };

    in outputs;
}
