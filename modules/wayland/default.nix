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

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

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

    # Fix for boot logs bleeding into the tuigreet
    # https://github.com/apognu/tuigreet/issues/68#issuecomment-2001807691
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
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
