{
  pkgs,
  unstable-pkgs,
  modulesPath,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # 16 core machine
  nix.settings.max-jobs = 16;

  # Set hostname
  networking.hostName = "nixius";
  networking.hosts."127.0.0.1" = [
    "drrisch.localhost.local"
    "mailhog.localhost.local"
    "portainer.localhost.local"
    "phpmyadmin.localhost.local"
    "adminer.localhost.local"
    "traefik.localhost.local"
    "swaggerui.localhost.local"
  ];

  # Set timezone and locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  # OpenVPN
  age.secrets.esyvpn.file = ../secrets/esyvpn.ovpn;

  # Enable wireshark
  programs.wireshark = {
    enable = true;
    package = unstable-pkgs.wireshark;
  };

  services.openvpn.servers = {
    esy = {
      autoStart = false;
      config = ''config ${config.age.secrets.esyvpn.path} '';
    };
  };

  # Boot configuration
  boot = {
    tmp = {
      useTmpfs = true;
      tmpfsSize = "75%";
    };

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
  hardware.cpu.amd.updateMicrocode = true;

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  modules.tailscale.useRoutingFeatures = "both";
  networking = {
    useDHCP = false;

    interfaces.enp24s0.useDHCP = true;

    extraHosts = ''
      192.168.17.65 usnconeboxax1aos.cloud.onebox.dynamics.com
      127.0.0.1 example.local
    '';
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
