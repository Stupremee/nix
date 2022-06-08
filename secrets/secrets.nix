let
  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvqrTPxGmyNg2lwwJsWVOl+MGwUVQBSiy+XRgqYQo0Q stu@nixius"
  ];

  systems = {
    nether = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBne4vK09XX3lP/aA//9N0CMj9Qvw2pV0TiB1q9yWEsV root@nether";
  };

  keysForSystem = system: users ++ [ systems."${system}" ];
  keysForSystems = list: users ++ (builtins.map (s: systems."${s}") list);
  keysForAll = users ++ (builtins.attrValues systems);
in
{
  # SSL certificates
  "cert/stu-dev.me.key".publicKeys = keysForSystem "nether";
  "cert/stu-dev.me.pem".publicKeys = keysForSystem "nether";

  "password/paperless".publicKeys = keysForSystem "nether";
  "password/restic".publicKeys = keysForSystem "nether";

  "rclone.conf".publicKeys = keysForSystem "nether";
  "vaultwarden.env".publicKeys = keysForSystem "nether";
}
