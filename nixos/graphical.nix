{pkgs, ...}: {
  programs.dconf.enable = true;

  services.geoclue2.enable = true;

  security.pam.services.swaylock.text = "auth include login";

  location.provider = "geoclue2";

  services.pipewire = {
    enable = true;

    wireplumber.enable = true;
    jack.enable = true;
    pulse.enable = true;
  };

  xdg = {
    portal = {
      extraPortals = with pkgs; [xdg-desktop-portal-gtk];
      config.common.default = [
        "hyprland"
        "gtk"
      ];
    };
  };

  programs.hyprland = {
    enable = true;
  };

  environment.systemPackages = [pkgs.xdg-utils];

  security.polkit.enable = true;
}
