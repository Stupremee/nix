{
  lib,
  modulesPath,
  config,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Hostname and HostId
  networking.hostName = "ironite";

  modules.deploy.enable = true;

  # Mutable users are not required on this server
  users.mutableUsers = false;

  # Erase `/` on every boot
  modules.eraseDarlings.enable = true;
  modules.eraseDarlings.machineId = "03259b66332b4f0eaef821867120f952";
  modules.eraseDarlings.rootSnapshopt = "rpool/root@blank";

  # Set timezone and locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  # Boot and Software RAID configuration
  boot = {
    initrd.availableKernelModules = ["ahci" "sd_mod"];
    initrd.kernelModules = ["dm-snapshot"];
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
    supportedFilesystems = ["zfs"];

    kernelPackages = pkgs.linuxPackages_hardened;

    loader.systemd-boot.enable = false;
    loader.grub = {
      enable = true;
      efiSupport = false;
      devices = ["/dev/sda" "/dev/sdb"];
    };
  };

  # Networking
  networking = {
    useDHCP = false;

    interfaces.enp6s0 = {
      useDHCP = false;

      ipv4.addresses = [
        {
          address = "94.130.88.190";
          prefixLength = 26;
        }
      ];

      ipv6.addresses = [
        {
          address = "2a01:4f8:10b:360e::1";
          prefixLength = 64;
        }
      ];
    };

    defaultGateway = "94.130.88.129";
    defaultGateway6 = "fe80::1";

    # We use our own firewall instead the one provided by hetzner
    firewall = {
      enable = true;
    };
  };

  fileSystems."/" = {
    device = "rpool/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "rpool/nix";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "rpool/boot";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/home";
    fsType = "zfs";
  };

  fileSystems."/persist" = {
    device = "rpool/persist";
    fsType = "zfs";
  };

  fileSystems."/persist/var/lib/postgres" = {
    device = "rpool/postgres";
    fsType = "zfs";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
