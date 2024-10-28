{...}: {
  imports = [
    ./disks.nix
  ];

  my = {
    desktop.enable = true;
    nvidia.enable = true;
    bluetooth.enable = true;

    home = {
      enable = true;
      import = ./home.nix;
    };

    nix-common.maxJobs = 8;
  };

  networking = {
    hostName = "dalton";
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
      kernelModules = [];
    };

    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
  };

  # nixpkgs meta related options
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
}
