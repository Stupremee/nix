{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../profiles/network/networkmanager.nix
    ../profiles/network/vpn.nix
    ../profiles/sshd.nix
  ];

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
  };

  # Mount filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/45afa7ac-dbac-4c44-8bd7-00dbd66c9d2b";
    fsType = "ext4";
  };

  swapDevices = [ ];
}
