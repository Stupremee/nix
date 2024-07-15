{
  lib,
  pkgs,
  ...
}: {
  modules.hyprland = {
    enable = true;

    sensitivity = "-0.5";

    monitors = {
      "DP-5" = {
        position = "0x0";
        resolution = "3840x2160@60";
        scale = "1.5";
      };

      "DP-3" = {
        position = "2560x0";
        resolution = "3840x2160@60";
        scale = "1.5";
      };

      "Unknown-1".disable = true;
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
}
