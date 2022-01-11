{
  description = "Configuration for my NixOS systems.";

  inputs = {
    unstable.url = "github:NixOS/nixpkgs/master";
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    home.url = "github:nix-community/home-manager";
    rust-overlay.url = "github:oxalica/rust-overlay";
    impermanence.url = "github:nix-community/impermanence";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    agenix.url = "github:ryantm/agenix";
    deploy-rs.url = "github:serokell/deploy-rs";

    mail-server.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
  };

  outputs =
    inputs@{ self
    , unstable
    , nixos
    , flake-utils
    , devshell
    , home
    , nixpkgs-wayland
    , agenix
    , rust-overlay
    , impermanence
    , deploy-rs
    , mail-server
    }:
    let
      inherit (self.lib) nixosModules importPaths overlayPaths importPkgs;
      inherit (flake-utils.lib) eachDefaultSystem;
      inherit (nixos.lib) recursiveUpdate;
      inherit (builtins) attrValues;

      extraModules = [
        home.nixosModules.home-manager
        # agenix.nixosModules.age
        impermanence.nixosModules.impermanence
        mail-server.nixosModules.mailserver
      ];

      extraOverlays = [
        devshell.overlay
        nixpkgs-wayland.overlay
        agenix.overlay
        rust-overlay.overlay
      ];

      outputs =
        let
          inherit (builtins) attrValues mapAttrs filterAttrs;
          system = "x86_64-linux";
          pkgs = self.legacyPackages."${system}";
        in
        {
          inherit nixosModules;

          nixosConfigurations = import ./hosts (recursiveUpdate inputs {
            inherit pkgs extraModules system rust-overlay;
            inherit (pkgs) lib;
          });

          overlay = import ./pkgs;
          overlays = importPaths overlayPaths;
          lib = import ./lib {
            inherit (nixos) lib;
          };

          # Deploy-rs checks and nodes
          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
          deploy = {
            magicRollback = true;
            autoRollback = true;

            nodes = builtins.mapAttrs
              (_: nixosConfig: {
                hostname =
                  if builtins.isNull nixosConfig.config.deploy.ip
                  # Connection through Tailscale using MagicDNS
                  then "${nixosConfig.config.networking.hostName}"
                  else "${nixosConfig.config.deploy.ip}";

                profiles.system = {
                  user = "root";
                  sshUser = "root";
                  path = deploy-rs.lib.${system}.activate.nixos nixosConfig;
                };
              })
              (nixos.lib.filterAttrs
                (_: v: v.config.deploy.enable)
                self.nixosConfigurations);
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
            ++ extraOverlays ++ (attrValues self.overlays);
          in
          importPkgs nixos overlays system;
      in
      {
        legacyPackages = pkgs;

        devShell = import ./shell { inherit pkgs nixos deploy-rs system; };
      }))
      outputs;
}
