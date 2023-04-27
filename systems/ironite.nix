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

  nix.settings.max-jobs = 16;

  # Mutable users are not required on this server
  users.mutableUsers = false;

  # Set timezone and locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  # Enable Argo tunnel
  modules.argo.enable = true;
  modules.argo.tunnel.name = "ironite";
  modules.argo.route."esy.stu-dev.me".toPort = 3131;

  # Boot and Software RAID configuration
  boot = {
    initrd.availableKernelModules = ["ahci" "sd_mod"];
    initrd.kernelModules = ["dm-snapshot"];
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];

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

    allowedTCPPorts = [27015];
    allowedUDPPorts = [27015 27020];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/35c74bb8-230b-42b5-9331-6d6fffec3fb8";
    fsType = "ext4";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
