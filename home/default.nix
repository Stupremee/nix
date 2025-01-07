{
  config,
  pkgs,
  lib,
  flake-self,
  ...
}:
with lib; let
  cfg = config.my.home;
in {
  options.my.home = {
    enable = mkEnableOption "Enable home manager";

    user = mkOption {
      type = types.str;
      default = "stu";
    };

    import = mkOption {
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    # Do not use useGlobalPackages
    home-manager.useUserPackages = true;

    home-manager.users."${cfg.user}" = {
      imports =
        (map (p: ./modules/${p}) (builtins.attrNames (builtins.readDir ./modules)))
        ++ [
          flake-self.inputs.catppuccin.homeManagerModules.catppuccin

          {
            nixpkgs.overlays = [
              flake-self.overlays.default
            ];
          }
          ./common.nix

          cfg.import
        ];

      nixpkgs.config = {
        allowBroken = true;
        allowUnfree = false;
      };
    };
  };
}
