{ ... }: {
  programs.dconf.enable = true;

  services.geoclue2.enable = true;

  security.pam.services.swaylock.text = "auth include login";
}
