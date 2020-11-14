{ ... }: {
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;

  # Only change if mentioned in release notes.
  system.stateVersion = "20.09";
  system.autoUpgrade.enable = true;
}
