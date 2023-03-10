let
  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMyNWZe1K8/5yebGKey+yjJcASH7qZg6E24OPTj8veLN stu@nixius"
  ];

  systems = {
    nether = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBne4vK09XX3lP/aA//9N0CMj9Qvw2pV0TiB1q9yWEsV root@nether";
    nixius = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFefmq/NK8J6q0Mf/6Gka3QeVOvAyljGlHLtC62WV81d root@nixius";
    ironite = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDo+vwZL8/jfJpRzTjhBKwHC7HfKJLP5ffXiOse5HOAo root@ironite";
  };

  keysForSystem = system: users ++ [systems."${system}"];
  keysForSystems = list: users ++ (builtins.map (s: systems."${s}") list);
in {
  # SSL certificates
  "cert/stu-dev.me.key".publicKeys = keysForSystem "nether";
  "cert/stu-dev.me.pem".publicKeys = keysForSystem "nether";

  "password/paperless".publicKeys = keysForSystems ["nether" "ironite"];
  "password/restic".publicKeys = keysForSystems ["nether" "ironite"];
  "password/keycloakDatabase".publicKeys = keysForSystem "ironite";

  "rclone.conf".publicKeys = keysForSystems ["nether" "ironite"];
  "vaultwarden.env".publicKeys = keysForSystems ["nether" "ironite"];

  "spotify".publicKeys = keysForSystem "nixius";
  "esyvpn.ovpn".publicKeys = keysForSystem "nixius";

  "argotunnel.json".publicKeys = keysForSystem "ironite";
}
