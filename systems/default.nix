{
  lib,
  inputs,
  self,
  ...
}: let
  inherit (builtins) map;
  inherit (lib) optionals flatten;

  overrideModules = [
    "services/misc/paperless"
  ];

  coreModules = [
    ../nixos/nix-daemon.nix
    ../nixos/users.nix
    ../nixos/network/sshd.nix
    ../nixos/network/network.nix
    ../nixos/network/tailscale.nix
    ../nixos/zsh.nix
    ../nixos/cachix.nix

    ../nixos/modules/erase-darlings.nix
    ../nixos/modules/deploy.nix
    ../nixos/modules/tailscale.nix
    ../nixos/modules/backup.nix
    ../nixos/modules/age.nix
    ../nixos/modules/argo.nix
    ../nixos/modules/kanidm.nix
    ../nixos/modules/roundcube

    inputs.agenix.nixosModules.default
    inputs.home-manager.nixosModules.default
    inputs.hyprland.nixosModules.default
    inputs.nixos-mailserver.nixosModules.mailserver
  ];

  mkHomeModule = modules: system: theme: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inherit inputs system;
      theme = (import ../themes {inherit lib;})."${theme}";
      unstable-pkgs = inputs.unstable.legacyPackages."${system}";
      packages = self.packages."${system}";
    };
    home-manager.users.stu = {...}: {
      # Default imports for the user
      imports =
        [
          inputs.hyprland.homeManagerModules.default
        ]
        ++ modules;
      home.stateVersion = "22.11";
    };
  };

  mkSystem = {
    system,
    modules,
    home ? false,
    theme ? "",
    homeModules ? [],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules =
        [
          {
            _module.args.unstable-pkgs = inputs.unstable.legacyPackages."${system}";
            _module.args.packages = self.packages."${system}";
            _module.args.inputs = inputs;
            _module.args.system = system;
          }
        ]
        ++ (flatten (map (mod: [
            {disabledModules = ["${mod}.nix"];}
            "${inputs.unstable}/nixos/modules/${mod}.nix"
          ])
          overrideModules))
        ++ coreModules
        ++ modules
        ++ (optionals home [(mkHomeModule homeModules system theme)]);
    };
in {
  flake.nixosConfigurations = {
    ironite = mkSystem {
      system = "x86_64-linux";
      modules = [
        ./ironite.nix
        ../nixos/server.nix
        ../nixos/containers.nix
        ../nixos/postgres.nix
        ../nixos/paperless.nix
        ../nixos/vaultwarden.nix
        ../nixos/mail.nix
        ../nixos/foldingathome.nix
      ];
      home = true;
      homeModules = [
        ../home/git.nix
      ];
    };

    nixius = mkSystem {
      system = "x86_64-linux";
      modules = [
        ./nixius.nix
        ../nixos/fonts.nix
        ../nixos/graphical.nix
        ../nixos/hardware/yubikey.nix
        ../nixos/hardware/logitech.nix
        ../nixos/containers.nix
      ];
      home = true;
      theme = "frappe";
      homeModules = [
        ../home/git.nix
        ../home/wayland
        ../home/alacritty.nix
        ../home/pgp.nix
        ../home/xdg.nix
        ../home/zsh.nix
        ../home/tmux.nix
        ../home/editors/nvim
        ../home/graphical
        ../home/dev

        inputs.nix-index-database.hmModules.nix-index
      ];
    };
  };
}
