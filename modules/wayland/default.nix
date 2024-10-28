{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.my.wayland;
in {
  options.my.wayland = {
    enable = mkEnableOption "Enable wayland";

    hyprland = {
      enable = mkEnableOption "Enable Hyprland window manager";
    };
  };

  config = mkIf cfg.enable {
    services.dbus.enable = true;

    xdg = {
      mime.enable = true;
      icons.enable = true;

      portal = {
        enable = true;

        wlr.enable = !cfg.hyprland.enable;
        extraPortals = optionals (!cfg.hyprland.enable) (with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
        ]);
      };
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time";
          user = "greeter";
        };
      };
    };

    security = {
      polkit.enable = true;
      rtkit.enable = true;
    };

    programs.hyprland = mkIf cfg.hyprland.enable {
      enable = true;
    };
  };
}
