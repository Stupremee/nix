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

  system.stateVersion = lib.mkForce 4;
}
