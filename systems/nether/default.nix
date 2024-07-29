{...}: {
  imports = [
    ./disks.nix
  ];

  networking.hostName = "nether";

  # Mutable users are not required on this server
  users.mutableUsers = false;
}
