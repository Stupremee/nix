# Module for configuring the nix-daemon
{
  config,
  lib,
  ...
}: {
  age.secrets.netrc.file = ../secrets/netrc;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      allowed-users = ["@wheel"];
      trusted-users = ["root" "@wheel" "ekd"];
      auto-optimise-store = lib.mkDefault true;
      log-lines = 50;
      netrc-file = config.age.secrets.netrc.path;
    };
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = lib.mkDefault "22.11";
}
