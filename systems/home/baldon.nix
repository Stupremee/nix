{
  lib,
  pkgs,
  ...
}: {
  modules.hyprland = {
    enable = true;

    sensitivity = "-1.0";

    monitors = {
      "HDMI-A-1" = {
        position = "2560x0";
        resolution = "3840x2160@60";
        scale = "1.5";
      };

      "DP-1" = {
        position = "0x0";
        resolution = "3840x2160@60";
        scale = "1.5";
      };
    };
  };

  programs.git = {
    userName = lib.mkForce "Justus Kliem";
    userEmail = lib.mkForce "justus.kliem@ekd-solar.de";

    signing.key = lib.mkForce "31AC6529";
  };

  programs.gpg = {
    enable = true;
  };

  home.packages = with pkgs; [pinentry-qt];

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
  };
}
