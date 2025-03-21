{ flake, ... }:
{
  imports = [
    flake.inputs.srvos.nixosModules.server
    ./disks.nix
  ];

  # Remote activation
  nixos-unified.sshTarget = "stu@rome";

  my = {
    persist = {
      enable = true;
      btrfs = {
        enable = true;
        disk = "/dev/disk/by-partlabel/disk-system-root";
      };
    };

    nix-common = {
      enable = true;
      maxJobs = 8;
      flakePath = "/home/stu/nix";
      isRemoteBuilder = true;
    };

    server.enable = true;

    secrets = {
      enable = true;
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEFO0TbdOgpnHFhsnHwi+VB/FMTGrTiXJtPcY+1lslT";
    };
  };

  networking = {
    hostName = "rome";
    hostId = "538d52a0";
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
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
