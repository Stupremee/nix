{
  config,
  pkgs,
  lib,
  flake,
  ...
}:
with lib;
let
  cfg = config.my.nh;
in
{
  options.my.nh = {
    enable = mkEnableOption "Enable the NH cli helper";

    isRemoteBuilder = mkOption {
      type = types.bool;
      description = "Indicates if this machine is used as a remote builder.";
      default = false;
    };

    flakePath = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 10";
      clean.dates = if cfg.isRemoteBuilder then "daily" else "weekly";
      flake = cfg.flakePath;
    };

    nix.settings.gc.automatic = mkForce false;
  };
}
