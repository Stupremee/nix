{
  pkgs,
  lib,
  modulesPath,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  environment.etc."ppp/options".text = "ipcp-accept-remote";

  environment.systemPackages = with pkgs; [
    networkmanager-fortisslvpn
    # (openfortivpn.overrideAttrs (_: rec {
    #   version = "1.20.5";
    #
    #   src = pkgs.fetchFromGitHub {
    #     owner = "adrienverge";
    #     repo = "openfortivpn";
    #     rev = "v${version}";
    #     hash = "sha256-jbgxhCQWDw1ZUOAeLhOG+b6JYgvpr5TnNDIO/4k+e7k=";
    #   };
    # }))
    openfortivpn
  ];

  networking.hosts."10.100.4.16" = [
    "mainframe.lan"
    "git.mainframe.lan"
    "ci.mainframe.lan"
    "cache.mainframe.lan"
    "ca.mainframe.lan"
    "docs.mainframe.lan"
  ];

  networking.firewall.enable = false;

  # Set timezone and locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "aerial";

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/deb06dc2-3260-4d2a-a8cc-2c1734110749";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/a5a2ffb9-e3f5-4f96-870c-3c3ac0c3ac3b";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4427-2BC6";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/9cd7e669-e109-40f7-864e-c688a2f2b18c";}
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
