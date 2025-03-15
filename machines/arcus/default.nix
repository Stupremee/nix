{ ... }:
{
  imports = [
    ./disks.nix
  ];

  my = {
    desktop.enable = true;
    wayland.hyprland.enable = true;

    home = {
      enable = true;
      import = ./home.nix;
    };

    persist = {
      enable = true;
      btrfs = {
        enable = true;
        disk = "/dev/disk/by-partlabel/disk-system-root";
      };
    };

    nix-common = {
      maxJobs = 8;
      flakePath = "/home/stu/dev/nix/nix";
    };
  };

  networking = {
    hostName = "arcus";
  };

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
      };
    };

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "rtsx_usb_sdmmc"
      ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
    enableAllFirmware = true;
  };

  # nixpkgs meta related options
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
}
