{pkgs, ...}: {
  services.pcscd.enable = true;
  environment.systemPackages = with pkgs; [
    yubikey-personalization
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];
}
