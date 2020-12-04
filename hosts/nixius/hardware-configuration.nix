# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1a4a5671-32eb-4e43-8fd9-a1c2c64c8bf1";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7A23-1979";
      fsType = "vfat";
    };

  fileSystems."/mnt/hdd1" =
    { device = "/dev/disk/by-uuid/83d0d963-78af-4668-a4aa-824bffb44e12";
      fsType = "ext4";
    };

  fileSystems."/mnt/hdd2" =
    { device = "/dev/disk/by-uuid/f17408fb-5c6d-49ee-884f-fa6768b086a8";
      fsType = "ext4";
    };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

}
