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
    ''
      EKD IoT
      =======
      -----BEGIN CERTIFICATE-----
      MIIB+jCCAaGgAwIBAgIQFhFPiBF3ZqnvLGMbW93QcjAKBggqhkjOPQQDAjBcMSgw
      JgYDVQQKEx9FbmVyZ2lla29uemVwdGUgRGV1dHNjaGxhbmQgSW9UMTAwLgYDVQQD
      EydFbmVyZ2lla29uemVwdGUgRGV1dHNjaGxhbmQgSW9UIFJvb3QgQ0EwHhcNMjMx
      MTE0MDkwMjM3WhcNMzMxMTExMDkwMjM3WjBcMSgwJgYDVQQKEx9FbmVyZ2lla29u
      emVwdGUgRGV1dHNjaGxhbmQgSW9UMTAwLgYDVQQDEydFbmVyZ2lla29uemVwdGUg
      RGV1dHNjaGxhbmQgSW9UIFJvb3QgQ0EwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNC
      AAQB7gbNYP8O2ntO4HjG7OtLlpyJAgH0QL7W2ie/uyk7YyuLSxMF8CKByVdFoDz2
      dMQPy/nLIqvOn6plvKZZgs3vo0UwQzAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/
      BAgwBgEB/wIBATAdBgNVHQ4EFgQU5sUqlR/EtAPcVCLitdL5ZJAouawwCgYIKoZI
      zj0EAwIDRwAwRAIgKdzvsbWpg9MWzOocnIwTqNYT2IbH+a4asJNyFKszJh0CIEtg
      zO6Es8OSLDik3apKt8xvvs+Nm95HSXyOOG3e0wD1
      -----END CERTIFICATE-----
    ''
  ];

  programs.ssh.startAgent = true;

  # Enable wireshark
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  environment.systemPackages = with pkgs; [
    bmap-tools
    mitmproxy
    nmap
    minicom
    inkscape-with-extensions
    (python3.withPackages (ps:
      with ps; [
        pymodbus
        click
        pyserial
        prompt-toolkit
        pygments
      ]))
  ];

  # Set timezone and locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  networking = {
    hostName = "baldon";
    wireguard.enable = true;
    enableIPv6 = false;
    firewall.enable = false;

    useDHCP = lib.mkDefault false;
    interfaces = {
      eno1.useDHCP = lib.mkDefault true;

      enp0s20f0u6u2.ipv4.addresses = [
        {
          address = "10.100.4.19";
          prefixLength = 24;
        }
      ];
    };

    hosts = {
      "10.100.4.16" = ["mainframe.lan" "git.mainframe.lan" "ci.mainframe.lan" "cache.mainframe.lan" "ca.mainframe.lan" "docs.mainframe.lan"];
      "10.5.4.4" = ["ekd-dev-k8s-mbi44zdo.privatelink.westeurope.azmk8s.io"];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;
}
