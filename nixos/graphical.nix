{pkgs, ...}: {
  programs.dconf.enable = true;

  services.geoclue2.enable = true;

  security.pam.services.swaylock.text = "auth include login";

  location.provider = "geoclue2";

  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings.screencast = {
        chooster_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };
  };
}
