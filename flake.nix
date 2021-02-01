{
  description = "Configuration for my NixOS systems.";

  inputs = {
    unstable.url = "github:NixOS/nixpkgs/master";
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    home.url = "github:nix-community/home-manager/release-20.09";

    neovim.url = "github:neovim/neovim/nightly?dir=contrib";
    nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
  };

  outputs =
    inputs@{ self
    , unstable
    , nixos
    , flake-utils
    , devshell
    , home
    , neovim
    , nixpkgs-wayland
    }:
    let
      inherit (self.lib) nixosModules importPaths overlayPaths importPkgs;
      inherit (flake-utils.lib) eachDefaultSystem;
      inherit (nixos.lib) recursiveUpdate;
      inherit (builtins) attrValues;

      extraModules = [ home.nixosModules.home-manager ];
      extraOverlays = [
        devshell.overlay
        nixpkgs-wayland.overlay
        neovim.overlay
      ];

      outputs =
        let
          system = "x86_64-linux";
          pkgs = self.legacyPackages."${system}";
        in
        {
          inherit nixosModules;

          nixosConfigurations = import ./hosts (recursiveUpdate inputs {
            inherit pkgs extraModules system;
            inherit (pkgs) lib;
          });

          overlay = import ./pkgs;
          overlays = importPaths overlayPaths;
          lib = import ./lib {
            inherit (nixos) lib;
          };
        };

    in
    recursiveUpdate
      (eachDefaultSystem (system:
      let
        unstablePkgs = importPkgs unstable [ ] system;
        pkgs =
          let
            override = import ./pkgs/override.nix;
            overlays = [
              (override unstablePkgs)
              self.overlay
              (final: prev: {
                lib = (prev.lib or { }) // {
                  inherit (nixos.lib) nixosSystem;
                  flk = self.lib;
                  utils = flake-utils.lib;
                };
              })
            ]
            ++ (attrValues self.overlays) ++ extraOverlays;
          in
          importPkgs nixos overlays system;
      in
      {
        legacyPackages = pkgs;

        devShell = import ./shell { inherit pkgs nixos; };
      }))
      outputs;
}
