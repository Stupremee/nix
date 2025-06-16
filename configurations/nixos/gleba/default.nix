{
  flake,
  lib,
  pkgs,
  ...
}:
{
  imports = with flake.inputs; [
    self.nixosModules.default
    lanzaboote.nixosModules.lanzaboote
  ];

  my = {
    desktop.enable = true;
    wayland.hyprland.enable = true;
    bluetooth.enable = true;

    nix-common.maxJobs = 8;
    nh = {
      enable = true;
      flakePath = "/home/stu/dev/nix/nix";
    };

    amdgpu.enable = true;
    laptop.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pkgs.sbctl
  ];

  networking = {
    hostName = "gleba";
  };

  boot = {
    # Enable secure boot
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";

      settings.reboot-for-bitlocker = "1";
    };

    loader = {
      efi.canTouchEfiVariables = true;

      # Disable, because lanzaboote replaces the systemd-boot module
      systemd-boot.enable = lib.mkForce false;
    };

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "ahci"
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
  system.stateVersion = "25.05";

  # Manual disk configuration
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/719e76d4-bb0d-4335-9ab9-0e144e1b039c";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/949B-CAD1";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/041b8ff1-a6ea-461a-ba75-928aefcd01da";
}
