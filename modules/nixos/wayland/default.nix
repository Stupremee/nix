{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.wayland;
in
{
  options.my.wayland = {
    enable = mkEnableOption "Enable wayland";

    hyprland = {
      enable = mkEnableOption "Enable Hyprland window manager";
    };
  };

  config = mkIf cfg.enable {
    services.dbus.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    xdg = {
      mime.enable = true;
      icons.enable = true;

      portal = {
        enable = true;

        wlr.enable = !cfg.hyprland.enable;
        extraPortals = optionals (!cfg.hyprland.enable) (
          with pkgs;
          [
            xdg-desktop-portal-wlr
            xdg-desktop-portal-gtk
          ]
        );
      };
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          user = "greeter";
        };
      };
    };

    # Options to avoid logs to override the tuigreet application.
    # https://github.com/apognu/tuigreet/issues/68#issuecomment-1586359960
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen

      # Without these boot logs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
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
