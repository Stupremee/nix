{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../profiles/network/networkmanager.nix
    ../../profiles/network/tailscale.nix
    ../../profiles/sshd.nix

    ./caddy.nix
    ./restic.nix
  ];

  # Make aether available for deployment
  deploy.enable = true;

  # Enable vaultwarden service
  age.secrets.vaultwardenEnv = {
    file = ../../secrets/vaultwarden.ini;
    owner = "vaultwarden";
    group = "vaultwarden";
  };

  services.vaultwarden = {
    enable = true;

    environmentFile = config.age.secrets.vaultwardenEnv.path;
    config = {
      domain = "https://bw.stu-dev.me";
      signupsAllowed = false;

      rocketAddress = "127.0.0.1";
      rocketPort = 9000;
    };
  };

  # Enable impersistent state (erase your darlings)
  networking.hostId = "41c80b61";
  environment.persist.erase = false;

  # Disallow mutation of users at runtime
  users.mutableUsers = false;
  users.users.root.hashedPassword = "$6$9wEYzcg7cyqq$fH7mVhB8sbLmjKWl9nAjFYxxv9W2aUQM9/uQU41TpbXI8VF6Q6/hI16qV407NTqz0JTxnCn264OJ3gxKWj7yc.";

  # Enable podman containers backend
  virtualisation = {
    containers.enable = true;
    containers.storage.settings.storage = {
      driver = "zfs";
      graphroot = "/var/lib/containers/storage";
      runroot = "/run/containers/storage";
    };

    oci-containers.backend = "podman";

    podman = {
      enable = true;
      extraPackages = [ pkgs.zfs ];
    };
  };

  # Boot configuration
  boot = {
    initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "virtio_scsi" "xhci_pci" "sd_mod" "sr_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    loader.grub.enable = true;
    loader.grub.version = 2;
    loader.grub.devices = [ "/dev/sda" ];
  };

  # Networking
  networking = {
    useDHCP = false;
    interfaces.ens3.useDHCP = true;

    # We use our own firewall instead the one provided by hetzner
    firewall = {
      enable = true;
    };
  };

  # Mount filesystems
  fileSystems."/" = {
    device = "rpool/local/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "rpool/local/nix";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "rpool/local/boot";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/safe/home";
    fsType = "zfs";
  };

  fileSystems."/persist" = {
    device = "rpool/safe/persist";
    fsType = "zfs";
    neededForBoot = true;
  };

  swapDevices = [ ];
}
