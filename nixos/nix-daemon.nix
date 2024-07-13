# Module for configuring the nix-daemon
{
  config,
  lib,
  ...
}: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      allowed-users = ["@wheel"];
      trusted-users = ["root" "@wheel" "ekd"];
      auto-optimise-store = lib.mkDefault true;
      log-lines = 50;
    };
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = lib.mkDefault "22.11";
}
