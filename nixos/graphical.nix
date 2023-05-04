{
  pkgs,
  inputs,
  system,
  ...
}: let
  hyprland = inputs.hyprland.packages."${system}".default.override {
    enableXWayland = true;
    nvidiaPatches = true;
    hidpiXWayland = true;
  };
in {
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

  programs.hyprland = {
    enable = true;
    package = hyprland;
  };

  environment.systemPackages = [pkgs.xdg-utils];

  security.polkit.enable = true;
}
