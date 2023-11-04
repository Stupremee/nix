{
  pkgs,
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.firewall.enable = false;
  networking.hosts = {
    "10.100.4.16" = ["mainframe.lan" "git.mainframe.lan" "ci.mainframe.lan" "cache.mainframe.lan" "ca.mainframe.lan" "docs.mainframe.lan"];
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  security.pki.certificates = [
    ''
      EKD Internal
      ============
      -----BEGIN CERTIFICATE-----
      MIICDzCCAbWgAwIBAgIQNzmWAVMXGZ/XRo2244SGkDAKBggqhkjOPQQDAjBmMS0w
      KwYDVQQKEyRFbmVyZ2lla29uemVwdGUgRGV1dHNjaGxhbmQgSW50ZXJuYWwxNTAz
      BgNVBAMTLEVuZXJnaWVrb256ZXB0ZSBEZXV0c2NobGFuZCBJbnRlcm5hbCBSb290
      IENBMB4XDTIzMDYxMzA4MTc1NVoXDTMzMDYxMDA4MTc1NVowZjEtMCsGA1UEChMk
      RW5lcmdpZWtvbnplcHRlIERldXRzY2hsYW5kIEludGVybmFsMTUwMwYDVQQDEyxF
      bmVyZ2lla29uemVwdGUgRGV1dHNjaGxhbmQgSW50ZXJuYWwgUm9vdCBDQTBZMBMG
      ByqGSM49AgEGCCqGSM49AwEHA0IABPfHqIRPD9+im74wI9OzYVotkZT2bSZk5ncY
      1jCHDciSx84h7YQrDJj5DqXJQ1ZZrzZI6P5uC91aCry5yPzzvZGjRTBDMA4GA1Ud
      DwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEBMB0GA1UdDgQWBBRMKWz3orYM
      y6vvHtrfmhGEjB0GpTAKBggqhkjOPQQDAgNIADBFAiAGTD63PhEn85wsuXTgXkgd
      gaWFp8T6dEAgicOQMbxESAIhAO/EfA4REITjK93mk/GkC5XQWxokwwAPGlXJGiDL
      iDZ2
      -----END CERTIFICATE-----
    ''
  ];

  # Enable wireshark
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Set timezone and locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "baldon";

  boot.initrd.availableKernelModules = ["vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/49c8985c-4b48-4bd3-999b-13d8867e11c9";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/fd2c2d53-f858-4642-9127-593e78f2dbcf";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E840-B125";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/fbe5f07a-5bcc-41a4-b492-596f98247466";}
  ];

  networking.useDHCP = lib.mkDefault false;
  networking.interfaces.eno1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;
}