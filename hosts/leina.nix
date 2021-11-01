# My Thinkpad Laptop.
{ lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/network/networkmanager.nix
    ../profiles/network/tailscale.nix
    ../profiles/laptop.nix
    ../profiles/yubikey.nix
    ../profiles/sshd.nix
    ../profiles/graphical
    ../profiles/graphical/sway.nix
    ../users/stu-laptop.nix
  ];

  # Limit max jobs to 4, because the PC only has 4 CPUs
  nix.maxJobs = lib.mkDefault 4;

  # Add Nixius workstation as remote builder
  nix.buildMachines = [{
    hostName = "nixius";
    system = "x86_64-linux";
    maxJobs = 16;
    speedFactor = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
  }];
  nix.distributedBuilds = true;

  # Optional, useful when the builder has a faster internet connection than yours
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  # Enable networking
  networking = {
    networkmanager.enable = true;

    # Disable the global `useDHCP` variable, and set it true for
    # each interface individually
    useDHCP = false;
    interfaces.enp0s31f6.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
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
  };
}
