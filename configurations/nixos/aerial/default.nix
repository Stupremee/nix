{ flake, ... }:
{
  imports = with flake.inputs; [
    self.nixosModules.default

    ./disks.nix
  ];

  my = {
    desktop.enable = true;
    wayland.hyprland.enable = true;

    nix-common = {
      maxJobs = 8;
      flakePath = "/home/stu/dev/nix/nix";
    };
  };

  networking = {
    hostName = "aerial";
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
      ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
    enableAllFirmware = true;
  };

  # nixpkgs meta related options
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";
}
