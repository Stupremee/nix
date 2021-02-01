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
    nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
  };

  outputs = inputs@{ self, home, nixos, unstable, flake-utils, ... }:
    let
      inherit (flake-utils.lib) eachDefaultSystem;
      inherit (nixos) lib;
      inherit (lib) recursiveUpdate attrValues;
      inherit (utils) importPkgs overlayPaths importPaths modules;

      utils = import ./lib/utils.nix { inherit lib; };

      extraModules = [ home.nixosModules.home-manager ];
      extraOverlays = with inputs; [
        devshell.overlay
        nixpkgs-wayland.overlay
        neovim.overlay
      ];

      outputs = let
        system = "x86_64-linux";
        pkgs = self.legacyPackages."${system}";
      in {
        nixosConfigurations = import ./hosts (recursiveUpdate inputs {
          inherit lib utils extraModules system pkgs;
        });

        overlay = import ./pkgs;

        overlays = importPaths overlayPaths;

        nixosModules = modules;
      };

    in recursiveUpdate (eachDefaultSystem (system:
      let
        unstablePkgs = importPkgs unstable [ ] system;
        pkgs = let
          override = import ./pkgs/override.nix;
          overlays = [ (override unstablePkgs) self.overlay ]
            ++ (attrValues self.overlays) ++ extraOverlays;
        in importPkgs nixos overlays system;
      in {
        legacyPackages = pkgs;

        devShell = import ./shell { inherit pkgs nixos; };
      })) outputs;
}
