{ flake, ... }:
{
  imports = with flake.inputs; [
    self.nixosModules.default

    ./disks.nix
  ];

  my = {
    desktop.enable = true;
    wayland.hyprland.enable = true;

    nix-common.maxJobs = 8;
    nh = {
      enable = true;
      flakePath = "/home/stu/dev/nix/nix";
    };
  };

  networking = {
    hostName = "aerial";

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
  ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
    enableAllFirmware = true;
  };

  # nixpkgs meta related options
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";
}
