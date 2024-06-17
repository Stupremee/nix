{
  unstable-pkgs,
  modulesPath,
  config,
  ...
}: {
  imports = [
    ./disks.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # 16 core machine
  nix.settings.max-jobs = 16;

  # Set hostname
  networking.hostName = "argon";

  # Set timezone and locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  # Boot configuration
  boot = {
    tmp = {
      useTmpfs = true;
      tmpfsSize = "75%";
    };

    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
    initrd.kernelModules = [];
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];

    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = ["nodev"];
        efiSupport = true;
        useOSProber = true;
      };
    };
  };

  # Hardware and network configuration
  time.hardwareClockInLocalTime = true;
  hardware.cpu.amd.updateMicrocode = true;

  services.tailscale.useRoutingFeatures = "both";

  networking = {
    useDHCP = false;
    interfaces.enp11s0.useDHCP = true;
  };
}
