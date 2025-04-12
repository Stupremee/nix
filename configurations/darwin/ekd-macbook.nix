{
  pkgs,
  lib,
  flake,
  ...
}:
{
  imports = with flake.inputs; [
    self.darwinModules.default
  ];

  my = {
    user = {
      name = "jkliem";
      import = ../. + "/home/jkliem@ekd-macbook.nix";
    };

    zsh.enable = true;
    nix-common = {
      enable = true;
      maxJobs = 4;
    };
  };

  services.nix-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    colima
    docker
    gnupg
  ];

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

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  nix.settings.builders = lib.mkForce "ssh://root@rome x86_64-linux";

  system.stateVersion = lib.mkForce 4;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
