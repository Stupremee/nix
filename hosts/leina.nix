# My Thinkpad Laptop.
{ lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/network/networkmanager.nix
  ];

  # Limit max jobs to 4, because the PC only has 4 CPUs
  nix.maxJobs = lib.mkDefault 4;

  # Enable networking
  networking = {
    networkmanager.enable = true;

    # Disable the global `useDHCP` variable, and set it true for
    # each interface individually
    useDHCP = false;
    interfaces.enp0s31f6.useDHCP = true;
    interfaces.wlp4s0.useDHCP = true;
  };

  # Kernel and boot configuration
  boot = {
    initrd = {
      availableKernelModules =
        [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    # Configure the GRUB bootloader
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
  };

  # Filesystem configuration
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/69297b2f-833b-4773-8448-bf2bda6e03a1";
    fsType = "ext4";
  };
  swapDevices =
    [{ device = "/dev/disk/by-uuid/dc613bd4-69fb-4877-aef1-df91347f33bd"; }];

  # Hardware configuration
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware = {
    video.hidpi.enable = lib.mkDefault true;
    cpu.intel.updateMicrocode = true;
    # Required to make the WIFI card work
    enableRedistributableFirmware = true;
  };
}
