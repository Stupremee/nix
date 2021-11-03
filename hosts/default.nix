{ self
, lib
, system
, home
, extraModules
, pkgs
, unstable
, nixos
, rust-overlay
, ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib.flk) recImports recImport;

  createSystem = hostName:
    lib.nixosSystem {
      inherit system;

      modules =
        let
          core = self.nixosModules.profiles.core;

          global = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            networking.hostName = hostName;
            nix.nixPath =
              let path = toString ../.;
              in
              [
                "nixos-unstable=${unstable}"
                "nixpkgs=${nixos}"
                "nixpkgs-overlays=${path}/overlays"
                "home-manager=${home}"
              ];

            nixpkgs.pkgs = pkgs;

            nix.registry = {
              unstable.flake = unstable;
              nixpkgs.flake = nixos;
              home-manager.flake = home;
              rust.flake = rust-overlay;
            };

            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          local =
            let
              path = "${toString ./.}/${hostName}";
              filePath = "${path}.nix";
            in
            if lib.pathIsRegularFile filePath then
              import "${path}.nix"
            else
              import "${path}";

          flakeModules =
            attrValues (removeAttrs self.nixosModules [ "profiles" ]);
        in
        flakeModules ++ [ core global local ] ++ extraModules;
    };

  hosts = recImport {
    dir = ./.;
    _import = createSystem;
  };
in
hosts
