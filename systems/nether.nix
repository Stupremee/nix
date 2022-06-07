{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Hostname and HostId
  networking.hostName = "nether";
  networking.hostId = "833697eb";

  modules.deploy.enable = true;

  # Erase `/` on every boot
  modules.eraseDarlings.enable = true;
  modules.eraseDarlings.machineId = "0976479ac02a6a7e51216d6e347729de";

  # Boot configuration
  boot = {
    initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sd_mod" "sr_mod" ];
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
    interfaces.enp1s0.useDHCP = true;

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
