# Module for configuring the nix-daemon
{...}: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      allowed-users = ["@wheel"];
      trusted-users = ["root" "@wheel"];
      auto-optimise-store = true;
    };

    optimise = {
      automatic = true;
      dates = ["11:00"];
    };

    gc = {
      automatic = true;
      # Run garbage collector every sunday at 1PM
      dates = "Sun 13:00";
    };
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.05";
}
