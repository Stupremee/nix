{
  lib,
  pkgs,
  ...
}: {
  services.nix-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    colima
    docker
    gnupg
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  users.users = {
    ekd = {
      home = "/Users/ekd";
    };
  };

  # Disable this on MacOS, as this seems to cause some issues
  # https://github.com/NixOS/nix/issues/7273
  nix.settings. auto-optimise-store = false;

  system.stateVersion = lib.mkForce 4;
}
