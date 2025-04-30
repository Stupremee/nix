{
  config,
  pkgs,
  lib,
  flake,
  ...
}:
with lib;
let
  cfg = config.my.nix-common;
in
{
  options.my.nix-common = {
    enable = mkEnableOption "Enable default settings for nix-daemon";

    maxJobs = mkOption {
      type = types.int;
      default = 4;
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ flake.inputs.self.overlays.default ];

    # Allow unfree licenced packages
    nixpkgs.config.allowUnfree = true;

    nix = {
      nixPath = [
        "nixpkgs=${flake.inputs.nixpkgs}"
        "nixpkgs-unstable=${flake.inputs.nixpkgs-unstable}"
      ];

      extraOptions = ''
        experimental-features = nix-command flakes
      '';

      settings = {
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
          "https://devenv.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
          "https://cache.flakehub.com/"
        ];

        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="

          # FlakeHub
          "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
          "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
          "cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU="
          "cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU="
          "cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8="
          "cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ="
          "cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o="
          "cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y="
        ];

        allowed-users = [ "root" ];
        trusted-users = [ "root" ];

        # Disable this on MacOS, as this seems to cause some issues
        # https://github.com/NixOS/nix/issues/7273
        auto-optimise-store = !pkgs.stdenv.isDarwin;
        log-lines = 50;

        max-jobs = cfg.maxJobs;
      };

      # Clean up old generations after 30 days
      gc = {
        automatic = mkDefault true;
        options = "--delete-older-than 30d";
      };
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
    system.configurationRevision = lib.mkIf (flake.inputs.self ? rev) flake.inputs.self.rev;

    nix.registry = {
      nixpkgs.flake = flake.inputs.nixpkgs;
      nixpkgs-unstable.flake = flake.inputs.nixpkgs-unstable;
      my.flake = flake.inputs.self;
    };
  };
}
