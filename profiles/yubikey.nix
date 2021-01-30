{ pkgs, ... }: {
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idProduct}=="7321", ATTR{idVendor}=="0955", MODE="0777"
  '';

  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [ yubikey-personalization ];
}
