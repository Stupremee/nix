{lib, ...}: {
  imports = [
    ./disks.nix
  ];

  networking.hostName = "nether";

  modules.deploy.enable = true;

  services.tailscale.useRoutingFeatures = lib.mkForce "server";
  services.vaultwarden.config.domain = "https://bw2.stu-dev.me";

  environment.persistence."/persist" = {
    enable = true;

    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/tailscale"
      "/var/lib/caddy"
      "/root"
    ];

    files = [
      "/etc/machine-id"
    ];
  };
  fileSystems."/persist".neededForBoot = true;

  services.openssh.hostKeys = [
    {
      path = "/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
    {
      path = "/persist/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
      bits = 4096;
    }
  ];

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /mnt
    mount -t btrfs /dev/sda2  /mnt
    btrfs subvolume delete /mnt/rootfs
    btrfs subvolume snapshot /mnt/rootfs-blank /mnt/rootfs
  '';

  # Mutable users are not required on this server
  users.mutableUsers = false;

  system.stateVersion = "24.11";
}
