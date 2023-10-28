# Module for configuring the nix-daemon
{lib, ...}: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      allowed-users = ["@wheel"];
      trusted-users = ["root" "@wheel" "ekd"];
      auto-optimise-store = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = lib.mkDefault "22.11";
}
