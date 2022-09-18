{ pkgs, ... }: {
  services.pcscd.enable = true;
  environment.systemPackages = with pkgs; [
    yubikey-personalization
  ];
}
