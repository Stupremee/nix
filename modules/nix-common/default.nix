{
  config,
  pkgs,
  lib,
  flake-self,
  nixpkgs,
  ...
}:
with lib; let
  cfg = config.my.nix-common;
in {
  options.my.nix-common = {
    enable = mkEnableOption "Enable default settings for nix-daemon";

    maxJobs = mkOption {
      type = types.int;
      default = 4;
    };

    flakePath = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [flake-self.overlays.default];

    # Allow unfree licenced packages
    nixpkgs.config.allowUnfree = true;

    nix = {
      nixPath = ["nixpkgs=${nixpkgs}"];

      extraOptions = ''
        experimental-features = nix-command flakes
      '';

      settings = {
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
          "https://devenv.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
        ];

        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        ];

        allowed-users = ["root"];
        trusted-users = ["root"];

        auto-optimise-store = true;
        log-lines = 50;

        max-jobs = cfg.maxJobs;
      };

      # Clean up old generations after 30 days
      gc = {
        automatic = !config.programs.nh.clean.enable;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 10";
      flake = cfg.flakePath;
    };

    system.activationScripts.update-diff = {
      supportsDryActivation = true;
      text = ''
        if [[ -e /run/current-system ]]; then
          echo "--- diff to current-system"
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
          echo "---"
        fi
      '';
    };

    # Let 'nixos-version --json' know the Git revision of this flake.
    system.configurationRevision =
      nixpkgs.lib.mkIf (flake-self ? rev) flake-self.rev;

    nix.registry.nixpkgs.flake = nixpkgs;
    nix.registry.my.flake = flake-self;
  };
}
