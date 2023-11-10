{
  pkgs,
  inputs,
  system,
  ...
}: let
  hyprland = inputs.hyprland.packages."${system}".default.override {
    enableXWayland = true;
    enableNvidiaPatches = true;
  };
in {
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

  # Onl yxdg portal because extraPortals will be added by the hyprland module
  xdg.portal = {
    enable = true;
  };

  programs.hyprland = {
    enable = true;
    package = hyprland;
  };

  environment.systemPackages = [pkgs.xdg-utils];

  security.polkit.enable = true;
}
