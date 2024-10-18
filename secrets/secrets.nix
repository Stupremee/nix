let
  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJqATr5SfHhUcyMfqrBBCrLM33Ax2u4FiQMiUPi37jkP stu@Stus-MacBook-3.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGfOv1f0ltBXJRN1DJSMzEIjWJ8Ty2LdPeOJowDTk4B stu@baldon"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0ACjf5QdZyZxmWvTwAhFZSH6yJJOynmdbz9BXxmRYm stu@argon"
  ];

  systems = {
    nether = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBne4vK09XX3lP/aA//9N0CMj9Qvw2pV0TiB1q9yWEsV root@nether";
    nixius = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFefmq/NK8J6q0Mf/6Gka3QeVOvAyljGlHLtC62WV81d root@nixius";
    ironite = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDo+vwZL8/jfJpRzTjhBKwHC7HfKJLP5ffXiOse5HOAo root@ironite";
    baldon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBlIP0divnspBrYWh2460kKVKjSes4q8ECrSkv3SDWB/ root@baldon";
  };

  keysForSystem = system: users ++ [systems."${system}"];
  keysForSystems = list: users ++ (builtins.map (s: systems."${s}") list);
in {
  # SSL certificates
  "cert/stu-dev.me.key".publicKeys = keysForSystems ["nether" "ironite"];
  "cert/stu-dev.me.pem".publicKeys = keysForSystems ["nether" "ironite"];

  "cert/localhost.key".publicKeys = keysForSystems ["ironite"];
  "cert/localhost.pem".publicKeys = keysForSystems ["ironite"];

  "password/paperless".publicKeys = keysForSystems ["nether" "ironite"];
  "password/restic".publicKeys = keysForSystems ["nether" "ironite"];
  "password/mail-at-stu-dev.me".publicKeys = keysForSystem "ironite";
  "password/docs-at-stu-dev.me".publicKeys = keysForSystem "ironite";
  "password/monitoring-at-stu-dev.me".publicKeys = keysForSystem "ironite";
  "password/grafana-admin".publicKeys = keysForSystem "ironite";

  "rclone.conf".publicKeys = keysForSystems ["nether" "ironite"];
  "vaultwarden.env".publicKeys = keysForSystems ["nether" "ironite"];

  "esyvpn.ovpn".publicKeys = keysForSystem "nixius";

  "enqs.ovpn".publicKeys = keysForSystem "baldon";

  "curseforge.env".publicKeys = keysForSystem "ironite";

  "coolify.env".publicKeys = keysForSystem "ironite";
}
