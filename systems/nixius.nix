{modulesPath, ...}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # 16 core machine
  nix.maxJobs = 16;

  # Set hostname
  networking.hostName = "nixius";

  # Set timezone and locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  # Boot configuration
  boot = {
    tmpOnTmpfs = true;

    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [];

    kernelModules = ["kvm-amd"];
    extraModulePackages = [];

    # Use systemd-boot boot loader
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Hardware and network configuration
  time.hardwareClockInLocalTime = true;
  # services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    opengl.enable = true;
    cpu.amd.updateMicrocode = true;
  };

  networking = {
    useDHCP = false;

    interfaces.enp24s0.useDHCP = true;
  };

  # File systems
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4bca2815-f155-4d7c-b5f2-834d3231992e";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3980-7C70";
    fsType = "vfat";
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/f17408fb-5c6d-49ee-884f-fa6768b086a8";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/d7721dea-b634-46f5-82f0-b47d302639d1";
    }
  ];
}
