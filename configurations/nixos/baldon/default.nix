{ flake, ... }:
{
  imports = with flake.inputs; [
    self.nixosModules.default

    ./disks.nix
  ];

  my = {
    desktop.enable = true;
    wayland.hyprland.enable = true;

    nvidia.enable = true;
    bluetooth.enable = true;

    nix-common = {
      maxJobs = 12;
      flakePath = "/home/stu/dev/nix/nix";
    };
  };

  networking = {
    hostName = "baldon";

    hosts = {
      "10.100.4.8" = [
        "mainframe.lan"
        "git.mainframe.lan"
        "ci.mainframe.lan"
        "cache.mainframe.lan"
        "ca.mainframe.lan"
        "docs.mainframe.lan"
      ];
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [
        "vmd"
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "rtsx_usb_sdmmc"
      ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
  };

  # Trust internally used root certificates
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

  # nixpkgs meta related options
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
}
