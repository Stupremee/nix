{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
    };

    hyprpolkitagent = {
      url = "github:hyprwm/hyprpolkitagent";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = ["aarch64-linux" "x86_64-linux" "aarch64-darwin"];

    nixpkgsFor = system:
      import nixpkgs {
        inherit system;
      };

    forAllSystems = fn: nixpkgs.lib.genAttrs supportedSystems (system: fn (nixpkgsFor system));
  in {
    nixosModules =
      builtins.listToAttrs (map
        (x: {
          name = x;
          value = {
            config,
            pkgs,
            lib,
            modulesPath,
            ...
          }: {
            imports = [
              (import ./modules/${x} {
                flake-self = self;
                inherit pkgs lib config modulesPath inputs nixpkgs;
              })
            ];
          };
        })
        (builtins.attrNames (builtins.readDir ./modules)))
      // {
        home = {
          config,
          pkgs,
          lib,
          modulesPath,
          ...
        }:
          import ./home {
            flake-self = self;
            inherit pkgs lib config modulesPath inputs nixpkgs;
          };
      };

    nixosConfigurations =
      builtins.listToAttrs
      (map
        (x: {
          name = x;
          value = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              flake-self = self;
            };

            modules =
              builtins.attrValues self.nixosModules
              ++ [
                inputs.disko.nixosModules.default
                inputs.home-manager.nixosModules.default

                (./machines + "/${x}/default.nix")
              ];
          };
        })
        (builtins.attrNames (builtins.readDir ./machines)));

    # Set formatter for `nix fmt` command
    formatter = forAllSystems (pkgs: pkgs.alejandra);

    overlays.default = final: prev: let
      unstable = import inputs.nixpkgs-unstable {
        inherit (final) system;
      };
    in
      {
        inherit (unstable) libinput;
      }
      // (inputs.hyprpolkitagent.overlays.default final prev)
      // (inputs.hyprland.overlays.default final prev);

    # Development shell when working on this flake
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
        ];
      };
    });
  };
}
