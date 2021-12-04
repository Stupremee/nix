{ profiles, suites, modulesPath, ... }:
{
  imports = suites.base ++ suites.server ++ [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ] ++ (with profiles.nixos-hardware; [ common-pc-ssd common-pc common-cpu-amd ]);

  # Erase your darlings!
  environment.persist.erase = true;
  networking.hostId = "c2092fef";

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
