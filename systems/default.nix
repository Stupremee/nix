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
    ../nixos/zsh.nix
    ../nixos/cachix.nix

    ../nixos/modules/erase-darlings.nix
    ../nixos/modules/deploy.nix
    ../nixos/modules/backup.nix
    ../nixos/modules/age.nix
    ../nixos/modules/argo.nix
    ../nixos/modules/kanidm.nix
    ../nixos/modules/roundcube

    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.default
    inputs.hyprland.nixosModules.default
    inputs.nixos-mailserver.nixosModules.mailserver
  ];

  mkHomeModule = modules: system: theme: user: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inherit inputs system;
      theme = (import ../themes {inherit lib;})."${theme}";
      unstable-pkgs = import inputs.unstable {
        inherit system;
        config.allowUnfree = true;
      };
      packages = self.packages."${system}";
    };
    home-manager.users."${user}" = {...}: {
      # Default imports for the user
      imports =
        [
          ../home/modules/hyprland.nix

          inputs.hyprland.homeManagerModules.default
        ]
        ++ modules;
      home.stateVersion = "22.11";
    };
  };

  mkDarwinSystem = {
    system,
    modules,
    theme,
    homeModules,
    user,
  }:
    inputs.darwin.lib.darwinSystem {
      inherit system;

      modules =
        modules
        ++ [
          inputs.home-manager.darwinModules.home-manager
          (mkHomeModule homeModules system theme user)
        ];
    };

  mkSystem = {
    system,
    modules,
    home ? false,
    theme ? "",
    homeModules ? [],
    flakePath ? "",
    user ? "stu",
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules =
        [
          {
            _module.args.unstable-pkgs = import inputs.unstable {
              inherit system;
              config.allowUnfree = true;
            };
            _module.args.packages = self.packages."${system}";
            _module.args.inputs = inputs;
            _module.args.system = system;
            _module.args.flakePath = flakePath;
          }
        ]
        ++ (flatten (map (mod: [
            {disabledModules = ["${mod}.nix"];}
            "${inputs.unstable}/nixos/modules/${mod}.nix"
          ])
          overrideModules))
        ++ coreModules
        ++ modules
        ++ (optionals home [(mkHomeModule homeModules system theme user)]);
    };
in {
  flake = {
    darwinConfigurations = {
      "MacBook-Pro-von-Energiekonzepte" = mkDarwinSystem {
        system = "aarch64-darwin";
        user = "ekd";
        modules = [
          ./ekd-macbook.nix
          ../nixos/nix-daemon.nix
          ../nixos/cachix.nix
          ../nixos/zsh.nix
        ];
        theme = "latte";
        homeModules = [
          ../home/git
          ../home/zsh.nix
          ../home/editors/nvim
          ../home/dev
          ../home/pgp.nix

          inputs.nix-index-database.hmModules.nix-index
        ];
      };
    };

    nixosConfigurations = {
      ironite = mkSystem {
        system = "x86_64-linux";
        theme = "latte";
        modules = [
          ./ironite.nix
          ../nixos/server.nix
          ../nixos/containers.nix
          ../nixos/caddy.nix
          ../nixos/postgres.nix
          ../nixos/paperless.nix
          ../nixos/vaultwarden.nix
          ../nixos/mail.nix
          ../nixos/foldingathome.nix
          ../nixos/network/tailscale.nix
          ../nixos/minecraft-server.nix
        ];
        home = true;
        homeModules = [
          ../home/git
        ];
      };

      aerial = mkSystem {
        system = "x86_64-linux";
        modules = [
          ./aerial.nix
          ../nixos/fonts.nix
          ../nixos/graphical.nix
          ../nixos/containers.nix
          ../nixos/network/wifi.nix
          ../nixos/hardware/laptop.nix
          ../nixos/printing.nix
        ];
        home = true;
        theme = "frappe";
        flakePath = "/home/stu/dev/nix/nix";
        homeModules = [
          ./home/aerial.nix
          ../home/git
          ../home/wayland
          ../home/terminal/alacritty.nix
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

      baldon = mkSystem {
        system = "x86_64-linux";
        modules = [
          ./baldon.nix
          ../nixos/fonts.nix
          ../nixos/graphical.nix
          ../nixos/containers.nix
          ../nixos/printing.nix
          ../nixos/keyring.nix
          ../nixos/binfmt.nix
          ../nixos/hardware/yubikey.nix
          ../nixos/hardware/nvidia.nix
          ../nixos/network/tailscale.nix
          ../nixos/stlink.nix
          ../nixos/zsa.nix
        ];
        home = true;
        theme = "frappe";
        flakePath = "/home/stu/dev/nix/nix";
        homeModules = [
          ./home/baldon.nix
          ../home/git
          ../home/wayland
          ../home/terminal/alacritty.nix
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

      nixius = mkSystem {
        system = "x86_64-linux";
        modules = [
          ./nixius.nix
          ../nixos/fonts.nix
          ../nixos/graphical.nix
          ../nixos/hardware/yubikey.nix
          ../nixos/hardware/logitech.nix
          ../nixos/hardware/nvidia.nix
          ../nixos/containers.nix
          ../nixos/network/tailscale.nix
        ];
        home = true;
        theme = "frappe";
        flakePath = "/home/stu/dev/nix/nix";
        homeModules = [
          ./home/nixius.nix
          ../home/git
          ../home/wayland
          ../home/terminal/alacritty.nix
          ../home/pgp.nix
          ../home/xdg.nix
          ../home/zsh.nix
          ../home/tmux.nix
          ../home/graphical/spotify.nix
          ../home/editors/nvim
          ../home/graphical
          ../home/dev

          inputs.nix-index-database.hmModules.nix-index
        ];
      };

      argon = mkSystem {
        system = "x86_64-linux";
        modules = [
          ./argon
          ../nixos/fonts.nix
          ../nixos/graphical.nix
          ../nixos/hardware/yubikey.nix
          ../nixos/hardware/logitech.nix
          ../nixos/hardware/amd-gpu.nix
          ../nixos/containers.nix
          ../nixos/network/tailscale.nix
        ];
        home = true;
        theme = "latte";
        flakePath = "/home/stu/dev/nix/nix";
        homeModules = [
          ./home/argon.nix
          ../home/git
          ../home/wayland
          ../home/terminal/alacritty.nix
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
  };
}
