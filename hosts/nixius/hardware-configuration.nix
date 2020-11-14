# Hardware configuration for my home pc.

{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e0877141-1e9b-4029-8920-fa32cee430c4";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3B79-0CE7";
    fsType = "vfat";
  };

  fileSystems."/mnt/hdd1" = {
    device = "/dev/disk/by-uuid/83d0d963-78af-4668-a4aa-824bffb44e12";
    fsType = "ext4";
  };

  fileSystems."/mnt/hdd2" = {
    device = "/dev/disk/by-uuid/f17408fb-5c6d-49ee-884f-fa6768b086a8";
    fsType = "ext4";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/b903be90-5693-4f8d-8af8-5bc36549a09e"; }];

  nix.maxJobs = lib.mkDefault 16;
}
