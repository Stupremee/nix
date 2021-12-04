{
  description = "A highly structured configuration database.";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters = "https://stx.cachix.org https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "stx.cachix.org-1:mCLmdjTaKn3704lctpvqOgc0uvmu0NnIUP3/d5g2aZ0= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs =
    {
      nixos.url = "github:nixos/nixpkgs/release-21.11";
      latest.url = "github:nixos/nixpkgs/nixos-unstable";

      digga.url = "github:divnix/digga";
      digga.inputs.nixpkgs.follows = "nixos";
      digga.inputs.nixlib.follows = "nixos";
      digga.inputs.home-manager.follows = "home";

      bud.url = "github:divnix/bud";
      bud.inputs.nixpkgs.follows = "nixos";
      bud.inputs.devshell.follows = "digga/devshell";

      home.url = "github:nix-community/home-manager/release-21.05";
      home.inputs.nixpkgs.follows = "nixos";

      darwin.url = "github:LnL7/nix-darwin";
      darwin.inputs.nixpkgs.follows = "latest";

      deploy.follows = "digga/deploy";

      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "latest";

      nvfetcher.url = "github:berberman/nvfetcher";
      nvfetcher.inputs.nixpkgs.follows = "latest";
      nvfetcher.inputs.flake-compat.follows = "digga/deploy/flake-compat";
      nvfetcher.inputs.flake-utils.follows = "digga/flake-utils-plus/flake-utils";

      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "latest";

      nixos-hardware.url = "github:nixos/nixos-hardware";
    };

  outputs =
    { self
    , digga
    , bud
    , nixos
    , home
    , nixos-hardware
    , nur
    , agenix
    , nvfetcher
    , deploy
    , ...
    } @ inputs:
    digga.lib.mkFlake
      {
        inherit self inputs;

        channelsConfig = { allowUnfree = true; };

        channels = {
          nixos = {
            imports = [ (digga.lib.importOverlays ./overlays) ];
            overlays = [
              nur.overlay
              agenix.overlay
              nvfetcher.overlay
              ./pkgs/default.nix
            ];
          };
          latest = {
            overlays = [
              deploy.overlay
            ];
          };
        };

        lib = import ./lib { lib = digga.lib // nixos.lib; };

        sharedOverlays = [
          (final: prev: {
            __dontExport = true;
            lib = prev.lib.extend (lfinal: lprev: {
              our = self.lib;
            });
          })
        ];

        nixos = {
          hostDefaults = {
            system = "x86_64-linux";
            channelName = "nixos";
            imports = [ (digga.lib.importExportableModules ./modules) ];
            modules = [
              { lib.our = self.lib; }
              digga.nixosModules.bootstrapIso
              digga.nixosModules.nixConfig
              home.nixosModules.home-manager
              agenix.nixosModules.age
              bud.nixosModules.bud
            ];
          };

          imports = [ (digga.lib.importHosts ./hosts) ];
          hosts = {
            /* set host specific properties here */
            NixOS = { };
          };
          importables = rec {
            profiles = digga.lib.rakeLeaves ./profiles // {
              nixos-hardware = nixos-hardware.nixosModules;
              users = digga.lib.rakeLeaves ./users;
            };
            suites = with profiles; rec {
              base = [ core users.nixos users.root network.networkmanager network.tailscale ];
              server = [ network.ssh ];
            };
          };
        };

        home = {
          imports = [ (digga.lib.importExportableModules ./users/modules) ];
          modules = [ ];
          importables = rec {
            profiles = digga.lib.rakeLeaves ./users/profiles;
            suites = with profiles; rec {
              base = [ direnv git ];
            };
          };
          users = {
            nixos = { suites, ... }: { imports = suites.base; };
          }; # digga.lib.importers.rakeLeaves ./users/hm;
        };

        devshell = ./shell;

        homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

        deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations {
          fiber = {
            sshUser = "root";
          };
        };

        defaultTemplate = self.templates.bud;
        templates.bud.path = ./.;
        templates.bud.description = "bud template";

      }
    //
    {
      budModules = { devos = import ./bud; };
    }
  ;
}
