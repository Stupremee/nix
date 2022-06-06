# Module for configuring the nix-daemon
{ ... }: {
  nix = {
    allowedUsers = [ "@wheel" ];
    trustedUsers = [ "root" "@wheel" ];

    autoOptimiseStore = true;
    optimise = {
      automatic = true;
      dates = [ "11:00" ];
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
